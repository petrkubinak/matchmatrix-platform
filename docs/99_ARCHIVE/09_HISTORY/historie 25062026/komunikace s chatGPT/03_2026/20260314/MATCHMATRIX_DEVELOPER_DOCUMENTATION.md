# MATCHMATRIX – DEVELOPER DOCUMENTATION

Autor: Petr Kubinák  
Projekt: MatchMatrix  
Verze: 1.0  
Datum: 2026

---

# 1. ÚVOD

MatchMatrix je komplexní platforma pro:

- sběr sportovních dat
- ukládání historických dat
- analýzu výkonu týmů
- výpočet ratingů
- machine learning predikce
- analýzu bookmaker odds
- inteligentní generování tiketů

Projekt je navržen jako **modulární datová platforma**.

---

# 2. HLAVNÍ ARCHITEKTURA

Systém je rozdělen do několika vrstev.

DATA PROVIDERS  
↓  
INGEST PIPELINE  
↓  
RAW PAYLOAD STORAGE  
↓  
STAGING DATABASE  
↓  
CANONICAL DATABASE  
↓  
FEATURE ENGINEERING  
↓  
MACHINE LEARNING  
↓  
PREDICTIONS  
↓  
ODDS ANALYSIS  
↓  
TICKET ENGINE  

---

# 3. ROOT STRUKTURA PROJEKTU

```
C:\MatchMatrix-platform
```

Obsahuje hlavní složky:

```
api
artifacts
backend
data
db
docs
experiments
frontend
infra
ingest
logs
ops
providers
reports
system
workers
```

---

# 4. INFRASTRUKTURA

Soubor:

```
infra/docker-compose.yml
```

Spouští kontejnery:

### PostgreSQL

```
container_name: matchmatrix_postgres
database: matchmatrix
port: 5432
```

### Redis

```
container_name: matchmatrix_redis
port: 6379
```

Redis slouží pro:

- worker locks
- queue
- cache

---

# 5. DATABASE ARCHITECTURE

Databáze používá PostgreSQL.

Schémata:

```
public
staging
ops
work
```

---

# 6. PUBLIC SCHEMA

Obsahuje canonical sportovní data.

## leagues

```
id
sport_id
name
country
season
```

## teams

```
id
league_id
name
country
founded
logo
```

## matches

```
id
league_id
season
home_team_id
away_team_id
kickoff
status
home_goals
away_goals
```

## players

```
id
team_id
name
birth_date
nationality
position
```

---

# 7. STAGING SCHEMA

Obsahuje data přímo z API providerů.

## stg_provider_leagues

```
provider
sport_code
external_league_id
league_name
season
```

## stg_provider_teams

```
provider
external_team_id
team_name
country
league_id
```

## stg_provider_fixtures

```
external_fixture_id
league_id
season
home_team_external_id
away_team_external_id
status
score
```

## stg_provider_odds

```
provider
fixture_id
bookmaker
market
outcome
odds
```

---

# 8. OPS SCHEMA

Obsahuje orchestraci ingest pipeline.

## ingest_planner

```
provider
sport_code
entity
provider_league_id
season
run_group
priority
status
attempts
next_run
```

## ingest_targets

```
sport_code
provider
league_id
season
fixtures_days_back
fixtures_days_forward
```

## scheduler_queue

fronta ingest jobů.

---

# 9. INGEST ARCHITECTURE

Složka:

```
ingest/
```

obsahuje:

```
api/
providers/
scrapers/
workers/
```

---

# 10. PROVIDERS

Složka:

```
providers/
```

obsahuje implementace providerů.

## base_provider.py

Základní interface.

### funkce

```
fetch()
parse()
store()
```

---

## api_football_provider.py

Implementace API-Football.

### funkce

```
get_leagues()
get_teams()
get_fixtures()
get_odds()
```

---

## api_hockey_provider.py

Provider pro hockey API.

---

# 11. API PAYLOAD STORAGE

Tabulka:

```
stg_api_payloads
```

obsahuje:

```
provider
sport_code
endpoint
payload_json
fetched_at
```

---

# 12. PAYLOAD PARSER

Script:

```
run_payload_parser.py
```

pipeline:

```
RAW PAYLOAD
↓
JSON PARSE
↓
NORMALIZATION
↓
STAGING TABLES
```

---

# 13. LEGACY BRIDGE

Scripts:

```
run_legacy_to_staging_bridge.py
run_legacy_to_staging_bridge_v2.py
run_legacy_to_staging_odds_bridge.py
```

Účel:

sjednotit staré tabulky do unified staging modelu.

---

# 14. MERGE PIPELINE

Script:

```
run_unified_staging_to_public_merge_v2.py
```

Provádí merge:

```
stg_provider_leagues → public.leagues
stg_provider_teams → public.teams
stg_provider_fixtures → public.matches
```

---

# 15. TEAMS PIPELINE

Script:

```
extract_teams_from_fixtures.py
```

Účel:

vytvořit týmy z fixture dat.

---

# 16. PLAYERS PIPELINE

Script:

```
run_players_bridge_v1.py
```

Zdroj:

```
players_import
```

Výstup:

```
public.players
```

---

# 17. ODDS PIPELINE

Script:

```
pull_api_football_odds.ps1
```

Parser:

```
theodds_parse_multi.py
```

---

# 18. RATING ENGINE

Script:

```
compute_mmr_ratings.py
```

Tabulky:

```
mm_team_ratings
mm_match_ratings
```

Rating obsahuje:

```
team rating
home rating
away rating
momentum
volatility
```

---

# 19. FEATURE ENGINEERING

Dataset:

```
ml_match_dataset_v2
```

Features:

```
team_rating_diff
home_advantage
form_last5
goal_diff
```

---

# 20. MACHINE LEARNING

Modely:

```
train_gbm_v1.py
train_gbm_v2.py
train_gbm_v3.py
```

Predikují:

```
P(home)
P(draw)
P(away)
```

---

# 21. PREDICTION PIPELINE

Script:

```
predict_matches_v3.py
```

Výstup:

```
ml_predictions
```

---

# 22. ODDS ANALYSIS

Porovnává:

```
model probability
vs
bookmaker odds
```

Výpočet:

```
value bet
expected value
```

---

# 23. TICKET ENGINE

Tabulky:

```
templates
template_blocks
template_block_matches
template_fixed_picks
generated_runs
generated_tickets
generated_ticket_blocks
```

Princip:

```
max 3 blocks
max 3 matches per block
max 27 variants
```

---

# 24. TICKET INTELLIGENCE LAYER

Tabulky:

```
ticket_settlements
ticket_pattern_stats
ticket_league_pattern_stats
ticket_generation_runs
ticket_variant_features
ticket_recommendation_feedback
```

Účel:

analýza úspěšnosti tiketů.

---

# 25. FRONTEND

Složka:

```
frontend/matchmatrix-web
```

React aplikace.

---

# 26. BACKEND API

poskytuje endpointy:

```
matches
predictions
tickets
statistics
```

---

# 27. LOGGING

Složka:

```
logs/
```

obsahuje:

```
ingest logs
prediction logs
system logs
```

---

# 28. BACKUPS

Složka:

```
backups/
```

obsahuje:

```
postgres dumps
snapshots
dataset exports
```

---

# 29. REPORTS

Složka:

```
reports/
```

obsahuje:

```
model reports
ROI reports
analýzy
```

---

# 30. AKTUÁLNÍ STAV PROJEKTU

Hotovo:

```
database architecture
ingest pipeline
scheduler
staging tables
merge pipeline
rating engine
prediction models
ticket runtime engine
```

---

# 31. NEDOKONČENÉ

```
teams pipeline
players pipeline
odds pipeline
ticket intelligence ML
frontend
```

---

# 32. DALŠÍ KROKY

1 dokončit teams ingest  
2 dokončit players ingest  
3 připravit odds pipeline  
4 provést API backfill  
5 dokončit ticket intelligence layer  
6 implementovat recommendation engine  

---

# 33. FINÁLNÍ VIZE

MatchMatrix bude:

```
SPORT DATA PLATFORM
+
PREDICTION ENGINE
+
BETTING INTELLIGENCE
+
TICKET OPTIMIZATION SYSTEM
```

---