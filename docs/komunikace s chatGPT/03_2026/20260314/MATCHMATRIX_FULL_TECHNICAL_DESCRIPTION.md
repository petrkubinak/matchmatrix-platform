# MATCHMATRIX – KOMPLETNÍ TECHNICKÝ POPIS PROJEKTU

Autor: Petr Kubinák  
Projekt: MatchMatrix  
Verze dokumentu: 1.0  
Datum: 2026

---

# 1. ÚVOD

MatchMatrix je komplexní sportovní datová a analytická platforma zaměřená na:

- sběr sportovních dat z API
- sjednocení dat z více zdrojů
- ukládání dat do vlastní databáze
- výpočet ratingů týmů
- predikci výsledků zápasů
- analýzu bookmaker odds
- generování inteligentních tiketů

Cílem systému není pouze predikovat jednotlivé zápasy.

Cílem je optimalizovat **celé tikety**.

---

# 2. HLAVNÍ KONCEPT

MatchMatrix kombinuje několik vrstev:

SPORT DATA PLATFORM  
+  
PREDICTION ENGINE  
+  
BETTING INTELLIGENCE  
+  
TICKET GENERATOR

---

# 3. HLAVNÍ ARCHITEKTURA

DATA PROVIDERS  
↓  
INGEST LAYER  
↓  
RAW PAYLOAD STORAGE  
↓  
STAGING DATABASE  
↓  
CANONICAL DATABASE  
↓  
RATING ENGINE  
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
↓  
FRONTEND / API

---

# 4. ROOT ADRESÁŘ PROJEKTU

Projekt je uložen v:

C:\MatchMatrix-platform

---

# 5. STRUKTURA PROJEKTU

C:\MatchMatrix-platform obsahuje složky:

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
programs  
providers  
reports  
system  
workers  

---

# 6. INFRASTRUKTURA

Soubor:

infra/docker-compose.yml

Obsahuje kontejnery:

POSTGRESQL  
REDIS

---

## 6.1 POSTGRESQL

container_name: matchmatrix_postgres

database: matchmatrix  
user: matchmatrix  

---

## 6.2 REDIS

container_name: matchmatrix_redis

Používá se pro:

- worker locks
- queue
- caching

---

# 7. DATABÁZE

MatchMatrix používá PostgreSQL.

Databáze obsahuje několik schémat.

public  
staging  
ops  
work  

---

# 8. PUBLIC SCHEMA

Obsahuje hlavní sportovní data.

---

## 8.1 leagues

sloupce:

id  
sport_id  
name  
country  
season  

---

## 8.2 teams

id  
league_id  
name  
country  
founded  
logo  

---

## 8.3 matches

id  
league_id  
season  
home_team_id  
away_team_id  
kickoff  
status  
home_goals  
away_goals  

---

## 8.4 players

id  
team_id  
name  
birth_date  
nationality  
position  

---

# 9. STAGING SCHEMA

Obsahuje data přímo z providerů.

---

## 9.1 stg_provider_leagues

provider  
sport_code  
external_league_id  
league_name  
season  

---

## 9.2 stg_provider_teams

provider  
external_team_id  
team_name  
country  
league_id  

---

## 9.3 stg_provider_fixtures

external_fixture_id  
league_id  
season  
home_team_external_id  
away_team_external_id  
status  
score  

---

## 9.4 stg_provider_odds

provider  
fixture_id  
bookmaker  
market  
outcome  
odds  

---

# 10. OPS SCHEMA

Obsahuje orchestrace ingest systému.

---

## 10.1 ingest_planner

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

---

## 10.2 ingest_targets

sport_code  
provider  
league_id  
season  
fixtures_days_back  
fixtures_days_forward  

---

## 10.3 scheduler_queue

fronta ingest jobů.

---

# 11. INGEST LAYER

Složka:

ingest/

obsahuje podsložky:

api  
providers  
scrapers  
workers  

---

# 12. PROVIDERS

Složka:

providers/

obsahuje implementace API providerů.

---

## 12.1 base_provider.py

základní provider interface.

---

## 12.2 api_football_provider.py

funkce:

get_leagues()  
get_teams()  
get_fixtures()  
get_odds()  

---

## 12.3 api_hockey_provider.py

provider pro hockey API.

---

# 13. API PAYLOAD STORAGE

Tabulka:

stg_api_payloads

sloupce:

provider  
sport_code  
entity_type  
endpoint  
payload_json  
fetched_at  

---

# 14. PAYLOAD PARSER

Script:

run_payload_parser.py

pipeline:

RAW PAYLOAD  
↓  
PARSING  
↓  
NORMALIZATION  
↓  
STAGING TABLES

---

# 15. LEGACY BRIDGE

Scripts:

run_legacy_to_staging_bridge.py  
run_legacy_to_staging_bridge_v2.py  
run_legacy_to_staging_odds_bridge.py  

Účel:

převod starých tabulek do unified staging modelu.

---

# 16. MERGE PIPELINE

Script:

run_unified_staging_to_public_merge_v2.py

Provádí:

stg_provider_leagues → public.leagues  
stg_provider_teams → public.teams  
stg_provider_fixtures → public.matches  

---

# 17. TEAMS PIPELINE

Script:

extract_teams_from_fixtures.py

Účel:

vytvoření týmů z fixture dat.

---

# 18. PLAYERS PIPELINE

Script:

run_players_bridge_v1.py

Zdroj dat:

players_import

Výstup:

public.players

---

# 19. ODDS PIPELINE

Script:

pull_api_football_odds.ps1

Parser:

theodds_parse_multi.py

---

# 20. RATING ENGINE

Script:

compute_mmr_ratings.py

Tabulky:

mm_team_ratings  
mm_match_ratings  

Rating obsahuje:

team rating  
home rating  
away rating  
momentum  
volatility  

---

# 21. FEATURE ENGINEERING

Dataset:

ml_match_dataset_v2

Features:

team_rating_diff  
home_advantage  
form_last5  
goal_diff  

---

# 22. MACHINE LEARNING

Modely:

train_gbm_v1.py  
train_gbm_v2.py  
train_gbm_v3.py  

Predikují:

P(home win)  
P(draw)  
P(away win)  

---

# 23. PREDICTION PIPELINE

Script:

predict_matches_v3.py

Výstup:

ml_predictions

---

# 24. ODDS ANALYSIS

Porovnává:

model probability  
vs  
bookmaker odds  

Výpočet:

value bet  
expected value  

---

# 25. TICKET ENGINE

Tabulky:

templates  
template_blocks  
template_block_matches  
template_fixed_picks  
generated_runs  
generated_tickets  
generated_ticket_blocks  

Princip:

max 3 blocks  
max 3 matches per block  

max 27 variant tiketů.

---

# 26. TICKET INTELLIGENCE LAYER

Nové tabulky:

ticket_settlements  
ticket_pattern_stats  
ticket_league_pattern_stats  
ticket_generation_runs  
ticket_variant_features  
ticket_recommendation_feedback  

Účel:

analýza úspěšnosti tiketů.

---

# 27. FRONTEND

Složka:

frontend/matchmatrix-web

React aplikace.

---

# 28. BACKEND API

poskytuje:

matches  
predictions  
tickets  
statistics  

---

# 29. LOGGING

Složka:

logs/

obsahuje:

ingest logs  
prediction logs  
system logs  

---

# 30. BACKUPS

Složka:

backups/

obsahuje:

postgres dumps  
snapshots  
dataset exports  

---

# 31. REPORTS

Složka:

reports/

obsahuje:

model reports  
ROI reports  
analýzy  

---

# 32. AKTUÁLNÍ STAV PROJEKTU

HOTOVO

database architecture  
ingest pipeline  
scheduler  
staging tables  
merge pipeline  
rating engine  
prediction models  
ticket runtime engine  

---

# 33. NEDOKONČENÉ

teams pipeline  
players pipeline  
odds pipeline  
ticket intelligence ML  
frontend UI  

---

# 34. DALŠÍ KROKY

1 dokončit teams ingest  
2 dokončit players ingest  
3 připravit odds pipeline  
4 provést API backfill  
5 dokončit ticket intelligence layer  
6 implementovat recommendation engine  

---

# 35. FINÁLNÍ VIZE

MatchMatrix bude:

SPORT DATA PLATFORM  
+  
PREDICTION ENGINE  
+  
BETTING INTELLIGENCE  
+  
TICKET OPTIMIZATION SYSTEM