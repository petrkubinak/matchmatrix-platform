# TicketMatrixPlatform – technický audit

Datum a čas: 2026-03-22 13:08:04
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 1123
- NEW: 24
- MODIFIED: 4
- DELETED: 22

## Nejvýznamnější změny
- DELETED: ingest\football_data_pull_V5.py
- DELETED: ingest\football_data_uk_history_pull.py
- DELETED: ingest\parse_api_sport_fixtures.py
- DELETED: ingest\parse_api_sport_leagues.py
- DELETED: ingest\predict_matches.py
- DELETED: ingest\run_football_data_pull_V5.bat
- DELETED: ingest\run_football_data_uk_history.bat
- DELETED: ingest\run_theodds.bat
- DELETED: ingest\run_theodds_parse_multi_V1.bat
- DELETED: ingest\theodds_parse_multi_V1.py
- DELETED: ingest\theodds_pull.py
- DELETED: ops\run_daily_ingest.py
- DELETED: ops\run_provider_job.py
- DELETED: workers\extract_missing_teams_from_fixtures_v1.py
- DELETED: workers\extract_teams_from_fixtures.py
- DELETED: workers\legacy_to_staging_bridge_report.txt
- DELETED: workers\repair_missing_teams_from_fixtures_v2.py
- DELETED: workers\run_full_ingest_pipeline.py
- DELETED: workers\run_legacy_to_staging_bridge_v2.py
- DELETED: workers\run_legacy_to_staging_odds_bridge.py

## Git
- Branch: main
- Last commit: 0ba44ab | 2026-03-22 00:08:31 +0100 | update players pipeline
```
M ingest/API-Football/pull_api_football_players.ps1
 M ingest/API-Hockey/pull_api_hockey_leagues.ps1
 M ingest/API-Hockey/pull_api_hockey_teams.ps1
 D ingest/football_data_pull_V5.py
 D ingest/football_data_uk_history_pull.py
 D ingest/parse_api_sport_fixtures.py
 D ingest/parse_api_sport_leagues.py
 D ingest/predict_matches.py
 D ingest/run_football_data_pull_V5.bat
 D ingest/run_football_data_uk_history.bat
 D ingest/run_theodds.bat
 D ingest/run_theodds_parse_multi_V1.bat
 M ingest/run_unified_ingest_batch_v1.py
 D ingest/theodds_parse_multi_V1.py
 D ingest/theodds_pull.py
 D ops/run_daily_ingest.py
 D ops/run_provider_job.py
 M reports/audit/2026-03-22/MATCHMATRIX_AUDIT_REPORT.md
 M reports/audit/2026-03-22/MATCHMATRIX_PROGRESS.md
 M reports/audit/latest_audit_report.md
 M reports/audit/latest_progress_report.md
 M reports/audit/latest_snapshot.txt
 M tools/matchmatrix_control_panel_V9.py
 D workers/extract_missing_teams_from_fixtures_v1.py
 D workers/extract_teams_from_fixtures.py
 D workers/legacy_to_staging_bridge_report.txt
 M workers/pull_api_football_players_v4.py
 D workers/repair_missing_teams_from_fixtures_v2.py
 D workers/run_full_ingest_pipeline.py
 M workers/run_ingest_cycle_v3.py
 D workers/run_legacy_to_staging_bridge_v2.py
 D workers/run_legacy_to_staging_odds_bridge.py
 D workers/run_payload_parser.py
 D workers/run_players_pipeline_full_v1.py
?? "docs/komunikace s chatGPT/20260321/matchmatrix - matchmatrix - ops.png"
?? "docs/komunikace s chatGPT/20260321/matchmatrix - matchmatrix - public.png"
?? "docs/komunikace s chatGPT/20260321/matchmatrix - matchmatrix - staging.png"
?? "docs/komunikace s chatGPT/20260322/"
?? legacy/
?? workers/run_players_fetch_only_v1.py
?? workers/run_players_parse_only_v1.py
?? workers/run_players_pipeline_transitional_v1.py
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
  - job_runs: 218
  - provider_jobs: 78
  - scheduler_queue: 6
- Player pipeline:
  - player_match_statistics: 0
  - players_import: 820
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