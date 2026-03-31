MATCHMATRIX – DENNÍ ZÁPIS

📅 25.03.2026
🎯 Fokus: HK (hockey) pipeline – kompletní zprovoznění

🔧 1. HLAVNÍ PROBLÉMY (NA ZAČÁTKU DNE)

Identifikované chyby:

❌ HK TEAMS
API vracelo results=0
parser neměl co zpracovat
❌ HK FIXTURES
endpoint volán bez season
→ API vracelo results=0
❌ PARSER FIXTURES
vůbec nebyl zapojen do scheduleru
❌ MERGE CRASH
chyba:
matches_score_status_chk
✅ 2. CO SE DNES OPRAVILO
2.1 API FIX – season fallback

Soubor:

C:\MatchMatrix-platform\ingest\API-Hockey\pull_api_hockey_fixtures.ps1

✔ přidáno:

if (-not $Season -or $Season -eq 0) {
    $Season = 2024
}
2.2 UNIFIED RAW zápis

✔ sjednocení:

external_id = league_season (např. 59_2024)
parse_status = pending
2.3 FIXTURES PARSER – napojení do pipeline

Soubor:

C:\MatchMatrix-platform\workers\run_ingest_cycle_v3.py

✔ přidán krok:

# STEP 1D - PARSE FIXTURES
run_parse_api_sport_fixtures_v1.py

✔ potvrzeno v logu:

STEP 1D - PARSE API SPORT FIXTURES
2.4 PARSER FIXTURES – FUNKČNÍ

Výsledek:

Payloads: 33
Fixtures upserted: 4398
Errors: 0

✔ data správně v:

staging.stg_provider_fixtures_hk
2.5 MERGE FIX (KRITICKÉ)

Chyba:

matches_score_status_chk

✔ opraveno:

nevalidní statusy → fallback / mapping

✔ výsledek:

MERGE: OK
2.6 PLANNER PRIORITY FIX

✔ odděleno:

🔝 aktivní liga
59 → priority 1010
⛔ prázdné ligy
6, 101, 110, 146, 224, 236 → priority 5000

✔ scheduler už necyklí prázdná data

📊 3. AKTUÁLNÍ STAV HK
📦 DATA
public.teams_hk           5410
public.matches_hk         108419
staging fixtures HK       OK
parser fixtures HK        OK
📡 PIPELINE
krok	stav
pull teams	✅
pull fixtures	✅
parse teams	✅
parse fixtures	✅
merge	✅
scheduler	✅
🧠 4. KLÍČOVÝ POSUN

Dnes jsme dokončili:

👉 FULL END-TO-END PIPELINE PRO HK

To znamená:

ingest → staging → parsing → merge → public
plně automaticky přes scheduler

👉 HK je teď referenční implementace pro ostatní sporty

🚀 5. CO BUDEME DĚLAT DÁL (BK)

Teď jdeme basketball (BK) – přesně stejný princip.

🎯 DALŠÍ KROK (JEDEN KONKRÉTNÍ)

Teď nebudeme nic vymýšlet.

👉 Uděláme audit BK fixtures scriptu

📂 OTEVŘI:
C:\MatchMatrix-platform\ingest\API-Sport\pull_api_sport_fixtures.ps1
🔍 ZKONTROLUJ:
Má fallback na season?
Posílá:
league + season
Používá endpoint:
games / fixtures (podle API)
📩 POŠLI MI:

👉 celý ten soubor (nebo screenshot)

⚠️ PROČ JE TO DŮLEŽITÉ

Protože přesně stejná chyba byla u HK:

👉 bez season = prázdná data

A nechceme to řešit znovu u BK.

🧩 NAVÁZÁNÍ NA PROJEKT

Tímhle tempem:

HK ✅ hotovo
BK 🔜 na řadě
VB (volleyball) už máš rozjeté
další sporty = jen kopie vzoru

👉 tohle je moment, kdy se projekt láme
→ začíná být škálovatelný