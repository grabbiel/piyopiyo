'use strict';
const https=require('node:https');const dns=require('node:dns/promises');const robotsParser=require('robots-parser');
const {publicURL,publicAddress}=require('./core.cjs');
const USER_AGENT='PiyoPiyoKnowledgeBot/1.0';
async function safeFetch(value,{maxBytes=20*1024*1024,headers={},redirects=0,beforeFetch}={}){
 const url=publicURL(value);if(beforeFetch)await beforeFetch(url);const records=await dns.lookup(url.hostname,{all:true});
 if(!records.length||records.some(r=>!publicAddress(r.address)))throw Error('Source resolves to a private or unsupported network address.');
 const pinned=records[0];
 const result=await new Promise((resolve,reject)=>{
  const req=https.get(url,{headers:{'User-Agent':USER_AGENT,'Accept-Encoding':'identity',...headers},lookup:(_host,options,cb)=>{if(options?.all)cb(null,[pinned]);else cb(null,pinned.address,pinned.family);},timeout:15000},res=>{
   let size=0;const chunks=[];
   if(res.headers['content-encoding']&&res.headers['content-encoding']!=='identity'){res.destroy();reject(Error('Compressed responses are unsupported. Submit a local copy.'));return;}
   if(Number(res.headers['content-length']||0)>maxBytes){res.destroy();reject(Error('Source exceeds the download limit.'));return;}
   res.on('data',chunk=>{size+=chunk.length;if(size>maxBytes){res.destroy();reject(Error('Source exceeds the download limit.'));}else chunks.push(chunk);});
   res.on('error',reject);res.on('end',()=>resolve({status:res.statusCode,headers:res.headers,body:Buffer.concat(chunks),url:url.href}));
  });req.on('error',reject);req.on('timeout',()=>req.destroy(Error('Source download timed out.')));
 });
 if([301,302,303,307,308].includes(result.status)){if(redirects>=4||!result.headers.location)throw Error('Too many source redirects.');return safeFetch(new URL(result.headers.location,url).href,{maxBytes,headers,redirects:redirects+1,beforeFetch});}
 if(result.status!==304&&(result.status<200||result.status>=300))throw Error('Source returned HTTP '+result.status);
 return result;
}
async function checkRobots(parsed){
 const robotURL=new URL('/robots.txt',parsed).href;
 let robot;
 try{robot=await safeFetch(robotURL,{maxBytes:256000});}catch(e){if(!/HTTP (404|410)/.test(e.message))throw Error('Unable to verify this source’s robots policy. Upload a permitted local copy instead.');}
 if(robot&&robotsParser(robotURL,robot.body.toString()).isAllowed(parsed.href,USER_AGENT)===false)throw Error('This source disallows automated retrieval. Upload a permitted local copy instead.');
}
const fetchDocument=(url,headers={})=>safeFetch(url,{headers,beforeFetch:checkRobots});
module.exports={safeFetch,fetchDocument};
