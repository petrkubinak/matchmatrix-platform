# MatchMatrix – New Chat Starter (posílej jako první zprávu v novém chatu)

## Prostředí
- Pracuji přes Docker
- Postgres container: matchmatrix_postgres (postgres:16)
- Redis container: matchmatrix_redis (redis:7)
- Spouštění SQL reportů běží přes: docker exec ... psql (psql není ve Windows)

## Orchestrace / wrappery
- C:\MATCHMATRIX-PLATFORM\wrappers\run_ingest_fixtures_all_targets.ps1
- C:\MATCHMATRIX-PLATFORM\wrappers\run_ingest_teams_all_targets.ps1
- Reporty:
  - C:\MATCHMATRIX-PLATFORM\system\run_reports.ps1  (docker exec)
  - C:\MATCHMATRIX-PLATFORM\system\RUN_DAILY_REPORT.bat
  - C:\MATCHMATRIX-PLATFORM\system\RUN_WEEKLY_REPORT.bat
  - C:\MATCHMATRIX-PLATFORM\system\RUN_ALL_REPORTS.bat
  - C:\MATCHMATRIX-PLATFORM\system\RUN_SYSTEM_CHECK.bat

## Databáze / řízení ingestu
- ops.ingest_targets: cíle ingestu (provider, run_group, enabled…)
- public.league_provider_map: mapování provider_league_id -> public.leagues.id

## Krátkodobý cíl
- EU start whitelist lig (fixtures historie 2022–2024 pro základ DB)
- Pak živý režim + odds

## Moje pravidla pro odpovědi (prosím dodržovat)
- Vždy napiš přesně: kam uložit, název souboru, jak spustit.
- V každém kódu přidej hlavičku-komentář (účel, umístění, spuštění, změny).
- Minimalizuj screenshoty; preferuj txt exporty (daily/weekly/system check).