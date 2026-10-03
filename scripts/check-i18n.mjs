// Verifica che ogni lingua abbia tutte le chiavi e nessun valore vuoto.
import fs from 'node:fs';
let errors = 0;
for (const file of ['i18n/viaggio.json', 'i18n/custode.json']) {
  const data = JSON.parse(fs.readFileSync(new URL('../' + file, import.meta.url)));
  const langs = Object.keys(data);
  const keys = new Set(langs.flatMap(l => Object.keys(data[l])));
  for (const l of langs) for (const k of keys) {
    if (!(k in data[l])) { console.error(`${file} [${l}] chiave mancante: ${k}`); errors++; }
    else if (typeof data[l][k] === 'string' && !data[l][k].trim()) { console.error(`${file} [${l}] valore vuoto: ${k}`); errors++; }
  }
  console.log(`${file}: ${langs.join(', ')} · ${keys.size} chiavi`);
}
if (errors) { console.error(`${errors} problemi`); process.exit(1); } else console.log('OK: traduzioni complete');
