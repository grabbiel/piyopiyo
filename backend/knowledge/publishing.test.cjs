const {test,mock}=require('node:test');const assert=require('node:assert/strict');
process.env.KNOWLEDGE_TABLE='knowledge-test';process.env.QUESTION_BUCKET='questions-test';
const S=require('./store.cjs');const {publish,model}=require('./worker.cjs')._test;
test('publication preserves original bank, excludes rejected questions and private evidence, and is idempotent',async()=>{
 const objects={'published/questions.json':[{id:'original',prompt:'Keep this original question'}]};let writes=0;
 mock.method(S,'readJSON',async(key,bucket,fallback)=>({value:objects[key]||fallback,etag:objects[key]?'etag':undefined}));
 mock.method(S,'write',async(key,value,type,bucket,condition)=>{assert.ok(condition.IfMatch||condition.IfNoneMatch);objects[key]=value;writes++;});
 const batch={id:'test-batch',createdAt:'2026-11-23T00:00:00Z',questions:[{id:'accepted',prompt:'Approved',validation:{accepted:true},evidence:[{quote:'private source wording'}]},{id:'rejected',validation:{accepted:false}}]};
 const result=await publish(batch,{title:'Book',topic:'Programming'});assert.equal(result.published,1);
 assert.deepEqual(objects['published/questions.json'],[{id:'original',prompt:'Keep this original question'},{id:'accepted',prompt:'Approved'}]);
 assert.deepEqual(objects['published/quizzes.json'][0].questionIds,['accepted']);
 await publish(batch,{title:'Book',topic:'Programming'});assert.equal(writes,2);
 mock.restoreAll();
});
test('concurrent bank changes are merged instead of overwritten',async()=>{
 let reads=0;const writes=[];
 mock.method(S,'readJSON',async key=>key.endsWith('questions.json')?{value:[{id:'original'},...(reads++?[{id:'concurrent'}]:[])],etag:'etag'+reads}:{value:[]});
 mock.method(S,'write',async(key,value)=>{if(key.endsWith('questions.json')&&reads===1)throw Object.assign(Error(),{name:'PreconditionFailed'});writes.push(value);});
 await publish({id:'batch',questions:[{id:'new',validation:{accepted:true}}]},{title:'Book',topic:'Programming'});
 assert.deepEqual(writes[0].map(q=>q.id),['original','concurrent','new']);mock.restoreAll();
});
test('monthly allowance and paused pipeline block inference before invocation',async()=>{
 mock.method(S,'settings',async()=>({enabled:false,maxModelCalls:60}));
 await assert.rejects(()=>model('system',{},10),/paused/);mock.restoreAll();
 mock.method(S,'settings',async()=>({enabled:true,maxModelCalls:60}));
 mock.method(S.db,'send',async command=>{assert.equal(command.input.ExpressionAttributeValues[':limit'],60);throw Object.assign(Error(),{name:'ConditionalCheckFailedException'});});
 await assert.rejects(()=>model('system',{},10),/allowance/);mock.restoreAll();
 await assert.rejects(()=>model('system',{text:'a'.repeat(21000)},10),/cost limit/);
});
test('withdrawal removes future quizzes while preserving questions for saved attempts',async()=>{
 const objects={'published/questions.json':[{id:'original'},{id:'generated',batchId:'batch'}],'published/quizzes.json':[{id:'batch'},{id:'other'}],'batches/batch.json':{id:'batch',questions:[{id:'generated'}]}};
 mock.method(S,'get',async(PK,SK)=>PK==='BATCH'?{PK,SK,id:SK,detailKey:'batches/batch.json'}:undefined);
 mock.method(S,'readJSON',async key=>({value:objects[key],etag:'etag'}));
 mock.method(S,'write',async(key,value)=>{objects[key]=value;});
 mock.method(S,'put',async()=>{});
 const result=await require('./worker.cjs').handler({Records:[{messageId:'one',body:JSON.stringify({op:'withdraw',batchId:'batch',jobId:'withdraw-test'})}]});
 assert.deepEqual(result.batchItemFailures,[]);assert.deepEqual(objects['published/questions.json'][0],{id:'original'});
 assert.equal(objects['published/questions.json'][1].retired,true);assert.deepEqual(objects['published/quizzes.json'],[{id:'other'}]);assert.equal(objects['batches/batch.json'].status,'withdrawn');mock.restoreAll();
});
