# MatchMatrix – Project State

## Co je cílem
- Největší databáze soutěží a zápasů (multi-provider)
- UI výběr dle nabídky + predikce + statistiky
- Krátkodobě: EU start whitelist (mužské národní ligy), historie 2022–2024

## Providery
- football_data (historicky)
- api_football (aktuální ingest)

## Jak řídíme ingest
- ops.ingest_targets: co se stahuje (enabled + run_group + okna)
- public.league_provider_map: mapování provider_league_id -> public.leagues.id

## Run groups (EU start)
- EU_exact_v1_1 / EU_exact_v1_2
- EU_major_v4_A / EU_major_v4_B
- EU_national_1_2
- UKI_EN_1_4
- UKI_islands_1_2

## Wrappery (PS1)
- wrappers\run_ingest_fixtures_all_targets.ps1
- wrappers\run_ingest_teams_all_targets.ps1

## Denní rutina
- spustit report: MATCHMATRIX_DAILY_STATUS.sql
- zkontrolovat ops.job_runs
- poslat export do chatu

## Týdenní rutina
- MATCHMATRIX_WEEKLY_DIAGNOSTICS.sql
- řešit duplicity / missing mapy / chybové joby