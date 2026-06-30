MatchMatrix – aktuální stav projektu (2026-03-05)
1. Architektura databáze

Projekt běží na PostgreSQL databázi matchmatrix rozdělené do několika logických částí:

public – hlavní produkční model

Obsahuje jádro systému:

Sportovní model

sports

countries

leagues

teams

matches

Mapování providerů

league_provider_map

team_provider_map

team_aliases

Bookmakeři a kurzy

bookmakers

markets

market_outcomes

odds

ML a analytika

ml_predictions

ml_match_dataset

ml_match_dataset_v2

ml_team_ratings

ml_value_latest_v1

ml_fair_odds_latest_v1

ml_block_candidates_latest_v1

Feature engineering

match_features

Views pro frontend

v_matches_base

v_matches_today

v_matches_tomorrow

v_matches_week

v_fd_matches_*

v_leagues_active_week

Tyto views jsou zdrojem pro Next.js API endpointy.

2. Ticket generator (kombinace sázek)

Plně připravený modul pro generování tiketů:

Tabulky:

templates

template_blocks

template_block_matches

template_feed_picks

Generování:

generated_runs

generated_tickets

generated_ticket_blocks

generated_ticket_fixes

generated_ticket_risk

Uživatelský výběr:

user_selections

Tento modul umožňuje:

generovat kombinace tiketů

pracovat s bloky zápasů

počítat pravděpodobnost a risk

3. Odds systém

Kurzy jsou ukládány v relační podobě:

odds
 match_id
 bookmaker_id
 market_outcome_id
 odd_value
 collected_at

Výhody:

více bookmakerů

historie kurzů

snadné porovnání

Existuje funkce:

mm_get_odds_compare(match_id, market_outcome_id)

která vrací nejlepší kurz napříč bookmakery.

4. Data ingest systém
tabulky pro řízení ingestu

jobs

job_runs

api_import_runs

api_raw_payloads

ingest konfigurace

ingest_targets

league_import_plan

pomocné tabulky

eu_batch_1

eu_batch_100

eu_keep_ids

api_football_coverage

Tyto tabulky řídí:

které ligy se stahují

kolik zápasů

jaký časový horizont

kolik API requestů

5. Providers
Football-Data

Používá se pro:

fixtures

základní ligy

týmy

Ligy mají:

ext_source = 'football_data'
ext_csv_code
API-Football

Používá se pro:

teams

fixtures

odds

Tabulky:

api_football_leagues

api_football_teams

api_football_fixtures

api_football_odds

RAW payloady jsou ukládány pro audit.

TheOdds API

Používá se pro:

bookmaker odds

Python ingest:

theodds_parse_multi_FINAL.py

Funkce:

načte theodds_key z leagues

stáhne odds

uloží RAW payload

naparsuje h2h market

mapuje týmy přes team_aliases

ukládá do odds

6. Frontend (Next.js)

Frontend běží na:

matchmatrix-web
Next.js 16

API endpointy:

/api/health/db
/api/leagues/active-week
/api/matches/today
/api/matches/tomorrow
/api/matches/week

Ty používají views:

v_matches_today
v_matches_tomorrow
v_matches_week

Frontend zobrazuje:

ligy

zápasy

výběr sázek (1 / X / 2 / 1X / 12 / X2)

Kurzy se mají zobrazovat po výběru bookmakeru.

7. ML / Predikce

Implementována základní infrastruktura:

Modelové výstupy:

ml_predictions

Dataset pro trénování:

ml_match_dataset
ml_match_dataset_v2

Derived views:

ml_value_latest_v1
ml_fair_odds_latest_v1
ml_block_candidates_latest_v1

Tyto výstupy budou použity pro:

predikci výsledků

value betting

výběr zápasů do bloků

8. Stav projektu
Hotovo

✔ databázový model
✔ ingest pipeline
✔ odds systém
✔ ticket generator
✔ ML feature dataset
✔ Next.js API
✔ základní frontend nabídky zápasů

Rozpracováno

ML predikční modely

integrace bookmakerů ve frontendu

UI ticket builder

generování variant tiketů

9. Cíl projektu

MatchMatrix má být systém pro:

analýzu fotbalových zápasů

výpočet pravděpodobností

generování sázek

optimalizaci tiketů

porovnání bookmaker odds