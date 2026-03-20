# TicketMatrixPlatform – technický audit

Datum a čas: 2026-03-19 22:10:57
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 906
- NEW: 0
- MODIFIED: 0
- DELETED: 0

## Nejvýznamnější změny
- Bez změn proti minulému auditu.

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
 D MatchMatrix-platform/Scripts/00_Schema/010_staging_api_football.sql/10_staging_api_football.sql
 D "MatchMatrix-platform/Scripts/00_Schema/010_staging_api_hockey.sql/010_create_api_hockey_teams_raw.sql (voliteln\303\251)"
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
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603190810.sql
?? MatchMatrix-platform/Dump/dump.ops-matchmatrix-202603181139.sql
?? MatchMatrix-platform/Dump/dump.ops-matchmatrix-202603181140.sql
?? MatchMatrix-platform/Dump/dump.public-matchmatrix-202603172216.sql
?? MatchMatrix-platform/Dump/dump_ops-matchmatrix-202603112252.sql
?? MatchMatrix-platform/Dump/dump_ops-matchmatrix-202603131533.sql
?? MatchMatrix-platform/Scripts/00_Schema/001_create_tables_tickets/082_refresh_frontend_match_views_with_team_logos.sql
?? MatchMatrix-platform/Scripts/00_Schema/001_create_tables_tickets/083_public_v_fd_matches_week_with_odds.sql
?? MatchMatrix-platform/Scripts/00_Schema/001_create_tables_tickets/090_v_fd_matches_week_ui.sql
?? MatchMatrix-platform/Scripts/00_Schema/001_create_tables_tickets/092_backfill_public_teams_logo_url_from_api_football.sql
?? MatchMatrix-platform/Scripts/00_Schema/011_staging_api_football/
?? MatchMatrix-platform/Scripts/00_Schema/012_staging_api_hockey/
?? MatchMatrix-platform/Scripts/00_Schema/013_player_staging/
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
?? "MatchMatrix-platform/Scripts/99_playground/P\305\231epo\304\215\303\255t\303\241 a upsertne match_features pro z\303\241pasy v tabulce matches.sql"
?? MatchMatrix-platform/Scripts/99_playground/cleanup_player_season_stats_scope_95_2024_v1.sql
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
?? db/migrations/049_add_unique_index_stg_provider_player_stats.sql
?? db/migrations/050_merge_player_match_statistics.sql
?? db/migrations/055_parse_api_football_players_to_stg_player_season_stats.sql
?? db/migrations/057_add_unique_index_stg_provider_player_season_stats.sql
?? db/migrations/057_deduplicate_stg_provider_player_season_stats.sql
?? db/migrations/059_merge_player_season_statistics.sql
?? db/migrations/064_insert_missing_players_from_staging.sql
?? db/migrations/065_insert_missing_player_provider_map.sql
?? db/migrations/066_insert_player_provider_map_from_stats.sql
?? db/migrations/076_insert_missing_players_from_profiles.sql
?? db/migrations/081_alter_public_teams_add_logo_url.sql
?? db/migrations/081_insert_missing_players_from_existing_players_payloads.sql
?? db/migrations/082_insert_missing_player_provider_map.sql
?? db/migrations/082_refresh_frontend_match_views_with_team_logos.sql
?? db/migrations/083_merge_player_season_statistics_final.sql
?? db/migrations/083_public_v_fd_matches_week_with_odds.sql
?? db/migrations/088_insert_missing_teams_from_players_payloads.sql
?? db/migrations/089_insert_missing_team_provider_map.sql
?? db/migrations/090_merge_player_season_statistics_after_team_fix.sql
?? db/migrations/092_backfill_public_teams_logo_url_from_api_football.sql
?? db/migrations/095_merge_player_season_statistics_dedup_maps.sql
?? db/migrations/096_merge_player_season_stats_final_clean.sql
?? db/migrations/097_merge_player_season_stats_final_business_dedup.sql
?? db/ops/
?? db/queries/
?? db/sql/046_merge_player_season_statistics_live.sql
?? db/sql/046a_check_player_season_duplicates.sql
?? db/sql/046b_deduplicate_player_season_statistics.sql
?? db/sql/046e_fix_unique_correct.sql
?? db/sql/048_check_players.sql
?? db/sql/050_merge_player_external_identity.sql
?? db/sql/051_check_player_external_identity.sql
?? db/sql/051_check_player_stats_pipeline.sql
?? db/sql/052_check_player_source_payloads.sql
?? db/sql/053_preview_player_payload.sql
?? db/sql/054_preview_last_success_player_payload.sql
?? db/sql/056_check_player_season_stats_loaded.sql
?? db/sql/059a_check_player_season_statistics_columns.sql
?? db/sql/060_check_player_season_mapping_gaps.sql
?? db/sql/061_list_unmapped_players_for_provider_map.sql
?? db/sql/062_match_unmapped_players_to_existing.sql
?? db/sql/063_check_unmapped_players_presence.sql
?? db/sql/067_check_players_vs_stats_overlap.sql
?? db/sql/068_check_missing_stats_players_in_profiles.sql
?? db/sql/069_list_missing_player_profiles_for_ingest.sql
?? db/sql/070_distinct_missing_player_profile_ids.sql
?? db/sql/071_create_work_missing_player_profile_ids.sql
?? db/sql/072_export_missing_player_profile_ids.sql
?? db/sql/073_create_missing_player_profile_batches.sql
?? db/sql/075_check_player_profiles_loaded.sql
?? db/sql/077_check_loaded_profiles_overlap.sql
?? db/sql/080_check_player_profile_payload_quality.sql
?? db/sql/085_check_final_merge_gaps_after_player_fix.sql
?? db/sql/086_list_unmapped_teams_for_player_stats.sql
?? db/sql/091_check_player_season_statistics_count.sql
?? db/sql/092_check_merge_src_count.sql
?? db/sql/093_check_sports_mapping.sql
?? db/sql/098_check_duplicate_business_keys_in_src_raw.sql
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
?? "docs/komunikace s chatGPT/20260319/"
?? docs/visual/
?? fronted/dashboard_preview.html
?? fronted/vzor.html
?? ingest/API-Football/pull_api_football_players_squads_v1.py
?? ingest/API-Football/pull_api_football_players_v4.py
?? ingest/API-Football/test_api_football_players_access.py
?? ingest/parse_api_football_player_profiles_v1.py
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
?? workers/fetch_player_profiles_batch_from_db_v1.py
?? workers/fetch_player_profiles_by_ids_v1.py
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
  - players: 779
  - teams: 5238
- OPS counts:
  - ingest_planner: 875
  - job_runs: 166
  - provider_jobs: 39
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