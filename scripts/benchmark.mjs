import {BedrockRuntimeClient,ConverseCommand} from '@aws-sdk/client-bedrock-runtime';
import {readFile,writeFile} from 'node:fs/promises';
import grading from '../backend/index.cjs';
import {createHash} from 'node:crypto';
import {promptFingerprint} from './grading-gate.cjs';
const client=new BedrockRuntimeClient({region:'us-east-1',maxAttempts:2});
let cases=JSON.parse(await readFile('tests/grading-cases.json','utf8'));
let labelSource='Agent-authored calibration; NOT human-scored release evidence';
let reviewMetadata;
if(process.argv.includes('--human')){
 const raw=await readFile('tests/grading-heldout.json','utf8');const heldout=JSON.parse(raw);
 const review=JSON.parse(await readFile('tests/grading-human-review.json','utf8'));
 const hash=createHash('sha256').update(raw).digest('hex');
 if(review.datasetSHA256!==hash||!review.reviewer||!review.completedAt||review.cases.length!==50||new Set(review.cases.map(c=>c.id)).size!==50||review.cases.some(c=>!Number.isInteger(c.score)||c.score<0||c.score>5))throw new Error('Incomplete or mismatched human review');
 const scores=new Map(review.cases.map(c=>[c.id,c.score]));
 cases=heldout.map(c=>({...c,expectedScore:scores.get(c.id)}));
 if(cases.some(c=>c.expectedScore===undefined))throw new Error('Missing human scores');
 labelSource='Owner-supplied scores; owner explicitly confirmed reviewing all 50 in conversation';
 reviewMetadata={reviewer:review.reviewer,datasetSHA256:hash,submittedCompletedAt:review.completedAt};
}
const promptSHA256=promptFingerprint();
// Re-runs use app-exclusive profiles so costs remain attributable. The first
// discovery run's candidate denials are preserved in grading-results.json.
const stack=JSON.parse(await readFile('.agent/stack.json','utf8'));
const nova=stack.Stacks[0].Outputs.find(x=>x.OutputKey==='GradingProfileArn')?.OutputValue;
if(!nova)throw new Error('Run scripts/configure-client.py after deploying the grading profile.');
const models=[process.env.PIYOPIYO_MODEL_PROFILE||process.env.PIYOPIYO_NOVA_PROFILE||nova,process.env.PIYOPIYO_HAIKU_PROFILE,process.env.PIYOPIYO_LLAMA_PROFILE].filter(Boolean);
const modelFamily=process.env.PIYOPIYO_MODEL_FAMILY||'nova';
const results={modelFamily,createdAt:new Date().toISOString(),labelSource,reviewMetadata,promptSHA256,models:[]};
for(const modelId of models){
 const model={modelId,cases:[],inputTokens:0,outputTokens:0};results.models.push(model);
 for(const item of cases){
  const start=Date.now();
  try{
   const question={prompt:item.question,rubric:item.rubric};
   const r=await client.send(new ConverseCommand(grading.gradingRequest(question,item.answer,modelId,modelFamily)),{abortSignal:AbortSignal.timeout(8000)});
   const raw=r.output.message.content.find(c=>c.text)?.text||'';const value=grading.parseGrade(question,item.answer,raw);
   model.cases.push({id:item.id,expected:item.expectedScore,actual:value.score,assessment:raw,missingConcepts:value.missingConcepts,agreement:value.score===item.expectedScore,latencyMs:Date.now()-start});model.inputTokens+=r.usage?.inputTokens||0;model.outputTokens+=r.usage?.outputTokens||0;
  }catch(e){model.cases.push({id:item.id,error:e.name,message:e.message,latencyMs:Date.now()-start});if(['AccessDeniedException','ValidationException','ResourceNotFoundException'].includes(e.name)){model.unavailable=true;break;}}
  if(model.cases.length%10===0)console.log(modelId,model.cases.length,'cases');
 }
 const latencies=model.cases.map(c=>c.latencyMs).sort((a,b)=>a-b);model.exactAgreement=model.cases.filter(c=>c.agreement).length/cases.length;model.p95LatencyMs=latencies[Math.ceil(latencies.length*.95)-1];
 model.releaseThresholdPassed=model.cases.length===50&&model.exactAgreement>=.9&&model.p95LatencyMs<3000&&!model.cases.some(c=>c.error);
 await writeFile(process.env.PIYOPIYO_BENCHMARK_OUTPUT||(process.argv.includes('--human')?'tests/grading-human-results.json':'tests/grading-results.json'),JSON.stringify(results,null,2)+'\n');console.log(modelId,'agreement',model.exactAgreement,'p95',model.p95LatencyMs,'unavailable',!!model.unavailable);
}

client.destroy();
