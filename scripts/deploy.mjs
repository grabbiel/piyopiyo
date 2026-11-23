// Use prepare -> inspect -> execute. No private key bytes are logged or committed.
import {execFileSync} from 'node:child_process';
import {readFileSync,writeFileSync,unlinkSync} from 'node:fs';
import {createHash} from 'node:crypto';
const aws=(service,operation,args=[])=>JSON.parse(execFileSync('./scripts/aws.sh',[service,operation,...args,'--output','json'],{encoding:'utf8',stdio:['ignore','pipe','pipe']})||'{}');
const identity=aws('sts','get-caller-identity');
if(identity.Account!=='992680757326'||identity.Arn.endsWith(':root'))throw new Error('Unexpected deployment identity');
if(process.argv[2]==='--execute'){
 const review=JSON.parse(readFileSync('.agent/deploy-review.json'));
 const change=aws('cloudformation','describe-change-set',['--stack-name','PiyoPiyoDev','--change-set-name',review.id]);
 if(change.Status!=='CREATE_COMPLETE')throw new Error('Change set is not ready');
 for(const c of change.Changes||[]){const r=c.ResourceChange;if(r.Action==='Remove'||(r.Replacement==='True'&&r.ResourceType!=='AWS::Budgets::Budget'))throw new Error('Destructive change requires separate review: '+r.LogicalResourceId);}
 aws('cloudformation','execute-change-set',['--stack-name','PiyoPiyoDev','--change-set-name',review.id]);
 console.log('Executing reviewed change set:',review.name);
}else{
 const backend=JSON.parse(readFileSync('artifacts/backend/manifest.json'));
 const bundle=readFileSync('artifacts/backend/function.zip');
 if(createHash('sha256').update(bundle).digest('hex')!==backend.sha256)throw new Error('Backend archive changed after build');
 aws('s3api','put-object',['--bucket','piyopiyo-provenance','--key',backend.key,'--body','artifacts/backend/function.zip','--content-type','application/zip']);
 const knowledge=JSON.parse(readFileSync('artifacts/knowledge/manifest.json'));
 for(const artifact of Object.values(knowledge)){
  if(createHash('sha256').update(readFileSync(artifact.path)).digest('hex')!==artifact.sha256)throw new Error('Knowledge archive changed after build');
  aws('s3api','put-object',['--bucket','piyopiyo-provenance','--key',artifact.key,'--body',artifact.path,'--content-type','application/zip']);
 }
 const template=JSON.stringify(JSON.parse(readFileSync('cdk.out/PiyoPiyoDev.template.json')));
 writeFileSync('.agent/release-template.json',template);
 const hash=createHash('sha256').update(template).digest('hex');
 let templateArgs=['--template-body','file://.agent/release-template.json'];
 if(Buffer.byteLength(template)>51200){
  const key='deploy/templates/'+hash+'.json';
  aws('s3api','put-object',['--bucket','piyopiyo-provenance','--key',key,'--body','.agent/release-template.json','--content-type','application/json']);
  templateArgs=['--template-url','https://piyopiyo-provenance.s3.us-east-1.amazonaws.com/'+key];
 }
 const current=aws('cloudformation','describe-stacks',['--stack-name','PiyoPiyoDev']).Stacks[0];
 const parameters=[{ParameterKey:'BudgetEmail',UsePreviousValue:true}];
 if(process.env.PIYOPIYO_APPLE_KEY_PATH)parameters.push({ParameterKey:'ApplePrivateKey',ParameterValue:readFileSync(process.env.PIYOPIYO_APPLE_KEY_PATH,'utf8')});
 else if(current.Parameters.some(p=>p.ParameterKey==='ApplePrivateKey'))parameters.push({ParameterKey:'ApplePrivateKey',UsePreviousValue:true});
 else throw new Error('Set PIYOPIYO_APPLE_KEY_PATH for the first Apple deployment');
 const file='.agent/cloudformation-parameters.json';
 writeFileSync(file,JSON.stringify(parameters),{mode:0o600});
 try{
  const name='release-'+Date.now();
  const result=aws('cloudformation','create-change-set',['--stack-name','PiyoPiyoDev','--change-set-name',name,'--change-set-type','UPDATE',...templateArgs,'--parameters','file://'+file,'--capabilities','CAPABILITY_IAM']);
  writeFileSync('.agent/deploy-review.json',JSON.stringify({name,id:result.Id,templateSHA256:hash}));
  console.log('Prepared change set:',name,'template:',hash);
 }finally{unlinkSync(file);}
}
