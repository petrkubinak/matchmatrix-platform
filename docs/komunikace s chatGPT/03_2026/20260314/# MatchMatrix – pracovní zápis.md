# MatchMatrix – pracovní zápis

## Datum

14.03.2026

---

# 1. Cíl dne

Dokončit **Teams pipeline** a zapojit ji do hlavního ingest cyklu platformy.

Dříve byl problém, že:

* API endpoint `teams` někdy nevrátil všechny týmy
* některé týmy existovaly pouze ve `fixtures`
* databáze pak měla chybějící týmy

Řešení bylo vytvořit **fallback extractor**, který dokáže týmy získat přímo z payloadu fixtures.

---

# 2. Finální architektura ingest cyklu

Nový ingest cycle má tento tok:

```
run_ingest_planner_jobs.py
↓
run_unified_ingest_v1.py
↓
extract_teams_from_fixtures_v2.py
↓
run_unified_staging_to_public_merge_v3.py
↓
public databáze
```

To znamená:

1️⃣ Planner vybere joby
2️⃣ Unified ingest stáhne data z API
3️⃣ Teams extractor doplní týmy z fixtures
4️⃣ Merge zapíše data do produkčních tabulek

---

# 3. Nový hlavní ingest orchestrátor

## Soubor

```
C:\MatchMatrix-platform\workers\run_ingest_cycle_v3.py
```

## Funkce

* získá worker lock
* spustí planner worker
* spustí teams fallback extractor
* spustí staging → public merge
* zapíše audit do `ops.job_runs`

---

# 4. Teams fallback extractor

## Soubor

```
C:\MatchMatrix-platform\workers\extract_teams_from_fixtures_v2.py
```

## Funkce

Čte payload:

```
staging.api_football_fixtures.raw
```

a extrahuje:

```
teams.home.id
teams.home.name
teams.away.id
teams.away.name
```

Data zapisuje do:

```
staging.stg_provider_teams
```

pomocí **UPSERT**:

```
ON CONFLICT (provider, external_team_id)
DO UPDATE
```

Tím se zajistí, že:

* duplicitní tým se pouze aktualizuje
* pipeline je idempotentní
* fallback je bezpečný

---

# 5. Unified merge

## Soubor

```
C:\MatchMatrix-platform\workers\run_unified_staging_to_public_merge_v3.py
```

Provádí merge:

```
staging.stg_provider_leagues → public.leagues
staging.stg_provider_teams → public.teams
staging.stg_provider_players → public.players
staging.stg_provider_fixtures → public.matches
```

Další tabulky:

```
public.league_provider_map
public.team_provider_map
public.player_provider_map
public.league_teams
```

---

# 6. Aktuální stav databáze

Po posledním běhu ingest cyklu:

```
public.leagues:              2713
public.league_provider_map:  1494

public.teams:                5234
public.team_provider_map:    2419

public.players:              475
public.player_provider_map:  475

public.matches:              107089
```

---

# 7. Ověření ingest cycle

Test běhu:

```
python C:\MatchMatrix-platform\workers\run_ingest_cycle_v3.py --limit 10
```

Výsledek:

```
Processed planner jobs: 10
Teams extractor: YES
Merge executed: YES
Final status: OK
```

To potvrzuje, že:

* planner worker funguje
* teams fallback funguje
* merge funguje
* audit v `ops.job_runs` funguje

---

# 8. Players pipeline – diagnostika

Zjištěné hodnoty:

```
staging.players_import = 480
staging.stg_provider_players = 475
public.players = 475
```

Bridge skript:

```
C:\MatchMatrix-platform\workers\run_players_bridge_v1.py
```

dělá pouze:

```
players_import → stg_provider_players
```

Tzn. pipeline hráčů **technicky funguje**, ale ingest hráčů je velmi malý.

Root cause:

```
players source ingest je nedostatečný
```

pravděpodobně v:

```
pull_api_football_players.ps1
```

---

# 9. Finální stav pipeline

## Hotové

```
Leagues ingest ✔
Teams ingest ✔
Fixtures ingest ✔
Matches merge ✔
Planner ✔
Ingest cycle ✔
Teams fallback ✔
```

## Rozpracované

```
Players ingest
```

## Nezačaté

```
Odds ingest
Betting model
Ticket engine runtime
```

---

# 10. Struktura projektu

## Workers

```
C:\MatchMatrix-platform\workers\
```

obsahuje:

```
run_ingest_cycle_v3.py
run_ingest_planner_jobs.py
run_unified_staging_to_public_merge_v3.py
extract_teams_from_fixtures_v2.py
run_players_bridge_v1.py
```

---

## API ingest

```
C:\MatchMatrix-platform\ingest\
```

obsahuje:

```
run_unified_ingest_v1.py
```

a provider skripty:

```
ingest\API-Football\
```

např.:

```
pull_api_football_fixtures.ps1
pull_api_football_teams.ps1
pull_api_football_players.ps1
```

---

# 11. Databázová architektura

## public

produkční tabulky:

```
leagues
teams
players
matches
league_teams
team_provider_map
player_provider_map
league_provider_map
```

---

## staging

ingest tabulky:

```
stg_api_payloads
stg_provider_leagues
stg_provider_teams
stg_provider_players
stg_provider_fixtures
```

---

## ops

orchestrace systému:

```
jobs
job_runs
worker_locks
ingest_planner_jobs
```

---

# 12. Další krok (příště)

Další práce bude:

```
PLAYERS PIPELINE
```

konkrétně:

1️⃣ analyzovat `pull_api_football_players.ps1`
2️⃣ rozšířit ingest hráčů
3️⃣ doplnit parser players payload
4️⃣ zapojit players ingest do planneru

Cíl:

```
public.players > 20 000
```

---

# 13. Dlouhodobý roadmap

Po players pipeline bude následovat:

```
ODDS PIPELINE
```

která umožní:

```
value betting
EV model
ticket engine
```

---

# 14. Stav projektu

MatchMatrix je nyní funkční jako:

```
sportovní datová platforma
```

s:

```
multi-sport ingest
unified staging
planner orchestrací
produkční databází
```

Platforma je připravena pro další vrstvu:

```
prediction engine
betting intelligence
ticket generator
```

---

# Konec zápisu
