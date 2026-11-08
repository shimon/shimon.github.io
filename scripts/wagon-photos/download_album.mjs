#!/usr/bin/env node
/** Download the shared album through Google Photos' public UI.
 * Private configuration is read from stdin, never stored in this repository:
 * {"album_url":"<private shared album URL>","archive":"/private/album.zip"}
 * No login automation, tokens, private APIs, or guessed media URLs.
 */
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import { chromium } from 'playwright';
let input='';
for await (const chunk of process.stdin) input += chunk;
const config=JSON.parse(input);
const url=new URL(config.album_url);
if(url.protocol!=='https:' || !['photos.app.goo.gl','photos.google.com'].includes(url.hostname)) throw new Error('Expected an HTTPS Google Photos shared album URL');
const repo=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../..');
const target=path.resolve(config.archive);
if(!path.isAbsolute(config.archive) || target===repo || target.startsWith(repo+path.sep)) throw new Error('Archive destination must be absolute and outside this repository');
try { await fs.access(target); throw new Error('Destination already exists; choose a new private path'); }
catch(error) { if(error.code!=='ENOENT') throw error; }
const browser=await chromium.launch({headless:config.headless!==false});
try {
 const context=await browser.newContext({acceptDownloads:true});
 const page=await context.newPage();
 await page.goto(url.href,{waitUntil:'domcontentloaded',timeout:60000});
 // Deliberately fail if Google requires authentication or changes its public UI.
 await page.getByRole('button',{name:'More options',exact:true}).click({timeout:30000});
 const pending=page.waitForEvent('download',{timeout:180000});
 await page.getByRole('menuitem',{name:'Download all',exact:true}).click({timeout:30000});
 const download=await pending;
 const failure=await download.failure();
 if(failure) throw new Error('Google Photos reported a failed download');
 await fs.mkdir(path.dirname(target),{recursive:true});
 await download.saveAs(target);
 const data=await fs.readFile(target);
 if(data[0]!==0x50 || data[1]!==0x4b) throw new Error('Downloaded file is not a ZIP');
 const sha=createHash('sha256').update(data).digest('hex');
 console.log(JSON.stringify({archive:target,bytes:data.length,sha256:sha}));
} finally { await browser.close(); }
