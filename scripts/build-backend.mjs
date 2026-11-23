import {build} from 'esbuild';
import {mkdir, readFile, writeFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';

await mkdir('artifacts/backend', {recursive:true});
await build({entryPoints:['backend/index.cjs'],bundle:true,platform:'node',target:'node22',format:'cjs',minify:true,legalComments:'eof',define:{'process.env.PIYOPIYO_RELEASE_COMMIT':JSON.stringify(process.env.GITHUB_SHA||'local')},outfile:'artifacts/backend/index.js'});
// Fix timestamps and metadata so identical source/dependencies produce the same archive.
execFileSync('python3',['-c',[
 'import pathlib, zipfile',
 'p=pathlib.Path("artifacts/backend")',
 'info=zipfile.ZipInfo("index.js", (2026,1,1,0,0,0))',
 'info.compress_type=zipfile.ZIP_DEFLATED',
 'info.external_attr=0o100644 << 16',
 'with zipfile.ZipFile(p/"function.zip", "w") as z: z.writestr(info,(p/"index.js").read_bytes())'
].join('\n')]);
const bytes=await readFile('artifacts/backend/function.zip');
const sha256=createHash('sha256').update(bytes).digest('hex');
await writeFile('artifacts/backend/manifest.json',JSON.stringify({sha256,key:`deploy/functions/${sha256}.zip`,bytes:bytes.length},null,2)+'\n');
console.log(`Bundled backend and pinned AWS SDK: ${bytes.length} bytes`);
