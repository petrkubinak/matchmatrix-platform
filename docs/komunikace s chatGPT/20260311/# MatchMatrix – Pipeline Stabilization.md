# MatchMatrix – Pipeline Stabilization & Control Panel
**Datum:** 2026-03-11  
**Fáze projektu:** Stabilizace datového pipeline + Control Panel orchestrace

---

# 1. Dokončení unified staging pipeline

Byla dokončena kompletní pipeline pro převod dat:


provider import
→ unified staging
→ public core


### Implementované kroky

#### Players bridge


staging.players_import
→ staging.stg_provider_players


Skript:


workers/run_players_bridge_v1.py


Funkce:

- normalizace hráčů z provider importu
- mapování `provider_player_id`
- upsert přes `(provider, external_player_id)`

---

#### Unified staging → public merge

Skript:


workers/run_unified_staging_to_public_merge_v1.py


Provádí merge:


stg_provider_leagues → public.leagues
stg_provider_teams → public.teams
stg_provider_players → public.players
stg_provider_fixtures → public.matches


Výsledek databáze:


public.leagues 2713
public.league_provider_map 1494

public.teams 5136
public.team_provider_map 2321

public.players 475
public.player_provider_map 475

public.matches 105146


---

# 2. Oprava MMR rating engine

Byl stabilizován skript:


ingest/compute_mmr_ratings.py


Engine počítá:

### Team ratings

Tabulka:


public.mm_team_ratings


Sloupce:


rating
rating_home
rating_away
momentum
volatility


Výsledek:


Saved mm_team_ratings: 5103


---

### Match ratings

Tabulka:


public.mm_match_ratings


Schema:


match_id
league_id
kickoff
home_team_id
away_team_id
home_rating
away_rating
rating_diff
created_at
home_rating_home
away_rating_away
home_momentum
away_momentum
home_volatility
away_volatility
ha_diff
momentum_diff
volatility_diff
volatility_sum


Výsledek:


Saved mm_match_ratings: 103422


---

# 3. Prediction pipeline

Skript:


ingest/predict_matches_V3.py


Použitý model:


baseline_logreg_v3


Feature dataset:


public.ml_match_predict_dataset_v1


Výsledek běhu:


Future matches loaded: 215
Inserted 215 predictions into public.ml_predictions


---

# 4. MatchMatrix Control Panel

Byl vytvořen orchestration panel pro pipeline.

Soubor:


tools/matchmatrix_control_panel.py


Panel umožňuje:

### CORE PIPELINE


Players bridge
Unified staging → public merge
Compute MMR ratings
Predict matches


### DAILY DATA (připraveno)


Pull fixtures
Pull odds
Pull historical data


### CONTEXT DATA (placeholder)


articles
injuries
comments
sentiment


### TICKET ENGINE (placeholder)


candidate pool
blocks
final tickets


---

# 5. Finální běh pipeline

Kompletní běh panelu:


Players bridge OK
Unified staging → public OK
Compute MMR ratings OK
Predict matches OK


Výsledek:


mm_match_ratings 103422
mm_team_ratings 5103
ml_predictions 215


Pipeline je nyní **stabilní a plně funkční**.

---

# 6. Architektura MatchMatrix (aktuální stav)

Datový tok:


DATA INGEST
↓
provider imports
↓
unified staging
↓
public core
↓
ratings engine
↓
prediction engine
↓
ticket engine (next phase)


---

# 7. Milník projektu

Byl dosažen zásadní milestone:

### MatchMatrix Core Pipeline

Je dokončeno:


data ingestion
unified staging
public core
rating engine
prediction engine
control panel orchestration


Systém je nyní připraven pro:


Ticket Engine layer


---

# 8. Další plán

Další fáze projektu:

### Ticket Engine

Plánované moduly:


candidate match pool
block generator
ticket combinator
probability optimizer
risk layer


---

# 9. Další technické kroky

Krátkodobé:


Control Panel V2.1
DB health check
run logs export
pipeline scheduling


Střednědobé:


context ingestion
sentiment layer
news signals
injury signals


---

# Shrnutí dne

Dnes byla dokončena kompletní stabilizace MatchMatrix pipeline.

Systém nyní dokáže:


automaticky ingestovat data
normalizovat entity
počítat ratingy
generovat predikce
spouštět pipeline z jednoho panelu


MatchMatrix je připraven na implementaci **Ticket Engine vrstvy**.

Pokud chceš, v dalším chatu ti rovnou připravím:

„Ticket Engine Architecture V1 přímo navrženou pro tvoji databázi a pipeline“

(což bude další velký krok projektu).