# Viaggio & Custode

App di viaggio per gruppi e turisti in Italia, creata da Kiko (Ahcene Zenati).

Questo repository contiene il **prototipo di design** (fatto in Claude Design) e tutto il materiale per trasformarlo in un'app vera con **Claude Code**.

## Cosa c'è dentro

| Cartella | Contenuto |
|---|---|
| `design/` | I prototipi interattivi: `Viaggio-v2.dc.html` (app principale), `Custode.dc.html`, `Viaggio-v1.dc.html` (vecchia versione), `support.js` (runtime del prototipo) |
| `docs/SPEC.md` | Tutte le funzioni dell'app, schermata per schermata |
| `docs/DATABASE.md` | Il database spiegato tabella per tabella |
| `docs/TEST-PLAN.md` | Il "controllo perfetto": tutti i test da superare prima del lancio |
| `supabase/migrations/` | Lo schema SQL del database (bozza pronta da applicare) |
| `i18n/` | Tutti i testi dell'app in FR, EN, PL, ES, RO (Viaggio) e IT, EN, PL, ES, FR, RO (Custode) |
| `data/` | Città, trasporti, musei, luoghi del programma automatico, valute, link ufficiali |
| `scripts/` | Controlli automatici: traduzioni complete, link ufficiali funzionanti |
| `CLAUDE.md` | Le istruzioni per Claude Code |

## Come continuare con Claude Code

1. Apri questo repository in Claude Code.
2. Scrivi: **"Leggi CLAUDE.md e costruisci l'app seguendo il piano, fase per fase."**
3. Claude Code legge lo spec, crea il database, costruisce l'app e la verifica con il piano di test.

## Stack scelto

- **App**: Expo (React Native + TypeScript) — una sola base di codice per iPhone, Android e web.
- **Database e login**: Supabase (PostgreSQL, Auth, Storage, Row Level Security, Edge Functions).
- **Test**: Vitest (logica), Playwright (web), Maestro (mobile), controlli SQL per la sicurezza.

## Stato attuale

Il prototipo funziona nel canvas di Claude Design. Prezzi, orari dei treni e tempi di spostamento sono **indicativi**; l'acquisto dei biglietti avviene sui **siti ufficiali** degli operatori (link in `data/`).
