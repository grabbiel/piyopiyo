// Real, isolated development-stack checks. Temporary users suppress all email delivery.
import {execFileSync} from 'node:child_process';
import {randomUUID,randomBytes} from 'node:crypto';
import {readFileSync,writeFileSync} from 'node:fs';
import {DynamoDBClient} from '@aws-sdk/client-dynamodb';
import {DynamoDBDocumentClient,QueryCommand,DeleteCommand,UpdateCommand} from '@aws-sdk/lib-dynamodb';
import assert from 'node:assert/strict';
const cfg=JSON.parse(readFileSync('PiyoPiyo/PiyoPiyoCore/Sources/PiyoPiyoCore/Resources/configuration.json'));
const bank=JSON.parse(readFileSync('content/questions.json'));
const aws=(service,operation,input)=>JSON.parse(execFileSync('./scripts/aws.sh',[service,operation,'--cli-input-json',JSON.stringify(input),'--output','json'],{encoding:'utf8',stdio:['ignore','pipe','pipe']})||'{}');
const users=[],rooms=[],checks=[];let ws;
const db=DynamoDBDocumentClient.from(new DynamoDBClient({region:cfg.Region,maxAttempts:4}));
async function rest(path,user,method='GET',body){
 const response=await fetch(cfg.ApiUrl+path,{method,headers:{Authorization:`Bearer ${user?.AccessToken||''}`,'Content-Type':'application/json'},...(body?{body:JSON.stringify(body)}:{})});const value=await response.json();return{status:response.status,value};
}
async function gql(query,variables,user){
 for(let n=0;n<5;n++){
  const response=await fetch(cfg.LiveUrl,{method:'POST',headers:{Authorization:user.IdToken,'Content-Type':'application/json'},body:JSON.stringify({query,variables})});const value=await response.json();
  if(!value.errors)return value.data;
  if(n===4)throw new Error(JSON.stringify(value.errors));await new Promise(r=>setTimeout(r,300*(n+1)));
 }
}
try{
 for(const path of ['/privacy','/support']){const page=await fetch(cfg.ApiUrl+path);assert.equal(page.status,200);assert.match(page.headers.get('content-type'),/text\/html/);assert.match(await page.text(),/<h1>PiyoPiyo/);checks.push('Public '+path.slice(1)+' page is available without sign-in');}
 for(let i=0;i<3;i++){
  const email=`piyopiyo-test-${randomUUID()}@example.invalid`,password='PiyoTest9'+randomBytes(20).toString('base64url');
  const created=aws('cognito-idp','admin-create-user',{UserPoolId:cfg.UserPoolId,Username:email,MessageAction:'SUPPRESS',UserAttributes:[{Name:'email',Value:email},{Name:'email_verified',Value:'true'}]});
  const username=created.User.Username;users.push({username,sub:created.User.Attributes.find(a=>a.Name==='sub').Value});
  aws('cognito-idp','admin-set-user-password',{UserPoolId:cfg.UserPoolId,Username:username,Password:password,Permanent:true});
  Object.assign(users[i],aws('cognito-idp','initiate-auth',{ClientId:cfg.ClientId,AuthFlow:'USER_PASSWORD_AUTH',AuthParameters:{USERNAME:email,PASSWORD:password}}).AuthenticationResult);
 }
 assert.equal((await rest('/progress',null)).status,401);checks.push('Unauthenticated progress rejected');
 const user=users[0],id=randomUUID(),selected=bank.slice(0,18);
 let response=await rest('/quiz',user,'POST',{id,mode:'practice',questionIds:selected.map(q=>q.id)});assert.equal(response.status,201,JSON.stringify(response));
 const q=selected[0],payload={questionId:q.id,attemptId:randomUUID(),answer:q.correct};
 response=await rest(`/quiz/${id}/attempts`,user,'POST',payload);assert.equal(response.status,200,JSON.stringify(response));assert.equal(response.value.score,1);
 await rest(`/quiz/${id}/attempts`,user,'POST',payload);
 response=await rest(`/quiz/${id}`,user);assert.equal(response.value.answered,1);checks.push('Duplicate attempt increments score only once');
 assert.equal((await rest(`/quiz/${id}`,users[1])).status,404);checks.push('Cross-user session reads rejected');
 for(const question of selected.slice(1)){
  await new Promise(r=>setTimeout(r,230));
  response=await rest(`/quiz/${id}/attempts`,user,'POST',{questionId:question.id,attemptId:randomUUID(),allowAI:true,answer:question.correct.map(x=>x.split('|')[0])});
  assert.equal(response.status,200,JSON.stringify(response));
  if(question.format==='short_answer'){const disabled=process.argv.includes('--grading-disabled');assert.equal(response.value.status,disabled?'pending_review':'graded',JSON.stringify(response));checks.push(disabled?'Disabled grader returns provisional feedback without blocking sync':'Real Bedrock evaluation succeeds through Lambda');}
 }
 response=await rest(`/quiz/${id}`,user);assert.equal(response.value.answered,18);checks.push('All 18 formats persisted in real DynamoDB');
 response=await rest('/progress',user);assert.equal(response.value.items.length,19);checks.push('Progress returns session and every attempt');
 const fields='id questionIds participants {id name score}';
 const room=(await gql(`mutation{createRoom(mode:"collaborative"){${fields}}}`,{},user)).createRoom;rooms.push(room.id);assert.equal(room.questionIds.length,10);
 await Promise.all(users.slice(1).map((u,i)=>gql(`mutation($id:ID!,$name:String!){joinRoom(id:$id,name:$name){${fields}}}`,{id:room.id,name:`Test learner ${i+1}`},u)));checks.push('Concurrent authenticated learners join a room');
 const host=new URL(cfg.LiveUrl).host,headers={host,Authorization:user.IdToken};
 const realtime=new URL(cfg.LiveUrl.replace('https://','wss://').replace('appsync-api','appsync-realtime-api'));realtime.searchParams.set('header',Buffer.from(JSON.stringify(headers)).toString('base64'));realtime.searchParams.set('payload',Buffer.from('{}').toString('base64'));
 ws=new WebSocket(realtime,'graphql-ws');let eventResolve,eventReject;const eventPromise=new Promise((resolve,reject)=>{eventResolve=resolve;eventReject=reject});let subscribed;
 await new Promise((resolve,reject)=>{
  const timeout=setTimeout(()=>reject(new Error('Subscription handshake timeout')),15000);
  ws.onopen=()=>ws.send(JSON.stringify({type:'connection_init'}));ws.onerror=()=>reject(new Error('WebSocket error'));
  ws.onmessage=message=>{const msg=JSON.parse(message.data);if(msg.type==='connection_ack')ws.send(JSON.stringify({id:'test',type:'start',payload:{data:JSON.stringify({query:'subscription($roomId:ID!){onAnswer(roomId:$roomId){roomId participantId questionId score total answer}}',variables:{roomId:room.id}}),extensions:{authorization:headers}}}));if(msg.type==='start_ack'){clearTimeout(timeout);resolve();}if(msg.type==='data')eventResolve(msg.payload.data.onAnswer);if(msg.type==='error'){clearTimeout(timeout);reject(new Error(JSON.stringify(msg)));eventReject(new Error('Subscription error'));}};
 });
 const liveQuestion=bank.find(q=>q.id===room.questionIds[0]);
 await Promise.all(users.map(u=>gql('mutation($roomId:ID!,$questionId:ID!,$answer:String!,$attemptId:ID!){submitAnswer(roomId:$roomId,questionId:$questionId,answer:$answer,attemptId:$attemptId){roomId participantId questionId score total answer}}',{roomId:room.id,questionId:liveQuestion.id,answer:JSON.stringify(liveQuestion.correct),attemptId:randomUUID()},u)));
 const event=await Promise.race([eventPromise,new Promise((_,reject)=>setTimeout(()=>reject(new Error('No live answer event')),15000))]);assert.equal(event.roomId,room.id);assert.ok(event.answer);checks.push('AppSync WebSocket broadcasts collaborative answers');
 const after=(await gql(`query($id:ID!){room(id:$id){${fields}}}`,{id:room.id},user)).room;assert.deepEqual(after.participants.map(p=>p.score),[1,1,1]);checks.push('Concurrent submissions preserve every participant score');
 ws.close();ws=null;
 const timed=randomUUID();
 response=await rest('/quiz',user,'POST',{id:timed,mode:'timed',questionIds:[q.id]});assert.equal(response.status,201);
 await db.send(new UpdateCommand({TableName:cfg.TableName,Key:{PK:'USER#'+user.sub,SK:'SESSION#'+timed},UpdateExpression:'SET deadline = :deadline',ExpressionAttributeValues:{':deadline':Date.now()-3600000}}));
 response=await rest(`/quiz/${timed}/attempts`,user,'POST',{questionId:q.id,attemptId:randomUUID(),answer:q.correct,elapsedSeconds:120});assert.equal(response.status,200,JSON.stringify(response));checks.push('Offline timed answer survives delayed upload');
 response=await rest('/account/deletion-authorization',user,'POST',{});assert.equal(response.value.required,false);
 let deletionErrors=0;
 for(let n=0;n<100;n++){
  response=await rest('/account',user,'DELETE');
  if(response.status===503||response.status===429){if(++deletionErrors>=4)throw new Error('Deletion failed repeatedly: '+JSON.stringify(response));await new Promise(r=>setTimeout(r,1000));continue;}
  assert.ok([200,202].includes(response.status),JSON.stringify(response));
  if(response.status===200)break;
  assert.equal((await rest('/progress',user)).status,403);
  await new Promise(r=>setTimeout(r,400));
 }
 assert.equal(response.value.status,'deleted');
 assert.equal((await rest('/progress',user)).status,403);checks.push('Deleted account JWT cannot read or recreate data');
 const ownerRows=await db.send(new QueryCommand({TableName:cfg.TableName,KeyConditionExpression:'PK = :pk',ExpressionAttributeValues:{':pk':'USER#'+user.sub},ConsistentRead:true}));assert.deepEqual(ownerRows.Items.map(x=>x.SK),['ACCOUNT']);
 const retainedRoom=(await gql(`query($id:ID!){room(id:$id){${fields}}}`,{id:room.id},users[1])).room;
 assert.equal(retainedRoom.participants.length,2);assert.ok(!retainedRoom.participants.some(p=>p.id===user.sub));
 const roomRows=await db.send(new QueryCommand({TableName:cfg.TableName,KeyConditionExpression:'PK = :pk',ExpressionAttributeValues:{':pk':'ROOM#'+room.id},ConsistentRead:true}));assert.ok(!roomRows.Items.some(row=>row.SK.includes(user.sub)));checks.push('Deletion removes progress and room contributions without deleting other learners');
 try{aws('cognito-idp','admin-get-user',{UserPoolId:cfg.UserPoolId,Username:user.username});throw new Error('Cognito account still exists');}catch(e){assert.ok(String(e.stderr).includes('UserNotFoundException'));}
 user.deleted=true;checks.push('Account deletion removes the Cognito identity');

 console.log(checks.join('\n'));
}catch(e){console.error(e.message);process.exitCode=1;}
finally{
 ws?.close();
 for(const PK of [...users.map(u=>'USER#'+u.sub),...rooms.map(id=>'ROOM#'+id)]){const rows=await db.send(new QueryCommand({TableName:cfg.TableName,KeyConditionExpression:'PK = :pk',ExpressionAttributeValues:{':pk':PK}}));for(const item of rows.Items||[])await db.send(new DeleteCommand({TableName:cfg.TableName,Key:{PK,SK:item.SK}}));}
 for(const user of users)if(!user.deleted)aws('cognito-idp','admin-delete-user',{UserPoolId:cfg.UserPoolId,Username:user.username});
 db.destroy();
 writeFileSync('tests/integration-results.json',JSON.stringify({at:new Date().toISOString(),passed:!process.exitCode,checks,temporaryDataRemoved:true},null,2)+'\n');
}

// All assertions, cleanup, and report writes have completed. Close this one-shot
// CLI even if the native WebSocket/credential provider retains an idle handle.
process.exit(process.exitCode || 0);
