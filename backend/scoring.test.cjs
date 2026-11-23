const {test}=require('node:test');const assert=require('node:assert/strict');const {score,fallback,handler}=require('./index.cjs');
const {gradingRequest,parseGrade}=require('./index.cjs');
test('rubric scoring rejects invented evidence, duplicate criteria and malformed output',()=>{
 const q={prompt:'Explain exclusion',rubric:'One point each. 1. One shared mutex. 2. Lock before reading.'};
 const answer='Use one shared mutex.';
 const checks=[{id:1,met:true,evidence:[1]},{id:2,met:false,evidence:[]}];
 const result=parseGrade(q,answer,JSON.stringify({checks}));
 assert.equal(parseGrade(q,answer,JSON.stringify(checks)).score,3);assert.equal(result.score,3);assert.deepEqual(result.missingConcepts,['Lock before reading.']);
 for(const bad of [[{id:1,met:true,evidence:[2]},checks[1]],[checks[0],checks[0]],[checks[0]],[{id:1,met:'yes',evidence:[1]},checks[1]]])assert.throws(()=>parseGrade(q,answer,JSON.stringify({checks:bad})));
 assert.throws(()=>parseGrade(q,answer,'not JSON'));
 const request=gradingRequest(q,answer,'dedicated-profile');assert.equal(request.inferenceConfig.maxTokens,300);
 assert.throws(()=>gradingRequest({prompt:'x',rubric:'no facts'},answer,'model'));
});
for(const format of ['multiple_choice','true_false','dropdown','visual','drag_drop','audio','game_2d','game_3d','live'])test(`${format}: exact answer, normalization, incorrect input`,()=>{assert.equal(score({format,correct:['A']},[' a ']),1);assert.equal(score({format,correct:['A']},['B']),0);assert.throws(()=>score({format,correct:['A']},[]),/Invalid answer/);});
for(const format of ['matching','categorization','ordering'])test(`${format}: preserves pair/order correspondence`,()=>{assert.equal(score({format,correct:['a','b']},['a','b']),1);assert.equal(score({format,correct:['a','b']},['b','a']),0);});
test('multiple select rejects duplicates and ignores ordering',()=>{const q={format:'multiple_select',correct:['a','b']};assert.equal(score(q,['b','a']),1);assert.equal(score(q,['a','a']),0);assert.equal(score(q,['a']),0);});
test('numeric handles tolerance, blank input and nonfinite input',()=>{const q={format:'numeric',correct:['0'],tolerance:0.1};assert.equal(score(q,['0.05']),1);assert.throws(()=>score(q,['']),/Invalid answer/);for(const a of ['NaN','Infinity','1'])assert.equal(score(q,[a]),0);});
test('fill blank accepts explicitly enumerated synonyms only',()=>{const q={format:'fill_blank',correct:['mutex|lock','thread']};assert.equal(score(q,['Lock','THREAD']),1);assert.equal(score(q,['lock','process']),0);});
for(const format of ['short_answer','homework','collaborative'])test(`${format}: fallback stays provisional and reports missing criteria`,()=>{const r=fallback({format,correct:[],criteria:['majority|quorum','randomized timeout']},['A quorum is needed']);assert.equal(r.score,3);assert.equal(r.status,'pending_review');assert.deepEqual(r.missingConcepts,['randomized timeout']);});
for(const c of require('../tests/fixtures/scoring-parity.json'))test(`parity fixture: ${c.name}`,()=>{
 const grade=()=>['short_answer','homework','collaborative'].includes(c.question.format)?fallback(c.question,c.answer):{score:score(c.question,c.answer)};
 if(c.invalid)return assert.throws(grade,/Invalid answer/);
 const r=grade();assert.equal(r.score,c.score);if(c.missing)assert.deepEqual(r.missingConcepts,c.missing);
});
test('malformed input cannot reach grading',()=>{assert.throws(()=>score({correct:['a']},'a'));assert.throws(()=>score({correct:['a']},['x'.repeat(6001)]));});
test('missing authentication cannot access user progress',async()=>{const r=await handler({rawPath:'/progress'});assert.equal(r.statusCode,401);});

test('saved timestamps reject invalid and future dates but retain offline attempt dates',()=>{
 const {clientTimestamp}=require('./index.cjs');
 assert.equal(clientTimestamp('2026-01-01T10:00:00.123Z'),Date.parse('2026-01-01T10:00:00.123Z'));
 for(const invalid of ['bad',42,'1999-01-01',new Date(Date.now()+600000).toISOString()])assert.throws(()=>clientTimestamp(invalid));
});
test('room question sampling draws distinct questions from the whole pool',()=>{
 const {sample}=require('./index.cjs');const pool=Array.from({length:50},(_,i)=>i);
 const draws=Array.from({length:20},()=>sample(pool,10));
 for(const draw of draws){assert.equal(draw.length,10);assert.equal(new Set(draw).size,10);assert.ok(draw.every(x=>pool.includes(x)));}
 assert.ok(draws.some(draw=>draw.some(x=>x>=10)));assert.deepEqual(sample([1,2],10).sort(),[1,2]);
});
