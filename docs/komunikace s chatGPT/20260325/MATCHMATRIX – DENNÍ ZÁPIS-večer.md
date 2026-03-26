MATCHMATRIX – DENNÍ ZÁPIS

Datum: 25.03.2026
Fokus: Multi-sport ingest stabilizace (HK + BK + VB)
Výsledek dne: 🔥 PLNĚ FUNKČNÍ MULTI-SPORT PIPELINE (teams + fixtures)

🧠 1. HLAVNÍ PROBLÉMY (RÁNO)
❌ HK / BK / VB stav:
scheduler běžel, ale:
fixtures → 0 results
teams parser → 0 payloads
chyběl:
fixtures parser krok
planner obsahoval:
špatné ligy (např. HK league 6, BK league 40)
duplicity
merge padal:
matches_score_status_chk
🔧 2. KLÍČOVÉ FIXY (DNES IMPLEMENTOVÁNO)
✅ 2.1 Přidání FIXTURES PARSER

Soubor:

C:\MatchMatrix-platform\workers\run_ingest_cycle_v3.py
Přidán krok:
STEP 1D - PARSE API SPORT FIXTURES

➡️ Tohle byl zásadní chybějící článek pipeline

✅ 2.2 Fix MATCHES constraint

Chyba:

matches_score_status_chk

Řešení:

validace score_status při merge
pipeline už nepadá
✅ 2.3 Fix planner dat (kritické)

Vyčištěno:

HK:
odstraněny ligy bez dat
fallback season 2024
BK:
odstraněn problém:
❌ league 40 → timeout
nastaven:
✅ league 12 / season 2024
VB:
potvrzen jako funkční referenční sport
✅ 2.4 Deduplikace planneru
odstraněny duplicity:
BK teams 12 / 2024
sjednocení:
jeden aktivní target = jedna pravda
🚀 3. FINÁLNÍ STAV PIPELINE
🏐 VB (Volleyball)
payloads: ✅
fixtures: 178
public.matches: 178
status: 🟢 STABLE
🏒 HK (Hockey)
fixtures:
league 59 → 1146 zápasů
parser:
4398 fixtures upserted
merge: OK
status: 🟢 STABLE
🏀 BK (Basketball)
fixtures:
league 117 / season 2023-2024 → 326 zápasů
další ligy připravené v planneru
teams:
league 12 / season 2024:
pull: OK
parser: OK
žádné nové inserty (data existují)
status: 🟢 STABLE
🧱 4. ARCHITEKTURA – TEĎ JE SPRÁVNĚ
Finální flow (platí pro všechny sporty)
PLANNER
  ↓
UNIFIED INGEST (API CALL)
  ↓
STAGING (stg_api_payloads)
  ↓
EXTRACT TEAMS FROM FIXTURES
  ↓
PARSE TEAMS
  ↓
PARSE FIXTURES   ✅ (dnes přidáno)
  ↓
MERGE → PUBLIC
📊 5. STAV DB (po dnešku)
public.leagues: 2986
public.teams: 5410
public.players: 839
public.matches: 108 419

➡️ Matches už se plní multi-sportově

⚠️ 6. CO JE JEŠTĚ OTEVŘENÉ
HK:
leagues mají error
ale neblokuje ingest
BK:
část planneru bez season → bude vracet 0
OK pro free plán (2022–2024 limit)
obecně:
zatím:
žádné odds
žádní players per sport (jen základ)
🎯 7. CO JSME DNES REÁLNĚ DOSÁHLI

👉 Tohle je zásadní:

sjednocen ingest pro:
HK
BK
VB
odstraněn hlavní bug pipeline
planner vyčištěn
data tečou do public.matches

🔥 MatchMatrix už není single-sport → je MULTI-SPORT PLATFORM

🧭 8. DALŠÍ KROK (ZÍTRA)

Půjdeme přesně takhle (1 krok):

👉 sjednotíme planner logiku pro všechny sporty

Cíl:

jeden systém:
priority
season fallback
valid league selection

➡️ odstraníme:

0-result ligy
timeout ligy
duplicity
💬 Shrnutí jednou větou

👉 Dnes jsme opravili ingest architekturu a dostali MatchMatrix do stavu, kdy reálně sbírá data napříč sporty.

A zítra už jdeme:
👉 planner jako mozek celé platformy (to bude další velký level