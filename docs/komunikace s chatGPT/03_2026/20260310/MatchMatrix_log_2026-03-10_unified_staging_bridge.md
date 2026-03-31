# MatchMatrix – pracovní zápis

## Datum: 10.03.2026

---

# 1. Cíl dne

Dokončit **sjednocení staging vrstvy** a převést historická data z původních sport-specifických tabulek do nového **unified staging modelu**.

Původní problém:

* každý sport měl vlastní strukturu
* football měl nejvíce tabulek
* hockey měl jiné názvy
* basketball zatím téměř nic

Cílem bylo vytvořit **jednotnou ingest architekturu**, aby bylo možné:

* ingestovat více sportů
* plánovat download přes scheduler
* sjednotit parser
* připravit data pro Ticket Engine.

---

# 2. Architektura databáze

Finální logická struktura:

```
public
  produkční tabulky

staging
  sjednocené ingest tabulky

ops
  orchestrace a scheduler

work
  pomocné pracovní tabulky
```

---

# 3. Unified staging tabulky

Vytvořeny a připraveny:

```
staging.stg_api_payloads

staging.stg_provider_leagues
staging.stg_provider_teams
staging.stg_provider_players
staging.stg_provider_fixtures
staging.stg_provider_odds
staging.stg_provider_events

staging.stg_provider_team_stats
staging.stg_provider_player_stats
```

Tyto tabulky jsou **nezávislé na sportu**.

---

# 4. Oprava indexů

Doplněny chybějící unikátní indexy pro správnou funkci `ON CONFLICT`.

Příklad:

```
(provider, external_league_id, season)
(provider, external_team_id)
(provider, external_fixture_id)
(provider, external_player_id)
```

---

# 5. Legacy → Unified staging bridge

Vytvořen worker:

```
workers/run_legacy_to_staging_bridge_v2.py
```

Tento skript převádí data z:

```
staging.api_football_leagues
staging.api_football_teams
staging.api_football_fixtures

staging.api_hockey_leagues
staging.api_hockey_teams
```

do:

```
staging.stg_provider_leagues
staging.stg_provider_teams
staging.stg_provider_fixtures
```

---

# 6. Řešené problémy

### 1️⃣ chybějící unique constraint

```
there is no unique or exclusion constraint matching the ON CONFLICT specification
```

vyřešeno vytvořením indexů.

---

### 2️⃣ duplicate rows

```
ON CONFLICT DO UPDATE command cannot affect row a second time
```

příčina:

* jeden tým existoval ve více sezónách

řešení:

```
SELECT DISTINCT ON (...)
```

aby bridge vybíral pouze jeden reprezentativní řádek.

---

# 7. Výsledek bridge

Po spuštění:

```
C:\MatchMatrix-platform\workers\run_legacy_to_staging_bridge_v2.py
```

stav unified staging:

```
stg_provider_leagues   = 1481
stg_provider_teams     = 974
stg_provider_fixtures  = 74583
```

Data jsou viditelná i v **DBeaveru** a odpovídají legacy tabulkám.

---

# 8. Stav ingest systému

Scheduler již funguje:

```
ops.scheduler_queue
ops.ingest_targets
ops.api_budget_status
```

Multi-sport scheduler:

```
run_multisport_scheduler_v3
```

fronta:

```
ops.scheduler_queue
```

executor:

```
run_scheduler_queue_executor_v2.py
```

---

# 9. API strategie

Cílem je využít **API SPORT PRO plán**.

Limity:

```
7500 requestů / den / sport
```

Cíl ingestu:

* co nejvíce sportů
* co nejvíce lig
* i nižší soutěže kvůli fanouškům

např.

```
football
hockey
basketball
tennis
mma
volleyball
cricket
field hockey
esports
baseball
american football
```

---

# 10. Datová strategie

Ke každému zápasu chceme postupně získat:

* fixtures
* teams
* leagues
* players
* odds
* match events
* team stats
* player stats
* články
* komentáře
* odkazy na oficiální stránky
* klubové znaky
* fan data

Cílem je vytvořit **bohatý datový profil zápasu**.

---

# 11. Další kroky

### 1️⃣ odds bridge

```
api_football_odds
→ stg_provider_odds
```

---

### 2️⃣ players bridge

```
players_import
player_provider_map_import
→ stg_provider_players
```

---

### 3️⃣ merge do produkčních tabulek

```
stg_provider_leagues → public.leagues
stg_provider_teams   → public.teams
stg_provider_fixtures → public.matches
```

---

### 4️⃣ sjednocení ingest pipeline

finální pipeline:

```
scheduler
→ provider download
→ stg_api_payloads
→ parser
→ stg_provider_*
→ public.*
```

---

# 12. Stav projektu

✔ multi-sport scheduler funguje
✔ unified staging model vytvořen
✔ legacy football data převedena
✔ legacy hockey data převedena
✔ databázová architektura stabilní

MatchMatrix je připraven na:

**masivní ingest dat přes API SPORT PRO.**

---

# Konec dne

Dnešní práce ukončena.

Další krok:
pokračovat implementací **odds + players bridge** a následně začít plnit **public databázi pro Ticket Engine**.
