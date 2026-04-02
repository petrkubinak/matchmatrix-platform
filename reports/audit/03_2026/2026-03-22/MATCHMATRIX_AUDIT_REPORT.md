# TicketMatrixPlatform – technický audit

Datum a čas: 2026-03-22 20:08:26
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 1127
- NEW: 4
- MODIFIED: 5
- DELETED: 0

## Nejvýznamnější změny
- MODIFIED: ingest\API-Football\pull_api_football_players.ps1
- MODIFIED: ingest\parse_api_football_player_profiles_v1.py
- MODIFIED: workers\run_ingest_planner_jobs.py
- MODIFIED: workers\run_players_fetch_only_v1.py
- MODIFIED: workers\run_players_parse_only_v1.py
- NEW: db\migrations\204_add_photo_url_to_staging_players_import.sql
- NEW: docs\komunikace s chatGPT\20260322\MATCHMATRIX – NAVAZOVACÍ ZÁPIS .md
- NEW: ingest\API-Football\pull_api_football_players_v5.py
- NEW: MatchMatrix-platform\Scripts\12_multisport\13_multisport_ingest_hokej\204_add_photo_url_to_staging_players_import.sql

## Git
- Branch: main
- Last commit: 589e7bd | 2026-03-22 13:10:31 +0100 | update players pipeline
```
M ingest/API-Football/pull_api_football_players.ps1
 M ingest/parse_api_football_player_profiles_v1.py
 M reports/audit/latest_snapshot.txt
 M workers/run_ingest_planner_jobs.py
 M workers/run_players_fetch_only_v1.py
 M workers/run_players_parse_only_v1.py
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/204_add_photo_url_to_staging_players_import.sql
?? db/migrations/204_add_photo_url_to_staging_players_import.sql
?? "docs/komunikace s chatGPT/20260322/MATCHMATRIX \342\200\223 NAVAZOVAC\303\215 Z\303\201PIS .md"
?? ingest/API-Football/pull_api_football_players_v5.py
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2713
  - matches: 107089
  - players: 779
  - teams: 5238
- OPS counts:
  - ingest_planner: 628
  - job_runs: 236
  - provider_jobs: 78
  - scheduler_queue: 6
- Player pipeline:
  - player_match_statistics: 0
  - players_import: 1360
  - public_players: 779
  - stg_provider_players: 533
- API budget:
  - 2026-03-10 | american_football | used=0 | limit=100 | remaining=100
  - 2026-03-10 | baseball | used=0 | limit=100 | remaining=100
  - 2026-03-10 | basketball | used=0 | limit=40 | remaining=40
  - 2026-03-10 | cricket | used=0 | limit=100 | remaining=100
  - 2026-03-10 | esports | used=0 | limit=100 | remaining=100
  - 2026-03-10 | field_hockey | used=0 | limit=100 | remaining=100
  - 2026-03-10 | football | used=0 | limit=20 | remaining=20
  - 2026-03-10 | handball | used=0 | limit=100 | remaining=100
  - 2026-03-10 | hockey | used=0 | limit=40 | remaining=40
  - 2026-03-10 | mma | used=0 | limit=100 | remaining=100
  - 2026-03-10 | rugby | used=0 | limit=100 | remaining=100
  - 2026-03-10 | tennis | used=0 | limit=100 | remaining=100
  - 2026-03-10 | volleyball | used=0 | limit=100 | remaining=100

## Navigator
- Projekt root: FOUND | C:\MatchMatrix-platform
- Workers: FOUND | C:\MatchMatrix-platform\workers
- Ingest: FOUND | C:\MatchMatrix-platform\ingest
- API-Football: FOUND | C:\MatchMatrix-platform\ingest\API-Football
- DB: FOUND | C:\MatchMatrix-platform\db
- Reports: FOUND | C:\MatchMatrix-platform\reports
- OPS Admin: FOUND | C:\MatchMatrix-platform\ops_admin
- Frontend root: FOUND | C:\MatchMatrix-platform\fronted
- MatchMatrix web: FOUND | C:\MatchMatrix-platform\fronted\matchmatrix-web
- Docs: FOUND | C:\MatchMatrix-platform\docs
- Dump: FOUND | C:\MatchMatrix-platform\MatchMatrix-platform\Dump
- Scripts: FOUND | C:\MatchMatrix-platform\MatchMatrix-platform\Scripts