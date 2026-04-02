# TicketMatrixPlatform – technický audit

Datum a čas: 2026-03-25 20:16:26
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 1300
- NEW: 41
- MODIFIED: 8
- DELETED: 1

## Nejvýznamnější změny
- DELETED: MatchMatrix-platform\Scripts\11_ops\022_reset_hk_bk_teams_pending.sql
- MODIFIED: ingest\API-Hockey\pull_api_hockey_fixtures.ps1
- MODIFIED: ingest\API-Hockey\pull_api_hockey_teams.ps1
- MODIFIED: ingest\API-Sport\pull_api_sport_fixtures.ps1
- MODIFIED: ingest\providers\api_hockey_provider.py
- MODIFIED: ingest\run_unified_ingest_v1.py
- MODIFIED: tools\matchmatrix_control_panel_V9.py
- MODIFIED: workers\run_ingest_cycle_v3.py
- MODIFIED: workers\run_unified_staging_to_public_merge_v3.py
- NEW: db\debug\027_check_hk_team_targets.sql
- NEW: db\debug\028_promote_hk_team_target_league_6.sql
- NEW: db\debug\029_check_hk_after_teams_fix.sql
- NEW: db\debug\030_promote_hk_fixtures_target_league_6.sql
- NEW: db\debug\031_find_working_hk_fixtures_targets.sql
- NEW: db\debug\032_promote_hk_fixtures_target_league_59.sql
- NEW: db\debug\033_deprioritize_empty_hk_fixtures_targets.sql
- NEW: db\debug\034_check_bk_fixtures_planner.sql
- NEW: db\debug\035_seed_bk_fixtures_planner_from_targets.sql
- NEW: db\debug\036_check_last_bk_fixtures_payload.sql
- NEW: db\debug\037_promote_bk_fixtures_target_117.sql

## Git
- Branch: main
- Last commit: 0715e1e | 2026-03-24 07:21:06 +0100 | %1
```
M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
 M MatchMatrix-platform/.dbeaver/project-metadata.json
 M ingest/API-Hockey/pull_api_hockey_leagues.ps1
 M ingest/API-Hockey/pull_api_hockey_teams.ps1
 M ingest/providers/api_hockey_provider.py
 M ingest/providers/generic_api_sport_provider.py
 M ingest/run_unified_ingest_batch_v1.py
 M ingest/run_unified_ingest_v1.py
 M reports/audit/2026-03-24/MATCHMATRIX_AUDIT_REPORT.md
 M reports/audit/2026-03-24/MATCHMATRIX_PROGRESS.md
 M reports/audit/latest_audit_report.md
 M reports/audit/latest_progress_report.md
 M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
 D "spu\305\241t\304\233n\303\255 controln\303\255ho panelu.txt"
 M tools/matchmatrix_control_panel_V9.py
 D tree_matchmatrix.txt
 D unmatched_theodds_108.csv
 D unmatched_theodds_108.sql
 D unmatched_theodds_110.csv
 D unmatched_theodds_110.sql
 M workers/run_ingest_cycle_v3.py
 M workers/run_unified_staging_to_public_merge_v3.py
?? MatchMatrix-platform/Scripts/11_ops/020_reset_vb_teams_pending.sql
?? MatchMatrix-platform/Scripts/11_ops/023_check_bk_planner_teams.sql
?? MatchMatrix-platform/Scripts/11_ops/026_check_bk_raw_payload.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/010_check_vb_staging_teams_after_fix.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/025_check_bk_stg_provider_teams.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/039_audit_multisport_planner_unification.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/040_unify_multisport_planner_teams_fixtures.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/232_parse_api_sport_bk_fixtures.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_basket/034_check_bk_fixtures_planner.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_basket/035_seed_bk_fixtures_planner_from_targets.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_basket/036_check_last_bk_fixtures_payload.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_basket/037_promote_bk_fixtures_target_117.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_basket/041_promote_bk_teams_target_12_deprioritize_40.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_basket/042_deduplicate_bk_teams_target_12.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_basket/250_insert_bk_test_planner_job.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/027_check_hk_team_targets.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/028_promote_hk_team_target_league_6.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/029_check_hk_after_teams_fix.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/030_promote_hk_fixtures_target_league_6.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/031_find_working_hk_fixtures_targets.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/032_promote_hk_fixtures_target_league_59.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/033_deprioritize_empty_hk_fixtures_targets.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/233_parse_api_hockey_leagues.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/234_parse_api_hockey_fixtures.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_volleyball/
?? db/checks/243_check_volleyball_by_sport_and_league.sql
?? db/checks/244_check_vb_provider_maps.sql
?? db/checks/245_check_vb_staging_teams.sql
?? db/debug/
?? db/migrations/232_parse_api_sport_bk_fixtures.sql
?? db/migrations/233_parse_api_hockey_leagues.sql
?? db/migrations/234_parse_api_hockey_fixtures.sql
?? db/migrations/236_parse_api_volleyball_fixtures.sql
?? db/migrations/239_reset_vb_fixtures_planner_job_4137.sql
?? db/migrations/240_check_volleyball_merge_result.sql
?? db/migrations/246_fix_vb_entity_plan_teams.sql
?? "db/migrations/246a_nastaven\303\255 entit.sql"
?? db/migrations/247_safe_backfill_entity_plan_base_sports.sql
?? db/migrations/250_insert_bk_test_planner_job.sql
?? db/migrations/Script-9.sql
?? db/ops/237_seed_ingest_planner_volleyball_fixtures.sql
?? db/ops/241_seed_data_provider_api_volleyball.sql
?? "docs/komunikace s chatGPT/20260323/MATCHMATRIX \342\200\223 Z\303\201PIS (API-SPORT + AP.md"
?? "docs/komunikace s chatGPT/20260324/"
?? "docs/komunikace s chatGPT/20260325/"
?? docs/visual/prilohy_267546.zip
?? ingest/API-Hockey/pull_api_hockey_fixtures.ps1
?? ingest/API-Sport/
?? legacy/workers/run_ingest_cycle_v3_1.py
?? legacy/workers/run_unified_staging_to_public_merge_v3.py
?? reports/audit/2026-03-25/
?? reports/audit/system_tree_2026-03-24_204041.txt
?? reports/audit/system_tree_2026-03-24_232620.txt
?? reports/audit/system_tree_2026-03-25_123722.txt
?? reports/audit/system_tree_2026-03-25_201624.txt
?? tools/run_check_psql.bat
?? workers/run_parse_api_sport_fixtures_v1.py
?? workers/run_parse_api_sport_teams_v1.py
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2986
  - matches: 108419
  - players: 839
  - teams: 5410
- OPS counts:
  - ingest_planner: 3084
  - job_runs: 443
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