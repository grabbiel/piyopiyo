'use strict';
const {createHash}=require('node:crypto');
const ipaddr=require('ipaddr.js');
const {Readability}=require('@mozilla/readability');
const {parseHTML}=require('linkedom');
const hash=x=>createHash('sha256').update(x).digest('hex');
const clean=x=>String(x||'').replace(/\s+/g,' ').trim();
function publicURL(value){
 const u=new URL(value);
 if(u.protocol!=='https:'||u.username||u.password||(u.port&&u.port!=='443')||u.href.length>2048)throw Error('Use a public HTTPS URL without credentials.');
 const host=u.hostname.replace(/^\[|\]$/g,'').toLowerCase();
 if(!host.includes('.')||/\.(local|internal|localhost)$/.test(host)||host==='localhost'||(ipaddr.isValid(host)&&!publicAddress(host)))throw Error('Private network addresses are not supported.');
 u.hash='';return u;
}
function publicAddress(value){try{let a=ipaddr.parse(value);if(a.kind()==='ipv6'&&a.isIPv4MappedAddress())a=a.toIPv4Address();return a.range()==='unicast';}catch{return false;}}
function chunkText(text,page=null){
 const value=String(text).replace(/\r/g,'').replace(/[ \t]+/g,' ').trim(),chunks=[];
 for(let start=0;start<value.length;){let end=Math.min(start+2200,value.length);if(end<value.length){const at=value.lastIndexOf(' ',end);if(at>start+1200)end=at;}const part=value.slice(start,end).trim();if(part.length>100)chunks.push({text:part,page,offset:start});if(end===value.length)break;start=end-180;}
 return chunks;
}
function htmlText(html){
 const {document}=parseHTML(html);for(const node of document.querySelectorAll('script,style,noscript,nav,footer,header,form,svg'))node.remove();
 const article=new Readability(document,{charThreshold:100}).parse();
 return {title:clean(article?.title||document.title).slice(0,200),text:clean(article?.textContent||document.body?.textContent)};
}
const topics=['Algorithms','Programming','Databases','Operating systems','Distributed systems','Software engineering','Computer science research'];
function validateQuestion(q,segments,existing=[]){
 const reasons=[];
 if(!q||!['multiple_choice','true_false','short_answer'].includes(q.format))return ['Unsupported format'];
 for(const [key,max] of [['prompt',600],['explanation',1200]])if(typeof q[key]!=='string'||q[key].trim().length<15||q[key].length>max)reasons.push('Invalid '+key);
 if(!topics.includes(q.topic)||!['easy','medium','hard'].includes(q.difficulty))reasons.push('Invalid classification');
 if(!Array.isArray(q.correct)||!q.correct.length||q.correct.some(x=>typeof x!=='string'||x.length>500))reasons.push('Invalid answer');
 if(!Array.isArray(q.options)||q.options.some(x=>typeof x!=='string'||!x.trim()||x.length>300))reasons.push('Invalid choices');
 else if(q.format==='multiple_choice'&&(q.options.length!==4||new Set(q.options.map(clean)).size!==4||q.correct?.length!==1||!q.options.includes(q.correct[0])))reasons.push('Choice/answer mismatch');
 else if(q.format==='true_false'&&(JSON.stringify(q.options)!=='["True","False"]'||q.correct?.length!==1||!q.options.includes(q.correct[0])))reasons.push('Invalid boolean question');
 if(q.format==='short_answer'&&(!Array.isArray(q.criteria)||q.criteria.length!==5||q.criteria.some(c=>typeof c!=='string'||c.length<3||c.length>160)||q.options?.length!==0||typeof q.rubric!=='string'||q.rubric.split(/(?:^|\s)\d+\.\s+/).slice(1).length!==5))reasons.push('Written answers require exactly five numbered facts');
 // PDF line wraps are layout, not different evidence. Normalize whitespace only;
 // spelling, punctuation, ordering and contiguous passage boundaries must match.
 if(!Array.isArray(q.evidence)||!q.evidence.length||q.evidence.length>5||q.evidence.some(e=>!e||!Number.isInteger(e.segment)||!segments.some(s=>s.id===e.segment)||typeof e.quote!=='string'||e.quote.length<20||e.quote.length>300||!clean(segments.find(s=>s.id===e.segment)?.text).includes(clean(e.quote))))reasons.push('Evidence must quote an exact supplied source segment');
 const words=clean(q.prompt).toLowerCase().replace(/[^\p{L}\p{N} ]/gu,'').split(' '),set=new Set(words);
 if(existing.some(old=>{const other=new Set(clean(old.prompt).toLowerCase().replace(/[^\p{L}\p{N} ]/gu,'').split(' '));const overlap=[...set].filter(w=>other.has(w)).length;return overlap/Math.max(1,new Set([...set,...other]).size)>.82;}))reasons.push('Duplicate or near-duplicate prompt');
 if(segments.some(s=>clean(s.text).toLowerCase().includes(clean(q.prompt).toLowerCase())))reasons.push('Question copies source wording');
 if(/ignore (?:all |previous |the )?instructions|system prompt|api key|reveal.*secret/i.test(q.prompt+' '+q.explanation))reasons.push('Instruction-like content');
 if(/\b(?:the|this) (?:passage|example|tutorial|code)\b|\bas (?:shown|described) (?:above|below)\b/i.test(q.prompt+' '+q.explanation))reasons.push('Question and explanation must stand alone without unseen examples');
 return reasons;
}
module.exports={hash,clean,publicURL,publicAddress,chunkText,htmlText,topics,validateQuestion};
