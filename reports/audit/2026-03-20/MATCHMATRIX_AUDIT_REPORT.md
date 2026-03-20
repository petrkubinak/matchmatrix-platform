# TicketMatrixPlatform – technický audit

Datum a čas: 2026-03-20 21:58:54
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 1082
- NEW: 87
- MODIFIED: 1
- DELETED: 67

## Nejvýznamnější změny
- DELETED: MatchMatrix-platform\Scripts\12_multisport\101_extend_existing_multisport_core.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\102_extend_existing_coach_core.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\102a_zjištění_sruktury_trenérských_tabulek.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\103_create_coach_provider_map.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\104_extend_stg_provider_coaches.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\105_create_ops_sport_entity_rules.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\106_create_ops_sport_dimension_rules.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\107_create_ops_provider_sport_matrix.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\108_seed_ops_ingest_entity_plan_multisport.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\109_create_v_ops_ingest_overview.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\111_audit_missing_multisport_coverage.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\112_seed_missing_sport_entity_rules.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\113_seed_missing_ingest_entity_plan_from_rules.sql
- DELETED: MatchMatrix-platform\Scripts\12_multisport\114_check_multisport_coverage_after_seed.sql
- DELETED: MatchMatrix-platform\Scripts\13_multisport_ingest\115_audit_ingest_targets_multisport.sql
- DELETED: MatchMatrix-platform\Scripts\13_multisport_ingest\116_audit_ingest_targets_sport_code_mapping.sql
- DELETED: MatchMatrix-platform\Scripts\13_multisport_ingest\117_fix_ingest_targets_sport_codes.sql
- DELETED: MatchMatrix-platform\Scripts\13_multisport_ingest\118_recheck_ingest_targets_multisport.sql
- DELETED: MatchMatrix-platform\Scripts\13_multisport_ingest\119_audit_football_ingest_targets_by_run_group.sql
- DELETED: MatchMatrix-platform\Scripts\13_multisport_ingest\120_audit_bk_hk_ingest_targets_by_run_group.sql

## Git
- Branch: main
- Last commit: f90ac55 | 2026-03-20 13:15:23 +0100 | Remove large SQL dumps from repo
```
M MatchMatrix-platform/.dbeaver/project-metadata.json
 D MatchMatrix-platform/Scripts/12_multisport/101_extend_existing_multisport_core.sql
 D MatchMatrix-platform/Scripts/12_multisport/102_extend_existing_coach_core.sql
 D "MatchMatrix-platform/Scripts/12_multisport/102a_zji\305\241t\304\233n\303\255_sruktury_tren\303\251rsk\303\275ch_tabulek.sql"
 D MatchMatrix-platform/Scripts/12_multisport/103_create_coach_provider_map.sql
 D MatchMatrix-platform/Scripts/12_multisport/104_extend_stg_provider_coaches.sql
 D MatchMatrix-platform/Scripts/12_multisport/105_create_ops_sport_entity_rules.sql
 D MatchMatrix-platform/Scripts/12_multisport/106_create_ops_sport_dimension_rules.sql
 D MatchMatrix-platform/Scripts/12_multisport/107_create_ops_provider_sport_matrix.sql
 D MatchMatrix-platform/Scripts/12_multisport/108_seed_ops_ingest_entity_plan_multisport.sql
 D MatchMatrix-platform/Scripts/12_multisport/109_create_v_ops_ingest_overview.sql
 D MatchMatrix-platform/Scripts/12_multisport/111_audit_missing_multisport_coverage.sql
 D MatchMatrix-platform/Scripts/12_multisport/112_seed_missing_sport_entity_rules.sql
 D MatchMatrix-platform/Scripts/12_multisport/113_seed_missing_ingest_entity_plan_from_rules.sql
 D MatchMatrix-platform/Scripts/12_multisport/114_check_multisport_coverage_after_seed.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/115_audit_ingest_targets_multisport.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/116_audit_ingest_targets_sport_code_mapping.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/117_fix_ingest_targets_sport_codes.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/118_recheck_ingest_targets_multisport.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/119_audit_football_ingest_targets_by_run_group.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/120_audit_bk_hk_ingest_targets_by_run_group.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/121_preview_bk_hk_targets.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/122_preview_hk_targets.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/123_shortlist_bk_hk_senior_primary_targets.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/124_preview_bk_maintenance_top_candidates.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/125_preview_bk_nbl_candidates.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/126_resolve_bk_nbl_league_names.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/127_preview_bk_china_candidates.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/128_seed_bk_maintenance_top.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/129_preview_hk_maintenance_top_candidates.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/130_resolve_hk_extraliga_candidates.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/131_seed_hk_maintenance_top.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/132_audit_top_run_groups_fb_bk_hk.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/133_preview_top_run_groups_fb_bk_hk.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/134_create_v_ops_top_ingest_targets.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/135_audit_v_top_ingest_targets_by_provider.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/136_create_v_ops_top_ingest_jobs.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/137_audit_missing_bk_top_jobs.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/138_seed_api_sport_bk_ingest_entity_plan.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/139_recheck_top_ingest_jobs.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/140_count_top_ingest_jobs.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/141_create_v_ops_top_ingest_jobs_ordered.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/142_create_v_ops_top_ingest_jobs_runnable.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/143_create_v_ops_top_ingest_jobs_test_mode.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/144_fix_v_ops_top_ingest_jobs_test_mode_no_odds.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/145_create_v_ops_top_ingest_jobs_full_mode.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/146_audit_ops_budget_runtime_objects.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/147_expand_ingest_entity_plan_to_all_sports.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/147_rebuild_ingest_planner_multisport.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/148_fix_legacy_football_code_SAFE.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/152_seed_fb_eu_run_group.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/154_create_v_ops_fb_eu_ingest_jobs.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/157_seed_football_data_fb_ingest_entity_plan.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/158_fix_v_ops_fb_eu_ingest_jobs_multi_provider.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/160_enable_fb_eu_targets.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/162_create_v_ops_fb_eu_test_mode.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/166_rename_fb_eu_to_fb_fd_core.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/167_create_v_ops_fb_fd_core_ingest_jobs.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/167a_create_v_ops_fb_fd_core_ingest_jobs_test_mode.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/168_seed_fb_api_expansion_run_group.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/170_create_v_ops_fb_api_expansion_ingest_jobs.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/170a_create_v_ops_fb_api_expansion_ingest_jobs_test_mode.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/172_create_v_ops_fb_test_mode_all_layers.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/173_create_v_ops_fb_test_mode_orchestrator.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/174_create_v_ops_fb_test_execution_order.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/176_create_v_ops_fb_test_phase1.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/177_create_v_ops_fb_job_catalog.sql
 D MatchMatrix-platform/Scripts/13_multisport_ingest/178_seed_fb_provider_jobs_from_catalog_FINAL.sql
 M reports/audit/2026-03-20/MATCHMATRIX_AUDIT_REPORT.md
 M reports/audit/2026-03-20/MATCHMATRIX_PROGRESS.md
 M reports/audit/latest_audit_report.md
 M reports/audit/latest_progress_report.md
 M reports/audit/latest_snapshot.txt
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest-footbal/
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/
?? db/checks/187_preview_hk_top_runnable_jobs.sql
?? db/ops/179_ops_hk_run_groups.sql
?? db/ops/180_seed_api_hockey_hk_ingest_entity_plan.sql
?? db/ops/185_seed_hk_provider_jobs.sql
?? db/views/181_create_v_ops_hk_top_ingest_jobs.sql
?? db/views/182_create_v_ops_hk_top_ingest_jobs_test_mode.sql
?? db/views/183_create_v_ops_hk_top_test_execution_order.sql
?? db/views/186_create_v_ops_hk_top_runnable_jobs.sql
?? db/views/Script.sql
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2713
  - matches: 107089
  - players: 779
  - teams: 5238
- OPS counts:
  - ingest_planner: 95
  - job_runs: 176
  - provider_jobs: 57
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