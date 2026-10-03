# Viaggio — Specifica funzionale

App mobile per viaggi di gruppo in Italia. Due ruoli: **Turista** e **Guida/Capogruppo**. Lingue: FR, EN, PL, ES, RO. Prezzi in euro con conversione nella valuta del viaggiatore (CAD, USD, GBP, CHF, JPY, BRL, CNY).

## 1. Onboarding
- Benvenuto con scelta lingua.
- Ruolo: Turista / Guida. Codice invito gruppo (es. ROMA-2026) o QR della guida.
- Consensi separati: Posizione (sempre inviata in SOS), Documenti (cifrati), Salute (dati sensibili, condivisi solo se attivati).
- Scansione passaporto (banda MRZ) → copia cifrata, offline. Rileva la valuta del viaggiatore.

## 2. Oggi
- Data, giorno X di Y, saluto.
- **Prossimo appuntamento** con conto alla rovescia, "Arrivo / In ritardo"; la guida vede le risposte (arrivano / in ritardo / nessuna risposta).
- Messaggio fissato della guida. Votazione di gruppo (chiusura, aggiunta al programma).
- "Non vedo il gruppo" → flusso per ritrovare il gruppo.
- Programma del giorno (giorno per giorno), cosa portare, consiglio del giorno, giornata libera con pianificatore personale.
- **Guida**: appello (presenti/assenti con ultima posizione), allerta al gruppo, diete e allergie per il ristorante, editor del percorso, scelta punti d'incontro, card "Nuovo programma".

## 3. Mappa
- Città, punti d'incontro P1–P4, hotel, posizione, zone di attenzione, mappa offline, "il mio hotel" da mostrare al tassista.

## 4. Prenota (tutta Italia)
- **Treni**: partenza, arrivo, oggi/domani; offerte Frecciarossa, Italo, Regionale/Intercity con "più veloce" e "più economico".
- **Bus/metro**: 8 città (Roma, Milano, Firenze, Venezia, Napoli, Bologna, Torino, Pisa) con biglietti urbani, pass 24 h, navette aeroporto.
- **Musei**: 23 musei e monumenti.
- Acquisto: foglio con viaggiatori, totale stimato, **sito ufficiale** → "Ho comprato · aggiungi ai miei biglietti". L'app **non vende** biglietti.
- I miei biglietti → anche in Documenti con QR.

## 5. Documenti
- Portafoglio cifrato (Face ID), passaporto, carta d'imbarco, assicurazione, hotel, biglietti.
- Esporta PDF per polizia / ambasciata. Funziona offline.

## 6. Gruppo (guida)
- Membri, presenze, schede salute condivise, punti d'incontro del percorso, invito (QR + link), chat gruppo/privata, messaggi prioritari con conferma di lettura.

## 7. SOS
- Categorie: Medico, Furto, Documento perso, Perso dal gruppo, Altro. Chiama 112.
- La guida riceve allerta sonora (anche in silenzioso) con posizione e scheda salute condivisa.
- Passi guidati per ogni caso (denuncia, ambasciata, blocco carta, ospedale più vicino).

## 8. Più
- Chat, consigli (usanze, truffe, mance, chiese), convertitore valute, Tax Free (scontrini, modulo, QR, aeroporto), profilo salute e contatto d'emergenza, posizione e notifiche (sempre / attività / mai tranne SOS), lingua.
- Guida: programma automatico, libreria percorsi, numero per il gruppo.

## 9. Programma automatico (capogruppo)
- Input: cliente (Agenzia + nome / Privato), persone (1–60), giorni (1–10), città in ordine, temi (fede e pellegrinaggio, storia, arte, gastronomia, panorami, quartieri), ritmo (3/4/5 tappe), budget (pasto 15/25/45 €).
- Output: giorni divisi tra le città, orari dalle 09:00, pranzo dopo la 2ª tappa, spostamenti a piedi o metro/bus (+10 min per gruppi ≥ 15), treno nei giorni di cambio città, etichetta "prenotazione di gruppo obbligatoria" (≥ 10 persone, ingresso a pagamento), costo a persona e totale.
- Il capogruppo decide: "Sostituisci" una tappa, "Altre idee" per il giorno, modifica criteri, **Approva e invia al gruppo**, PDF preventivo per l'agenzia / PDF per il cliente, salva come modello.

## Custode (secondo concept)
Italiano di base, ruoli: solo / membro / capogruppo. Funzioni: documenti protetti, programma minuto per minuto, racconti dei luoghi (solo), zona del gruppo con allerta se ci si allontana, zona borseggi, musei con prezzi, transfer aeroporto, SOS.
