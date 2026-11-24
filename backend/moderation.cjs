'use strict';
const {createHash}=require('node:crypto');
const reasons=new Set(['harassment','inappropriate_content','spam','other']);
function displayName(value){
 if(value===undefined||value==='')return 'Learner';
 if(typeof value!=='string')throw Error('Choose a different display name.');
 const text=value.normalize('NFKC').trim();
 const filtered=text.toLowerCase().replace(/[013457@$]/g,c=>({'0':'o','1':'i','3':'e','4':'a','5':'s','7':'t','@':'a','$':'s'}[c]));
 if(!text||text.length>30||/[\p{Cc}\p{Cf}]/u.test(text)||/https?:|www\.|@/.test(text)||/\b(fuck\w*|shit\w*|bitch\w*|cunt\w*|nigg\w*|fagg\w*|porn\w*|puta\w*|mierda\w*|cabron\w*)\b/i.test(filtered))throw Error('Choose a different display name. Keep study rooms respectful.');
 return text;
}
function roomAnswer(question,text){
 let values;try{values=JSON.parse(text);}catch{throw Error('Choose one of this question’s answers.');}
 if(!question||question.retired||question.format!=='multiple_choice'||!Array.isArray(values)||values.length!==1||!question.options.includes(values[0]))throw Error('Choose one of this question’s answers.');
 return values;
}
function reportId(reporter,room,target){return createHash('sha256').update(JSON.stringify([reporter,room,target])).digest('hex').slice(0,40);}
module.exports={displayName,roomAnswer,reportId,reasons};
