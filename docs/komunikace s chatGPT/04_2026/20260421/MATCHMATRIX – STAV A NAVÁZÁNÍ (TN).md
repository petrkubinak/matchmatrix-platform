MATCHMATRIX – STAV A NAVÁZÁNÍ (TN HOTOVO + CRICKET START)
📅 Datum

2026-04-21

🎾 TENNIS (TN) – CORE PIPELINE DOKONČENA
✅ Stav vrstev
1) Leagues (turnaje)
stav: PARTIAL
funguje přes RapidAPI search / fixtures
dostačující pro core
2) Teams (players jako teams)
stav: CONFIRMED
hráč = team model
napojeno na:
public.teams
public.team_provider_map
3) Fixtures (matches)
stav: CONFIRMED
pipeline:
RAW → staging → public.matches
plně kompatibilní se shared modelem
4) Odds
stav: CONFIRMED
Pipeline:
pull_api_tennis_odds_v1.py
RAW → public.api_raw_payloads
parser → public.odds
Důležité:
používá se:
home.fractionalValue
away.fractionalValue

převod:

decimal = 1 + (a / b)
výsledek:
správné decimal odds (např. 1.40, 2.75)
5) OPS audit
runtime_entity_audit:
leagues → PARTIAL
teams → CONFIRMED
fixtures → CONFIRMED
odds → CONFIRMED
players → PLANNED
sport_completion_audit:
TN core → DONE / READY
🧠 ZÁVĚR TN

👉 TN je plně připraven jako core sport:

jednotný model
reusable pipeline
kompatibilní s ticket enginem
⚠️ OTEVŘENÉ BODY (TN)
1 payload má jiný JSON shape (odds) → dořešit později
leagues nejsou plně řízený feed (zatím OK)
🏏 DALŠÍ KROK: CRICKET (CRK)
🎯 Důvod
api_sport cricket nepokrývá dostatečně / nefunguje
RapidAPI má lepší coverage
📦 Cíl (stejný model jako TN)

Postavit:

1) Leagues
staging.api_cricket_leagues
public.leagues
2) Teams
staging.api_cricket_teams
public.teams
public.team_provider_map
3) Fixtures
staging.api_cricket_fixtures
public.matches
4) Odds
public.api_raw_payloads
public.odds
🛠️ Implementační plán (CRICKET)
Krok 1

👉 vytvořit ingest složku:

C:\MatchMatrix-platform\ingest\API-Cricket\
Krok 2

vytvořit .env:

RAPIDAPI_CRICKET_HOST=...
RAPIDAPI_CRICKET_BASE=...
RAPIDAPI_KEY=...
Krok 3

vytvořit první worker:

pull_api_cricket_fixtures_v1.py
Krok 4

navázat:

parser fixtures
merge do public.matches
Krok 5

odds (později):

RAW pull
parser → public.odds
🔥 STRATEGIE (důležité)

👉 opakujeme TN model:

Python = ingest + parser
OPS = audit + planner
SQL = merge + kontrola
🚀 NAVÁZÁNÍ

👉 pokračujeme:

"pokračujeme CRK core – fixtures ingest"