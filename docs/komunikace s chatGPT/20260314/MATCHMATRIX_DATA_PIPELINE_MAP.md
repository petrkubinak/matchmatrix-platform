# MATCHMATRIX – DATA PIPELINE MAP

Autor: Petr Kubinák  
Projekt: MatchMatrix  
Dokument: Data Pipeline Map  
Verze: 1.0  
Datum: 2026

---

# 1. ÚČEL DOKUMENTU

Tento dokument popisuje kompletní datový tok systému MatchMatrix.

Cílem je:

- pochopit odkud přichází data
- jak jsou zpracována
- kde jsou uložena
- jak vznikají predikce
- jak vznikají tikety

Dokument popisuje celý tok:

API → INGEST → DATABASE → ML → TICKET ENGINE

---

# 2. HLAVNÍ DATA FLOW

```
DATA PROVIDERS
↓
INGEST TARGETS
↓
INGEST PLANNER
↓
SCHEDULER QUEUE
↓
INGEST WORKERS
↓
API REQUEST
↓
RAW PAYLOAD STORAGE
↓
PAYLOAD PARSER
↓
STAGING TABLES
↓
MERGE PIPELINE
↓
CANONICAL TABLES
↓
FEATURE ENGINEERING
↓
RATING ENGINE
↓
ML TRAINING
↓
PREDICTIONS
↓
ODDS ANALYSIS
↓
TICKET ENGINE
```

---

# 3. DATA PROVIDERS

MatchMatrix využívá externí sportovní API.

Aktuální provider:

```
API-Football
```

Budoucí providery:

```
API-Hockey
TheOdds API
Football-data
Transfermarkt
custom scrapers
```

Data získáváme přes HTTP API.

---

# 4. INGEST TARGETS

Tabulka:

```
ops.ingest_targets
```

Obsahuje seznam:

- lig
- sezón
- providerů
- rozsah dat

Příklad:

```
sport_code = football
provider = api_football
league_id = 39
season = 2024
```

---

# 5. INGEST PLANNER

Script:

```
build_ingest_planner_jobs.py
```

Vytváří plán ingest jobů.

Výstup:

```
ops.ingest_planner
```

Každý řádek = jeden ingest job.

---

# 6. SCHEDULER QUEUE

Tabulka:

```
ops.scheduler_queue
```

Obsahuje joby připravené ke spuštění.

Scheduler z ní vybírá joby.

---

# 7. WORKER EXECUTION

Script:

```
run_scheduler_queue_executor.py
```

Provádí:

```
SELECT job
FROM scheduler_queue
WHERE status = pending
LIMIT N
```

Worker pak spustí ingest.

---

# 8. API REQUEST

Worker zavolá provider.

Například:

```
GET /fixtures
GET /teams
GET /leagues
```

Odpověď API je JSON.

---

# 9. RAW PAYLOAD STORAGE

API odpověď se ukládá do:

```
stg_api_payloads
```

Obsah:

```
provider
sport_code
endpoint
payload_json
timestamp
```

Výhoda:

- audit
- debugging
- replay dat

---

# 10. PAYLOAD PARSER

Script:

```
run_payload_parser.py
```

Provádí:

```
JSON parse
↓
data normalization
↓
insert into staging tables
```

---

# 11. STAGING TABLES

Staging obsahuje data z providerů.

Tabulky:

```
stg_provider_leagues
stg_provider_teams
stg_provider_fixtures
stg_provider_players
stg_provider_odds
```

Staging data nejsou canonical.

---

# 12. MERGE PIPELINE

Script:

```
run_unified_staging_to_public_merge_v2.py
```

Provádí merge:

```
stg_provider_leagues → public.leagues
stg_provider_teams → public.teams
stg_provider_fixtures → public.matches
stg_provider_players → public.players
```

---

# 13. CANONICAL DATABASE

Canonical data jsou uložena v:

```
public schema
```

Hlavní tabulky:

```
leagues
teams
matches
players
```

---

# 14. FEATURE ENGINEERING

Script:

```
build_match_features.py
```

Vytváří dataset:

```
ml_match_dataset_v2
```

Obsahuje:

```
team ratings
form
goal difference
home advantage
```

---

# 15. RATING ENGINE

Script:

```
compute_mmr_ratings.py
```

Počítá rating týmů.

Tabulky:

```
mm_team_ratings
mm_match_ratings
```

---

# 16. MACHINE LEARNING

Script:

```
train_gbm_v3.py
```

Model:

```
Gradient Boosting
```

Predikuje:

```
P(home)
P(draw)
P(away)
```

---

# 17. PREDICTION PIPELINE

Script:

```
predict_matches_v3.py
```

Výstup:

```
ml_predictions
```

---

# 18. ODDS INGEST

Script:

```
pull_api_football_odds.ps1
```

Parser:

```
theodds_parse_multi.py
```

Výsledkem jsou:

```
bookmaker odds
```

---

# 19. ODDS ANALYSIS

Porovnává:

```
model probability
vs
bookmaker odds
```

Výsledkem:

```
value bets
expected value
```

---

# 20. TICKET ENGINE

Runtime generátor tiketů.

Tabulky:

```
templates
template_blocks
template_block_matches
generated_runs
generated_tickets
generated_ticket_blocks
```

Logika:

```
max 3 blocks
max 3 matches per block
27 ticket variants
```

---

# 21. TICKET INTELLIGENCE

Analytická vrstva.

Tabulky:

```
ticket_settlements
ticket_pattern_stats
ticket_league_pattern_stats
ticket_generation_runs
ticket_variant_features
```

Slouží pro:

- analýzu úspěšnosti tiketů
- trénink ML modelu

---

# 22. FINAL OUTPUT

Finální výstup systému:

```
predictions
value bets
recommended tickets
```

---

# 23. FRONTEND

Frontend aplikace používá:

```
React
```

Endpointy:

```
/matches
/predictions
/tickets
```

---

# 24. CELÝ PIPELINE TOK

```
API
↓
RAW PAYLOAD
↓
STAGING
↓
MERGE
↓
CANONICAL DATABASE
↓
FEATURE ENGINEERING
↓
RATING ENGINE
↓
ML PREDICTION
↓
ODDS ANALYSIS
↓
TICKET ENGINE
```

---

# 25. DALŠÍ VÝVOJ

Další kroky:

1 dokončit teams ingest  
2 dokončit players ingest  
3 dokončit odds ingest  
4 provést historický backfill  
5 implementovat ticket intelligence ML  

---

# 26. DLOUHODOBÁ VIZE

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