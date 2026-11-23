// Upload the verified universal IPA after the App Store Connect record exists.
// Default mode performs read-only preflight; pass --upload for the authorized upload.
import {readFileSync} from 'node:fs';
import {dirname} from 'node:path';
import {createHash,createPrivateKey,sign} from 'node:crypto';
import {spawn} from 'node:child_process';
const credentials=JSON.parse(readFileSync('.agent/apple-credentials.json'));
const metadata=JSON.parse(readFileSync('docs/app-store-metadata.json'));
const release=JSON.parse(readFileSync('tests/knowledge-release-artifacts.json'));
const artifact=release.artifacts.find(a=>a.path.endsWith('.ipa'));
if(!artifact||createHash('sha256').update(readFileSync(artifact.path)).digest('hex')!==artifact.sha256)throw Error('The signed IPA does not match the verified release manifest.');
const encode=x=>Buffer.from(JSON.stringify(x)).toString('base64url'),now=Math.floor(Date.now()/1000);
const input=encode({alg:'ES256',kid:credentials.keyId,typ:'JWT'})+'.'+encode({iss:credentials.issuerId,iat:now,exp:now+300,aud:'appstoreconnect-v1'});
const jwt=input+'.'+sign('sha256',Buffer.from(input),{key:createPrivateKey(readFileSync(credentials.keyPath)),dsaEncoding:'ieee-p1363'}).toString('base64url');
const query=new URLSearchParams({'filter[bundleId]':metadata.bundleId,'fields[apps]':'name,bundleId,sku'});
const response=await fetch('https://api.appstoreconnect.apple.com/v1/apps?'+query,{headers:{Authorization:'Bearer '+jwt}});
if(!response.ok)throw Error('App Store Connect preflight failed with HTTP '+response.status);
const apps=(await response.json()).data;
if(apps.length!==1)throw Error('PiyoPiyo has no unique App Store Connect record yet. Resolve the account agreement requirement and create the app record first.');
console.log('Verified signed IPA for',metadata.bundleId,'version',metadata.version,'build',metadata.build,'App Store Connect ID',apps[0].id);
if(process.argv.includes('--upload')){
 const child=spawn('xcrun',['altool','--upload-package',artifact.path,'--wait','--api-key',credentials.keyId,'--api-issuer',credentials.issuerId],{stdio:'inherit',env:{...process.env,API_PRIVATE_KEYS_DIR:dirname(credentials.keyPath)}});
 const code=await new Promise((resolve,reject)=>{child.on('error',reject);child.on('close',resolve);});
 process.exitCode=typeof code==='number'?code:1;
}else console.log('Read-only preflight passed. Use --upload to submit this verified build.');
