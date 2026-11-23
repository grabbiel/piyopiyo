const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const os=require('node:os');
const path=require('node:path');
const {spawnSync}=require('node:child_process');
const {sha256}=require('../scripts/grading-gate.cjs');
const gate=path.resolve('scripts/grading-gate.cjs');

function verifyFixture(change){
 const dir=fs.mkdtempSync(path.join(os.tmpdir(),'piyopiyo-grading-gate-'));
 try{
  for(const file of ['backend/grading-release.json','tests/grading-human-results.json','tests/grading-human-review.json','tests/grading-human-attestation.json','tests/grading-heldout.json']){
   fs.mkdirSync(path.dirname(path.join(dir,file)),{recursive:true});
   fs.copyFileSync(file,path.join(dir,file));
  }
  const edit=(file,mutate)=>{const target=path.join(dir,file),data=JSON.parse(fs.readFileSync(target));mutate(data);fs.writeFileSync(target,JSON.stringify(data));};
  const refreshReportHash=()=>edit('backend/grading-release.json',a=>{a.reportSHA256=sha256(fs.readFileSync(path.join(dir,'tests/grading-human-results.json')));});
  change?.(edit,refreshReportHash);
  return spawnSync(process.execPath,[gate],{cwd:dir,encoding:'utf8'});
 }finally{fs.rmSync(dir,{recursive:true,force:true});}
}

test('approved owner-reviewed grading evidence passes',()=>assert.equal(verifyFixture().status,0));
test('changing the benchmark invalidates approval',()=>{
 const r=verifyFixture(edit=>edit('tests/grading-human-results.json',r=>{r.createdAt='changed';}));
 assert.notEqual(r.status,0);assert.match(r.stderr,/report changed/);
});
test('changing human scores invalidates the owner attestation',()=>{
 const r=verifyFixture(edit=>edit('tests/grading-human-review.json',r=>{r.cases[0].score=(r.cases[0].score+1)%6;}));
 assert.notEqual(r.status,0);assert.match(r.stderr,/owner confirmation/);
});
test('a stale grader fingerprint cannot enable grading',()=>{
 const r=verifyFixture((edit,hash)=>{edit('tests/grading-human-results.json',r=>{r.promptSHA256='stale';});hash();});
 assert.notEqual(r.status,0);assert.match(r.stderr,/Grader changed/);
});
test('the gate recalculates accuracy instead of trusting the summary',()=>{
 const r=verifyFixture((edit,hash)=>{edit('tests/grading-human-results.json',r=>{for(const c of r.models[0].cases)c.actual=(c.expected+1)%6;r.models[0].exactAgreement=1;});hash();});
 assert.notEqual(r.status,0);assert.match(r.stderr,/below 90%/);
});
test('the gate recalculates latency instead of trusting the summary',()=>{
 const r=verifyFixture((edit,hash)=>{edit('tests/grading-human-results.json',r=>{for(const c of r.models[0].cases)c.latencyMs=4000;r.models[0].p95LatencyMs=1;});hash();});
 assert.notEqual(r.status,0);assert.match(r.stderr,/exceeds 3 seconds/);
});
