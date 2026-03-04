# MatchMatrix – API-Football Backfill (2026-03-04)

## Cíl
Dokončit historický backfill zápasů z API-Football do canonical vrstvy public.

Provider:
api_football

Data:
fixtures (zápasy)

Cílová tabulka:
public.matches

Whitelist lig:
EU_top + EU_exact_v1

Počet lig:
100

Sezona:
2024

---

# Stav na začátku

Ve staging vrstvě bylo velké množství dat:

staging.api_football_fixtures ≈ desítky tisíc záznamů

V public vrstvě však bylo jen malé množství zápasů z api_football, protože merge pipeline nebyla plně funkční.

---

# Identifikované problémy

## 1) Merge skript používal Windows cesty

Skript:

090_api_football_merge_run.sql

používal příkazy:

\i C:/...

Tyto cesty nejsou dostupné uvnitř Docker kontejneru Postgres.

Projev:

No such file or directory

Řešení:

Merge byl spouštěn streamováním SQL souborů z PowerShellu:

Get-Content ... -Raw | docker exec -i ... psql

---

## 2) Skript 034 měl pevné run_id

V souboru:

034_upsert_matches_api_football.sql

bylo natvrdo:

WHERE f.run_id = 98

Řešení:

změněno na:

WHERE f.run_id = :run_id

---

## 3) Chybějící team_provider_map

Velká část fixtures se nemergovala, protože chyběl záznam v:

public.team_provider_map

Diagnostika:

missing_league_map = 0
missing_team_map > 0

To znamenalo, že ligy existovaly, ale týmy nebyly namapované.

---

# Řešení

Byl vytvořen SQL fix, který:

1) najde chybějící team_id ve staging fixtures
2) vytvoří placeholder týmy:

Team <team_id>

3) vloží je do:

public.teams

4) vytvoří mapování:

public.team_provider_map

Poté byl znovu spuštěn merge skript:

034_upsert_matches_api_football.sql

---

# Kontrolní dotazy

## Kontrola staging vs public

SELECT
(SELECT COUNT(*) FROM staging.api_football_fixtures) AS staging_fixtures,
(SELECT COUNT(*) FROM public.matches WHERE ext_source='api_football') AS public_matches_api_football;

---

## Kontrola missing podle run_id

SELECT
f.run_id,
COUNT(DISTINCT f.fixture_id) AS staging_distinct,
COUNT(DISTINCT f.fixture_id)
FILTER (WHERE m.ext_match_id IS NULL) AS missing_in_public_now
FROM staging.api_football_fixtures f
LEFT JOIN public.matches m
ON m.ext_source='api_football'
AND m.ext_match_id = f.fixture_id::text
GROUP BY f.run_id
ORDER BY f.run_id;

---

# Stav na konci dne

Po opravě merge pipeline:

missing_in_public_now = 0

pro všechny runy.

Data z api_football jsou nyní plně zapsána v:

public.matches

---

# Architektura ingest pipeline

API-Football
↓
staging.api_football_fixtures
↓
merge skripty
031_upsert_leagues
032_upsert_teams
033_upsert_league_teams
034_upsert_matches
↓
public tabulky

public.leagues
public.teams
public.league_teams
public.matches

---

# Poznámky

Placeholder názvy týmů:

Team <id>

budou později nahrazeny správnými názvy při ingestu týmů nebo mapováním na canonical data (football_data).

---

# Další kroky

Backfill:

sezona 2023
sezona 2022

Denní režim:

ingest pouze aktuálních zápasů
update výsledků
central orchestrator pro všechny sporty

---

# Struktura projektu

ingest/API-Football
ingest/API-Hockey

Scripts/03_generation

staging schema
public schema

---

# Výsledek

Merge pipeline je funkční.
Historická data pro sezonu 2024 jsou úspěšně převedena do canonical databáze.