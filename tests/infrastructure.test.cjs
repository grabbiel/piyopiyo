const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const template=JSON.parse(fs.readFileSync('cdk.out/PiyoPiyoDev.template.json','utf8'));
const resources=Object.values(template.Resources);
const ofType=t=>resources.filter(r=>r.Type===t);
test('storage is private, encrypted, versioned, and retained',()=>{
 assert.equal(ofType('AWS::S3::Bucket').length,4);
 for(const r of ofType('AWS::S3::Bucket')) {
  assert.ok(Object.values(r.Properties.PublicAccessBlockConfiguration).every(v=>v===true));
  assert.equal(r.Properties.VersioningConfiguration.Status,'Enabled');
  assert.ok(r.Properties.BucketEncryption);assert.equal(r.DeletionPolicy,'Retain');
 }
});
test('capacity and spending defaults fit a small audience',()=>{
 const table=ofType('AWS::DynamoDB::Table')[0].Properties;
 assert.equal(table.BillingMode,'PAY_PER_REQUEST');assert.equal(table.OnDemandThroughput.MaxWriteRequestUnits,5);
 assert.equal(ofType('AWS::Lambda::Function')[0].Properties.ReservedConcurrentExecutions,2);
 const budget=ofType('AWS::Budgets::Budget')[0].Properties;
 assert.equal(budget.Budget.BudgetLimit.Amount,15);
 assert.deepEqual(budget.Budget.CostFilters.TagKeyValue,['user:Project$PiyoPiyo']);
 assert.equal(budget.NotificationsWithSubscribers[0].Notification.Threshold,80);
});
test('authentication is required except for explicit public endpoints',()=>{
 for(const r of ofType('AWS::ApiGatewayV2::Route')) if(!['GET /','GET /health','GET /account/apple/callback','GET /privacy','GET /support'].includes(r.Properties.RouteKey)) {
  assert.equal(r.Properties.AuthorizationType,'JWT');assert.deepEqual(r.Properties.AuthorizationScopes,['openid','aws.cognito.signin.user.admin']);
 }
 assert.equal(ofType('AWS::Cognito::IdentityPool')[0].Properties.AllowUnauthenticatedIdentities,false);
 assert.equal(ofType('AWS::Cognito::UserPoolClient')[0].Properties.GenerateSecret,false);
});
test('no agent IAM identity or shared application resource is created or referenced',()=>{
 assert.equal(ofType('AWS::IAM::User').length,0);assert.equal(ofType('AWS::SSO::PermissionSet').length,0);
 assert.equal(ofType('AWS::IAM::Role').length,7);
 const serialized=JSON.stringify(template);
 for(const unrelated of ['auto-applicator','discutierlist','shuverse','swooshkey','farrot']) assert.ok(!serialized.includes(unrelated));
 for(const r of ofType('AWS::IAM::Role')) {
  const trust=r.Properties.AssumeRolePolicyDocument.Statement;
  assert.ok(trust.every(s=>s.Principal.Service||s.Principal.Federated));
 }
});

test('grading candidates use app-exclusive tagged inference profiles',()=>{
 const profiles=ofType('AWS::Bedrock::ApplicationInferenceProfile');assert.equal(profiles.length,7);
 for(const profile of profiles){assert.ok(profile.Properties.InferenceProfileName.startsWith('piyopiyo-'));assert.ok(profile.Properties.Tags.some(t=>t.Key==='Project'&&t.Value==='PiyoPiyo'));}
});
test('account deletion and budget alerts are explicitly provisioned',()=>{
 assert.ok(ofType('AWS::ApiGatewayV2::Route').some(r=>r.Properties.RouteKey==='DELETE /account'));
 const alerts=ofType('AWS::Budgets::Budget')[0].Properties.NotificationsWithSubscribers;
 assert.deepEqual(alerts.map(x=>[x.Notification.NotificationType,x.Notification.Threshold]),[['FORECASTED',80],['ACTUAL',80],['ACTUAL',100]]);
 const policies=ofType('AWS::IAM::Policy').flatMap(p=>p.Properties.PolicyDocument.Statement);
 const deletion=policies.filter(p=>[].concat(p.Action).includes('cognito-idp:AdminDeleteUser'));
 assert.equal(deletion.length,1);assert.notEqual(deletion[0].Resource,'*');
});
test('knowledge loops are serialized, bounded, private, and scheduled three times a week',()=>{
 const functions=ofType('AWS::Lambda::Function').filter(r=>r.Properties.FunctionName.startsWith('piyopiyo-knowledge'));
 assert.equal(functions.length,3);assert.ok(functions.every(r=>r.Properties.ReservedConcurrentExecutions===1));
 const schedules=ofType('AWS::Scheduler::Schedule');assert.equal(schedules.length,2);
 for(const schedule of schedules){assert.match(schedule.Properties.ScheduleExpression,/MON,WED,FRI/);assert.equal(schedule.Properties.ScheduleExpressionTimezone,'America/Lima');assert.equal(schedule.Properties.Target.SqsParameters.MessageGroupId,'pipeline');}
 const queue=ofType('AWS::SQS::Queue').find(r=>r.Properties.QueueName==='piyopiyo-knowledge.fifo').Properties;
 assert.equal(queue.FifoQueue,true);assert.equal(queue.VisibilityTimeout,1800);assert.equal(queue.RedrivePolicy.maxReceiveCount,3);
 assert.equal(ofType('AWS::Lambda::EventSourceMapping')[0].Properties.BatchSize,1);
});
