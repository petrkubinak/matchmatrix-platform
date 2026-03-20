# TicketMatrixPlatform – technický audit

Datum a čas: 2026-03-18 23:19:21
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 801
- NEW: 19
- MODIFIED: 0
- DELETED: 0

## Nejvýznamnější změny
- NEW: db\migrations\046_players_core_completion.sql
- NEW: db\migrations\046_players_db_finish.sql
- NEW: db\migrations\047_merge_player_season_statistics.sql
- NEW: db\migrations\047_players_staging_completion.sql
- NEW: db\migrations\048_players_merge_upserts.sql
- NEW: db\sql\046_merge_player_season_statistics_live.sql
- NEW: db\sql\046a_check_player_season_duplicates.sql
- NEW: db\sql\046b_deduplicate_player_season_statistics.sql
- NEW: db\sql\046e_fix_unique_correct.sql
- NEW: db\sql\048_check_players.sql
- NEW: db\sql\Script-14.sql
- NEW: docs\komunikace s chatGPT\20260318\schema.txt
- NEW: MatchMatrix-platform\Scripts\00_Schema\010_staging_api_football.sql\046a_check_player_season_duplicates.sql
- NEW: MatchMatrix-platform\Scripts\00_Schema\010_staging_api_football.sql\046c_add_unique_player_season_statistics.sql
- NEW: MatchMatrix-platform\Scripts\00_Schema\010_staging_api_football.sql\046d_fix_unique_wrong.sql
- NEW: MatchMatrix-platform\Scripts\00_Schema\010_staging_api_football.sql\046e_fix_unique_correct.sql
- NEW: MatchMatrix-platform\Scripts\00_Schema\010_staging_api_football.sql\047_merge_player_season_statistics.sql
- NEW: MatchMatrix-platform\Scripts\00_Schema\010_staging_api_football.sql\048_check_players.sql
- NEW: MatchMatrix-platform\Scripts\Script.sql

## Git
- Branch: main
- Last commit: ca41518 | 2026-03-17 10:32:39 +0100 | MatchMatrix ingest + players pipeline updates
```
M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
 M MatchMatrix-platform/.dbeaver/project-metadata.json
 D MatchMatrix-platform/Dump/dump-matchmatrix-202602272251_leagues.sql
 D MatchMatrix-platform/Dump/dump-matchmatrix-202602282349.sql
 D MatchMatrix-platform/Dump/dump-matchmatrix-202603012240.sql
 D MatchMatrix-platform/Dump/dump-matchmatrix-202603020927.sql
 D MatchMatrix-platform/Dump/dump-matchmatrix-202603022246.sql
 D MatchMatrix-platform/Dump/dump-matchmatrix-202603091608.sql
 M "docs/komunikace s chatGPT/20260311/MatchMatrix \342\200\223 pracovn\303\255 z\303\241pis.md"
 M fronted/matchmatrix-web/app/api/matches/today/route.ts
 M fronted/matchmatrix-web/app/api/matches/tomorrow/route.ts
 M fronted/matchmatrix-web/app/api/matches/week/route.ts
 M fronted/matchmatrix-web/app/globals.css
 M fronted/matchmatrix-web/app/layout.tsx
 M fronted/matchmatrix-web/app/page.tsx
 D "ingest/API-Football/Spou\305\241t\304\233c\303\255 p\305\231\303\255kaz - 009_merge_players.txt"
 D "ingest/API-Football/Spou\305\241t\304\233c\303\255 p\305\231\303\255kaz - fix_teammap_from_fixtures.ps1.txt"
 D "ingest/API-Football/Spou\305\241t\304\233c\303\255 p\305\231\303\255kaz - merge_only.ps1.txt"
 D "ingest/API-Football/Spou\305\241t\304\233c\303\255 p\305\231\303\255kaz - run_ingest_teams.txt"
 D ingest/API-Football/api_football_pull_v1.py
 M ingest/API-Football/pull_api_football_odds.ps1
 M ingest/API-Football/pull_api_football_players.ps1
 D ingest/API-Football/run_api_football_pipeline.ps1
 D ingest/API-Football/run_api_football_pipeline_V1.ps1
 D "ingest/API-Football/spou\305\241t\304\233n\303\255 a odkaz-run_api_football_pipeline.txt"
 D "ingest/API-Football/spou\305\241t\304\233n\303\255 run_ingest_fixtures_all_targets.ps1.txt"
 D "ingest/API-Football/spou\305\241t\304\233n\303\255-run_api_football_pipeline.txt"
 D ingest/predict_matches_V2.py
 D ingest/run_predict_matches.bat
 D ingest/run_theodds_parse.bat
 D ingest/run_theodds_parse_multi.bat
 D ingest/run_train_gbm_v1.bat
 D ingest/run_train_gbm_v2.bat
 D "ingest/spou\305\241t\304\233c\303\255_pull_skript_pro_jednu_ligu.txt"
 D ingest/theodds_parse.py
 D ingest/theodds_parse_multi.py
 D ingest/train_gbm_v1.py
 D ingest/train_gbm_v2.py
 D ingest/unmatched_theodds_105.csv
 D ingest/unmatched_theodds_105.sql
 D ingest/unmatched_theodds_107.csv
 D ingest/unmatched_theodds_107.sql
 D workers/run_legacy_to_staging_bridge.py
 D workers/run_multisport_scheduler.py
 D workers/run_multisport_scheduler_v2.py
 D workers/run_multisport_scheduler_v3.py
 D workers/run_players_bridge_v1.py
 D workers/run_scheduler_queue_executor.py
 D workers/run_unified_staging_to_public_merge_v1.py
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603122251.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603122252.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603132305.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603132306.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603150829.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603151432.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603160648.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603162300.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603172219.sql
?? MatchMatrix-platform/Dump/dump.ops-matchmatrix-202603181139.sql
?? MatchMatrix-platform/Dump/dump.ops-matchmatrix-202603181140.sql
?? MatchMatrix-platform/Dump/dump.public-matchmatrix-202603172216.sql
?? MatchMatrix-platform/Dump/dump_ops-matchmatrix-202603112252.sql
?? MatchMatrix-platform/Dump/dump_ops-matchmatrix-202603131533.sql
?? MatchMatrix-platform/Scripts/00_Schema/001_create_tables_tickets/082_refresh_frontend_match_views_with_team_logos.sql
?? MatchMatrix-platform/Scripts/00_Schema/001_create_tables_tickets/083_public_v_fd_matches_week_with_odds.sql
?? MatchMatrix-platform/Scripts/00_Schema/001_create_tables_tickets/090_v_fd_matches_week_ui.sql
?? MatchMatrix-platform/Scripts/00_Schema/001_create_tables_tickets/092_backfill_public_teams_logo_url_from_api_football.sql
?? MatchMatrix-platform/Scripts/00_Schema/010_staging_api_football.sql/038_alter_stg_provider_player_stats_for_match_merge.sql
?? MatchMatrix-platform/Scripts/00_Schema/010_staging_api_football.sql/039_create_player_season_statistics.sql
?? MatchMatrix-platform/Scripts/00_Schema/010_staging_api_football.sql/046a_check_player_season_duplicates.sql
?? MatchMatrix-platform/Scripts/00_Schema/010_staging_api_football.sql/046c_add_unique_player_season_statistics.sql
?? MatchMatrix-platform/Scripts/00_Schema/010_staging_api_football.sql/046d_fix_unique_wrong.sql
?? MatchMatrix-platform/Scripts/00_Schema/010_staging_api_football.sql/046e_fix_unique_correct.sql
?? MatchMatrix-platform/Scripts/00_Schema/010_staging_api_football.sql/047_merge_player_season_statistics.sql
?? MatchMatrix-platform/Scripts/00_Schema/010_staging_api_football.sql/048_check_players.sql
?? MatchMatrix-platform/Scripts/00_Schema/020_provider_maps.sql/037_players_multisource_foundation.sql
?? MatchMatrix-platform/Scripts/00_Schema/020_provider_maps.sql/038_players_enrichment_reseed_squads_team_based.sql
?? MatchMatrix-platform/Scripts/00_Schema/030_ingest_schema.sql/035_ops_create_ingest_planner.sql
?? MatchMatrix-platform/Scripts/00_Schema/030_ingest_schema.sql/036_ops_create_worker_locks.sql
?? MatchMatrix-platform/Scripts/00_Schema/030_ingest_schema.sql/037_ops_insert_job_ingest_cycle_v2.sql
?? MatchMatrix-platform/Scripts/00_Schema/030_ingest_schema.sql/038_ops_create_dashboard_views.sql
?? MatchMatrix-platform/Scripts/00_Schema/030_ingest_schema.sql/039_ops_insert_job_unified_staging_to_public_merge.sql
?? MatchMatrix-platform/Scripts/07_audity/078_audit_player_season_statistics_v1.sql
?? MatchMatrix-platform/Scripts/07_audity/079_audit_player_season_statistics_report_v1.sql
?? MatchMatrix-platform/Scripts/07_audity/080_debug_player_stats_merge_mapping_v1.sql
?? MatchMatrix-platform/Scripts/07_audity/081_fix_player_season_statistics_merge_v1.sql
?? MatchMatrix-platform/Scripts/10_sql/sql_players_pipeline_audit_queries.sql
?? MatchMatrix-platform/Scripts/11_ops/
?? MatchMatrix-platform/Scripts/99_playground/099_kontrola_ingest_planneru.sql
?? MatchMatrix-platform/Scripts/99_playground/099_kontrola_running_planneru_a_zruseni.sql
?? "MatchMatrix-platform/Scripts/99_playground/099_vr\303\241cen\303\255_konkr\303\251tn\303\255_jobu_zp\304\233t.sql"
?? MatchMatrix-platform/Scripts/99_playground/cleanup_player_season_stats_scope_95_2024_v1.sql
?? MatchMatrix-platform/Scripts/Script.sql
?? db/audit/
?? db/migrations/024_ops_create_ingest_entity_plan.sql
?? db/migrations/036_ops_extend_stg_provider_players.sql
?? db/migrations/037_players_multisource_foundation.sql
?? db/migrations/038_players_enrichment_reseed_squads_team_based.sql
?? db/migrations/046_players_core_completion.sql
?? db/migrations/046_players_db_finish.sql
?? db/migrations/047_merge_player_season_statistics.sql
?? db/migrations/047_players_staging_completion.sql
?? db/migrations/048_players_merge_upserts.sql
?? db/migrations/081_alter_public_teams_add_logo_url.sql
?? db/migrations/082_refresh_frontend_match_views_with_team_logos.sql
?? db/migrations/083_public_v_fd_matches_week_with_odds.sql
?? db/migrations/092_backfill_public_teams_logo_url_from_api_football.sql
?? db/ops/
?? db/queries/
?? db/sql/046_merge_player_season_statistics_live.sql
?? db/sql/046a_check_player_season_duplicates.sql
?? db/sql/046b_deduplicate_player_season_statistics.sql
?? db/sql/046e_fix_unique_correct.sql
?? db/sql/048_check_players.sql
?? db/sql/114_sql_players_pipeline_audit_queries.sql
?? db/sql/Script-14.sql
?? db/views/090_v_fd_matches_week_ui.sql
?? docs/GitHub/
?? "docs/komunikace s chatGPT/20260312/"
?? "docs/komunikace s chatGPT/20260313/"
?? "docs/komunikace s chatGPT/20260314/"
?? "docs/komunikace s chatGPT/20260315/"
?? "docs/komunikace s chatGPT/20260316/"
?? "docs/komunikace s chatGPT/20260317/"
?? "docs/komunikace s chatGPT/20260318/"
?? docs/visual/
?? fronted/dashboard_preview.html
?? fronted/vzor.html
?? ingest/API-Football/pull_api_football_players_squads_v1.py
?? ingest/API-Football/pull_api_football_players_v4.py
?? ingest/API-Football/test_api_football_players_access.py
?? ingest/providers/
?? ingest/run_unified_ingest_batch_v1.py
?? ingest/run_unified_ingest_v1.py
?? ops_admin/MatchMatrix_Mission_Control_V6.vbs
?? ops_admin/MatchMatrix_Mission_Control_V7.vbs
?? ops_admin/panel_matchmatrix_audit_v6.py
?? ops_admin/panel_matchmatrix_audit_v7.py
?? programs/icofxsetup.exe
?? reports/audit/
?? reports/file_audit/
?? reports/player_audit/
?? run_player_audit_report.bat
?? tools/matchmatrix_control_panel_V3.py
?? tools/matchmatrix_control_panel_V4.py
?? tools/run_matchmatrix_control_panel_V3.bat
?? tools/run_matchmatrix_panel_V4.bat
?? tree_matchmatrix.txt
?? workers/build_ingest_planner_jobs.py
?? workers/build_player_enrichment_jobs.py
?? workers/extract_missing_teams_from_fixtures_v1.py
?? workers/extract_teams_from_fixtures.py
?? workers/extract_teams_from_fixtures_v2.py
?? workers/pull_api_football_players_v4.py
?? workers/repair_missing_teams_from_fixtures_v2.py
?? workers/run_audit_player_season_statistics_report_docker_v1.ps1
?? workers/run_audit_player_season_statistics_report_v1.ps1
?? workers/run_ingest_cycle_v3.py
?? workers/run_ingest_planner_jobs.py
?? workers/run_multisport_scheduler_v4.py
?? workers/run_player_match_statistics_public_merge_v1.py
?? workers/run_player_profiles_public_merge_v1.py
?? workers/run_player_season_statistics_public_merge_v1.py
?? workers/run_player_season_statistics_stage_parser_v1.py
?? workers/run_players_bridge_v4.py
?? workers/run_players_public_merge_v2.py
?? workers/run_players_season_stats_bridge_v3.py
?? workers/run_unified_staging_to_public_merge_v3.py
?? workers/test_db_connection.py
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2713
  - matches: 107089
  - players: 559
  - teams: 5234
- OPS counts:
  - ingest_planner: 875
  - job_runs: 166
  - provider_jobs: 39
  - scheduler_queue: 6
- Player pipeline:
  - player_match_statistics: 0
  - players_import: 820
  - public_players: 559
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