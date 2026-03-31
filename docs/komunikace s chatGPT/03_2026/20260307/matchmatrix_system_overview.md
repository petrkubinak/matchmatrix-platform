# MatchMatrix -- Kompletní technický přehled systému

## 1. Účel projektu

MatchMatrix je datová a analytická platforma pro sportovní data a
betting intelligence. Cílem je vytvořit systém, který:

-   sbírá sportovní data z více API
-   normalizuje je do jednotné databáze
-   počítá ratingy týmů a lig (MMR)
-   trénuje ML modely pro predikci zápasů
-   analyzuje kurzy bookmakerů
-   generuje optimální tikety
-   učí se z historických tiketů

Primární monetizace: - generování tiketů - analytické služby - predikční
API - prodej datových modelů

------------------------------------------------------------------------

# 2. Architektura systému

## 2.1 Data Providers

Externí zdroje dat:

-   API-Football
-   TheOdds API
-   Football-data
-   Transfermarkt
-   další poskytovatelé

Data obsahují:

-   ligy
-   týmy
-   zápasy
-   statistiky
-   kurzy bookmakerů

------------------------------------------------------------------------

# 3. Data Ingest Layer

Ingest pipeline:

1.  stáhne data z API
2.  uloží RAW payload
3.  normalizuje strukturu
4.  uloží do databáze

### hlavní tabulky

-   api_raw_payloads
-   api_import_runs
-   matches
-   teams
-   leagues
-   odds

### funkce ingestu

-   deduplikace
-   mapování týmů (alias systém)
-   mapování bookmakerů
-   logování importů

------------------------------------------------------------------------

# 4. Rating Engine (MMR)

MatchMatrix používá vlastní rating systém.

## rating komponenty

-   team_rating_total
-   team_rating_home
-   team_rating_away
-   momentum
-   volatility

### vlastnosti

-   rating počítán per liga
-   dynamický model remíz
-   momentum (EWMA)
-   volatilita formy týmu

### tabulky

mm_match_ratings

-   match_id
-   home_rating
-   away_rating
-   rating_diff
-   momentum
-   volatility

mm_team_ratings

-   league_id
-   team_id
-   rating
-   rating_home
-   rating_away
-   momentum
-   volatility

------------------------------------------------------------------------

# 5. Feature Engineering Layer

Vytváří ML dataset.

dataset view:

ml_match_dataset_v2

### příklady feature

-   last5_points
-   last5_goal_diff
-   rest_days
-   h2h goal diff
-   rating_diff
-   momentum_diff

------------------------------------------------------------------------

# 6. Machine Learning Layer

Modely pro predikci výsledku.

## modely

GBM v1\
GBM v2 (weighted)\
GBM v3 (weighted + calibrated)

predikují:

-   p_home
-   p_draw
-   p_away

model uložen jako:

artifacts/gbm_v3.joblib

------------------------------------------------------------------------

# 7. Prediction Layer

Pipeline:

1.  načte budoucí zápasy
2.  aplikuje model
3.  uloží pravděpodobnosti

tabulka:

ml_predictions

sloupce:

-   model_code
-   run_ts
-   match_id
-   p_home
-   p_draw
-   p_away

------------------------------------------------------------------------

# 8. Betting Data Layer

Obsahuje kurzy bookmakerů.

tabulky:

-   bookmakers
-   markets
-   market_outcomes
-   odds

příklad trhu:

market: h2h

outcomes:

-   1
-   X
-   2

------------------------------------------------------------------------

# 9. Ticket Intelligence Layer (návrh)

## tabulka tickets

ticket_id\
created_at\
strategy_code\
risk_level\
stake\
expected_value\
probability\
status

------------------------------------------------------------------------

## tabulka ticket_matches

ticket_match_id\
ticket_id\
match_id\
market_id\
outcome_id\
model_probability\
bookmaker_odds\
value_score

------------------------------------------------------------------------

## tabulka ticket_structures

structure_id\
name\
matches_count\
min_odds\
max_odds\
description

------------------------------------------------------------------------

## tabulka ticket_history

history_id\
ticket_id\
result\
profit_loss\
settled_at

------------------------------------------------------------------------

## tabulka ticket_patterns

pattern_id\
matches_count\
league_combination\
avg_odds\
hit_rate\
roi

------------------------------------------------------------------------

# 10. Ticket Engine (architektura)

Ticket Engine je hlavní produkt MatchMatrix.

## vstup

filtry:

-   počet zápasů
-   rozsah kurzů
-   ligy
-   typy trhů
-   rizikovost

## generování kombinací

algoritmus:

1.  vyber kandidátní zápasy
2.  spočítej value
3.  filtruj podle pravděpodobnosti
4.  generuj kombinace
5.  spočítej EV tiketu

### pravděpodobnost tiketu

P(ticket) = product(P(match))

### EV

EV = P(ticket) \* odds - (1 - P(ticket))

------------------------------------------------------------------------

# 11. Ticket Learning System

Systém se učí z historie.

vyhodnocuje:

-   úspěšnost struktur
-   úspěšnost lig
-   úspěšnost kurzových intervalů

výstup:

lepší generování tiketů.

------------------------------------------------------------------------

# 12. Celková architektura

DATA PROVIDERS → INGEST → DATABASE → RATING ENGINE → FEATURE ENGINEERING
→ ML MODELS → PREDICTIONS → ODDS ANALYSIS → TICKET GENERATOR → TICKET
LEARNING

------------------------------------------------------------------------

# 13. Roadmap

1.  rozšířit ingest
2.  dokončit ticket engine
3.  vytvořit API
4.  vytvořit web UI
5.  monetizace
