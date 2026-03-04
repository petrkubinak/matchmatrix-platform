# MatchMatrix – Pipeline Overview

## 1) Backfill (historie) – jednorázově
Cíl: naplnit canonical DB pro výpočty statistik a modely.

```mermaid
flowchart TD
  A[API-Football / API-Hockey / ...] -->|ingest| B[(staging.*)]
  B -->|merge scripts| C[(public.* canonical)]
  C --> D[Derived views / materialized views]
  D --> E[Model features / analytics]
  E --> F[TicketMatrix / UI / API]
Poznámky

staging = landing zóna (RAW / fixtures)

public = canonical model (leagues/teams/matches/odds)

backfill běží typicky po sezonách (2024 → 2023 → 2022)

2) Daily Update (produkce) – průběžně

Cíl: aktualizovat jen nové a změněné zápasy (výsledky, statusy), minimum requestů.

flowchart TD
  A[Orchestrator / Scheduler] --> B[Ingest window: -2d..+7d]
  B --> C[(staging.* last run)]
  C --> D[Merge to public (upserts)]
  D --> E[Recompute derived stats (incremental)]
  E --> F[Export/cache for UI]

Produkční pravidla

pouze enabled soutěže (whitelist)

limit requestů per sport (např. 100/day)

retence staging (mazat staré runy / držet posledních N)

3) Složky v projektu (doporučený standard)
Ingest skripty (per sport)

C:\MatchMatrix-platform\ingest\API-Football\

C:\MatchMatrix-platform\ingest\API-Hockey\

další sporty stejný pattern

DB skripty (repo)

C:\MATCHMATRIX-PLATFORM\MatchMatrix-platform\Scripts\03_generation\...

C:\MATCHMATRIX-PLATFORM\MatchMatrix-platform\Scripts\09_Run\...

C:\MATCHMATRIX-PLATFORM\MatchMatrix-platform\Scripts\99_reports\...

Logy

C:\MatchMatrix-platform\logs\

api_football_backfill_status_YYYY-MM-DD_HHMMSS.txt

(později i denní logs pro orchestrátor)

4) Data vrstvy v DB
staging (landing)

staging.api_football_fixtures

(podobně pro další sporty)

public (canonical)

public.leagues

public.teams

public.league_teams

public.matches

public.odds (pokud používáme)

ops (operace / řízení)

ops.ingest_targets (co se má stahovat)

ops.job_runs (běhy ingest/merge)

5) Merge logika (zjednodušeně)

upsert leagues

upsert teams (+ provider map)

upsert league_teams

upsert matches

(optional) upsert odds

Každý merge běží nad run_id a výsledek se ověřuje reportem (missing=0).

6) Orchestrátor (budoucí stav)

Jednotný proces pro všechny sporty:

ingest (okno / targets)

merge

report + log

staging retention

Cíl: 1 konfigurace → více sportů, stejné chování.


### Poznámka k Mermaid diagramům
Mermaid se na GitHubu běžně renderuje, ale záleží na nastavení repa a vieweru. Když by se ti to nezobrazovalo, můžu ti poslat i ASCII diagram (vždy funguje) nebo obrázek.

---

## Bonus: ASCII diagram (když nechceš Mermaid)

```text
API (per sport)
   |
   v
staging.<provider>_<entity>   (landing / raw)
   |
   v
merge (031..034 + fix maps)
   |
   v
public.* (canonical)
   |
   v
derived stats / features
   |
   v
TicketMatrix UI / API / Models