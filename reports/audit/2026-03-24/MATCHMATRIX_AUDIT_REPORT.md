# TicketMatrixPlatform – technický audit

Datum a čas: 2026-03-24 23:26:21
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 1237
- NEW: 20
- MODIFIED: 1
- DELETED: 0

## Nejvýznamnější změny
- MODIFIED: workers\run_unified_staging_to_public_merge_v3.py
- NEW: db\checks\243_check_volleyball_by_sport_and_league.sql
- NEW: db\checks\244_check_vb_provider_maps.sql
- NEW: db\checks\245_check_vb_staging_teams.sql
- NEW: db\migrations\239_reset_vb_fixtures_planner_job_4137.sql
- NEW: db\migrations\240_check_volleyball_merge_result.sql
- NEW: db\ops\237_seed_ingest_planner_volleyball_fixtures.sql
- NEW: db\ops\241_seed_data_provider_api_volleyball.sql
- NEW: docs\komunikace s chatGPT\20260324\Denní Zápis - Aktuální stav (klíč).md
- NEW: ingest\API-Sport\pull_api_sport_teams.ps1
- NEW: legacy\workers\run_unified_staging_to_public_merge_v3.py
- NEW: MatchMatrix-platform\Dump\dump-matchmatrix-202603242325.sql
- NEW: MatchMatrix-platform\Dump\dump.ops-matchmatrix-202603242043.sql
- NEW: MatchMatrix-platform\Scripts\12_multisport\13_multisport_ingest_volleyball\237_seed_ingest_planner_volleyball_fixtures.sql
- NEW: MatchMatrix-platform\Scripts\12_multisport\13_multisport_ingest_volleyball\238_seed_data_provider_api_sport.sql
- NEW: MatchMatrix-platform\Scripts\12_multisport\13_multisport_ingest_volleyball\239_reset_vb_fixtures_planner_job_4137.sql
- NEW: MatchMatrix-platform\Scripts\12_multisport\13_multisport_ingest_volleyball\240_check_volleyball_merge_result.sql
- NEW: MatchMatrix-platform\Scripts\12_multisport\13_multisport_ingest_volleyball\241_seed_data_provider_api_volleyball.sql
- NEW: MatchMatrix-platform\Scripts\12_multisport\13_multisport_ingest_volleyball\243_check_volleyball_by_sport_and_league.sql
- NEW: MatchMatrix-platform\Scripts\12_multisport\13_multisport_ingest_volleyball\244_check_vb_provider_maps.sql

## Git
- Branch: main
- Last commit: 0715e1e | 2026-03-24 07:21:06 +0100 | %1
```
M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
 M MatchMatrix-platform/.dbeaver/project-metadata.json
 M ingest/API-Hockey/pull_api_hockey_leagues.ps1
 M ingest/providers/api_hockey_provider.py
 M ingest/providers/generic_api_sport_provider.py
 M ingest/run_unified_ingest_batch_v1.py
 M reports/audit/2026-03-24/MATCHMATRIX_AUDIT_REPORT.md
 M reports/audit/2026-03-24/MATCHMATRIX_PROGRESS.md
 M reports/audit/latest_audit_report.md
 M reports/audit/latest_progress_report.md
 M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
 D "spu\305\241t\304\233n\303\255 controln\303\255ho panelu.txt"
 D tree_matchmatrix.txt
 D unmatched_theodds_108.csv
 D unmatched_theodds_108.sql
 D unmatched_theodds_110.csv
 D unmatched_theodds_110.sql
 M workers/run_unified_staging_to_public_merge_v3.py
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/232_parse_api_sport_bk_fixtures.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/233_parse_api_hockey_leagues.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/234_parse_api_hockey_fixtures.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_volleyball/
?? db/checks/243_check_volleyball_by_sport_and_league.sql
?? db/checks/244_check_vb_provider_maps.sql
?? db/checks/245_check_vb_staging_teams.sql
?? db/migrations/232_parse_api_sport_bk_fixtures.sql
?? db/migrations/233_parse_api_hockey_leagues.sql
?? db/migrations/234_parse_api_hockey_fixtures.sql
?? db/migrations/236_parse_api_volleyball_fixtures.sql
?? db/migrations/239_reset_vb_fixtures_planner_job_4137.sql
?? db/migrations/240_check_volleyball_merge_result.sql
?? db/migrations/Script-9.sql
?? db/ops/237_seed_ingest_planner_volleyball_fixtures.sql
?? db/ops/241_seed_data_provider_api_volleyball.sql
?? "docs/komunikace s chatGPT/20260323/MATCHMATRIX \342\200\223 Z\303\201PIS (API-SPORT + AP.md"
?? "docs/komunikace s chatGPT/20260324/"
?? docs/visual/prilohy_267546.zip
?? ingest/API-Hockey/pull_api_hockey_fixtures.ps1
?? ingest/API-Sport/
?? legacy/workers/run_unified_staging_to_public_merge_v3.py
?? reports/audit/system_tree_2026-03-24_204041.txt
?? reports/audit/system_tree_2026-03-24_232620.txt
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2986
  - matches: 107095
  - players: 839
  - teams: 5369
- OPS counts:
  - ingest_planner: 3064
  - job_runs: 362
  - provider_jobs: 140
  - scheduler_queue: 6
- Player pipeline:
  - player_match_statistics: 0
  - players_import: 1360
  - public_players: 839
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