// A separate ordinary learner for Apple's private App Review credentials field.
// No email is delivered, and this identity never receives content-admin access.
import {CognitoIdentityProviderClient,AdminCreateUserCommand,AdminSetUserPasswordCommand,InitiateAuthCommand} from '@aws-sdk/client-cognito-identity-provider';
import {existsSync,readFileSync,writeFileSync,chmodSync} from 'node:fs';
import {randomBytes} from 'node:crypto';
const file='.agent/app-review-account.json';
if(existsSync(file)){console.log('Private App Review credentials are already prepared.');process.exit(0);}
const config=JSON.parse(readFileSync('PiyoPiyo/PiyoPiyoCore/Sources/PiyoPiyoCore/Resources/configuration.json'));
const client=new CognitoIdentityProviderClient({region:config.Region,maxAttempts:3});
const username='piyopiyo-review-'+randomBytes(6).toString('hex')+'@example.invalid';
const password='PiyoReview9'+randomBytes(24).toString('base64url');
try{
 const result=await client.send(new AdminCreateUserCommand({UserPoolId:config.UserPoolId,Username:username,MessageAction:'SUPPRESS',UserAttributes:[{Name:'email',Value:username},{Name:'email_verified',Value:'true'},{Name:'name',Value:'PiyoPiyo App Review'}]}));
 writeFileSync(file,JSON.stringify({username,password,cognitoUsername:result.User.Username,userPoolId:config.UserPoolId,createdAt:new Date().toISOString(),purpose:'Apple App Review only; ordinary learner'},null,2),{mode:0o600});chmodSync(file,0o600);
 await client.send(new AdminSetUserPasswordCommand({UserPoolId:config.UserPoolId,Username:result.User.Username,Password:password,Permanent:true}));
 const session=await client.send(new InitiateAuthCommand({ClientId:config.ClientId,AuthFlow:'USER_PASSWORD_AUTH',AuthParameters:{USERNAME:username,PASSWORD:password}}));
 const response=await fetch(config.ApiUrl+'/questions',{headers:{Authorization:'Bearer '+session.AuthenticationResult.AccessToken}});
 if(!response.ok)throw Error('App Review learner could not load the question library.');
 const questions=await response.json();console.log('Prepared and verified an ordinary App Review learner. Question count:',questions.length);
}finally{client.destroy();}
