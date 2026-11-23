// One-time delivery access, deployed by the owner's admin profile, never by CI.
import {App,Stack,BootstraplessSynthesizer,Tags,CfnOutput,aws_iam as iam} from 'aws-cdk-lib';
import {readFileSync} from 'node:fs';
const app=new App();
const stack=new Stack(app,'PiyoPiyoDelivery',{env:{account:'992680757326',region:'us-east-1'},synthesizer:new BootstraplessSynthesizer(),description:'PiyoPiyo GitHub Actions OIDC delivery access'});
Tags.of(stack).add('Project','PiyoPiyo');
const principal=new iam.FederatedPrincipal('arn:aws:iam::992680757326:oidc-provider/token.actions.githubusercontent.com',{
 StringEquals:{'token.actions.githubusercontent.com:aud':'sts.amazonaws.com','token.actions.githubusercontent.com:sub':'repo:grabbiel@90626364/piyopiyo@1466624853:environment:aws-production'}
},'sts:AssumeRoleWithWebIdentity');
const role=new iam.Role(stack,'GitHubDeploy',{roleName:'piyopiyo-github-deploy',assumedBy:principal,description:'Only main via the aws-production GitHub environment; existing PiyoPiyo function delivery',inlinePolicies:{ApplicationDelivery:iam.PolicyDocument.fromJson(JSON.parse(readFileSync('infra/policies/github-deploy.json','utf8')))}});
new CfnOutput(stack,'GitHubDeployRoleArn',{value:role.roleArn});
app.synth();
