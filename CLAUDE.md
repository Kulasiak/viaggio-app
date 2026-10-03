# CLAUDE.md — Viaggio

Instructions for Claude Code. The owner (Kiko) speaks Italian: talk to him in simple Italian, short and practical. When there is a choice, pick the best option, apply it, and explain briefly.

## Goal

Turn the Claude Design prototype in `design/Viaggio-v2.dc.html` into a production app, with a real database, and verify everything with the test plan in `docs/TEST-PLAN.md` until it passes 100%.

`Custode.dc.html` is a second concept (Italian-first, solo / member / leader). Build Viaggio first; reuse the same backend for Custode later.

## Source of truth

- Behaviour and screens: `docs/SPEC.md` + the prototype (`design/Viaggio-v2.dc.html`, logic is in the `<script type="text/x-dc">` block: data constants at the top, `class Component` below).
- Texts: `i18n/viaggio.json` (UI keys, 5 languages) and `i18n/viaggio-content-dictionary.json` (content strings keyed by English text → pl/es/ro).
- Seed data: `data/*.json`.
- Database: `docs/DATABASE.md` and `supabase/migrations/0001_init.sql`.

## Stack (decided)

- Expo SDK (latest stable), React Native, TypeScript strict, Expo Router.
- Supabase: Postgres + RLS, Auth (email OTP + Apple/Google), Storage (encrypted documents), Edge Functions (notifications, PDF, programme generator).
- State/data: TanStack Query + Supabase client; offline cache with SQLite (expo-sqlite) for programme, documents index, tips, tickets.
- i18n: i18next with the JSON files in `i18n/`. Languages: fr, en, pl, es, ro (+ it for Custode).
- Maps: react-native-maps; push: expo-notifications.
- Tests: Vitest (unit), Playwright (web e2e), Maestro (mobile e2e), pgTAP or SQL tests for RLS.

## Build plan (do it in this order, commit after each phase)

1. **Scaffold**: Expo app, lint (ESLint + Prettier), TypeScript strict, CI (GitHub Actions running lint, typecheck, tests).
2. **Database**: apply `supabase/migrations/0001_init.sql`, write seed script from `data/*.json`, RLS policies, SQL tests proving a tourist cannot read other groups, health data or other people's documents.
3. **Auth + onboarding**: welcome, language, role (tourist/guide), group invite code / QR, 3 separate consents (location, documents, health), passport scan (MRZ) with encrypted storage.
4. **Today**: day plan, next meeting with "on my way / late" replies, pinned message, group vote, "I can't see the group", tip of the day. Guide: roll call, alerts, replies summary, "New programme" card.
5. **Map**: meeting points, caution zones, offline map, lost-from-group flow.
6. **Book (all Italy)**: trains (Trenitalia / Italo), city transport (8 cities), museums (23). Purchase = open the **official site** (URLs in `data/`), then "I've bought it" saves the ticket (PDF/QR upload) in Documents. Never sell or charge inside the app.
7. **Documents**: encrypted wallet, Face ID unlock, PDF export for police/embassy, offline.
8. **Group & chat**: members, presence, health cards (only if shared, GDPR art. 9), private/group chat, priority messages with read receipts.
9. **SOS**: categories, 112, guide alert with live location until closed, step-by-step guidance.
10. **More**: currency converter, Tax Free (receipts, form, QR, airport), health profile, location settings, tips.
11. **Automatic programme (guide only)**: agency or private client, people, days, cities in order, themes, pace, budget → day-by-day programme with times, lunch, trains between cities, group-booking tags, cost per person and group total. Leader can replace stops, regenerate a day, approve & send, export PDF quote, save as template. Port the algorithm from `planVals()` and move it to an Edge Function.
12. **Polish**: accessibility, dark mode, performance, store builds (EAS).

## Rules

- Prices, train times and walking times in the prototype are **placeholders**. Mark them as indicative in the UI until real data sources are connected (Trenitalia/Italo have no public booking API: deep-link to their sites).
- Health data and documents: encrypted, visible only to the owner and (if consented) the group guide; delete trip data after return (configurable retention).
- Every UI string must come from i18n. No hard-coded text.
- Touch targets ≥ 44 px, contrast AA, real buttons/labels.
- Never commit secrets. Use `.env` + EAS secrets.

## "Controllo perfetto" — definition of done

All items in `docs/TEST-PLAN.md` green, plus:
- `node scripts/check-i18n.mjs` → 0 missing keys in every language.
- `node scripts/check-links.mjs` → every official URL answers 2xx/3xx.
- CI green on main. Report the results to Kiko in Italian with a short list.
