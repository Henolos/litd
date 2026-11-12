#!/usr/bin/env node
// Runs on an isolated CI runner. Tests the real exported service worker and PCK,
// independently of WebGL rendering; no user browser/profile is accessed.
'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const fsp = require('node:fs/promises');
const path = require('node:path');
const http = require('node:http');
const crypto = require('node:crypto');
const { chromium } = require(process.env.PWA_PLAYWRIGHT_MODULE || 'playwright');
const [beforeArg, afterArg, outputArg] = process.argv.slice(2);
if (!beforeArg || !afterArg || !outputArg) throw new Error('Usage: baseline-directory candidate-directory evidence-directory');
const dirs = { before: path.resolve(beforeArg), after: path.resolve(afterArg) };
const out = path.resolve(outputArg);
const sha = data => crypto.createHash('sha256').update(data).digest('hex');
let active = 'before';
let browser;
let server;
const report = { status: 'running', baseline_ref: process.env.PWA_BASELINE_REF,
  candidate_ref: process.env.PWA_CANDIDATE_REF, scope: 'exported service-worker cache lifecycle; not WebGL/gameplay', stages: [] };
const html = '<!doctype html><meta charset="utf-8"><title>LITD PWA cache QA</title>' +
  '<style>body{background:#101219;color:#eee;font:18px monospace;padding:30px}pre{white-space:pre-wrap}</style>' +
  '<h1>LITD — PWA cache QA (isolated CI)</h1><p>Real exported worker / real PCK. No manual cache clearing.</p><pre id="result">Starting</pre>';
async function poll(fn, message, timeout = 45000) {
  const until = Date.now() + timeout;
  while (Date.now() < until) {
    const value = await fn();
    if (value) return value;
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  throw new Error(message);
}
async function cachedPacks(page) {
  return page.evaluate(async () => {
    const output = [];
    for (const name of await caches.keys()) {
      const cache = await caches.open(name);
      const response = await cache.match('/game/index.pck');
      let hash = null;
      if (response) hash = Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256', await response.arrayBuffer())))
        .map(x => x.toString(16).padStart(2, '0')).join('');
      output.push({ name, pck_sha256: hash });
    }
    return output;
  });
}
async function fetchPack(page) {
  return page.evaluate(async () => {
    if (!navigator.serviceWorker.controller) throw new Error('PCK request is not controlled by a service worker');
    const response = await fetch('/game/index.pck');
    if (!response.ok) throw new Error('PCK fetch failed: ' + response.status);
    return Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256', await response.arrayBuffer())))
      .map(x => x.toString(16).padStart(2, '0')).join('');
  });
}
async function record(control, name, observations) {
  report.stages.push({ name, ...observations });
  await control.locator('#result').evaluate((element, data) => { element.textContent = JSON.stringify(data, null, 2); }, report);
  await control.screenshot({ path: path.join(out, name + '.png'), fullPage: true });
}
(async () => {
  await fsp.mkdir(out, { recursive: true });
  report.expected = {};
  for (const [key, dir] of Object.entries(dirs)) {
    for (const file of ['index.pck', 'index.service.worker.js', 'index.html', 'index.wasm'])
      assert.ok(fs.statSync(path.join(dir, file)).size > 0, key + ': missing ' + file);
    report.expected[key] = {
      pck_sha256: sha(await fsp.readFile(path.join(dir, 'index.pck'))),
      worker_sha256: sha(await fsp.readFile(path.join(dir, 'index.service.worker.js')))
    };
  }
  if (report.expected.before.pck_sha256 === report.expected.after.pck_sha256) {
    report.status = 'not_applicable';
    report.reason = 'identical PCKs; no package update to validate';
    console.log('PWA_CACHE_UPDATE_SKIPPED identical_pck');
    return;
  }
  assert.notEqual(report.expected.before.worker_sha256, report.expected.after.worker_sha256, 'Worker bytes must change to signal an update');
  server = http.createServer((req, res) => {
    const pathname = new URL(req.url, 'http://localhost').pathname;
    res.setHeader('Cache-Control', 'no-cache');
    if (pathname === '/control.html' || pathname === '/game/probe.html') {
      res.setHeader('Content-Type', 'text/html; charset=utf-8'); res.end(html); return;
    }
    if (!pathname.startsWith('/game/')) { res.writeHead(404); res.end(); return; }
    const file = path.resolve(dirs[active], pathname.slice('/game/'.length));
    if (!file.startsWith(dirs[active] + path.sep) || !fs.existsSync(file) || !fs.statSync(file).isFile()) {
      res.writeHead(404); res.end(); return;
    }
    const mime = { '.js': 'application/javascript', '.html': 'text/html', '.wasm': 'application/wasm', '.json': 'application/json', '.png': 'image/png' };
    res.setHeader('Content-Type', mime[path.extname(file)] || 'application/octet-stream');
    res.setHeader('Content-Length', fs.statSync(file).size);
    fs.createReadStream(file).on('error', () => res.destroy()).pipe(res);
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const origin = 'http://127.0.0.1:' + server.address().port;
  report.origin = origin;
  browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ serviceWorkers: 'allow', viewport: { width: 1280, height: 960 } });
  const control = await context.newPage(); // outside /game/ worker scope
  await control.goto(origin + '/control.html');
  await control.evaluate(async () => { await navigator.serviceWorker.register('/game/index.service.worker.js', { updateViaCache: 'none' }); });
  await control.waitForFunction(async () => (await navigator.serviceWorker.getRegistration('/game/'))?.active?.state === 'activated');
  let client = await context.newPage();
  await client.goto(origin + '/game/probe.html');
  await client.waitForFunction(() => !!navigator.serviceWorker.controller);
  await client.evaluate(() => localStorage.setItem('pwa_qa_sentinel', 'kept'));
  assert.equal(await fetchPack(client), report.expected.before.pck_sha256, 'First client must receive baseline PCK');
  const firstCaches = await poll(async () => {
    const values = await cachedPacks(control);
    return values.some(x => x.pck_sha256 === report.expected.before.pck_sha256) && values;
  }, 'Baseline PCK was not cached');
  await record(control, '01-baseline-cached', { caches: firstCaches });
  active = 'after'; // same origin, same browser context, same controlled client
  await control.evaluate(async () => { const r = await navigator.serviceWorker.getRegistration('/game/'); await r.update(); });
  await control.waitForFunction(async () => !!(await navigator.serviceWorker.getRegistration('/game/'))?.waiting);
  assert.equal(await fetchPack(client), report.expected.before.pck_sha256, 'Old controlled tab must retain its coherent old package until activation');
  await record(control, '02-update-waiting', { old_client_pck: report.expected.before.pck_sha256, caches: await cachedPacks(control) });
  await client.close(); // normal SW lifecycle: release all clients of /game/
  await control.waitForFunction(async () => {
    const r = await navigator.serviceWorker.getRegistration('/game/');
    return r && !r.waiting && r.active?.state === 'activated';
  });
  client = await context.newPage();
  await client.goto(origin + '/game/probe.html');
  await client.waitForFunction(() => !!navigator.serviceWorker.controller);
  assert.equal(await fetchPack(client), report.expected.after.pck_sha256, 'Reopened client must receive the candidate PCK');
  assert.equal(await client.evaluate(() => localStorage.getItem('pwa_qa_sentinel')), 'kept', 'Origin storage sentinel must survive');
  const finalCaches = await poll(async () => {
    const values = await cachedPacks(control);
    return values.some(x => x.pck_sha256 === report.expected.after.pck_sha256) &&
      !values.some(x => x.pck_sha256 === report.expected.before.pck_sha256) && values;
  }, 'Candidate cache was not populated or old PCK cache survived activation');
  report.status = 'passed';
  await record(control, '03-candidate-cached', { caches: finalCaches, origin_storage_sentinel: 'kept' });
  console.log('PWA_CACHE_UPDATE_OK baseline=' + report.expected.before.pck_sha256 + ' candidate=' + report.expected.after.pck_sha256);
})().catch(error => {
  report.status = 'failed'; report.error = error.stack; console.error(error); process.exitCode = 1;
}).finally(async () => {
  await fsp.mkdir(out, { recursive: true });
  await fsp.writeFile(path.join(out, 'result.json'), JSON.stringify(report, null, 2) + '\n');
  if (browser) await browser.close();
  if (server) await new Promise(resolve => server.close(resolve));
});
