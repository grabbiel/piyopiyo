// Publishes content/questions.json to S3 without discarding rows the knowledge pipeline owns.
// Usage: AWS_PROFILE=admin AWS_REGION=us-east-1 node scripts/publish-questions.mjs [--dry-run]
import {readFileSync} from 'node:fs';
import {pathToFileURL} from 'node:url';
import {S3Client,GetObjectCommand,PutObjectCommand} from '@aws-sdk/client-s3';

const Bucket=process.env.QUESTION_BUCKET||'piyopiyo-question-banks',Key='published/questions.json';

export function merge(remote,local){
 const rows=new Map(remote.map(q=>[q.id,q]));
 const stats={remote:remote.length,added:0,updated:0,unchanged:0,kept:0};
 for(const q of local){
  const old=rows.get(q.id);
  if(old?.batchId)throw Error(`Authored id ${q.id} collides with generated row`);
  const next=old?.retired?{...q,retired:true}:q;
  if(!old)stats.added++;else if(JSON.stringify(old)===JSON.stringify(next))stats.unchanged++;else stats.updated++;
  rows.set(q.id,next);
 }
 const ids=new Set(local.map(q=>q.id));
 stats.kept=remote.filter(q=>!ids.has(q.id)).length;
 return {questions:[...rows.values()],stats};
}

async function read(s3){
 try{const r=await s3.send(new GetObjectCommand({Bucket,Key}));return {value:JSON.parse(await r.Body.transformToString()),etag:r.ETag};}
 catch(e){if(e.name==='NoSuchKey')return {value:[]};throw e;}
}

async function main(){
 const dryRun=process.argv.includes('--dry-run');
 const local=JSON.parse(readFileSync(new URL('../content/questions.json',import.meta.url)));
 const s3=new S3Client({region:process.env.AWS_REGION||'us-east-1'});
 for(let attempt=1;;attempt++){
  const current=await read(s3);
  const {questions,stats}=merge(current.value,local);
  console.log(JSON.stringify({bucket:Bucket,key:Key,etag:current.etag||null,...stats,total:questions.length,dryRun}));
  if(dryRun)return;
  try{
   await s3.send(new PutObjectCommand({Bucket,Key,Body:JSON.stringify(questions),ContentType:'application/json',...(current.etag?{IfMatch:current.etag}:{IfNoneMatch:'*'})}));
   return console.log('Published');
  }catch(e){if(e.name!=='PreconditionFailed'||attempt===3)throw e;console.log('Object changed during publish; retrying');}
 }
}

if(import.meta.url===pathToFileURL(process.argv[1]).href)await main();
