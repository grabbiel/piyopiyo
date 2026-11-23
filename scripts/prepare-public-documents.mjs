import {readFile, writeFile} from 'node:fs/promises';

const css=await readFile('docs/website.css','utf8');
const icon=(await readFile('PiyoPiyo/App/Assets.xcassets/AppIcon.appiconset/mac-128@2x.png')).toString('base64');
const header='<a class="skip" href="#main">Skip to content</a><header><a class="brand" href="/">PiyoPiyo</a><nav aria-label="Main navigation"><a href="/support">Support</a><a href="/privacy">Privacy</a></nav></header>';
const footer='<footer><p>© 2026 Francisco Cruzado Arroyo</p><p>Little steps. No ads. No cross-app tracking.</p></footer>';
const pages = {
  '/': (await readFile('docs/home.html','utf8')).replace('{{PIYO_ICON}}','data:image/png;base64,'+icon),
  '/privacy': await readFile('docs/privacy-policy.html', 'utf8'),
  '/support': (await readFile('docs/support.html', 'utf8')).replace('href="privacy-policy.html"', 'href="/privacy"')
};
for(const [path,html] of Object.entries(pages)){
 const body=html.replace(/<style>[\s\S]*?<\/style>/,'').replace('<main>', '<main id="main" class="reading">');
 pages[path]=body.replace(/<main\b/, '<style>'+css+'</style>'+header+'<main').replace('</main>','</main>'+footer);
}
await writeFile('backend/public-documents.json', JSON.stringify(pages, null, 2) + '\n');
