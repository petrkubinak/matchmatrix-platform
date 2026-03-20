MatchMatrix – pracovní zápis
Datum

12.03.2026

1. Cíl dne

Dokončit Unified Ingest Batch architekturu a napojit ji na:

ops.ingest_targets

Control Panel

logování do ops.job_runs

Cílem bylo dostat ingest do stavu, kdy:

se nespouští jednotlivé ligy ručně

ingest běží dávkově podle konfigurace v databázi

všechny běhy jsou logovány.

2. Unified Ingest Runner

Funkční komponenty:

run_unified_ingest_v1.py

Zajišťuje:

jednotné spouštění ingestu

předání parametrů providerům

výpis statusu běhu

Parametry:

provider
sport
entity
league_id
season
run_group

Runner spouští provider wrapper.

3. Provider wrapper

Použit provider:

providers/api_football_provider.py

Wrapper:

generuje správný PS příkaz

předává parametry:

-LeagueId
-Season
-From
-To
-RunId

Sezónní okno:

season = 2022
From = 2022-07-01
To   = 2023-06-30
4. PowerShell ingest

Použité skripty:

pull_api_football_leagues.ps1
pull_api_football_teams.ps1
pull_api_football_fixtures.ps1

Výstup:

Fixtures inserted into staging: 156

nebo

No fixtures returned
5. Batch ingest

Vytvořen skript:

run_unified_ingest_batch_v1.py

Funkce:

načte ingest cíle z DB

spustí ingest pro každou ligu

vyhodnotí výsledek

SQL zdroj:

ops.ingest_targets

použité sloupce:

provider
sport_code
provider_league_id
season
run_group
enabled
6. Paralelizace ingestu

Batch runner nyní podporuje:

--max-workers

Použito:

--max-workers 3

To umožňuje paralelní ingest více lig.

7. Limit pro testování

Pro ladění byl přidán parametr:

--limit

Například:

--limit 5

Výstup:

OK
WARNING
ERROR
UNKNOWN
8. Panel

Panel:

matchmatrix_control_panel_V3.py

Nový krok:

Football Fixtures Batch

spouští:

run_unified_ingest_batch_v1.py

parametry:

provider = api_football
sport = football
entity = fixtures
run_group = FOOTBALL_MAINTENANCE
limit = 5
max_workers = 3
9. Logování běhů

Batch ingest nyní zapisuje do:

ops.job_runs

Byl vytvořen nový job:

ops.jobs.code = unified_ingest_batch

Log obsahuje:

job_code
started_at
finished_at
status
message
rows_affected

Příklad záznamu:

id = 61
job_code = unified_ingest_batch
status = warning
message = Batch finished. OK=4, WARNING=1, ERROR=0
rows_affected = 5
10. Potvrzené funkční části

Funguje celý řetězec:

Control Panel
        ↓
run_unified_ingest_batch_v1.py
        ↓
ops.ingest_targets
        ↓
run_unified_ingest_v1.py
        ↓
provider wrapper
        ↓
PowerShell ingest
        ↓
staging tables
        ↓
ops.job_runs
11. Stav ingest engine

Unified Ingest V1 je nyní:

funkční

konfigurovatelný z DB

spustitelný z panelu

paralelizovaný

logovaný

To je základ MatchMatrix ingest orchestration layer.

12. Architektonické rozhodnutí

Football slouží jako referenční implementace.

Architektura je:

unified orchestration
+ sport-specific adapters

To umožní později přidat:

hockey
basketball
tennis
mma
darts

bez změny ingest engine.

13. Plán na zítřek

Postup bude pokračovat v tomto pořadí.

1️⃣ Football Teams Batch

Rozšířit ingest batch na:

entity = teams

Cíl:

Football Teams Batch
2️⃣ Zápis detailních výsledků ingestu

Rozšířit ops.job_runs.details o:

league_id
season
status

pro každou ligu.

3️⃣ Odds ingest

Napojit ingest:

theodds

do stejné architektury.

4️⃣ Hockey ingest

Přidat nový provider adapter.

14. Aktuální stav projektu

MatchMatrix má nyní funkční:

Docker infra
Postgres DB
Unified staging
Provider ingest
Batch ingest
Control panel
Scheduler log

Platforma je připravena na další fázi:

core data pipeline
ratings
predictions
ticket engine

✔ Unified Ingest Batch je dnes považován za dokončený milník.