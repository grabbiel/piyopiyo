const {test,mock}=require('node:test');
const assert=require('node:assert/strict');
const {DynamoDBDocumentClient}=require('@aws-sdk/lib-dynamodb');
const {S3Client}=require('@aws-sdk/client-s3');
const M=require('./moderation.cjs'),{handler}=require('./index.cjs');
const room={PK:'ROOM#room-1',SK:'META',id:'room-1',hostId:'learner',mode:'collaborative',questionIds:['q1'],participants:[{id:'learner',name:'Learner',score:0},{id:'peer',name:'Peer',score:0}],expiresAt:Math.floor(Date.now()/1000)+7200,version:1};
const event=(field,args,sub='learner')=>({identity:{claims:{sub}},info:{fieldName:field},arguments:args});
function store(reads={}){
 const writes=[];
 const db=mock.method(DynamoDBDocumentClient.prototype,'send',async c=>{
  if(c.constructor.name==='GetCommand'){
   const k=c.input.Key;
   if(k.PK===room.PK&&k.SK==='META')return {Item:structuredClone(room)};
   return {Item:reads[k.PK+'/'+k.SK]};
  }
  if(c.constructor.name==='QueryCommand')return {Items:[]};
  writes.push(c.input);return {};
 });
 return {writes,restore:()=>db.mock.restore()};
}
test('room names filter abusive content, URLs and invisible control characters',()=>{
 for(const x of ['f u c k\u200b','f4ggot','https://spam.invalid','someone@example.com','fuck','mierda'])assert.throws(()=>M.displayName(x));
 for(const x of ['Ana María','Piyo Learner','Grace Hopper'])assert.equal(M.displayName(x),x);
 assert.equal(M.displayName(undefined),'Learner');
});
test('shared answers must be one actual option, never arbitrary user text',()=>{
 const q={format:'multiple_choice',options:['A','B']};
 assert.deepEqual(M.roomAnswer(q,'["A"]'),['A']);
 for(const value of ['not JSON','["spam"]','["A","B"]','{"value":"A"}'])assert.throws(()=>M.roomAnswer(q,value));
 assert.throws(()=>M.roomAnswer({...q,retired:true},'["A"]'));
});
test('report validates room membership, target and reason before writing',async()=>{
 const db=store();try{
  await assert.rejects(handler(event('reportParticipant',{roomId:'room-1',participantId:'peer',reason:'spam'},'outsider')),/Join this room first/);
  await assert.rejects(handler(event('reportParticipant',{roomId:'room-1',participantId:'learner',reason:'spam'})),/another participant/);
  await assert.rejects(handler(event('reportParticipant',{roomId:'room-1',participantId:'peer',reason:'invented'})),/report reason/);
  assert.equal(db.writes.length,0);
  assert.equal(await handler(event('reportParticipant',{roomId:'room-1',participantId:'peer',reason:'spam'})),true);
  const items=db.writes.at(-1).TransactItems;
  assert.equal(items[1].Update.ExpressionAttributeValues[':limit'],10);
  assert.equal(items[2].Put.Item.reporterId,'learner');assert.equal(items[2].Put.Item.status,'pending');
  assert.ok(items[2].Put.Item.expiresAt>Date.now()/1000);
 }finally{db.restore();}
});
test('blocking leaves the room, transfers host, and persists an account-scoped block',async()=>{
 const db=store();try{
  assert.equal(await handler(event('blockParticipant',{roomId:'room-1',participantId:'peer'})),true);
  const items=db.writes.at(-1).TransactItems;
  assert.deepEqual(items[1].Put.Item.PK,'USER#learner');assert.equal(items[1].Put.Item.SK,'BLOCK#peer');
  assert.deepEqual(items[2].Put.Item.participants.map(p=>p.id),['peer']);assert.equal(items[2].Put.Item.hostId,'peer');
 }finally{db.restore();}
});
test('either side of a persistent block prevents joining another shared room',async()=>{
 for(const key of ['USER#new/BLOCK#peer','USER#peer/BLOCK#new']){
  const db=store({[key]:{targetId:'blocked'}});try{
   await assert.rejects(handler(event('joinRoom',{id:'room-1',name:'New'},'new')),/because of a block/);
   assert.equal(db.writes.length,0);
  }finally{db.restore();}
 }
});
test('restricted participants cannot access rooms and disappear from room listings',async()=>{
 const db=store({'USER#peer/ROOM_RESTRICTION':{reportId:'r'}});try{
  await assert.rejects(handler(event('room',{id:'room-1'},'peer')),/access is restricted/);
  assert.deepEqual((await handler(event('room',{id:'room-1'}))).participants.map(p=>p.id),['learner']);
 }finally{db.restore();}
});
test('report inbox rejects ordinary learners and requires the exact administrator group',async()=>{
 for(const groups of [[],['content-admins-other'],['content-admins']]){
  const db=store();try{
   const response=await handler({rawPath:'/moderation/reports',requestContext:{http:{method:'GET'},authorizer:{jwt:{claims:{sub:'learner','cognito:groups':groups}}}}});
   assert.equal(response.statusCode,groups.includes('content-admins')?200:403);
  }finally{db.restore();}
 }
});
test('non-option room submissions cannot broadcast arbitrary content',async()=>{
 const db=store(),s3=mock.method(S3Client.prototype,'send',async()=>({Body:{transformToString:async()=>JSON.stringify([{id:'q1',format:'multiple_choice',options:['A','B'],correct:['A']}])}}));
 try{await assert.rejects(handler(event('submitAnswer',{roomId:'room-1',questionId:'q1',attemptId:'a1',answer:'["unmoderated text"]'})),/Choose one/);assert.equal(db.writes.length,0);}
 finally{db.restore();s3.mock.restore();}
});
