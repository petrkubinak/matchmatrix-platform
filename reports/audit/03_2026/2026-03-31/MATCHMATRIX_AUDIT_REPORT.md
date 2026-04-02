# TicketMatrixPlatform – technický audit

Datum a čas: 2026-03-31 16:55:05
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 1539
- NEW: 21
- MODIFIED: 2
- DELETED: 0

## Nejvýznamnější změny
- MODIFIED: legacy\ingest\run_football_data_pull_V5.bat
- MODIFIED: MatchMatrix-platform\.dbeaver\project-metadata.json
- NEW: CSV výstup\5.csv
- NEW: db\debug\411_check_bundesliga_matches_vs_standings.sql
- NEW: db\fix\413_refresh_top8_league_standings_from_matches.sql
- NEW: db\ops\407_create_v_ops_dashboard_summary.sql
- NEW: db\ops\409_create_v_ops_dashboard_by_provider.sql
- NEW: db\ops\410_create_v_ops_panel_top_queue.sql
- NEW: db\ops\411_create_v_ops_panel_action_queue.sql
- NEW: db\ops\Script-5.sql
- NEW: docs\komunikace s chatGPT\03_2026\20260331\MatchMatrix – dnešní zápis.md
- NEW: legacy\ingest\football_data_pull_V6.py
- NEW: legacy\ingest\run_football_data_pull_and_refresh_top8.bat
- NEW: legacy\ingest\run_football_data_pull_V6.bat
- NEW: MatchMatrix-platform\Dump\Dump.public - 202603311654.sql
- NEW: MatchMatrix-platform\Scripts\11_ops\407_create_v_ops_dashboard_summary.sql
- NEW: MatchMatrix-platform\Scripts\11_ops\408_create_v_ops_dashboard_by_sport.sql
- NEW: MatchMatrix-platform\Scripts\11_ops\409_create_v_ops_dashboard_by_provider.sql
- NEW: MatchMatrix-platform\Scripts\11_ops\410_create_v_ops_panel_top_queue.sql
- NEW: MatchMatrix-platform\Scripts\11_ops\411_check_bundesliga_matches_vs_standings.sql

## Git
- Branch: main
- Last commit: 38bf38e | 2026-03-31 16:52:13 +0200 | update players pipeline
```
M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
?? reports/audit/system_tree_2026-03-31_165503.txt
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2986
  - matches: 105603
  - players: 1490
  - teams: 5428
- OPS counts:
  - ingest_planner: 3084
  - job_runs: 469
  - provider_jobs: 140
  - scheduler_queue: 6
- Player pipeline:
  - player_match_statistics: 0
  - players_import: 1546
  - public_players: 1490
  - stg_provider_players: 1465
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