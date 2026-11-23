const {test}=require('node:test');const assert=require('node:assert/strict');
test('publish merge keeps generated and retired rows and updates authored rows by id',async()=>{
 const {merge}=await import('../scripts/publish-questions.mjs');
 const remote=[{id:'a',prompt:'old'},{id:'generated-1',batchId:'b'},{id:'gone',retired:true},{id:'r',prompt:'x',retired:true},{id:'same',prompt:'s'}];
 const {questions,stats}=merge(remote,[{id:'a',prompt:'new'},{id:'r',prompt:'y'},{id:'same',prompt:'s'},{id:'fresh',prompt:'f'}]);
 assert.deepEqual(questions,[{id:'a',prompt:'new'},{id:'generated-1',batchId:'b'},{id:'gone',retired:true},{id:'r',prompt:'y',retired:true},{id:'same',prompt:'s'},{id:'fresh',prompt:'f'}]);
 assert.deepEqual(stats,{remote:5,added:1,updated:2,unchanged:1,kept:2});
 assert.throws(()=>merge(remote,[{id:'generated-1'}]),/collides/);
});
