MATCHMATRIX MASTER ARCHITECTURE MAP V1

Datum: 06.06.2026

1. EXECUTIVE SUMMARY
Co je MatchMatrix

Multisportovní datová platforma pro:

sportovní data
People vrstvu
Media vrstvu
Odds vrstvu
MMR/Rating vrstvu
Prediction vrstvu
Ticket Engine
Web platformu
Autonomous OPS
Hlavní cíl

Vytvořit jednotnou sportovní platformu s vlastní databází, autonomním harvestem a webem pro platící uživatele.

2. MASTER FILOZOFIE
JEDNA PRAVDA
↓
ops.database_object_governance

JEDEN PANEL
↓
V18 MASTER OPS PANEL

JEDEN MOZEK
↓
ops.v_autonomous_ops_brain_v5

JEDEN PLÁNOVAČ
↓
ops.ingest_planner

JEDNA FRONTA
↓
ops.scheduler_queue

JEDEN DATOVÝ TOK
↓
Provider → Raw → Staging → Public → Web
3. PROVIDER LAYER
Účel

Získávání dat.

Aktuální provideři

Football

API-Football
Football-Data

Basketball

API-Sport
SportsDataIO

Hockey

API-Hockey

Baseball

API-Baseball

Cricket

API-Cricket

American Football

API-American-Football

Odds

TheOdds

Media

Official Sites
RSS
4. RAW LAYER
Účel

Uložit přesnou odpověď providerů.

Provider
↓
RAW Payload

Vlastnosti:

bez úprav
audit
možnost reprocessingu
5. STAGING LAYER
Účel

Normalizace dat.

RAW
↓
STAGING

Tabulky:

stg_provider_fixtures
stg_provider_leagues
stg_provider_teams
stg_provider_players
stg_provider_odds
stg_media_articles

a další.

6. MERGE LAYER
Účel

Převod provider dat do kanonického modelu.

STAGING
↓
MERGE
↓
PUBLIC
7. PUBLIC LAYER
Hlavní produkční databáze

Obsahuje:

sports
countries
leagues
teams
matches
players
articles
odds
8. PEOPLE LAYER
Moduly

Players

Profiles

Photos

Season Stats

Match Stats

Rankings

Coaches

Řízení

MASTER:

ops.people_master_provider_matrix
ops.provider_people_audit
9. MEDIA LAYER
Moduly

Articles

Videos

Highlights

Team Linking

Player Linking

Match Linking

Zdroj:

RSS
Official Sites
10. ODDS LAYER
Moduly

Prematch Odds

Live Odds

Historical Odds

Bookmakers

Markets

11. MMR / ML LAYER
Výpočty

Team Rating

Player Rating

Match Rating

Predictions

Value Detection

Betting Edge

12. TICKET ENGINE
Funkce

Generování tiketů

Strategie

Settlement

Risk Scoring

Value Bets

13. WEB PLATFORM
Uživatel

Web

Mobil

API

Budoucí moduly

Profil

Předplatné

Oblíbené týmy

Oblíbení hráči

Notifikace

Komunitní obsah

Amatérské soutěže

14. OPS LAYER
Hlavní řízení systému

MASTER VIEW

v_autonomous_ops_brain_v5
v_provider_routing_master_v2
v_data_gap_engine_v2
v_people_pipeline_summary_v1
v_sport_completion_dashboard_v2
v_run_next_queue_v1
15. AUTONOMOUS BRAIN
Úloha

Automaticky rozhodovat:

co spustit
co zastavit
co opravit
kdy změnit provider
kdy čekat
16. GOVERNANCE LAYER
Hlavní pravda
ops.database_object_governance

Statusy:

ACTIVE_MASTER

ACTIVE_PANEL

ACTIVE

ACTIVE_REVIEW

LEGACY_KEEP

DROP_CANDIDATE

17. SECOND PC HARVEST SERVER

Role:

historical backfill
people harvest
media harvest
batch workers

Pravidlo:

ŽÁDNÝ PŘÍMÝ HARVEST

VŠE PŘES:

ops.ingest_planner
ops.scheduler_queue
ops.worker_locks
18. MASTER DATA FLOW
PROVIDER
↓
RAW
↓
STAGING
↓
MERGE
↓
PUBLIC
↓
PEOPLE
↓
MEDIA
↓
ODDS
↓
MMR
↓
PREDICTIONS
↓
TICKET ENGINE
↓
WEB
↓
OPS
↓
AUTONOMOUS BRAIN
19. RELEASE ROADMAP

2026

Červen

Governance
V18

Červenec

Massive Harvest

Srpen

Second PC

Září

Web Beta

Říjen

Closed Beta

Listopad

Public Beta

Prosinec

First Paying Users
20. LONG TERM VISION

MatchMatrix se stane jednotnou sportovní platformou kombinující:

Data
People
Media
Odds
AI
Predictions
Ticket Engine
Community
Amateur Competitions

v jednom ekosystému pro uživatele po celém světě.