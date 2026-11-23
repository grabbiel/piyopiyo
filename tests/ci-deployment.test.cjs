const {test}=require('node:test');
const assert=require('node:assert/strict');
const {assertCodeOnly,assertSafeChangeSet}=require('../scripts/ci/deploy-policy.cjs');
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
test('change-set guard rejects replacement, deletion, and permission updates',()=>{
 const resource={Action:'Modify',Replacement:'False',ResourceType:'AWS::Lambda::Function',Details:[{Target:{Attribute:'Properties',Name:'Code'}}]};
 const change=r=>({Status:'CREATE_COMPLETE',ExecutionStatus:'AVAILABLE',Changes:[{ResourceChange:r}]});
 assert.doesNotThrow(()=>assertSafeChangeSet(change(resource)));
 for(const mutation of [{Replacement:'Conditional'},{Action:'Remove'},{ResourceType:'AWS::IAM::Role'},{Details:[{Target:{Attribute:'Properties',Name:'Role'}}]}])assert.throws(()=>assertSafeChangeSet(change({...resource,...mutation})));
 assert.throws(()=>assertSafeChangeSet({...change(resource),NextToken:'next'}));
});
