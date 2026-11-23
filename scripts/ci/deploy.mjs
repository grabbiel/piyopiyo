// Deliver exactly the artifacts tested in this GitHub run. No permanent AWS credentials.
import {CloudFormationClient,DescribeStacksCommand,GetTemplateCommand,CreateChangeSetCommand,DescribeChangeSetCommand,ExecuteChangeSetCommand,DeleteChangeSetCommand} from '@aws-sdk/client-cloudformation';
import {S3Client,PutObjectCommand} from '@aws-sdk/client-s3';
import {STSClient,GetCallerIdentityCommand} from '@aws-sdk/client-sts';
import {readFile,writeFile,mkdir,appendFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {setTimeout as delay} from 'node:timers/promises';
import policy from './deploy-policy.cjs';
const config={region:'us-east-1',maxAttempts:3}, cf=new CloudFormationClient(config),s3=new S3Client(config),sts=new STSClient(config);
const stack='PiyoPiyoDev',bucket='piyopiyo-provenance';
const proof={commit:process.env.GITHUB_SHA||null,startedAt:new Date().toISOString(),stack,status:'STARTED'};
const digest=bytes=>createHash('sha256').update(bytes).digest('hex');
let changeId, executed=false;
await mkdir('artifacts/ci',{recursive:true});
try {
 const identity=await sts.send(new GetCallerIdentityCommand({}));
 if(identity.Account!=='992680757326'||identity.Arn.endsWith(':root')) throw Error('Unexpected deployment identity');
 proof.identity=identity.Arn;
 const current=(await cf.send(new DescribeStacksCommand({StackName:stack}))).Stacks[0];
 if(!['CREATE_COMPLETE','UPDATE_COMPLETE','UPDATE_ROLLBACK_COMPLETE'].includes(current.StackStatus)) throw Error('Stack is not in a stable deployable state');
 if(current.RoleARN) throw Error('Unexpected CloudFormation service role; review its permissions before CI delivery');
 const previous=JSON.parse((await cf.send(new GetTemplateCommand({StackName:stack,TemplateStage:'Original'}))).TemplateBody);
 const proposed=JSON.parse(await readFile('cdk.out/PiyoPiyoDev.template.json','utf8'));
 proof.changedFunctions=policy.assertCodeOnly(previous,proposed);
 if(process.argv.includes('--plan')) {
  proof.status='PLAN_VALID';console.log('Code-only deployment plan validated:',proof.changedFunctions.length,'functions');
 } else {
  const backend=JSON.parse(await readFile('artifacts/backend/manifest.json','utf8'));
  const knowledge=JSON.parse(await readFile('artifacts/knowledge/manifest.json','utf8'));
  const artifacts=[{...backend,path:'artifacts/backend/function.zip'},...Object.values(knowledge)];
  if(artifacts.length!==4) throw Error('Expected exactly four tested function archives');
  const keys=new Set();
  for(const a of artifacts) {
   const bytes=await readFile(a.path);
   if(digest(bytes)!==a.sha256||a.key!==`deploy/functions/${a.sha256}.zip`) throw Error('Artifact integrity check failed');
   keys.add(a.key);
  }
  for(const resource of Object.values(proposed.Resources)) if(resource.Type==='AWS::Lambda::Function'&&!keys.has(resource.Properties.Code.S3Key)) throw Error('Template references an unverified artifact');
  for(const a of artifacts) await s3.send(new PutObjectCommand({Bucket:bucket,Key:a.key,Body:await readFile(a.path),ContentType:'application/zip',ServerSideEncryption:'AES256',ChecksumSHA256:Buffer.from(a.sha256,'hex').toString('base64')}));
  const template=JSON.stringify(proposed),hash=digest(template),key=`deploy/templates/${hash}.json`;
  await s3.send(new PutObjectCommand({Bucket:bucket,Key:key,Body:template,ContentType:'application/json',ServerSideEncryption:'AES256'}));
  const name=`ci-${(process.env.GITHUB_SHA||hash).slice(0,12)}-${process.env.GITHUB_RUN_ID||Date.now()}`;
  const created=await cf.send(new CreateChangeSetCommand({StackName:stack,ChangeSetName:name,ChangeSetType:'UPDATE',TemplateURL:`https://${bucket}.s3.us-east-1.amazonaws.com/${key}`,Parameters:current.Parameters.map(p=>({ParameterKey:p.ParameterKey,UsePreviousValue:true})),Capabilities:['CAPABILITY_IAM'],Description:`PiyoPiyo validated artifacts ${proof.commit||hash}`}));
  changeId=created.Id;proof.changeSet=changeId;proof.templateSHA256=hash;
  let change;
  for(let i=0;i<90;i++) {
   change=await cf.send(new DescribeChangeSetCommand({StackName:stack,ChangeSetName:changeId}));
   if(['CREATE_COMPLETE','FAILED'].includes(change.Status))break;
   await delay(4000);
  }
  if(change.Status==='FAILED'&&/didn.t contain changes|No updates are to be performed/i.test(change.StatusReason||'')) {
   proof.status='NO_CHANGES';await cf.send(new DeleteChangeSetCommand({StackName:stack,ChangeSetName:changeId}));changeId=undefined;
  } else {
   policy.assertSafeChangeSet(change);
   await cf.send(new ExecuteChangeSetCommand({StackName:stack,ChangeSetName:changeId}));executed=true;
   for(let i=0;i<150;i++) {
    const state=(await cf.send(new DescribeStacksCommand({StackName:stack}))).Stacks[0].StackStatus;
    if(state==='UPDATE_COMPLETE') {proof.status=state;break;}
    if(!state.endsWith('_IN_PROGRESS'))throw Error(`Deployment ended in ${state}`);
    await delay(5000);
   }
   if(proof.status==='STARTED')throw Error('Deployment timed out; inspect CloudFormation before retrying');
  }
  proof.smoke=[];
  for(const [path,expected] of [['/',200],['/health',200],['/privacy',200],['/support',200],['/questions',401]]) {
   const response=await fetch(`https://piyopiyo.grabbiel.com${path}`,{signal:AbortSignal.timeout(15000)});
   await response.arrayBuffer();proof.smoke.push({path,status:response.status});
   if(response.status!==expected) throw Error(`Post-deploy smoke check failed for ${path}: HTTP ${response.status}`);
  }
  console.log(`Deployment ${proof.status}; public pages, health, and authentication boundary passed.`);
 }
} catch(error) {
 proof.status='FAILED';proof.error=error.message;process.exitCode=1;
 console.error(error.message);
 if(changeId&&!executed)try{await cf.send(new DeleteChangeSetCommand({StackName:stack,ChangeSetName:changeId}));}catch{console.error('Could not remove the unexecuted change set.');}
} finally {
 proof.finishedAt=new Date().toISOString();await writeFile('artifacts/ci/deployment.json',JSON.stringify(proof,null,2)+'\n');
 if(process.env.GITHUB_STEP_SUMMARY)await appendFile(process.env.GITHUB_STEP_SUMMARY,`## AWS delivery\n\nStatus: **${proof.status}**\n\nCommit: \`${proof.commit}\`\n\n[Website](https://piyopiyo.grabbiel.com)\n`);
}
