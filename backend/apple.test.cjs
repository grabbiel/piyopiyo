const {test,mock}=require('node:test');const assert=require('node:assert/strict');
const {generateKeyPairSync,sign}=require('node:crypto');
const {DynamoDBDocumentClient}=require('@aws-sdk/lib-dynamodb');
const {SecretsManagerClient}=require('@aws-sdk/client-secrets-manager');
const {handler}=require('./index.cjs');
const rsa=generateKeyPairSync('rsa',{modulusLength:2048}),ec=generateKeyPairSync('ec',{namedCurve:'prime256v1'});
process.env.APPLE_CLIENT_ID='app.piyopiyo.login';process.env.APPLE_TEAM_ID='test-team';process.env.APPLE_KEY_ID='test-key';process.env.APPLE_CALLBACK_URL='https://example.invalid/account/apple/callback';
const encode=x=>Buffer.from(JSON.stringify(x)).toString('base64url');
for(const scenario of ['valid','wrong-subject','wrong-nonce','expired','tampered-signature','stale-state'])test('Apple deletion callback: '+scenario,async()=>{
 const state={state:'random-state',nonce:'random-nonce',subject:'apple-user',expiresAt:Math.floor(Date.now()/1000)+600};
 const handle=encode({sub:'cognito-user',state:'random-state'});let revoked=false,marked=false;
 const db=mock.method(DynamoDBDocumentClient.prototype,'send',async command=>{
  if(command.constructor.name==='GetCommand')return {Item:scenario==='stale-state'?{...state,used:true}:state};
  if(command.constructor.name==='TransactWriteCommand')marked=true;
  return {};
 });
 const sm=mock.method(SecretsManagerClient.prototype,'send',async()=>({SecretString:ec.privateKey.export({type:'pkcs8',format:'pem'})}));
 const fetcher=mock.method(globalThis,'fetch',async url=>{
  if(url.endsWith('/keys'))return new Response(JSON.stringify({keys:[{...rsa.publicKey.export({format:'jwk'}),kid:'rsa-key',alg:'RS256',use:'sig'}]}));
  if(url.endsWith('/revoke')){revoked=true;return new Response('');}
  const claims={iss:'https://appleid.apple.com',aud:process.env.APPLE_CLIENT_ID,sub:scenario==='wrong-subject'?'somebody-else':state.subject,nonce:scenario==='wrong-nonce'?'other':state.nonce,exp:Math.floor(Date.now()/1000)+(scenario==='expired'?-60:600)};
  const data=encode({alg:'RS256',kid:'rsa-key'})+'.'+encode(claims);
  const signature=sign('RSA-SHA256',Buffer.from(data),rsa.privateKey);
  if(scenario==='tampered-signature')signature[0]^=0xff;
  return new Response(JSON.stringify({id_token:data+'.'+signature.toString('base64url'),refresh_token:'test-refresh'}));
 });
 try{
  const response=await handler({rawPath:'/account/apple/callback',requestContext:{http:{method:'GET'}},queryStringParameters:{state:handle,code:'test-code'}});
  assert.equal(response.statusCode,302);
  assert.equal(new URL(response.headers.location).searchParams.get('status'),scenario==='valid'?'ready':'failed');
  assert.equal(revoked,scenario==='valid');assert.equal(marked,scenario==='valid');
 }finally{db.mock.restore();sm.mock.restore();fetcher.mock.restore();}
});
