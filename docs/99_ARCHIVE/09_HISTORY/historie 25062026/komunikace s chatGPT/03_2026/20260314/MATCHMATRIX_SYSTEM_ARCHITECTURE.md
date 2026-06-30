# MATCHMATRIX – SYSTEM ARCHITECTURE DOCUMENTATION

Autor: Petr Kubinák  
Projekt: MatchMatrix  
Dokument: System Architecture  
Verze: 1.0  
Datum: 2026

---

# 1. ÚČEL DOKUMENTU

Tento dokument popisuje kompletní architekturu systému MatchMatrix.

Obsahuje:

- architekturu ingest systému
- plánování ingest jobů
- worker architekturu
- databázový model
- data pipeline
- machine learning pipeline
- ticket engine
- plán dalšího vývoje

Dokument je určen pro vývojáře a architekty systému.

---

# 2. HLAVNÍ ARCHITEKTURA SYSTÉMU

MatchMatrix je modulární datová platforma.

Systém se skládá z několika vrstev:

```
DATA PROVIDERS
↓
INGEST PLANNER
↓
INGEST WORKERS
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
↓
FRONTEND / API
```

---

# 3. DATA PROVIDERS

Systém pracuje s více datovými zdroji.

Aktuálně implementované:

```
API-Football
API-Hockey
TheOdds API
```

Budoucí zdroje:

```
Transfermarkt
Football-data
custom scrapers
```

---

# 4. INGEST ARCHITEKTURA

Ingest systém je navržen jako **plánovaný worker systém**.

Pipeline:

```
INGEST TARGETS
↓
INGEST PLANNER
↓
SCHEDULER QUEUE
↓
INGEST WORKERS
↓
API CALL
↓
RAW PAYLOAD STORAGE
↓
PAYLOAD PARSER
↓
STAGING TABLES
↓
MERGE TO CANONICAL TABLES
```

---

# 5. INGEST TARGETS

Tabulka:

```
ops.ingest_targets
```

Definuje:

- které ligy
- které sezóny
- který provider
- jaký rozsah zápasů

---

# 6. INGEST PLANNER

Tabulka:

```
ops.ingest_planner
```

Obsahuje plán ingest jobů.

Sloupce:

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

Status může být:

```
pending
running
done
error
```

---

# 7. SCHEDULER QUEUE

Tabulka:

```
ops.scheduler_queue
```

Obsahuje joby připravené ke spuštění.

Worker z ní vybírá úlohy.

---

# 8. WORKER LOCKS

Tabulka:

```
ops.worker_locks
```

Zabraňuje paralelnímu spuštění stejných jobů.

Používá:

```
lock_name
owner_id
expires_at
heartbeat_at
```

---

# 9. API REQUEST BUDGET

Tabulka:

```
ops.api_budget_status
```

Sleduje API limity.

Sloupce:

```
requests_limit
requests_used
requests_remaining
```

---

# 10. INGEST WORKERS

Workers spouští ingest pipeline.

Hlavní skripty:

```
run_ingest_planner_jobs.py
run_scheduler_queue_executor.py
run_payload_parser.py
```

---

# 11. PAYLOAD STORAGE

RAW API odpovědi se ukládají do:

```
staging.stg_api_payloads
```

Obsahuje:

```
provider
sport_code
entity_type
endpoint
payload_json
fetched_at
```

---

# 12. PAYLOAD PARSER

Parser převádí JSON payload do staging tabulek.

Pipeline:

```
JSON payload
↓
normalize
↓
insert into staging tables
```

---

# 13. STAGING TABLES

Hlavní staging tabulky:

```
stg_provider_leagues
stg_provider_teams
stg_provider_fixtures
stg_provider_odds
stg_provider_players
stg_provider_events
```

---

# 14. MERGE PIPELINE

Script:

```
run_unified_staging_to_public_merge_v2.py
```

Provádí transformaci:

```
staging → public
```

---

# 15. CANONICAL DATABASE

Canonical tabulky obsahují normalizovaná data.

Hlavní tabulky:

```
leagues
teams
matches
players
```

---

# 16. FEATURE ENGINEERING

Script:

```
build_match_features.py
```

Vytváří dataset:

```
ml_match_dataset_v2
```

---

# 17. RATING ENGINE

Script:

```
compute_mmr_ratings.py
```

Počítá:

```
team rating
home rating
away rating
momentum
volatility
```

Tabulky:

```
mm_team_ratings
mm_match_ratings
```

---

# 18. MACHINE LEARNING

Modely:

```
Gradient Boosting
```

Scripts:

```
train_gbm_v1.py
train_gbm_v2.py
train_gbm_v3.py
```

---

# 19. PREDICTION ENGINE

Script:

```
predict_matches_v3.py
```

Výstup:

```
ml_predictions
```

---

# 20. ODDS ANALYSIS

Srovnává:

```
model probability
vs
bookmaker odds
```

Výsledkem jsou:

```
value bets
expected value
```

---

# 21. TICKET ENGINE

Runtime generátor tiketů.

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

# 22. TICKET INTELLIGENCE

Analytická vrstva.

Tabulky:

```
ticket_settlements
ticket_pattern_stats
ticket_league_pattern_stats
ticket_generation_runs
ticket_variant_features
ticket_recommendation_feedback
```

---

# 23. FRONTEND

Frontend aplikace:

```
React
```

Složka:

```
frontend/matchmatrix-web
```

---

# 24. BACKEND

Backend poskytuje API.

Endpointy:

```
/matches
/predictions
/tickets
/statistics
```

---

# 25. LOGGING

Logs se ukládají do:

```
logs/
```

Typy:

```
ingest logs
model logs
system logs
```

---

# 26. BACKUPS

Složka:

```
backups/
```

Obsahuje:

```
database dumps
snapshots
dataset exports
```

---

# 27. AKTUÁLNÍ STAV PROJEKTU

Dokončeno:

```
database architecture
ingest planner
scheduler
staging pipeline
merge pipeline
rating engine
prediction models
ticket runtime engine
```

---

# 28. NEDOKONČENÉ

```
teams ingest pipeline
players ingest pipeline
odds pipeline
ticket intelligence ML
frontend UI
```

---

# 29. DALŠÍ FÁZE VÝVOJE

FÁZE 1

```
stabilizace ingest pipeline
```

FÁZE 2

```
API data backfill
```

FÁZE 3

```
ML model improvements
```

FÁZE 4

```
ticket intelligence engine
```

---

# 30. DLOUHODOBÁ VIZE

MatchMatrix bude kompletní platforma:

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