MATCHMATRIX – ZÁPIS (2026-04-09)
🎯 HLAVNÍ POSUN DNE

👉 Dnes jsme opravili nejkritičtější slabinu systému: execution layer (parse binding)

Konkrétně:

pull → raw → staging payload → ❌ STOP

➡️ přeměněno na:

pull → raw → staging payload → PARSE → stg_provider_* ✔️
🧠 1. ROOT CAUSE (nalezen a potvrzen)

Pro všechny API-Sport entity (multisport) platilo:

parser existoval ✅
payload se ukládal ✅
ale parser se nespouštěl ❌

👉 problém nebyl v:

API
DB
scheduleru

👉 problém byl v:
chybějícím napojení parseru v pull scriptu

🔧 2. KLÍČOVÝ FIX

Soubor:

ingest/API-Sport/pull_api_sport_teams.ps1

👉 doplněno:

& C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_parse_api_sport_teams_v1.py
🔥 3. BREAKTHROUGH – BK TEAMS
Stav před:
stg_provider_teams_bk = 0
parse_status = pending
chain končil na payload
Stav po:
stg_provider_teams: +18 řádků

👉 viz snapshot:

Barcelona
Baskonia
Real Madrid
Valencia
…
✅ Výsledek
BK teams:
pull ✔️
raw ✔️
payload ✔️
PARSE ✔️
stg_provider_teams ✔️

👉 STAGING_CONFIRMED

🧩 4. STAV SYSTÉMU PO DNES
🟢 HK (Hockey)
teams → CONFIRMED
fixtures → PARTIAL (čeká merge delta)
🟡 BK (Basketball)
fixtures → PARTIAL
teams → 🔥 STAGING_CONFIRMED (dnes opraveno)
🔵 VB (Volleyball)
fixtures → PARTIAL
leagues → PARTIAL
teams → PARTIAL (dispatch OK)
odds → PLANNED
⚫ FB (Football)
RUNNABLE (bez fresh auditu)
🧠 5. ARCHITEKTURA – POTVRZENÁ

👉 finálně potvrzen model:

✔ HYBRID
SHARED (API-Sport)
pull layer
payload storage
PER ENTITY
parse
merge
🚨 6. KLÍČOVÝ INSIGHT

👉 systém nebyl rozbitý

👉 jen chyběl:

execution layer (parse binding)
🚀 7. CO TO ODEMYKÁ

Teď už:

multisport ingest funguje
parser pattern je reusable
nové sporty = minimální práce
▶️ ZÍTŘEK (PRVNÍ KROK)
🔥 BK provider_map

👉 cíl:

stg_provider_teams
→ team_provider_map
→ public.teams
Konkrétně budeme řešit:
mapování external_team_id → team_id
deduplikace
alias logiku
merge do canonical vrstvy
🧠 TL;DR

👉 dnes jsme opravili:
nejdůležitější technickou chybu v systému

👉 výsledek:
BK teams pipeline poprvé end-to-end funguje

👉 zítra:
napojíme to na real business layer (provider_map + public)

▶️ RÁNO START

Stačí napsat:

👉 „jedeme BK provider_map“

a jedeme další level 🔥