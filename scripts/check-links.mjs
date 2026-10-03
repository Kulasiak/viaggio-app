// Verifica che tutti i link ufficiali (data/*.json) rispondano.
import fs from 'node:fs';
const files = ['cities.json', 'transport-products.json', 'museums.json'];
const urls = new Set(['https://www.trenitalia.com', 'https://www.italotreno.com/en']);
for (const f of files) {
  const d = JSON.parse(fs.readFileSync(new URL('../data/' + f, import.meta.url)));
  for (const r of d) for (const k of ['official_url', 'transit_url']) if (r[k]) urls.add(r[k]);
}
let bad = 0;
for (const u of urls) {
  try {
    const res = await fetch(u, { method: 'GET', redirect: 'follow', signal: AbortSignal.timeout(15000), headers: { 'user-agent': 'Mozilla/5.0 viaggio-link-check' } });
    const ok = res.status < 400;
    if (!ok) bad++;
    console.log(`${ok ? 'OK ' : 'ERR'} ${res.status} ${u}`);
  } catch (e) { bad++; console.log(`ERR --- ${u} (${e.name})`); }
}
console.log(`${urls.size - bad}/${urls.size} link funzionanti`);
process.exit(bad ? 1 : 0);
