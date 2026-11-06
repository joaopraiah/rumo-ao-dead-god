// Gera index.html (artifact claude.ai) e docs/index.html (GitHub Pages) a partir de template.html + data/
const fs=require('fs'),p=f=>__dirname+'/'+f;
const body=fs.readFileSync(p('template.html'),'utf8')
  .replace('__ACH__',fs.readFileSync(p('data/achievements.json'),'utf8'))
  .replace('__SAMPLE__',fs.readFileSync(p('data/sample.json'),'utf8'))
  .replace('__STEAMMAP__',fs.readFileSync(p('data/steammap.json'),'utf8'));
fs.writeFileSync(p('index.html'),body);
const full=`<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<style>body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style>
</head><body>
${body}
</body></html>
`;
fs.writeFileSync(p('docs/index.html'),full);
console.log('ok',body.length);
