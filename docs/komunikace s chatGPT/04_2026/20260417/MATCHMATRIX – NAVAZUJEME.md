MATCHMATRIX – NAVAZUJEME (API-FOOTBALL FIXTURES FIX)

Navazujeme na opravu API-Football fixtures pipeline.

🔧 CO BYLO PROBLÉM

API-Football fixtures se po ingestu dostávaly pouze do:

staging.api_football_fixtures

ale nepropagovaly se do public.matches.

🧠 ROOT CAUSE

Problém byl v orchestrace vrstvě:

run_ingest_cycle_v3.py nevolal větev:
RAW -> PUBLIC (API-Football fixtures)
parser run_parse_api_sport_fixtures_v1.py se na API-Football nevztahuje
výsledkem bylo:
API → RAW → STAGING ❌ STOP
✅ CO BYLO OPRAVENO

Do run_ingest_cycle_v3.py přidána větev:

STEP 2B - API FOOTBALL RAW TO PUBLIC MERGE

Logika:

detekce provider=api_football + entity=fixtures
extrakce run_id z planner outputu
spuštění:
run_api_football_fixtures_raw_to_public.ps1
📊 DŮKAZ (OVĚŘENÉ RUNY)
20260417213521047 → 240 / 240 / 0
20260417213618896 → 306 / 306 / 0
20260417213733016 → 192 / 192 / 0

✔ všechny runy:

present_in_public = raw_distinct
missing_after_merge = 0
🗄️ STAV DB
public.matches (api_football) = 77435

✔ data rostou
✔ merge funguje automaticky
✔ žádné ruční zásahy potřeba

🧩 FINÁLNÍ PIPELINE
API-Football
    ↓
RAW (api_football_fixtures)
    ↓
STAGING
    ↓
RAW → PUBLIC MERGE (STEP 2B)
    ↓
public.matches ✅
🔥 KLÍČOVÝ POSUN

API-Football fixtures jsou teď:

✔ plně napojené do ingest cycle
✔ automatické
✔ ověřené runtime i DB
✔ připravené pro downstream (odds, ticket engine)
📍 NA CO NAVAZUJEME

Další krok:

🎯 ODDS ATTACH (TheOdds → matches)

Konkrétně:

zkontrolovat public.odds
analyzovat NO_MATCH_ID
napojit odds na nově potvrzené matches
🚀 START DALŠÍHO KROKU

V novém chatu napiš:

navazujeme na odds attach

a jedeme:

➡️ linker debug
➡️ false pairing
➡️ cleanup NO_MATCH_ID

Hotovo – můžeš to rovnou použít jako start dalšího vlákna