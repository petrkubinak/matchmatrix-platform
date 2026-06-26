# MATCHMATRIX – DATABASE BIBLE

Autor: Petr Kubinák  
Projekt: MatchMatrix  
Dokument: Database Bible  
Verze: 1.0  
Datum: 2026  

---

# 1. ÚČEL DOKUMENTU

Tento dokument popisuje kompletní databázový model systému MatchMatrix.

Obsahuje:

- všechny databázové schémata
- tabulky
- sloupce
- vztahy mezi tabulkami
- datové toky

Dokument slouží jako **hlavní reference databázové architektury projektu**.

---

# 2. DATABASE OVERVIEW

MatchMatrix používá PostgreSQL.

Databáze je rozdělena do schémat:

```
public
staging
ops
work
analytics
```

Každé schéma má specifickou roli.

---

# 3. PUBLIC SCHEMA – CANONICAL DATA

Toto schéma obsahuje hlavní sportovní data.

## sports

```
id
code
name
```

---

## countries

```
id
name
code
```

---

## leagues

```
id
sport_id
country_id
name
logo
type
```

---

## seasons

```
id
league_id
year
start_date
end_date
```

---

## teams

```
id
league_id
name
country
founded
logo
venue_id
```

---

## venues

```
id
name
city
capacity
```

---

## players

```
id
team_id
name
birth_date
nationality
position
height
weight
```

---

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

---

## match_events

```
id
match_id
team_id
player_id
event_type
minute
```

---

# 4. ODDS DOMAIN

## bookmakers

```
id
name
country
```

---

## markets

```
id
name
```

---

## market_outcomes

```
id
market_id
name
```

---

## odds

```
id
match_id
bookmaker_id
market_id
outcome_id
odds_value
timestamp
```

---

# 5. STAGING SCHEMA

Obsahuje data přímo z providerů.

---

## stg_api_payloads

```
id
provider
sport_code
endpoint
payload_json
fetched_at
```

---

## stg_provider_leagues

```
provider
external_league_id
name
season
country
```

---

## stg_provider_teams

```
provider
external_team_id
name
country
league_external_id
```

---

## stg_provider_fixtures

```
provider
external_fixture_id
league_external_id
season
home_team_external_id
away_team_external_id
status
score
```

---

## stg_provider_players

```
provider
external_player_id
team_external_id
name
position
```

---

## stg_provider_odds

```
provider
fixture_external_id
bookmaker
market
outcome
odds
```

---

# 6. OPS SCHEMA – ORCHESTRACE

## ingest_targets

```
sport_code
provider
league_id
season
fixtures_days_back
fixtures_days_forward
```

---

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

---

## scheduler_queue

```
job_id
job_type
payload
status
created_at
```

---

## worker_locks

```
lock_name
owner_id
expires_at
heartbeat_at
```

---

## job_runs

```
job_name
started_at
finished_at
status
message
```

---

# 7. ANALYTICS SCHEMA

Obsahuje modelové a analytické výpočty.

---

## mm_team_ratings

```
team_id
league_id
rating
home_rating
away_rating
momentum
volatility
```

---

## mm_match_ratings

```
match_id
home_rating
away_rating
expected_home
expected_away
```

---

## ml_match_dataset_v2

dataset pro ML modely.

---

## ml_predictions

```
match_id
p_home
p_draw
p_away
model_version
```

---

# 8. TICKET ENGINE

## templates

```
id
name
description
```

---

## template_blocks

```
id
template_id
block_index
```

---

## template_block_matches

```
block_id
match_id
pick
```

---

## template_fixed_picks

```
template_id
match_id
pick
```

---

## generated_runs

```
run_id
created_at
status
```

---

## generated_tickets

```
ticket_id
run_id
probability
odds
expected_value
```

---

## generated_ticket_blocks

```
ticket_id
block_id
pick
```

---

# 9. TICKET INTELLIGENCE

## ticket_settlements

```
ticket_id
result
profit
```

---

## ticket_pattern_stats

```
pattern
hit_rate
roi
```

---

## ticket_league_pattern_stats

```
league_id
pattern
roi
```

---

## ticket_generation_runs

```
run_id
config
results
```

---

## ticket_variant_features

dataset pro ML model.

---

# 10. DATA RELATIONSHIPS

```
league → teams
teams → players
teams → matches
matches → events
matches → odds
matches → predictions
predictions → tickets
```

---

# 11. INDEX STRATEGY

Indexy jsou vytvořeny na:

```
match_id
team_id
league_id
season
timestamp
```

---

# 12. DATA FLOW

```
API
↓
stg_api_payloads
↓
stg_provider_tables
↓
merge pipeline
↓
public tables
↓
analytics tables
↓
predictions
↓
tickets
```

---

# 13. DATABASE GOALS

Databáze musí:

- být auditovatelná
- být rozšiřitelná
- podporovat více sportů
- podporovat více providerů

---

# 14. FINÁLNÍ ROLE DATABASE

MatchMatrix database je:

```
SPORT DATA WAREHOUSE
+
BETTING ANALYTICS ENGINE
+
ML TRAINING DATASET
```

---