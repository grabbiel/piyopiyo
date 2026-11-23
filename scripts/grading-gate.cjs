'use strict';
const fs=require('node:fs');
const {createHash}=require('node:crypto');
const assert=require('node:assert/strict');
const sha256=value=>createHash('sha256').update(value).digest('hex');
function promptFingerprint(){
 const grading=require('../backend/index.cjs');
 return sha256(grading.answerSegments.toString()+grading.gradingRequest.toString()+grading.parseGrade.toString());
}
function verifyGradingRelease(){
 const approval=JSON.parse(fs.readFileSync('backend/grading-release.json'));
 if(approval.enabled!==true)return {enabled:false,reason:approval.reason};
 const rawReport=fs.readFileSync('tests/grading-human-results.json');
 const rawReview=fs.readFileSync('tests/grading-human-review.json');
 const rawDataset=fs.readFileSync('tests/grading-heldout.json');
 const report=JSON.parse(rawReport),review=JSON.parse(rawReview),dataset=JSON.parse(rawDataset);
 const attestation=JSON.parse(fs.readFileSync('tests/grading-human-attestation.json'));
 assert.equal(approval.reportSHA256,sha256(rawReport),'Grading report changed after approval');
 assert.equal(attestation.reviewSHA256,sha256(rawReview),'Human review does not match owner confirmation');
 assert.equal(attestation.confirmation,'I reviewed all 50 scores');
 assert.equal(review.datasetSHA256,sha256(rawDataset),'Reviewed answers changed');
 assert.equal(report.reviewMetadata?.datasetSHA256,review.datasetSHA256);
 assert.equal(report.reviewMetadata?.reviewer,review.reviewer);
 assert.equal(report.promptSHA256,promptFingerprint(),'Grader changed after benchmark');
 assert.equal(report.modelFamily,approval.modelFamily,'Model configuration changed after benchmark');
 assert.equal(approval.modelFamily,'haiku45','Runtime model family must match approved infrastructure');
 assert.ok(review.reviewer&&review.completedAt);
 assert.equal(dataset.length,50);assert.equal(new Set(dataset.map(c=>c.id)).size,50);
 assert.equal(review.cases.length,50);assert.equal(new Set(review.cases.map(c=>c.id)).size,50);
 const expected=new Map(review.cases.map(c=>[c.id,c.score]));
 const selected=report.models.find(m=>m.modelId===approval.modelId);
 assert.ok(selected,'Approved model is absent from the benchmark');
 assert.match(selected.modelId,/^arn:aws:bedrock:us-east-1:992680757326:application-inference-profile\//);
 assert.equal(selected.cases.length,50);assert.equal(new Set(selected.cases.map(c=>c.id)).size,50);
 let agreement=0;
 for(const item of dataset){
  const result=selected.cases.find(c=>c.id===item.id),score=expected.get(item.id);
  assert.ok(Number.isInteger(score)&&score>=0&&score<=5);
  assert.ok(result&&!result.error);
  assert.equal(result.expected,score);
  assert.ok(Number.isInteger(result.actual)&&result.actual>=0&&result.actual<=5);
  assert.ok(Number.isFinite(result.latencyMs)&&result.latencyMs>0);
  if(result.actual===score)agreement++;
 }
 const latencies=selected.cases.map(c=>c.latencyMs).sort((a,b)=>a-b);
 assert.ok(agreement>=45,'Human grade agreement is below 90%');
 assert.ok(latencies[47]<3000,'Grading p95 exceeds 3 seconds');
 return {...approval,agreement,p95LatencyMs:latencies[47]};
}
module.exports={sha256,promptFingerprint,verifyGradingRelease};
if(require.main===module)console.log(JSON.stringify(verifyGradingRelease(),null,2));
