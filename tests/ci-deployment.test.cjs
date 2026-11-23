const {test}=require('node:test');
const assert=require('node:assert/strict');
const {assertCodeOnly,retainTelemetry,assertSafeChangeSet}=require('../scripts/ci/deploy-policy.cjs');
const template=()=>({Parameters:{Key:{NoEcho:true}},Resources:{Function:{Type:'AWS::Lambda::Function',Properties:{FunctionName:'piyopiyo-dev-api',Role:'existing-role',Code:{S3Bucket:'app-only',S3Key:'deploy/functions/'+ 'a'.repeat(64)+'.zip'}}},Table:{Type:'AWS::DynamoDB::Table',DeletionPolicy:'Retain',Properties:{TableName:'PiyoPiyoQuizSessions'}}}});
test('delivery accepts only content-addressed code on existing app functions',()=>{
 const before=template(),after=template();after.Resources.Function.Properties.Code.S3Key='deploy/functions/'+'b'.repeat(64)+'.zip';assert.deepEqual(assertCodeOnly(before,after),['Function']);
});
test('delivery rejects role, configuration, resource removal, and parameter changes',()=>{
 for(const mutate of [x=>x.Resources.Function.Properties.Role='admin',x=>x.Resources.Function.Properties.Environment={Variables:{new:'value'}},x=>delete x.Resources.Table,x=>x.Parameters.Key.NoEcho=false,x=>x.Resources.Function.Properties.Code.S3Bucket='other-bucket']){
  const proposed=template();mutate(proposed);assert.throws(()=>assertCodeOnly(template(),proposed),/Infrastructure change/);
 }
});
test('delivery rejects missing, mutable, or foreign function artifact keys',()=>{
 const after=template();after.Resources.Function.Properties.Code.S3Key='latest.zip';assert.throws(()=>assertCodeOnly(template(),after),/Invalid artifact key/);
 const foreign=template();foreign.Resources.Function.Properties.FunctionName='other-app';assert.throws(()=>assertCodeOnly(template(),foreign),/Infrastructure change/);
});
function changeFixture() {
 const before=template(),after=template();after.Resources.Function.Properties.Code.S3Key='deploy/functions/'+'b'.repeat(64)+'.zip';
 const resource={LogicalResourceId:'Function',PhysicalResourceId:'piyopiyo-dev-api',Action:'Modify',Replacement:'False',ResourceType:'AWS::Lambda::Function',Details:[{Target:{Attribute:'Properties',Name:'Code',RequiresRecreation:'Never'},Evaluation:'Static',ChangeSource:'DirectModification'}]};
 const change={Status:'CREATE_COMPLETE',ExecutionStatus:'AVAILABLE',Changes:[{ResourceChange:resource}]};
 return {before,after,resource,change};
}
test('change-set guard rejects replacement, deletion, and permission updates',()=>{
 const {before,after,resource,change}=changeFixture();
 assert.doesNotThrow(()=>assertSafeChangeSet(change,before,after));
 for(const mutation of [{Replacement:'Conditional'},{Action:'Remove'},{ResourceType:'AWS::IAM::Role'},{PhysicalResourceId:'other-app'},{Details:[{Target:{Attribute:'Properties',Name:'Role'}}]}])assert.throws(()=>assertSafeChangeSet({...change,Changes:[{ResourceChange:{...resource,...mutation}}]},before,after));
 assert.throws(()=>assertSafeChangeSet({...change,NextToken:'next'},before,after));
});
test('only unchanged dependencies of a verified stable Lambda ARN are accepted',()=>{
 const {before,after,change}=changeFixture();
 for(const [type,property] of [['AWS::Lambda::Permission','FunctionName'],['AWS::ApiGatewayV2::Integration','IntegrationUri'],['AWS::IAM::Policy','PolicyDocument'],['AWS::AppSync::DataSource','LambdaConfig']]) {
  before.Resources.Dependent={Type:type,Properties:{[property]:{'Fn::GetAtt':['Function','Arn']}}};
  after.Resources.Dependent=structuredClone(before.Resources.Dependent);
  const detail={Evaluation:'Dynamic',ChangeSource:'ResourceAttribute',CausingEntity:'Function.Arn',Target:{Attribute:'Properties',Name:property,RequiresRecreation:type==='AWS::Lambda::Permission'?'Always':'Never'}};
  const dependency={LogicalResourceId:'Dependent',ResourceType:type,Action:'Modify',Replacement:type==='AWS::Lambda::Permission'?'Conditional':'False',Details:[detail]};
  const withDependency=r=>({...change,Changes:[...change.Changes,{ResourceChange:r}]});
  assert.doesNotThrow(()=>assertSafeChangeSet(withDependency(dependency),before,after));
  for(const mutation of [{Evaluation:'Static'},{ChangeSource:'DirectModification'},{CausingEntity:'OtherFunction.Arn'},{Target:{Attribute:'Properties',Name:'Role'}}])assert.throws(()=>assertSafeChangeSet(withDependency({...dependency,Details:[{...detail,...mutation}]}),before,after));
  for(const mutation of [{Action:'Remove'},{Replacement:'True'},{ResourceType:'AWS::DynamoDB::Table'}])assert.throws(()=>assertSafeChangeSet(withDependency({...dependency,...mutation}),before,after));
  after.Resources.Dependent.Properties[property]='changed-value';
  assert.throws(()=>assertSafeChangeSet(withDependency(dependency),before,after),/Infrastructure change/);
 }
});
test('code delivery retains deployed telemetry without masking application changes',()=>{
 const {before,after}=changeFixture();
 before.Resources.CDKMetadata={Type:'AWS::CDK::Metadata',Properties:{Analytics:'old'}};
 after.Resources.CDKMetadata={Type:'AWS::CDK::Metadata',Properties:{Analytics:'new'}};
 assertCodeOnly(before,after);
 assert.deepEqual(retainTelemetry(before,after).Resources.CDKMetadata,before.Resources.CDKMetadata);
 after.Resources.CDKMetadata={Type:'AWS::IAM::Role',Properties:{RoleName:'unexpected'}};
 assert.throws(()=>assertCodeOnly(before,after),/Infrastructure change/);
});
