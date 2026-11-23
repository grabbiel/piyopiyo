// Explicit TestFlight upload only; never submits review or releases an App Store version.
import {readFile,mkdtemp,writeFile,rm} from 'node:fs/promises';
import {createHash,createPrivateKey,sign} from 'node:crypto';
import {spawn} from 'node:child_process';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {setTimeout as delay} from 'node:timers/promises';
const path='artifacts/apple-release/manifest.json',proof=JSON.parse(await readFile(path,'utf8'));
const artifact=proof.artifacts.find(a=>a.path===proof.ipaPath);
if(!artifact||createHash('sha256').update(await readFile(artifact.path)).digest('hex')!==artifact.sha256)throw Error('Signed IPA integrity check failed');
const b64=x=>Buffer.from(JSON.stringify(x)).toString('base64url');
async function asc(resource){
 const now=Math.floor(Date.now()/1000),input=b64({alg:'ES256',kid:process.env.ASC_KEY_ID,typ:'JWT'})+'.'+b64({iss:process.env.ASC_ISSUER_ID,iat:now,exp:now+300,aud:'appstoreconnect-v1'});
 const jwt=input+'.'+sign('sha256',Buffer.from(input),{key:createPrivateKey(process.env.ASC_PRIVATE_KEY),dsaEncoding:'ieee-p1363'}).toString('base64url');
 const response=await fetch('https://api.appstoreconnect.apple.com'+resource,{headers:{Authorization:'Bearer '+jwt},signal:AbortSignal.timeout(30000)});
 if(!response.ok)throw Error('Apple API returned HTTP '+response.status);
 return response.json();
}
const apps=(await asc('/v1/apps?'+new URLSearchParams({'filter[bundleId]':'app.piyopiyo.iphone'}))).data;
if(apps.length!==1||apps[0].id!=='6838389242')throw Error('Unexpected Apple application record');
const privateDir=await mkdtemp(join(process.env.RUNNER_TEMP||tmpdir(),'piyopiyo-upload-'));
try{
 await writeFile(join(privateDir,`AuthKey_${process.env.ASC_KEY_ID}.p8`),process.env.ASC_PRIVATE_KEY,{mode:0o600});
 const child=spawn('xcrun',['altool','--upload-package',proof.ipaPath,'--wait','--api-key',process.env.ASC_KEY_ID,'--api-issuer',process.env.ASC_ISSUER_ID],{stdio:'inherit',env:{...process.env,API_PRIVATE_KEYS_DIR:privateDir}});
 const result=await new Promise((resolve,reject)=>{child.on('error',reject);child.on('close',resolve);});
 if(result!==0)throw Error('Apple binary upload failed');
 for(let attempt=0;attempt<90;attempt++){
  const response=await asc('/v1/builds?'+new URLSearchParams({'filter[app]':apps[0].id,'filter[version]':proof.build,include:'preReleaseVersion'}));
  const versions=new Map((response.included||[]).filter(r=>r.type==='preReleaseVersions').map(r=>[r.id,r.attributes.version]));
  const build=response.data.find(b=>versions.get(b.relationships?.preReleaseVersion?.data?.id)===proof.version);
  if(build?.attributes.processingState==='VALID'){
   proof.apple={appId:apps[0].id,buildId:build.id,processingState:'VALID',uploadedAt:build.attributes.uploadedDate};
   await writeFile(path,JSON.stringify(proof,null,2)+'\n');console.log('Apple processed the TestFlight build successfully. No review submission or public release was made.');process.exitCode=0;break;
  }
  if(['FAILED','INVALID'].includes(build?.attributes.processingState))throw Error('Apple rejected build processing');
  if(attempt===89)throw Error('Apple processing remains pending; inspect App Store Connect before retrying upload');
  await delay(10000);
 }
}finally{await rm(privateDir,{recursive:true,force:true});}
