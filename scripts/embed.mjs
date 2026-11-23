import {pipeline,env} from '@huggingface/transformers';
import fs from 'node:fs/promises';
env.cacheDir='.agent/model-cache';
const chunks=JSON.parse(await fs.readFile('content/chunks.json','utf8'));
if(!chunks.length)throw new Error('No source chunks acquired');
const model='Xenova/all-MiniLM-L6-v2';
const extract=await pipeline('feature-extraction',model,{dtype:'q8'});
const vectors=[];
for(let i=0;i<chunks.length;i+=8){
 const batch=chunks.slice(i,i+8),out=await extract(batch.map(c=>c.text),{pooling:'mean',normalize:true});
 out.tolist().forEach((vector,j)=>vectors.push({id:batch[j].id,topic:batch[j].topic,sourceId:batch[j].sourceId,vector}));
}
await fs.writeFile('content/vectors.json',JSON.stringify({model,dimension:384,vectors}));
console.log(`Embedded ${vectors.length} source chunks locally.`);
