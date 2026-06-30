MatchMatrix – vývojový zápis
Datum

16.03.2026

1. Hlavní cíl dne

Stabilizovat players pipeline a dokončit architekturu pro plánování ingestu pomocí:

ops.ingest_entity_plan

a připravit panel tak, aby entity nebyly hardcoded, ale načítaly se z databáze.

2. Players pipeline – stav
Hotové části
Players ingest

Funguje skript:

pull_api_football_players_v4.py

funkce:

paging

správné načítání .env

ukládání payloadu

data se ukládají do:

staging.players_import

test liga:

Segunda Liga (95)
season 2024

výsledek:

60 hráčů načteno
Players bridge

skript:

run_players_bridge_v4.py

převádí:

staging.players_import
↓
staging.stg_provider_players
Season stats bridge

implementován nový worker:

run_players_season_stats_bridge_v3.py

pipeline:

players_import
↓
statistics parser
↓
stg_provider_player_season_stats

výsledek testu:

players processed: 60
stat rows parsed: 168
total rows table: 2574
Data coverage

např.:

appearances
assists
duels_total
minutes_played
rating

mají již vyplněná data.

Player enrichment architektura

v OPS existuje:

player_enrichment_plan
v_player_enrichment_queue

to umožňuje budoucí pipeline:

players
player_profiles
player_stats
player_transfers
player_injuries
3. OPS architektura – ingest plánování

Dnes byla navržena a vytvořena nová tabulka:

ops.ingest_entity_plan

tato tabulka je centrální definice ingest entit.

Tabulka
ops.ingest_entity_plan

definuje:

provider
sport_code
entity
priority
scope_type
requires_league
requires_season
default_run_group
source_endpoint
target_table
worker_script
Football entity definované dnes
leagues
teams
fixtures
odds
players
player_profiles
player_season_stats
player_stats
4. Panel V4 – úpravy

Panel byl upraven tak, aby:

dříve

entity byly:

hardcoded v pythonu
nyní

entity se načítají z:

ops.ingest_entity_plan

dotaz:

SELECT entity
FROM ops.ingest_entity_plan
WHERE enabled = true
ORDER BY priority;
Panel nyní načítá z DB
komponenta	zdroj
sporty	ops.ingest_targets
entity	ops.ingest_entity_plan
run_group	ops.ingest_targets
5. Databázová architektura

Kompletní vrstvy:

RAW

provider data

api_football_leagues
api_football_teams
api_football_fixtures
api_football_odds
STAGING

sjednocená ingest vrstva

stg_provider_leagues
stg_provider_teams
stg_provider_fixtures
stg_provider_odds
stg_provider_players
stg_provider_player_profiles
stg_provider_player_season_stats
PUBLIC (canonical)

produkční tabulky

sports
leagues
teams
matches
players
odds
ANALYTICS

modelové tabulky

mm_match_ratings
mm_team_ratings
mm_team_form
mm_match_features
OPS

orchestrace

sports_import_plan
league_import_plan
ingest_entity_plan
ingest_targets
ingest_planner
scheduler_queue
provider_jobs
job_runs
6. Stav projektu MatchMatrix
ingest architektura

✔ unified staging
✔ multi-sport model
✔ scheduler
✔ planner
✔ player ingest
✔ player season stats parser

pipeline
API
↓
RAW provider
↓
STAGING unified
↓
PUBLIC canonical
↓
ANALYTICS
↓
Ticket Engine
7. Stav dat

football:

leagues: ~850
teams: ~2400
matches: ~1200
players: ingest pipeline funkční
8. Největší přínosy dne
dokončená players pipeline

včetně:

season stats parser
zavedení entity konfigurace
ops.ingest_entity_plan

odstranění:

hardcoded entity
panel V4

je nyní plně DB-driven.

9. Co je nejdůležitější přidat pro přehled projektu

Doporučuji vytvořit tyto meta tabulky / dokumenty.

1. datový katalog
ops.data_catalog

obsah:

schema
table_name
description
layer
owner
refresh_type
2. pipeline katalog
ops.pipeline_catalog

obsah:

pipeline_name
source_table
target_table
worker_script
schedule
owner
3. entity katalog
ops.entity_catalog

obsah:

entity
sport_code
provider
description
api_endpoint
staging_table
public_table
4. feature katalog
ops.feature_catalog

pro modely:

feature_name
source_table
description
model_usage
5. ticket engine katalog
ops.ticket_strategy_catalog

obsah:

strategy_name
description
model_source
risk_profile
10. Doporučené dokumenty

v adresáři:

docs/

doporučuji:

MATCHMATRIX_DATABASE_MAP.md
MATCHMATRIX_PIPELINE_MAP.md
MATCHMATRIX_ENTITY_MODEL.md
MATCHMATRIX_FEATURE_ENGINE.md
TICKETMATRIX_ARCHITECTURE.md
11. Plán na zítřek
1️⃣ player public merge

zkontrolovat:

run_players_public_merge_v2.py

pipeline:

stg_provider_player_season_stats
↓
public.player_season_statistics
2️⃣ player enrichment pipeline

implementovat:

player_profiles
player_stats

pipeline:

players
↓
player_profiles
↓
player_stats
3️⃣ planner generator

vytvořit worker:

build_ingest_planner_jobs_v2.py

který generuje planner joby z:

ingest_entity_plan
+
league_import_plan
4️⃣ scheduler upgrade

upravit:

run_multisport_scheduler_v4.py

aby respektoval:

entity priority
5️⃣ feature engine start

začít tabulky:

mm_team_form
mm_team_strength
mm_player_form
12. Dlouhodobé cíle

MatchMatrix směřuje k platformě:

sports data platform
+
prediction engine
+
ticket engine
+
fan statistics portal
13. Stav projektu

projekt je nyní přibližně:

70–75 % infrastruktury

zbývá:

feature engine
prediction engine
ticket engine
frontend
Zítřejší start

začneme:

players public merge

a pak:

player enrichment