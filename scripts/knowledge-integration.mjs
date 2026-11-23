// End-to-end checks use an email-suppressed disposable Cognito identity.
import {CognitoIdentityProviderClient,AdminCreateUserCommand,AdminSetUserPasswordCommand,AdminAddUserToGroupCommand,InitiateAuthCommand,AdminDeleteUserCommand} from '@aws-sdk/client-cognito-identity-provider';
import {S3Client,GetObjectCommand} from '@aws-sdk/client-s3';
import {readFileSync,writeFileSync} from 'node:fs';
import {randomUUID,randomBytes,createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const cfg=JSON.parse(readFileSync('PiyoPiyo/PiyoPiyoCore/Sources/PiyoPiyoCore/Resources/configuration.json'));
const cognito=new CognitoIdentityProviderClient({region:cfg.Region,maxAttempts:3}),s3=new S3Client({region:cfg.Region,maxAttempts:3});
let username,token;const checks=[];
const pause=ms=>new Promise(r=>setTimeout(r,ms));
async function api(path,method='GET',body,expected){
 const response=await fetch(cfg.ApiUrl+path,{method,headers:{Authorization:'Bearer '+(token||''),'Content-Type':'application/json'},body:body?JSON.stringify(body):undefined});
 const value=await response.json();if(expected)assert.equal(response.status,expected,JSON.stringify(value));else assert.ok(response.ok,JSON.stringify(value));return value;
}
async function until(label,predicate){for(let i=0;i<48;i++){const data=await api('/knowledge/dashboard');const result=predicate(data);if(result)return result;if(i%6===0)console.log('Waiting for '+label);await pause(5000);}throw Error('Timed out waiting for '+label);}
async function bank(){const result=await s3.send(new GetObjectCommand({Bucket:'piyopiyo-question-banks',Key:'published/questions.json'}));return JSON.parse(await result.Body.transformToString());}
try{
 const email='piyopiyo-knowledge-'+randomUUID()+'@example.invalid',password='Piyo9'+randomBytes(25).toString('base64url');
 const created=await cognito.send(new AdminCreateUserCommand({UserPoolId:cfg.UserPoolId,Username:email,MessageAction:'SUPPRESS',UserAttributes:[{Name:'email',Value:email},{Name:'email_verified',Value:'true'}]}));username=created.User.Username;
 await cognito.send(new AdminSetUserPasswordCommand({UserPoolId:cfg.UserPoolId,Username:username,Password:password,Permanent:true}));
 const login=async()=>{token=(await cognito.send(new InitiateAuthCommand({ClientId:cfg.ClientId,AuthFlow:'USER_PASSWORD_AUTH',AuthParameters:{USERNAME:email,PASSWORD:password}}))).AuthenticationResult.AccessToken;};
 await login();await api('/knowledge/dashboard','GET',undefined,403);checks.push('Learner JWT cannot access the administrator API');
 await cognito.send(new AdminAddUserToGroupCommand({UserPoolId:cfg.UserPoolId,Username:username,GroupName:'content-admins'}));await login();
 await api('/knowledge/dashboard');checks.push('Content administrator JWT can access the source library');
 if(process.argv.includes('--withdraw-initial')){
  const initial='4db78672-e0fd-400d-bbae-a1de574fcef0';
  await api('/knowledge/batches/'+initial+'/withdraw','POST');
  await until('initial batch withdrawal',d=>d.batches.find(b=>b.id===initial&&b.status==='withdrawn'));
  assert.ok(!(await api('/quizzes')).some(q=>q.id===initial));
  assert.ok((await bank()).filter(q=>q.batchId===initial).every(q=>q.retired));
  checks.push('Initial batch withdrawn from future quizzes while original records remain for saved attempts');
 }
 const before=await bank();
 const submitted=await api('/knowledge/sources','POST',{kind:'url',url:'https://docs.python.org/3/tutorial/datastructures.html',title:'Python tutorial: data structures',topic:'Programming',rights:'open_license',consent:true});
 const id=submitted.source.id;
 await until('Python source extraction',d=>{const s=d.sources.find(s=>s.id===id);if(s?.status==='failed')throw Error(s.error);return s?.status==='ready'&&s;});checks.push('Public documentation imported, extracted, hashed and chunked');
 const duplicate=await api('/knowledge/sources','POST',{kind:'url',url:'https://docs.python.org/3/tutorial/datastructures.html',title:'Python tutorial: data structures',topic:'Programming',consent:true});assert.equal(duplicate.duplicate,true);checks.push('Repeated URL is deduplicated');
 const pdf=readFileSync('tests/fixtures/knowledge-notes.pdf'),sha256=createHash('sha256').update(pdf).digest('hex');
 const upload=await api('/knowledge/sources','POST',{kind:'pdf',title:'PiyoPiyo original notes: queues and stacks',topic:'Algorithms',rights:'open_license',bytes:pdf.length,sha256,consent:true});
 if(upload.uploadURL){const response=await fetch(upload.uploadURL,{method:'PUT',headers:{'Content-Type':upload.contentType,'x-amz-checksum-sha256':upload.checksum},body:pdf});assert.ok(response.ok,'Signed S3 upload failed: '+response.status);await api('/knowledge/sources/'+upload.source.id+'/complete','POST');}
 await until('PDF extraction',d=>{const s=d.sources.find(s=>s.id===upload.source.id);if(s?.status==='failed')throw Error(s.error);return s?.status==='ready'&&s;});checks.push('PDF uploaded with SHA-256 verification and extracted by the private Python worker');
 const job=await api('/knowledge/run','POST',{op:'generate',sourceId:process.argv.includes('--generation-pdf')?upload.source.id:id});
 const batch=await until('independent review and publication',d=>{const j=d.jobs.find(j=>j.jobId===job.jobId);if(j?.status==='failed')throw Error(j.error);return d.batches.find(b=>b.id===job.jobId&&['published','rejected'].includes(b.status));});
 assert.equal(batch.status,'published',JSON.stringify(batch));assert.ok(batch.published>0);
 const detail=await api('/knowledge/batches/'+batch.id);assert.ok(detail.questions.filter(q=>q.validation.accepted).every(q=>q.evidence.length));
 checks.push('Real Bedrock generation and independent review automatically published validated questions');
 const after=await bank();for(const old of before)assert.deepEqual(after.find(q=>q.id===old.id),old);
 assert.ok(after.length>before.length);assert.ok(after.filter(q=>q.batchId===batch.id).every(q=>!q.evidence&&!q.validation));checks.push('Publication preserved every existing question and withheld private source excerpts');
 const quizzes=await api('/quizzes');assert.ok(quizzes.find(q=>q.id===batch.id)?.questionIds.length);checks.push('Published quiz manifest available through the learner API');
 await api('/knowledge/settings','PATCH',{enabled:false});await api('/knowledge/run','POST',{op:'generate'},409);await api('/knowledge/settings','PATCH',{enabled:true});checks.push('Pipeline pause prevents new generation requests and resumes safely');
 const discovery=await api('/knowledge/run','POST',{op:'discover'});await until('scheduled discovery logic',d=>{const j=d.jobs.find(j=>j.jobId===discovery.jobId);if(j?.status==='failed')throw Error(j.error);return j?.status==='completed'&&j;});checks.push('Live arXiv discovery runs independently of source submission');
 if(process.argv.includes('--seed')){
  for(const source of [{url:'https://www.postgresql.org/docs/current/tutorial-transactions.html',title:'PostgreSQL documentation: transactions',topic:'Databases'},{url:'https://pages.cs.wisc.edu/~remzi/OSTEP/vm-beyondphys-policy.pdf',title:'Operating Systems: Three Easy Pieces - page replacement policies',topic:'Operating systems'}]){
   const submitted=await api('/knowledge/sources','POST',{...source,kind:'url',consent:true});
   await until(source.title,d=>{const s=d.sources.find(s=>s.id===submitted.source.id);if(s?.status==='failed')throw Error(s.error);return s?.status==='ready'&&s;});
  }
  checks.push('Authoritative database documentation and an operating-systems textbook chapter seeded');
 }
 console.log(checks.join('\n'));
 writeFileSync('tests/knowledge-integration-results.json',JSON.stringify({at:new Date().toISOString(),passed:true,checks,sourceId:id,pdfSourceId:upload.source.id,batchId:batch.id,published:batch.published,questionsBefore:before.filter(q=>!q.retired).length,questionsAfter:after.filter(q=>!q.retired).length},null,2)+'\n');
}catch(error){console.error(error.message);writeFileSync('tests/knowledge-integration-results.json',JSON.stringify({at:new Date().toISOString(),passed:false,checks,error:error.message},null,2)+'\n');process.exitCode=1;}
finally{if(username)await cognito.send(new AdminDeleteUserCommand({UserPoolId:cfg.UserPoolId,Username:username}));cognito.destroy();s3.destroy();}
