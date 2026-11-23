'use strict';
const {randomUUID}=require('node:crypto');const {PutObjectCommand,GetObjectCommand,HeadObjectCommand}=require('@aws-sdk/client-s3');const {getSignedUrl}=require('@aws-sdk/s3-request-presigner');
const {hash,clean,publicURL,topics}=require('./core.cjs');const S=require('./store.cjs');
const reply=(statusCode,body)=>({statusCode,headers:{'content-type':'application/json','cache-control':'no-store'},body:JSON.stringify(body)});
exports.handler=async event=>{
 try{
  const claims=event.requestContext?.authorizer?.jwt?.claims;let groups=claims?.['cognito:groups']||[];if(typeof groups==='string')groups=groups.replace(/[\[\]"']/g,'').split(/[,\s]+/);
  if(!claims?.sub||!groups.includes('content-admins'))return reply(403,{error:'This app is available only to PiyoPiyo content administrators.'});
  const method=event.requestContext.http.method,path=event.rawPath;
  if(event.body&&Buffer.byteLength(event.body)>24000)return reply(413,{error:'Request too large.'});
  const body=event.body?JSON.parse(event.body):{};
  if(method==='GET'&&path==='/knowledge/dashboard'){
   const [sources,batches,jobs,settings,usage,signals]=await Promise.all([S.list('SOURCE',500),S.list('BATCH',1000),S.list('JOB',1000),S.settings(),S.get('USAGE',new Date().toISOString().slice(0,7)),S.list('SIGNALS',20)]);
   return reply(200,{sources:sources.map(({abstract,submittedBy,...s})=>s).sort((a,b)=>b.updatedAt.localeCompare(a.updatedAt)),batches:batches.sort((a,b)=>b.createdAt.localeCompare(a.createdAt)).slice(0,100),jobs:jobs.sort((a,b)=>(b.completedAt||b.updatedAt||b.startedAt||'').localeCompare(a.completedAt||a.updatedAt||a.startedAt||'')).slice(0,100),settings,usage:usage||{calls:0},signals,schedule:'Monday, Wednesday, Friday · discovery 09:30, generation 10:30 · America/Lima'});
  }
  if(method==='POST'&&path==='/knowledge/sources'){
   if(body.consent!==true)return reply(400,{error:'Confirm this source may be processed by PiyoPiyo and Amazon Bedrock.'});
   const title=clean(body.title).slice(0,200);if(title.length<3)return reply(400,{error:'Add a source title.'});
   const topic=topics.includes(body.topic)?body.topic:'Computer science research';let id,url;
   if(body.kind==='url'){try{url=publicURL(body.url).href;}catch(e){return reply(400,{error:e.message});}id=hash(url);}
   else if(['pdf','text'].includes(body.kind)&&/^[a-f0-9]{64}$/.test(body.sha256)&&Number.isInteger(body.bytes)&&body.bytes>0&&body.bytes<=20*1024*1024)id=body.sha256;
   else return reply(400,{error:'Choose an HTTPS URL, PDF, or text file up to 20 MB.'});
   const prior=await S.get('SOURCE',id);if(prior&&prior.status!=='awaiting_upload')return reply(200,{source:prior,duplicate:true});
   if(!prior&&(await S.list('SOURCE',500)).length>=500)return reply(409,{error:'The library has reached its 500-source allowance. Contact the administrator before increasing it.'});
   const now=new Date().toISOString(),source=prior||{PK:'SOURCE',SK:id,id,title,topic,kind:body.kind,url,bytes:body.bytes,sha256:body.sha256,rawKey:`raw/${id}/input`,status:url?'queued':'awaiting_upload',rights:body.rights==='open_license'?'open_license':'private_reference',createdAt:now,updatedAt:now,submittedBy:claims.sub,cursor:0,active:true};
   await S.put(source);
   if(url){await S.enqueue({op:'ingest',sourceId:id,jobId:randomUUID()});return reply(202,{source});}
   const contentType=body.kind==='pdf'?'application/pdf':'text/plain';
   const uploadURL=await getSignedUrl(S.s3,new PutObjectCommand({Bucket:S.Bucket,Key:source.rawKey,ContentType:contentType,ContentLength:body.bytes,ChecksumSHA256:Buffer.from(body.sha256,'hex').toString('base64')}),{expiresIn:900,unhoistableHeaders:new Set(['x-amz-checksum-sha256'])});
   return reply(201,{source,uploadURL,contentType,checksum:Buffer.from(body.sha256,'hex').toString('base64')});
  }
  const sourceMatch=path.match(/^\/knowledge\/sources\/([a-f0-9]{64})\/(complete|retry|pause|resume|download)$/);
  if(sourceMatch){const [,id,action]=sourceMatch,source=await S.get('SOURCE',id);if(!source)return reply(404,{error:'Source not found.'});
   if(action==='download'&&method==='GET')return reply(200,{url:await getSignedUrl(S.s3,new GetObjectCommand({Bucket:S.Bucket,Key:source.rawKey}),{expiresIn:300})});
   if(method==='POST'){
    if(action==='complete'){const info=await S.s3.send(new HeadObjectCommand({Bucket:S.Bucket,Key:source.rawKey,ChecksumMode:'ENABLED'}));if(info.ContentLength!==source.bytes||info.ChecksumSHA256!==Buffer.from(source.sha256,'hex').toString('base64'))return reply(400,{error:'Upload size/checksum did not match.'});}
    await S.enqueue({op:['pause','resume'].includes(action)?action:'ingest',sourceId:id,jobId:randomUUID()});return reply(202,{accepted:true});
   }
  }
  if(method==='POST'&&path==='/knowledge/run'){
   if(!['discover','generate'].includes(body.op))return reply(400,{error:'Unsupported operation.'});
   const cfg=await S.settings();if(!cfg.enabled)return reply(409,{error:'Resume the pipeline first.'});
   const jobId=randomUUID();await S.enqueue({op:body.op,jobId,...(/^[a-f0-9]{64}$/.test(body.sourceId||'')?{sourceId:body.sourceId}:{})});return reply(202,{jobId});
  }
  if(method==='PATCH'&&path==='/knowledge/settings'){
   const current=await S.settings();if(typeof body.enabled!=='boolean')return reply(400,{error:'Specify whether background processing is enabled.'});
   await S.put({...current,PK:'CONFIG',SK:'pipeline',enabled:body.enabled,updatedAt:new Date().toISOString()});return reply(200,{enabled:body.enabled});
  }
  if(method==='GET'&&path.startsWith('/knowledge/batches/')){const id=path.split('/').pop();if(!/^[a-zA-Z0-9-]{1,100}$/.test(id))return reply(400,{error:'Invalid batch.'});const batch=await S.get('BATCH',id);if(!batch)return reply(404,{error:'Batch not found.'});return reply(200,(await S.readJSON(batch.detailKey)).value);}
  const withdraw=path.match(/^\/knowledge\/batches\/([a-zA-Z0-9-]{1,100})\/withdraw$/);
  if(method==='POST'&&withdraw){if(!await S.get('BATCH',withdraw[1]))return reply(404,{error:'Batch not found.'});await S.enqueue({op:'withdraw',batchId:withdraw[1],jobId:randomUUID()});return reply(202,{accepted:true});}
  return reply(404,{error:'Not found.'});
 }catch(e){console.warn(JSON.stringify({event:'knowledge_api_error',type:e.name}));return reply(e.name==='SyntaxError'?400:503,{error:e.name==='SyntaxError'?'Invalid request.':'The source service is temporarily unavailable. Please retry.'});}
};
