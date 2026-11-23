'use strict';
const {isDeepStrictEqual} = require('node:util');
const allowedFunctions = new Set(['piyopiyo-dev-api','piyopiyo-knowledge-api','piyopiyo-knowledge-worker','piyopiyo-knowledge-pdf']);
function assertCodeOnly(previous, proposed) {
  const before = structuredClone(previous), after = structuredClone(proposed);
  const changed=[];
  for (const template of [before,after]) {
    delete template.Metadata;
    for (const [id,resource] of Object.entries(template.Resources||{})) {
      delete resource.Metadata;
      if(resource.Type==='AWS::CDK::Metadata') delete template.Resources[id];
    }
  }
  for(const [id,resource] of Object.entries(after.Resources||{})) {
    const old=before.Resources[id];
    if(resource.Type!=='AWS::Lambda::Function'||!old||!allowedFunctions.has(resource.Properties?.FunctionName)) continue;
    const key=resource.Properties?.Code?.S3Key;
    if(!/^deploy\/functions\/[a-f0-9]{64}\.zip$/.test(key||'')) throw Error(`Invalid artifact key for ${id}`);
    if(old.Properties?.Code?.S3Key!==key) changed.push(id);
    resource.Properties.Code.S3Key=old.Properties?.Code?.S3Key;
  }
  if(!isDeepStrictEqual(before,after)) throw Error('Infrastructure change detected. Automatic delivery accepts only existing Lambda code changes; use the reviewed infrastructure deployment procedure.');
  return changed;
}
function retainTelemetry(previous, proposed) {
  // A code delivery should not rewrite CDK's independent analytics resource.
  const result=structuredClone(proposed);
  for(const [id,r] of Object.entries(result.Resources)) if(r.Type==='AWS::CDK::Metadata') delete result.Resources[id];
  for(const [id,r] of Object.entries(previous.Resources)) if(r.Type==='AWS::CDK::Metadata') result.Resources[id]=structuredClone(r);
  return result;
}
function assertSafeChangeSet(change, previous, proposed) {
  if(change.Status!=='CREATE_COMPLETE'||change.ExecutionStatus!=='AVAILABLE') throw Error('Change set is not executable');
  if(change.NextToken) throw Error('Unexpected paginated change set; requires infrastructure review');
  const expected=new Set(assertCodeOnly(previous,proposed));
  const stableArns=new Set();
  for(const {ResourceChange:r} of change.Changes||[]) {
    if(r?.ResourceType!=='AWS::Lambda::Function') continue;
    if(!expected.has(r.LogicalResourceId)||r.PhysicalResourceId!==previous.Resources[r.LogicalResourceId]?.Properties.FunctionName||r.Action!=='Modify'||r.Replacement!=='False'||!r.Details?.length||r.Details.some(d=>d.Target?.Attribute!=='Properties'||d.Target?.Name!=='Code'||d.Target?.RequiresRecreation!=='Never'||d.Evaluation!=='Static'||d.ChangeSource!=='DirectModification')) throw Error('Unexpected function change; automatic execution stopped');
    stableArns.add(r.LogicalResourceId+'.Arn');
  }
  if(stableArns.size!==expected.size) throw Error('Change set does not match the validated function updates');
  const dependentProperties={
    'AWS::Lambda::Permission':'FunctionName',
    'AWS::ApiGatewayV2::Integration':'IntegrationUri',
    'AWS::IAM::Policy':'PolicyDocument',
    'AWS::AppSync::DataSource':'LambdaConfig',
  };
  for(const item of change.Changes||[]) {
    const r=item.ResourceChange;
    if(r?.ResourceType==='AWS::Lambda::Function') continue;
    // CloudFormation conservatively lists dependents of an updated Lambda ARN.
    // The complete template comparison and non-replacing Code-only update above
    // prove that this ARN and the dependent resource's properties stay unchanged.
    const property=dependentProperties[r?.ResourceType];
    const replacement=r?.ResourceType==='AWS::Lambda::Permission'?['False','Conditional']:['False'];
    if(!r||!previous.Resources[r.LogicalResourceId]||!property||r.Action!=='Modify'||!replacement.includes(r.Replacement)||!r.Details?.length||r.Details.some(d=>d.Evaluation!=='Dynamic'||d.ChangeSource!=='ResourceAttribute'||!stableArns.has(d.CausingEntity)||d.Target?.Attribute!=='Properties'||d.Target?.Name!==property)) throw Error('Unexpected or destructive CloudFormation change; automatic execution stopped');
  }
}
module.exports={allowedFunctions,assertCodeOnly,retainTelemetry,assertSafeChangeSet};
