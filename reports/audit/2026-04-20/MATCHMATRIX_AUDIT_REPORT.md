# TicketMatrixPlatform – technický audit

Datum a čas: 2026-04-20 12:04:10
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 3047
- NEW: 127
- MODIFIED: 4
- DELETED: 0

## Nejvýznamnější změny
- MODIFIED: ingest\API-Sport\pull_api_sport_fixtures.ps1
- MODIFIED: MatchMatrix-platform\.dbeaver\project-metadata.json
- MODIFIED: reports\614_worker_file_scan_v2.csv
- MODIFIED: workers\run_unified_staging_to_public_merge_v3.py
- NEW: db\audit\721_audit_hb_planner_queue.sql
- NEW: db\checks\000_check_hb_leagues_ingest_planner.sql
- NEW: db\checks\001_check_hb_leagues_public_after_run.sql
- NEW: db\checks\004_check_hb_leagues_after_sportcode_fix.sql
- NEW: db\checks\005_check_hb_teams_fixtures_after_leagues_fix.sql
- NEW: db\checks\006_check_hb_staging_fixtures_coverage.sql
- NEW: db\checks\008_check_hb_planner_vs_targets.sql
- NEW: db\checks\009_show_ingest_planner_schema.sql
- NEW: db\checks\011_check_hb_planner_refill.sql
- NEW: db\checks\012_show_hb_fixture_targets.sql
- NEW: db\checks\014_check_hb_targets_after_expand.sql
- NEW: db\checks\018_check_hb_fixture_team_mapping_after_parse.sql
- NEW: db\checks\019_check_latest_hb_payload_statuses.sql
- NEW: db\checks\024b_show_missing_hb_team_map_details.sql
- NEW: db\checks\025_check_missing_hb_team_ids_in_team_layers.sql
- NEW: db\checks\706_check_hb_team_provider_map_source_v2.sql

## Git
- Branch: main
- Last commit: 626bdfd | 2026-04-17 22:18:50 +0200 | update players pipeline
```
M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
 M MatchMatrix-platform/.dbeaver/project-metadata.json
 D MatchMatrix-platform/Scripts/07_Audity/718_audit_fb_run_group_distribution.sql
 D "docs/komunikace s chatGPT/04_2026/20260409/# 614 \342\200\223 CODE WORKER AUDIT CHECKLIST.txt"
 D "docs/komunikace s chatGPT/04_2026/20260409/MATCHMATRIX \342\200\223 Z\303\201PIS (2026-04-09).md"
 M ingest/API-Sport/pull_api_sport_fixtures.ps1
 M ingest/API-Sport/pull_api_sport_leagues.ps1
 M reports/audit/latest_audit_report.md
 M reports/audit/latest_progress_report.md
 M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
 M workers/run_unified_staging_to_public_merge_v3.py
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/000_check_hb_leagues_ingest_planner.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/001_check_hb_leagues_public_after_run.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/002_find_hb_leagues_merge_logic.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/004_check_hb_leagues_after_sportcode_fix.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/005_check_hb_teams_fixtures_after_leagues_fix.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/006_check_hb_staging_fixtures_coverage.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/008_check_hb_planner_vs_targets.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/009_show_ingest_planner_schema.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/010_refill_ingest_planner_from_targets_hb.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/011_check_hb_planner_refill.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/012_show_hb_fixture_targets.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/013_expand_hb_fixture_targets_to_full_scope.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/014_check_hb_targets_after_expand.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/018_check_hb_fixture_team_mapping_after_parse.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/019_check_latest_hb_payload_statuses.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/021_refill_hb_teams_planner_from_targets.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/024b_show_missing_hb_team_map_details.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/025_check_missing_hb_team_ids_in_team_layers.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/223_fb_team_provider_map_insert_safe_rerun_after_merges.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/701_hb_runtime_audit_confirmed.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/701_update_or_insert_runtime_entity_audit_hb_core_confirmed.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/702_hb_extend_ingest_targets_safe.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/702_insert_public_leagues_hb_core.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/703_insert_ingest_targets_hb_core_extension.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/704_fix_hb_target_131_canonical_league.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/705_insert_league_provider_map_hb_core.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/705a_insert_data_provider_api_handball.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/706_check_hb_team_provider_map_source_v2.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/706_insert_public_teams_hb_131_smoke.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/707_check_hb_teams_raw_and_staging_v2.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/707_insert_team_provider_map_hb_131_smoke.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/708_check_hb_teams_raw_parse_status.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/709_check_hb_teams_after_rerun.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/711_check_hb_teams_handball_code.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/712_check_hb_fixtures_merge_source.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/713_insert_public_matches_hb_131_smoke.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/hb_teams_from_fixtures_v2.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/711_audit_hb_runtime_start_fix1.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/712_audit_hb_runtime_reality.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/713_audit_hb_worker_binding.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/714_seed_runtime_entity_audit_hb_core_fix2.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/714_update_runtime_entity_audit_hb_public_merge_confirmed.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/715_check_hb_145_183_teams_after_pull.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/716_check_hb_planner_source.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/716_insert_public_teams_hb_145_183.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/717_check_hb_145_183_teams_after_batch.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/717_insert_team_provider_map_hb_145_183.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/718_audit_fb_run_group_distribution.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/718_check_hb_145_183_fixtures_after_error_batch.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/718_fix_hb_fixtures_date_window.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/719_insert_public_matches_hb_145_183.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/720_insert_hb_ingest_targets.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/721_audit_hb_planner_queue.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/722_audit_hb_planner_rows.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/723_insert_hb_ingest_planner.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/725_check_hb_payloads.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/727_expand_hb_ingest_targets.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/728_audit_hb_leagues_discovery.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/729_audit_hb_leagues_provider_coverage.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/730_audit_hb_leagues_payload_json.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/731_audit_hb_leagues_parse_filter.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/732_audit_hb_stg_provider_leagues_structure.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/733_audit_hb_active_leagues_2024.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/734_activate_hb_2024_leagues_safe.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_4_kontrola_runn\305\257_/716_check_hb_leagues_after_first_run.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_4_kontrola_runn\305\257_/716_check_hb_leagues_after_first_run_fix.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_4_kontrola_runn\305\257_/717_fix_hb_target_ehf_to_champions_league.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_5_pipeline_full/136_hb_full_pipeline.sql"
?? db/audit/711_audit_hb_runtime_start_fix1.sql
?? db/audit/712_audit_hb_runtime_reality.sql
?? db/audit/713_audit_hb_worker_binding.sql
?? db/audit/714_seed_runtime_entity_audit_hb_core_fix2.sql
?? db/audit/721_audit_hb_planner_queue.sql
?? db/checks/000_check_hb_leagues_ingest_planner.sql
?? db/checks/001_check_hb_leagues_public_after_run.sql
?? db/checks/004_check_hb_leagues_after_sportcode_fix.sql
?? db/checks/005_check_hb_teams_fixtures_after_leagues_fix.sql
?? db/checks/006_check_hb_staging_fixtures_coverage.sql
?? db/checks/008_check_hb_planner_vs_targets.sql
?? db/checks/009_show_ingest_planner_schema.sql
?? db/checks/011_check_hb_planner_refill.sql
?? db/checks/012_show_hb_fixture_targets.sql
?? db/checks/014_check_hb_targets_after_expand.sql
?? db/checks/018_check_hb_fixture_team_mapping_after_parse.sql
?? db/checks/019_check_latest_hb_payload_statuses.sql
?? db/checks/024b_show_missing_hb_team_map_details.sql
?? db/checks/025_check_missing_hb_team_ids_in_team_layers.sql
?? db/checks/706_check_hb_team_provider_map_source_v2.sql
?? db/checks/707_check_hb_teams_raw_and_staging_v2.sql
?? db/checks/708_check_hb_teams_raw_parse_status.sql
?? db/checks/709_check_hb_teams_after_rerun.sql
?? db/checks/711_check_hb_teams_handball_code.sql
?? db/checks/712_check_hb_fixtures_merge_source.sql
?? db/checks/715_check_hb_145_183_teams_after_pull.sql
?? db/checks/716_check_hb_planner_source.sql
?? db/checks/717_check_hb_145_183_teams_after_batch.sql
?? db/checks/717_fix_hb_target_ehf_to_champions_league.sql
?? db/checks/718_fix_hb_fixtures_date_window.sql
?? db/checks/Script-6.sql
?? db/fix/hb_teams_from_fixtures_v2.sql
?? db/migrations/002_find_hb_leagues_merge_logic.sql
?? db/migrations/010_refill_ingest_planner_from_targets_hb.sql
?? db/migrations/013_expand_hb_fixture_targets_to_full_scope.sql
?? db/migrations/021_refill_hb_teams_planner_from_targets.sql
?? db/migrations/701_hb_runtime_audit_confirmed.sql
?? db/migrations/701_update_or_insert_runtime_entity_audit_hb_core_confirmed.sql
?? db/migrations/702_hb_extend_ingest_targets_safe.sql
?? db/migrations/702_insert_public_leagues_hb_core.sql
?? db/migrations/703_insert_ingest_targets_hb_core_extension.sql
?? db/migrations/704_fix_hb_target_131_canonical_league.sql
?? db/migrations/705_insert_league_provider_map_hb_core.sql
?? db/migrations/705a_insert_data_provider_api_handball.sql
?? db/migrations/706_insert_public_teams_hb_131_smoke.sql
?? db/migrations/707_insert_team_provider_map_hb_131_smoke.sql
?? db/migrations/713_insert_public_matches_hb_131_smoke.sql
?? db/migrations/714_update_runtime_entity_audit_hb_public_merge_confirmed.sql
?? db/migrations/716_insert_public_teams_hb_145_183.sql
?? db/migrations/717_insert_team_provider_map_hb_145_183.sql
?? db/migrations/718_check_hb_145_183_fixtures_after_error_batch.sql
?? db/migrations/719_insert_public_matches_hb_145_183.sql
?? db/migrations/720_insert_hb_ingest_targets.sql
?? db/migrations/722_audit_hb_planner_rows.sql
?? db/migrations/723_insert_hb_ingest_planner.sql
?? db/migrations/725_check_hb_payloads.sql
?? db/migrations/727_expand_hb_ingest_targets.sql
?? db/migrations/728_audit_hb_leagues_discovery.sql
?? db/migrations/729_audit_hb_leagues_provider_coverage.sql
?? db/migrations/730_audit_hb_leagues_payload_json.sql
?? db/migrations/731_audit_hb_leagues_parse_filter.sql
?? db/migrations/732_audit_hb_stg_provider_leagues_structure.sql
?? db/migrations/733_audit_hb_active_leagues_2024.sql
?? db/migrations/734_activate_hb_2024_leagues_safe.sql
?? db/migrations/Script-6.sql
?? db/sql/136_hb_full_pipeline.sql
?? "docs/komunikace s chatGPT/04_2026/20260409-audit/"
?? "docs/komunikace s chatGPT/04_2026/20260417/"
?? "docs/komunikace s chatGPT/04_2026/20260418/"
?? "docs/komunikace s chatGPT/04_2026/20260419/"
?? "docs/komunikace s chatGPT/04_2026/20260420/"
?? "ingest/API-H\303\241zen\303\241/"
?? logs/api_football_backfill_status_2026-04-20_120307.txt
?? logs/api_football_backfill_status_2026-04-20_120327.txt
?? reports/audit/2026-04-18/
?? reports/audit/2026-04-19/
?? reports/audit/2026-04-20/
?? reports/audit/system_tree_2026-04-18_233249.txt
?? reports/audit/system_tree_2026-04-20_120408.txt
?? workers/run_parse_api_sport_leagues_v1.py
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 3205
  - matches: 114629
  - players: 2435
  - teams: 6822
- OPS counts:
  - ingest_planner: 4727
  - job_runs: 747
  - provider_jobs: 140
  - scheduler_queue: 6
- Player pipeline:
  - player_match_statistics: 0
  - players_import: 2506
  - public_players: 2435
  - stg_provider_players: 2410
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