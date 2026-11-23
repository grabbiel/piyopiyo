import {build} from 'esbuild';
import {mkdir,readFile,writeFile,copyFile,rm} from 'node:fs/promises';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
const manifest={};
for(const name of ['api','worker','pdf']){
 const dir=`artifacts/knowledge/${name}`;await rm(dir,{recursive:true,force:true});await mkdir(dir,{recursive:true});
 if(name==='pdf'){
  execFileSync(process.env.PIYOPIYO_PYTHON||'python3',['-m','pip','install','--quiet','--upgrade','--target',dir,'--no-deps','pypdf==7.1.1'],{stdio:'inherit'});
  await copyFile('backend/pdf/index.py',dir+'/index.py');
 }else await build({entryPoints:[`backend/knowledge/${name}.cjs`],bundle:true,platform:'node',target:'node22',format:'cjs',minify:true,legalComments:'eof',outfile:dir+'/index.js'});
 execFileSync('python3',['-c',`import pathlib,zipfile
p=pathlib.Path(${JSON.stringify(dir)})
with zipfile.ZipFile(p.parent/${JSON.stringify(name+'.zip')},'w') as z:
 for f in sorted(p.rglob('*')):
  if not f.is_file() or '__pycache__' in f.parts or f.suffix=='.pyc': continue
  i=zipfile.ZipInfo(str(f.relative_to(p)),(2026,1,1,0,0,0));i.compress_type=zipfile.ZIP_DEFLATED;i.external_attr=0o100644<<16
  z.writestr(i,f.read_bytes())`]);
 const path=`artifacts/knowledge/${name}.zip`,bytes=await readFile(path),sha256=createHash('sha256').update(bytes).digest('hex');
 manifest[name]={path,sha256,key:`deploy/functions/${sha256}.zip`,bytes:bytes.length};
}
await writeFile('artifacts/knowledge/manifest.json',JSON.stringify(manifest,null,2)+'\n');
console.log('Built three knowledge pipeline artifacts.');
