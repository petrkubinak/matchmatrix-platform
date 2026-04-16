# TicketMatrixPlatform – technický audit

Datum a čas: 2026-04-11 09:55:14
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 2305
- NEW: 67
- MODIFIED: 1
- DELETED: 0

## Nejvýznamnější změny
- MODIFIED: reports\614_worker_file_scan_v2.csv
- NEW: data\raw\api_american_football\fixtures\api_american_football_fixtures_league_1_season_2024_20260410_231121.json
- NEW: data\raw\api_american_football\teams\api_american_football_teams_league_1_season_2024_20260410_154500.json
- NEW: db\checks\127_update_or_insert_runtime_entity_audit_bk_teams_confirmed.sql
- NEW: db\checks\128_update_or_insert_runtime_entity_audit_bk_fixtures_confirmed.sql
- NEW: db\checks\129_update_or_insert_sport_completion_audit_bk_fixtures_core_done.sql
- NEW: db\checks\130_update_or_insert_sport_completion_audit_bk_teams_core_done.sql
- NEW: db\checks\131_update_or_insert_runtime_entity_audit_bk_leagues_confirmed.sql
- NEW: db\checks\132_update_runtime_entity_audit_bk_fixtures_batch_ok.sql
- NEW: db\checks\135_update_or_insert_runtime_entity_audit_vb_fixtures_confirmed.sq.sql
- NEW: db\checks\136_update_or_insert_runtime_entity_audit_vb_teams_confirmed.sql
- NEW: db\checks\137_update_or_insert_runtime_entity_audit_vb_leagues_confirmed.sql
- NEW: db\checks\139_update_or_insert_sport_completion_audit_vb_teams_core_done.sql
- NEW: db\checks\704_upsert_runtime_entity_audit_afb_teams.sql
- NEW: db\checks\707_upsert_runtime_entity_audit_afb_fixtures.sql
- NEW: db\checks\708_upsert_runtime_entity_audit_afb_leagues.sql
- NEW: db\checks\709_upsert_sport_completion_audit_afb_fix2.sql
- NEW: db\scripts\.112_runtime_audit_export_V2.ps1.txt
- NEW: db\sql\133_bk_full_pipeline.sql
- NEW: db\sql\134_vb_full_pipeline.sql

## Git
- Branch: main
- Last commit: 8b03f52 | 2026-04-06 21:54:00 +0200 | update players pipeline
```
D "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/575_create_v_harvest_e2e_control.sql"
 D ingest/API-Sport/pull_api_basketball_players.ps1
 M ingest/API-Sport/pull_api_sport_teams.ps1
 M ingest/TheOdds/theodds_parse_multi_V3.py
 M ingest/providers/generic_api_sport_provider.py
 M ingest/run_unified_ingest_batch_v1.py
 M ingest/run_unified_ingest_v1.py
 M reports/audit/latest_audit_report.md
 M reports/audit/latest_progress_report.md
 M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
 D reports/audit/system_tree_2026-04-01_103734.txt
 D reports/audit/system_tree_2026-04-01_205300.txt
 D reports/audit/system_tree_2026-04-02_074300.txt
 D reports/audit/system_tree_2026-04-02_112803.txt
 D reports/audit/system_tree_2026-04-02_235719.txt
 D reports/audit/system_tree_2026-04-04_090424.txt
 D reports/audit/system_tree_2026-04-04_235058.txt
 D reports/audit/system_tree_2026-04-05_231123.txt
 D reports/audit/system_tree_2026-04-06_120927.txt
 D reports/audit/system_tree_2026-04-06_191203.txt
 D reports/audit/system_tree_2026-04-06_211837.txt
 D reports/audit/system_tree_2026-04-06_215252.txt
?? "MATCHMATRIX \342\200\223 popis ORCHESTRACE INGESTU.md"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_2_coaches/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_3_players/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_4_kontrola_runn\305\257_/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_5_pipeline_full/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_6_sporty_cel\303\251_postupy/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/Script.sql"
?? data/
?? db/audit/601_reuse_audit_ops_core_status.sql
?? db/audit/602_harvest_final_classification.sql
?? db/audit/603_wave_planner_input.sql
?? db/audit/604_planner_seed_candidates.sql
?? db/audit/605_planner_seed_insert_preview.sql
?? db/audit/606_wave1_core_filter_preview.sql
?? db/audit/607_planner_seed_insert_core_preview.sql
?? db/audit/608_planner_seed_core_stage.sql
?? db/audit/610_provider_sport_entity_matrix.sql
?? db/audit/612_normalized_structure_matrix.sql
?? db/audit/613_runtime_build_backlog.sql
?? db/audit/616_hk_teams_public_merge_check_v2.sql
?? db/audit/701_audit_fb_players_ready_definition.sql
?? db/audit/702_audit_fb_players_pro_harvest_ready.sql
?? db/audit/706_audit_fb_players_wave1_coverage.sql
?? db/checks/110_seed_runtime_entity_audit_known_state.sql
?? db/checks/112_runtime_audit_master_quickcheck_v2.sql
?? db/checks/113_hk_fixtures_after_run_check_v2.sql
?? db/checks/115_update_runtime_entity_audit_hk_fixtures_stage_confirmed.sql
?? db/checks/116_preview_hk_provider_fixtures.sql
?? db/checks/117_bk_teams_after_run_check_v2.sql
?? db/checks/119_update_runtime_entity_audit_bk_teams_payload_only.sql
?? db/checks/120_bk_fixtures_after_run_check.sql
?? db/checks/121_update_runtime_entity_audit_bk_fixtures_stage_confirmed.sql
?? db/checks/122_find_bk_teams_parser_state.sql
?? db/checks/123_update_runtime_entity_audit_vb_fixtures_partial.sql
?? db/checks/124_insert_runtime_entity_audit_vb_leagues.sql
?? db/checks/124_update_runtime_entity_audit_vb_leagues_partial.sql
?? db/checks/125_insert_runtime_entity_audit_vb_odds.sql
?? db/checks/126_update_runtime_entity_audit_vb_teams_partial.sql
?? db/checks/127_update_or_insert_runtime_entity_audit_bk_teams_confirmed.sql
?? db/checks/128_update_or_insert_runtime_entity_audit_bk_fixtures_confirmed.sql
?? db/checks/129_update_or_insert_sport_completion_audit_bk_fixtures_core_done.sql
?? db/checks/130_update_or_insert_sport_completion_audit_bk_teams_core_done.sql
?? db/checks/131_update_or_insert_runtime_entity_audit_bk_leagues_confirmed.sql
?? db/checks/132_update_runtime_entity_audit_bk_fixtures_batch_ok.sql
?? db/checks/135_update_or_insert_runtime_entity_audit_vb_fixtures_confirmed.sq.sql
?? db/checks/136_update_or_insert_runtime_entity_audit_vb_teams_confirmed.sql
?? db/checks/137_update_or_insert_runtime_entity_audit_vb_leagues_confirmed.sql
?? db/checks/138_update_or_insert_sport_completion_audit_vb_fixtures_core_done.s
?? db/checks/139_update_or_insert_sport_completion_audit_vb_teams_core_done.sql
?? db/checks/576_inspect_fb_entity_audit.sql
?? db/checks/577_fb_execution_flow_snapshot.sql
?? db/checks/578_fb_runtime_job_flow.sql
?? db/checks/580_fb_provider_reality.sql
?? db/checks/581_fb_entity_audit_table.sql
?? db/checks/582_fb_entity_audit_seed_core.sql
?? db/checks/583_fb_entity_audit_seed_extended.sql
?? db/checks/584_hk_audit_start.sql
?? db/checks/585_bk_audit_start.sql
?? db/checks/586_vb_audit_start.sql
?? db/checks/589_create_ops_provider_people_audit.sql
?? "db/checks/590_inspect_people_provider_candidates.sql (FINAL FOR YOUR DB).sql"
?? db/checks/592_seed_missing_people_audit_rows.sql
?? db/checks/593_coaches_reality_matrix.sql
?? db/checks/594_seed_coaches_runtime_checklist.sql
?? db/checks/595_apply_coaches_runtime_result_template.sql
?? db/checks/596_create_ops_sport_completion_audit.sql
?? db/checks/597_seed_sport_completion_audit.sql
?? db/checks/598_create_v_sport_completion_summary.sql
?? db/checks/599_fb_completion_tasks.sql
?? db/checks/600_fb_coaches_mapping_gap_check.sql
?? db/checks/601_fb_coaches_mapping_data_gap.sql
?? db/checks/602_fb_coaches_ingest_gap_check.sql
?? db/checks/603_fix_fb_coaches_completion_note.sql
?? db/checks/604A_fb_coaches_jobs_structure.sql
?? db/checks/604B_fb_coaches_job_binding_check.sql
?? db/checks/604_fb_coaches_worker_path_check.sql
?? db/checks/605_fb_coaches_ingest_binding_note.sql
?? db/checks/606_find_fb_coaches_worker_binding.ps1
?? db/checks/606_find_fb_coaches_worker_binding_output.txt
?? db/checks/607_cleanup_bad_fb_coaches_stage_rows.sql
?? db/checks/608_fb_coaches_team_mapping_check.sql
?? db/checks/609_fb_missing_team_provider_map_check.sql
?? db/checks/610_insert_missing_fb_coaches_team_provider_map.sql
?? db/checks/611_fb_coaches_to_public.sql
?? db/checks/612_fb_team_coach_history.sql
?? db/checks/613_update_fb_coaches_completion_after_runtime.sql
?? db/checks/614_fb_players_runtime_gap_check.sql
?? db/checks/615_hk_teams_after_pull_check_v3.sql
?? db/checks/704_upsert_runtime_entity_audit_afb_teams.sql
?? db/checks/707_upsert_runtime_entity_audit_afb_fixtures.sql
?? db/checks/708_upsert_runtime_entity_audit_afb_leagues.sql
?? db/checks/709_upsert_sport_completion_audit_afb_fix2.sql
?? db/migrations/109_create_ops_runtime_entity_audit.sql
?? db/ops/703_build_fb_players_pro_priority_buckets.sql
?? db/ops/704_select_fb_players_wave_0.sql
?? db/ops/705_select_fb_players_wave_1.sql
?? db/scripts/.112_runtime_audit_export_V2.ps1.txt
?? db/scripts/112_runtime_audit_export_V2.ps1
?? db/scripts/614_worker_file_scan.ps1
?? db/scripts/614_worker_file_scan_v2.ps1
?? db/sql/133_bk_full_pipeline.sql
?? db/sql/134_vb_full_pipeline.sql
?? db/sql/700_bk_team_provider_map.sql
?? db/sql/701_afb_readiness_audit.sql
?? db/sql/701_bk_team_provider_map_fix.sql
?? db/sql/702_bk_team_provider_map_manual_fix.sql
?? db/sql/702_create_stg_api_american_football_teams.sql
?? db/sql/703_bk_fixtures_merge.sql
?? db/sql/703_merge_api_american_football_teams_to_public.sql
?? db/sql/704_bk_league_mapping.sql
?? db/sql/704_update_runtime_entity_audit_afb_teams.sql
?? db/sql/705_create_stg_api_american_football_fixtures.sql
?? db/sql/706_merge_api_american_football_fixtures_to_public_matches.sql
?? db/views/109_create_v_runtime_entity_audit_summary.sql
?? db/views/111_view_z_runtime_entity_audit_summary.sql
?? "docs/komunikace s chatGPT/04_2026/20260406/Z\303\201PIS NA DNE\305\240EK \342\200\223 P\305\230\303\215PRAVA NA Z\303\215T\305\230E.md"
?? "docs/komunikace s chatGPT/04_2026/20260407/"
?? "docs/komunikace s chatGPT/04_2026/20260408/"
?? "docs/komunikace s chatGPT/04_2026/20260409/"
?? "docs/komunikace s chatGPT/04_2026/20260410/"
?? ingest/API-American-Football/
?? ingest/API-Basketball/
?? ingest/providers/generic_api_sport_provider_V1.py
?? ingest/providers/generic_api_sport_provider_V2.py
?? reports/audit/2026-04-07/
?? reports/audit/2026-04-08/
?? reports/audit/2026-04-09/
?? reports/audit/2026-04-10/
?? reports/audit/2026-04-11/
?? reports/audit/system_tree_2026-04-08_225934.txt
?? reports/audit/system_tree_2026-04-09_225748.txt
?? reports/audit/system_tree_2026-04-11_095512.txt
?? reports/reports_runner/112_runtime_audit_export.txt
?? unmatched_theodds_195.csv
?? unmatched_theodds_195.sql
?? workers/run_api_football_coaches_ingest_v1.py
?? workers/run_fb_players_wave1_pro.ps1
?? workers/run_players_pipeline_merge_only_v1.ps1
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2987
  - matches: 106258
  - players: 2429
  - teams: 5423
- OPS counts:
  - ingest_planner: 3084
  - job_runs: 501
  - provider_jobs: 140
  - scheduler_queue: 6
- Player pipeline:
  - player_match_statistics: 0
  - players_import: 2506
  - public_players: 2429
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