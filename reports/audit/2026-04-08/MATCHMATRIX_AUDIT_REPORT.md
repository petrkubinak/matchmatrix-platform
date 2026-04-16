# TicketMatrixPlatform – technický audit

Datum a čas: 2026-04-08 22:59:36
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 2183
- NEW: 20
- MODIFIED: 0
- DELETED: 0

## Nejvýznamnější změny
- NEW: db\audit\601_reuse_audit_ops_core_status.sql
- NEW: db\audit\602_harvest_final_classification.sql
- NEW: db\audit\603_wave_planner_input.sql
- NEW: db\audit\604_planner_seed_candidates.sql
- NEW: db\audit\605_planner_seed_insert_preview.sql
- NEW: db\audit\606_wave1_core_filter_preview.sql
- NEW: db\audit\607_planner_seed_insert_core_preview.sql
- NEW: db\audit\608_planner_seed_core_stage.sql
- NEW: db\audit\610_provider_sport_entity_matrix.sql
- NEW: db\audit\612_normalized_structure_matrix.sql
- NEW: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\601_reuse_audit_ops_core_status.sql
- NEW: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\602_harvest_final_classification.sql
- NEW: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\603_wave_planner_input.sql
- NEW: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\604_planner_seed_candidates.sql
- NEW: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\605_planner_seed_insert_preview.sql
- NEW: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\606_wave1_core_filter_preview.sql
- NEW: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\607_planner_seed_insert_core_preview.sql
- NEW: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\608_planner_seed_core_stage.sql
- NEW: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\610_provider_sport_entity_matrix.sql
- NEW: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\612_normalized_structure_matrix.sql

## Git
- Branch: main
- Last commit: 8b03f52 | 2026-04-06 21:54:00 +0200 | update players pipeline
```
D "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/575_create_v_harvest_e2e_control.sql"
 M ingest/TheOdds/theodds_parse_multi_V3.py
 M reports/audit/latest_audit_report.md
 M reports/audit/latest_progress_report.md
 M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_2_coaches/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_3_players/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/601_reuse_audit_ops_core_status.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/602_harvest_final_classification.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/603_wave_planner_input.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/604_planner_seed_candidates.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/605_planner_seed_insert_preview.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/606_wave1_core_filter_preview.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/607_planner_seed_insert_core_preview.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/608_planner_seed_core_stage.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/610_provider_sport_entity_matrix.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/612_normalized_structure_matrix.sql"
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
?? db/audit/701_audit_fb_players_ready_definition.sql
?? db/audit/702_audit_fb_players_pro_harvest_ready.sql
?? db/audit/706_audit_fb_players_wave1_coverage.sql
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
?? db/ops/703_build_fb_players_pro_priority_buckets.sql
?? db/ops/704_select_fb_players_wave_0.sql
?? db/ops/705_select_fb_players_wave_1.sql
?? "docs/komunikace s chatGPT/04_2026/20260406/Z\303\201PIS NA DNE\305\240EK \342\200\223 P\305\230\303\215PRAVA NA Z\303\215T\305\230E.md"
?? "docs/komunikace s chatGPT/04_2026/20260407/"
?? "docs/komunikace s chatGPT/04_2026/20260408/"
?? reports/audit/2026-04-07/
?? reports/audit/2026-04-08/
?? reports/audit/system_tree_2026-04-08_071644.txt
?? reports/audit/system_tree_2026-04-08_100346.txt
?? reports/audit/system_tree_2026-04-08_225934.txt
?? unmatched_theodds_195.csv
?? unmatched_theodds_195.sql
?? workers/run_api_football_coaches_ingest_v1.py
?? workers/run_fb_players_wave1_pro.ps1
?? workers/run_players_pipeline_merge_only_v1.ps1
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2986
  - matches: 105603
  - players: 2429
  - teams: 5306
- OPS counts:
  - ingest_planner: 3084
  - job_runs: 472
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