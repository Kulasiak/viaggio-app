# Database (Supabase / PostgreSQL)

Schema: `supabase/migrations/0001_init.sql`. Seed: `data/*.json`.

## Dati di riferimento (pubblici)
| Tabella | Cosa contiene |
|---|---|
| `cities` | 8 città con nome in 5 lingue, operatore dei trasporti e sito ufficiale |
| `pois` | Luoghi e musei: categoria, durata, prezzo, orari, link ufficiale (base del programma automatico) |
| `transport_products` | Biglietti bus/metro/navette per città, con link ufficiale |
| `currencies` | Cambi verso l'euro (da aggiornare ogni giorno con una Edge Function) |

## Persone e gruppi
| Tabella | Cosa contiene |
|---|---|
| `profiles` | Utente: nome, lingua, valuta |
| `agencies` | Agenzie clienti del capogruppo |
| `trips` | Il viaggio/gruppo: guida, agenzia o privato, codice invito, date, stato |
| `trip_members` | Chi è nel gruppo, ruolo, presenza, ultima posizione nota |
| `consents` | I 3 consensi separati per viaggio |

## Programma
| Tabella | Cosa contiene |
|---|---|
| `programmes` | Programma (anche modelli): parametri del generatore, costo a persona, stato bozza/approvato |
| `programme_items` | Ogni tappa: giorno, orario, tipo (luogo, pasto, treno…), spostamento, prezzo, punto d'incontro |
| `meeting_replies` | Risposte "arrivo / in ritardo" |

## Comunicazione
`messages` (gruppo o privato, prioritari, fissati), `message_reads` (conferme di lettura), `votes` / `vote_options` / `vote_ballots`.

## Sicurezza e dati sensibili
| Tabella | Regola |
|---|---|
| `sos_alerts` | La guida del viaggio li vede tutti |
| `location_pings` | Conservazione breve; la guida vede solo se il consenso lo permette (sempre in SOS) |
| `health_cards` | Cifrate lato client; la guida legge solo se `health_shared = true` |
| `documents` | Solo il proprietario. **La guida non li vede mai** |
| `tickets`, `taxfree_receipts` | Solo il proprietario |

## Regole fondamentali (Row Level Security)
1. Un turista vede solo il proprio gruppo.
2. I viaggiatori vedono il programma **solo dopo che il capogruppo lo approva**.
3. Documenti, biglietti e Tax Free: solo il proprietario.
4. Dati salute: solo con consenso esplicito, solo alla guida del proprio gruppo.
5. Posizione: secondo il consenso; sempre durante SOS.

## Lavori automatici (Edge Functions / cron)
- `generate-programme`: porta qui l'algoritmo `planVals()` del prototipo.
- `programme-pdf`: preventivo agenzia / PDF cliente.
- `notify`: push per messaggi prioritari, promemoria appuntamenti, SOS.
- `purge`: cancella `location_pings` dopo 48 h e i dati del viaggio dopo il ritorno (retention configurabile).
- `rates`: aggiorna `currencies`.
