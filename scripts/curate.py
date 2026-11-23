"""Acquire public reference material; never bundle raw sources in the app."""
import hashlib,json,subprocess,urllib.request,urllib.robotparser,urllib.parse,re
from pathlib import Path
from datetime import datetime,timezone
import trafilatura,ssl,certifi
ROOT=Path(__file__).resolve().parents[1];raw=ROOT/'content/raw';raw.mkdir(parents=True,exist_ok=True)
sources=[
 ('mit-syllabus','MIT 6.006 syllabus','Algorithms','https://ocw.mit.edu/courses/6-006-introduction-to-algorithms-spring-2020/pages/syllabus/'),
 ('mit-algorithms','MIT 6.006 course review','Algorithms','https://ocw.mit.edu/courses/6-006-introduction-to-algorithms-spring-2020/aa4f264093faf990054cc4820553bb46_MIT6_006S20_lec20.pdf'),
 ('cmu-syllabus','CMU 15-440 Distributed Systems','Distributed systems','https://courseweb.sp.cs.cmu.edu/15-440/fall-2026/syllabus/'),
 ('raft','In Search of an Understandable Consensus Algorithm','Distributed systems','https://raft.github.io/raft.pdf'),
 ('ostep','OSTEP: Concurrency introduction','Operating systems','https://pages.cs.wisc.edu/~remzi/OSTEP/threads-intro.pdf'),
 ('postgres','PostgreSQL transaction isolation','Databases','https://www.postgresql.org/docs/current/transaction-iso.html'),
 ('python','Python data structures','Programming','https://docs.python.org/3/tutorial/datastructures.html'),
 ('acm-news','ACM TechNews','Research','https://technews.acm.org/'),
 ('acm-queue','ACM Queue','Software engineering','https://queue.acm.org/'),
 ('cacm','Communications of the ACM','Research','https://cacm.acm.org/'),
 ('books-index','Community textbook discovery index','Discovery','https://github.com/namelessandgood/Books'),
 ('show-hn','Show Hacker News','Discovery','https://news.ycombinator.com/show')]
ledger=[];chunks=[];seeds=[]
for sid,title,topic,url in sources:
 entry={'id':sid,'title':title,'url':url,'accessedAt':datetime.now(timezone.utc).isoformat(),'kind':'academic' if sid in ['mit-syllabus','mit-algorithms','cmu-syllabus','raft','ostep'] else 'reference','topic':topic,'retrievalMethod':'public_https','redistributable':False,'releaseInclusion':'citation_only'}
 try:
  request=urllib.request.Request(url,headers={'User-Agent':'PiyoPiyo research prototype; personal educational use'})
  with urllib.request.urlopen(request,timeout=25,context=ssl.create_default_context(cafile=certifi.where())) as response:data=response.read();entry['resolvedURL']=response.url
  sha=hashlib.sha256(data).hexdigest();entry['sha256']=sha;entry['status']='acquired'
  suffix='.pdf' if data.startswith(b'%PDF') else '.html';path=raw/(sha+suffix);path.write_bytes(data)
  if suffix=='.pdf':
   text=subprocess.run(['pdftotext','-layout',str(path),'-'],capture_output=True,text=True,check=True).stdout
   pages=text.split('\f')
  else: pages=[trafilatura.extract(data.decode('utf8',errors='replace'),include_links=False) or '']
  if topic!='Discovery':
   for page_no,page in enumerate(pages,1):
    # 560 words approximates 700-850 tokens; stride preserves 12.5% overlap.
    words=page.split()
    for start in range(0,len(words),490):
     excerpt=' '.join(words[start:start+560]);digest=hashlib.sha256(excerpt.encode()).hexdigest()
     if len(excerpt)<100:continue
     chunk={'id':digest,'sourceId':sid,'topic':topic,'page':page_no,'heading':page.strip().split('\n')[0][:160],'text':excerpt}
     chunks.append(chunk);seeds.append({'seed_id':'sha256:'+digest,'source_url':url,'source_title':title,'topic':topic,'concept':chunk['heading'],'difficulty':'medium','candidate_formats':['multiple_choice','short_answer','ordering'],'source_excerpt_hash':'sha256:'+digest,'page':page_no,'reviewStatus':'needs_editorial_review'})
  subprocess.run([str(ROOT/'scripts/aws.sh'),'s3','cp',str(path),'s3://piyopiyo-question-banks/raw-sources/'+path.name,'--only-show-errors'],check=True)
 except Exception as e:entry.update(status='unavailable',error=str(e))
 ledger.append(entry)
 print(sid,entry['status'],flush=True)
 with (ROOT/'.agent/build-log.md').open('a') as f:f.write(f"\n- {entry['accessedAt']} source {sid}: {entry['status']}; {url}; SHA-256 {entry.get('sha256','unavailable')}.\n")
(ROOT/'provenance.json').write_text(json.dumps(ledger,indent=2)+'\n')
(ROOT/'content/chunks.json').write_text(json.dumps(chunks,indent=2)+'\n')
(ROOT/'content/seeds.json').write_text(json.dumps(seeds,indent=2)+'\n')
print('chunks',len(chunks),'seeds',len(seeds))
