import {chromium} from 'playwright';
import fs from 'node:fs/promises';import {createHash} from 'node:crypto';
const browser=await chromium.launch({headless:true});
const pages=[['naver','https://www.naver.com','compact information hierarchy'],['duolingo','https://www.duolingo.com','friendly progress and raised buttons'],['rosetta','https://www.rosettastone.com','clear learning paths'],['notion','https://www.notion.com','quiet typography and navigation'],['canva','https://www.canva.com','generous cards'],['kahoot','https://kahoot.com','readable quiz choices']];
const ledger=[];
for(const [id,url,use] of pages){
 const entry={id:`visual-${id}`,url,accessedAt:new Date().toISOString(),kind:'visual_reference',intendedUse:use,redistributable:false,releaseInclusion:'none'};
 const page=await browser.newPage({viewport:{width:1440,height:900}});
 try{await page.goto(url,{waitUntil:'domcontentloaded',timeout:25000});await page.screenshot({path:`references/${id}.png`,fullPage:true,timeout:15000});entry.sha256=createHash('sha256').update(await fs.readFile(`references/${id}.png`)).digest('hex');entry.styles=await page.evaluate(()=>{const s=getComputedStyle(document.body);return {font:s.fontFamily,color:s.color,background:s.backgroundColor}});entry.status='captured';}catch(e){entry.status='unavailable';entry.error=e.message.slice(0,300);}
 ledger.push(entry);await page.close();console.log(id,entry.status);
}
await browser.close();
await fs.writeFile('references/visual-ledger.json',JSON.stringify(ledger,null,2));
await fs.writeFile('references/sources.csv','url,access_timestamp,intended_use,status\n'+ledger.map(x=>[x.url,x.accessedAt,x.intendedUse,x.status].map(s=>JSON.stringify(s)).join(',')).join('\n')+'\n');
