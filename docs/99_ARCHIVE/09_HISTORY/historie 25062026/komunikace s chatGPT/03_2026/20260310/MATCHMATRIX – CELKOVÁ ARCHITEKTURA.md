MATCHMATRIX – CELKOVÁ ARCHITEKTURA

Celý systém má 7 hlavních vrstev.

DATA SOURCES
     ↓
RAW INGEST
     ↓
CORE SPORTS DATABASE
     ↓
FEATURE ENGINE
     ↓
ML PREDICTIONS
     ↓
TICKET ENGINE
     ↓
CONTENT & USER LAYER
1️⃣ DATA SOURCES (externí zdroje)

Sem patří všechna API a scrapers.

API-SPORT
API-FOOTBALL
API-HOCKEY
scrapers

Z těchto zdrojů taháš:

sports
leagues
seasons
teams
players
fixtures
odds
statistics
events
2️⃣ RAW INGEST LAYER

To jsou tabulky, které jsi poslal na posledním screenshotu.

api_football_fixtures
api_football_leagues
api_football_odds
api_football_teams

api_hockey_leagues
api_hockey_leagues_raw
api_hockey_teams
api_hockey_teams_raw

players_import
player_provider_map_import

Tyto tabulky mají funkci:

API payload → uložit → zpracovat → převést do core DB

Výhody:

můžeš data znovu parsovat

můžeš opravovat ingest

můžeš dělat debugging

3️⃣ INGEST ORCHESTRATION

Tahle vrstva řídí co a kdy se má stáhnout.

Tabulky:

league_import_plan
ingest_targets
jobs
job_runs
api_request_log
provider_accounts
league_import_plan

strategický plán lig

provider
provider_league_id
sport_code
season
tier
enabled
ingest_targets

runtime ingest

sport_code
canonical_league_id
provider_league_id
season
tier
run_group
jobs

definice jobů

job_runs

log běhů

api_request_log

log API requestů

4️⃣ CORE SPORTS DATABASE

To je hlavní sportovní databáze.

Obsahuje:

sports
countries
leagues
seasons
teams
players
stadiums
coaches
transfers
lineups
matches
match_events
match_weather
team_match_statistics
player_match_statistics

To je sportovní model MatchMatrix.

5️⃣ ODDS & MARKET LAYER

Sázková data.

Tabulky:

bookmakers
markets
market_outcomes
odds
closing_odds

Tyhle tabulky rostou velmi rychle.

6️⃣ FEATURE ENGINE

Zápasy se převádějí na feature dataset pro ML.

Tabulky:

match_features
mm_match_ratings
mm_team_ratings
mm_value_bets

Výpočty:

MMR rating
team form
home/away strength
momentum
volatility
7️⃣ ML PREDICTION LAYER

Python modely:

train_gbm_v1.py
train_gbm_v2.py
train_gbm_v3.py
train_baseline_logreg.py

Predikce:

ml_predictions
ml_value_latest_v1
ml_value_ev_latest_v1

Ty počítají:

1X2 probabilities
expected value
value bets
8️⃣ TICKET ENGINE

Generuje sázkové tikety.

Tabulky:

templates
template_blocks
template_block_matches
template_fixed_picks

Generování:

generated_runs
generated_tickets
generated_ticket_blocks
generated_ticket_fixed
generated_ticket_risk

Varianty:

ticket_variants
ticket_variant_matches
ticket_variant_block_choices
ticket_variant_features

Vyhodnocení:

ticket_settlements
ticket_run_settlements
ticket_pattern_stats
ticket_league_pattern_stats
9️⃣ CONTENT LAYER

Obsah kolem sportu.

Tabulky:

articles
article_team_map
article_league_map
article_match_map
article_translations
content_sources

Obsahuje:

news
komentáře
preview zápasů
recaps
🔟 USER LAYER

Uživatelé a personalizace.

users
subscriptions
subscription_plans
user_favorite_teams
user_favorite_leagues
user_notifications
1️⃣1️⃣ WORKER & PIPELINE

Python workers:

run_daily_ingest.py
run_daily_pipeline.py
run_ticket_generation.py
run_provider_job.py

Pipeline:

ratings
 → features
 → predictions
 → ticket_generation
 → settlement
1️⃣2️⃣ MULTI-SPORT EXPANSION

Tvůj plán:

football
hockey
tennis
mma
volleyball
cricket
rugby
basketball
baseball
handball

Architektura to už podporuje díky:

sport_code
provider
provider_league_id
1️⃣3️⃣ STORAGE STRATEGY (tvých 6 TB)

Doporučené rozdělení:

2 TB  PostgreSQL data
2 TB  raw API payload
1 TB  content
1 TB  backup / rezervy
1️⃣4️⃣ CO TEĎ CHYBÍ

Systém je silný, ale potřebujeme ještě:

1️⃣ global sport import plan

pro všechny sporty.

2️⃣ request budget scheduler

aby se využilo

7500 requestů / sport / den
3️⃣ discovery ingest

automatické hledání:

nových lig
nových sezón
nových týmů
🧩 FINÁLNÍ MAPA MATCHMATRIX
API SOURCES
     ↓
RAW INGEST TABLES
     ↓
INGEST ORCHESTRATION
     ↓
CORE SPORTS DATABASE
     ↓
ODDS & MARKET DATA
     ↓
FEATURE ENGINE
     ↓
ML PREDICTIONS
     ↓
TICKET ENGINE
     ↓
CONTENT LAYER
     ↓
USER APPLICATION