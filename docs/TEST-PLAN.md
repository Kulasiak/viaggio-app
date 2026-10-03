# Piano di test — "controllo perfetto"

Ogni voce deve essere verde prima del lancio. Claude Code la esegue e riporta i risultati.

## A. Controlli automatici (CI su ogni commit)
- [ ] ESLint + Prettier: 0 errori
- [ ] TypeScript strict: 0 errori
- [ ] `node scripts/check-i18n.mjs`: nessuna chiave mancante in fr, en, pl, es, ro
- [ ] `node scripts/check-links.mjs`: tutti i link ufficiali rispondono (2xx/3xx)
- [ ] Unit test (Vitest) ≥ 90% sulla logica: generatore programma, prezzi/valute, offerte treni, date/orari

## B. Database e sicurezza (test SQL / pgTAP)
- [ ] Un turista del gruppo A non legge nulla del gruppo B
- [ ] Un turista non vede il programma finché non è `approved`
- [ ] La guida **non** può leggere `documents` di nessuno
- [ ] La guida legge `health_cards` solo con `health_shared = true`
- [ ] Posizione: con `sos_only` la guida vede i ping solo durante SOS
- [ ] Solo la guida può inviare al gruppo se `travellers_can_post = false`
- [ ] Il job `purge` cancella i ping dopo 48 h

## C. Flussi end-to-end (Maestro su iOS/Android, Playwright su web)
- [ ] Onboarding completo turista (lingua, codice gruppo, consensi, passaporto)
- [ ] Onboarding guida
- [ ] "Arrivo / In ritardo" → la guida vede la risposta in tempo reale
- [ ] Messaggio prioritario → notifica + conferma di lettura
- [ ] SOS turista → allerta guida, posizione condivisa, chiusura allerta
- [ ] "Non vedo il gruppo" → indicazioni → "Ho trovato il gruppo"
- [ ] Prenota treno → apre sito ufficiale → "Ho comprato" → biglietto in Documenti
- [ ] Prenota museo in ogni città (8) → link corretto
- [ ] Programma automatico: agenzia 40 persone, 3 città, 5 giorni → genera, sostituisci tappa, altre idee, approva, i turisti lo ricevono
- [ ] Programma privato 2 persone → PDF cliente
- [ ] Tax Free: aggiungi scontrino, soglia 70 €, QR
- [ ] Convertitore valute in tutte le 7 valute
- [ ] Cambio lingua in ogni schermata (5 lingue): nessun testo non tradotto, nessun testo tagliato

## D. Offline
- [ ] Modalità aereo: programma, documenti, biglietti, consigli e mappa offline leggibili
- [ ] Messaggi in coda inviati al ritorno della rete

## E. Accessibilità e qualità
- [ ] Contrasto AA, pulsanti ≥ 44 px, VoiceOver/TalkBack leggono tutti i controlli
- [ ] Avvio app < 2 s su telefono medio; nessun crash in 30 min di uso (Sentry)

## F. Privacy (GDPR)
- [ ] Informativa e consensi separati registrati con data
- [ ] Esporta i miei dati / elimina account funzionano
- [ ] Dati sanitari cifrati, mai nei log

## G. Contenuti da verificare a mano prima del lancio
- [ ] Prezzi musei e trasporti 2026 dalle fonti ufficiali
- [ ] Orari treni reali (o indicare chiaramente "indicativi")
- [ ] Indirizzi e numeri (ambasciate, ospedali, hotel)
