MatchMatrix – Vývojový zápis

Datum: 2026-03-09
Fáze: Multi-sport ingest pipeline (API-SPORT → canonical DB)

1. Stav projektu na začátku dne

Projekt byl ve fázi rozšiřování ingest pipeline z fotbalu na více sportů.

Funkční části:

Docker infrastruktura

Postgres databáze

API runner (run_provider_job.py)

RAW ingest tabulky

api_import_runs

api_raw_payloads

Testován byl pouze football.

Cílem dne bylo:

připravit ingest pro více sportů

rozchodit fixtures parser

opravit mapování lig

vytvořit orchestraci ingestu.

2. API SPORT ingest – multi-sport

Byl rozšířen ingest tak, aby fungoval pro více sportů:

Aktivní sporty:

sport_id	code	sport
1	FB	Football
2	HK	Hockey
3	BK	Basketball
4	TN	Tennis

Testované sporty:

Football

Hockey

Basketball

3. Provider job runner

Skript:

ops/run_provider_job.py

byl upraven tak, aby:

podporoval query parametry

posílal parametr date

správně zapisoval api_import_runs

Byl přidán builder parametrů:

build_query_params()

který pro fixtures generuje:

date = today
4. Oprava API fixtures endpointu

Problém:

"errors": {"required": "Je vyžadován alespoň jeden parametr."}

Endpoint fixtures vyžaduje minimálně jeden parametr.

Vyřešeno:

/fixtures?date=YYYY-MM-DD
5. Parser leagues

Skript:

ingest/parse_api_sport_leagues.py

byl otestován pro všechny sporty.

Výsledky importu:

Football:

Leagues imported: 1219

Hockey:

Leagues imported: 262

Basketball:

Leagues imported: 427
6. Parser fixtures

Skript:

ingest/parse_api_sport_fixtures.py

Byl otestován na payloadu:

Payload ID: 623
Fixtures: 140

Výsledek:

Imported fixtures: 140
Skipped: 0
7. Problém – chybějící league mapping

Po prvním běhu bylo zjištěno:

matches_without_league = 94

Důvod:

některé ligy existovaly ve fixtures payloadu, ale nebyly v tabulce leagues.

8. Řešení – fallback vytvoření lig

Do parseru fixtures byla přidána funkce:

upsert_league_from_fixture()

Logika:

fixtures parser hledá ligu v public.leagues

pokud neexistuje

vytvoří ji přímo z fixture["league"]

Výsledek:

matches_without_league = 0
9. Final DB stav

Po ingestu:

leagues = 1219
teams   = 2418
matches = 1211

Rozdělení lig:

sport	leagues
Football	851
Hockey	231
Basketball	137
10. Denní ingest orchestrátor

Vytvořen skript:

ops/run_daily_ingest.py

Funkce:

spustí provider joby

stáhne RAW payloady

spustí parsers

naplní canonical tabulky

Pořadí:

leagues job
fixtures job
parse leagues
parse fixtures

Podporované sporty:

football
hockey
basketball

Spuštění:

python ops/run_daily_ingest.py
11. Struktura ingest pipeline

Finální datový tok:

API-SPORT
    ↓
api_import_runs
    ↓
api_raw_payloads
    ↓
parse_api_sport_leagues.py
parse_api_sport_fixtures.py
    ↓
public.leagues
public.teams
public.matches
12. Stav systému

Funkční:

multi-sport ingest

RAW payload storage

leagues parser

fixtures parser

fallback league creation

daily ingest orchestrator

Databáze nyní obsahuje reálná data pro:

football

hockey

basketball

13. Další plánovaný krok

Další vývoj bude pokračovat:

1️⃣ Standings parser

nový skript:

parse_api_sport_standings.py

Tabulka:

team standings
league tables
2️⃣ Odds ingest

přidat endpoint:

odds

pro value-bet pipeline.

3️⃣ Napojení na MatchMatrix prediction pipeline

Datový tok:

matches
→ match_features
→ predictions
→ value bets
→ ticket engine
14. Stav projektu

Projekt se dnes posunul z fáze:

prototyp ingestu

do fáze:

funkční multi-sport datová platforma

Canonical databáze nyní obsahuje:

ligy

týmy

zápasy

pro více sportů a je připravena na další vrstvy systému