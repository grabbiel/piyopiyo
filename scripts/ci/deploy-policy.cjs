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
function assertSafeChangeSet(change) {
  if(change.Status!=='CREATE_COMPLETE'||change.ExecutionStatus!=='AVAILABLE') throw Error('Change set is not executable');
  if(change.NextToken) throw Error('Unexpected paginated change set; requires infrastructure review');
  for(const item of change.Changes||[]) {
    const r=item.ResourceChange;
    if(r?.ResourceType==='AWS::CDK::Metadata'&&r.Action==='Modify'&&r.Replacement==='False') continue;
    if(!r||r.Action!=='Modify'||r.Replacement!=='False'||r.ResourceType!=='AWS::Lambda::Function'||!r.Details?.length||r.Details.some(d=>d.Target?.Attribute!=='Properties'||d.Target?.Name!=='Code')) throw Error('Unexpected or destructive CloudFormation change; automatic execution stopped');
  }
}
module.exports={allowedFunctions,assertCodeOnly,assertSafeChangeSet};
