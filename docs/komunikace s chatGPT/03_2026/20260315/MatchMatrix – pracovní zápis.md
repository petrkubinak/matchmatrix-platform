MatchMatrix – pracovní zápis
Datum

15.03.2026

1. Cíl dne

Rozšířit datovou pipeline o hráčskou vrstvu a vytvořit základ pro:

hráčské statistiky

sílu kádru

budoucí feature engineering pro Ticket Engine.

Cílem bylo:

dokončit player identity layer

naplnit player profiles

implementovat player season statistics pipeline

ověřit kvalitu dat přes audit SQL.

2. Player identity vrstva

Byl dokončen canonical model pro hráče.

Tabulky
public.players
public.player_provider_map
public.player_external_identity
Pipeline
staging.stg_provider_players
staging.stg_provider_player_profiles
        ↓
run_player_profiles_public_merge_v1.py
        ↓
public.players
public.player_provider_map
public.player_external_identity
Výsledek
public.players                559
public.player_provider_map    559
public.player_external_identity 27

Pipeline vytvořila automaticky chybějící hráče podle provider ID.

3. Player season statistics pipeline

Byla implementována nová pipeline pro sezonní statistiky hráčů.

Endpoint API:

api_football / players

Poznámka:

Tento endpoint vrací season-level statistiky, nikoli match-level.

3.1 Staging vrstva

Nová tabulka:

staging.stg_provider_player_season_stats

Obsahuje EAV model:

provider
sport_code
external_league_id
season
player_external_id
team_external_id
stat_name
stat_value
raw_payload_id
3.2 Parser worker

Soubor:

workers/run_player_season_statistics_stage_parser_v1.py

Pipeline:

stg_api_payloads
        ↓
player season parser
        ↓
stg_provider_player_season_stats
Výsledek parseru
payloads processed  : 8
rows inserted       : 3906

Parser správně ignoruje payloady s chybou free plánu (page > 3).

3.3 Public merge worker

Soubor:

workers/run_player_season_statistics_public_merge_v1.py

Pipeline:

stg_provider_player_season_stats
        ↓
grouping
        ↓
public.player_season_statistics
Výsledek merge
grouped rows      : 63
merged rows       : 63
public rows       : 60

Bez chyb:

skipped missing player : 0
skipped missing team   : 0
skipped missing league : 0
4. Audit dat

Byl vytvořen audit skript:

db/queries/audit_player_season_statistics_v1.sql

Audit ukázal:

rows                60
players             60
teams               16
leagues             1
season              2024
league              Segunda Liga

Coverage metrik:

appearances        1
minutes_played     1
rating             1
goals              1
assists            1

To znamená:

pipeline funguje

ale většina hráčů má prázdné statistiky.

5. Identifikované limity API

API-Football free plan má omezení:

players endpoint
max page = 3

Page 4 vrací:

Free plans are limited to a maximum value of 3 for the Page parameter

Navíc endpoint players vrací:

league + season aggregated statistics

ne:

match-level statistics

Proto nelze tento endpoint použít pro:

public.player_match_statistics
6. Aktuální architektura player layer
players identity
    ↓
player profiles
    ↓
player season statistics
Datové toky
API
 ↓
stg_api_payloads
 ↓
player season parser
 ↓
stg_provider_player_season_stats
 ↓
player season merge
 ↓
public.player_season_statistics
7. Stav projektu MatchMatrix

Po dnešku máme funkční:

Core data
sports
leagues
teams
matches
Player layer
players
player_provider_map
player_external_identity
player_season_statistics
Pipeline
ingest planner
payload storage
parsers
public merges

Systém je připraven pro další feature layer.

8. Další kroky
8.1 Audit raw player payload

Je potřeba ověřit:

zda API skutečně vrací statistiky jen pro část hráčů

nebo parser nečte všechny varianty JSON.

Kontrola:

stg_provider_player_season_stats
8.2 Encoding fix

Některé názvy týmů mají znaky:

Uni?o de Leiria

To naznačuje problém s:

UTF8 → client encoding

Bude potřeba opravit encoding pipeline.

8.3 Rozšíření player coverage

Naplánovat ingest pro více lig:

EU whitelist

aby se naplnila tabulka:

player_season_statistics

pro všechny ligy.

8.4 Player feature layer

Další krok pro Ticket Engine:

možné feature:

player_attack_index
player_defense_index
player_form
player_minutes_ratio
player_team_impact

Tyto feature budou počítány nad:

player_season_statistics
9. Shrnutí dne

Byla dokončena první plně funkční hráčská pipeline v MatchMatrix.

Hotovo:

player identity layer

player profiles merge

player season statistics parser

player season statistics merge

audit SQL

Systém je připraven na:

rozšíření ingestu

player feature engineering

budoucí predikční modely.