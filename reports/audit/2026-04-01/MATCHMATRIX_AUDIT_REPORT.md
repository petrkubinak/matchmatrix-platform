# TicketMatrixPlatform – technický audit

Datum a čas: 2026-04-01 20:53:01
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 1656
- NEW: 66
- MODIFIED: 3
- DELETED: 3

## Nejvýznamnější změny
- DELETED: docs\komunikace s chatGPT\20260329\ticket_history_base.txt
- DELETED: ingest\run_theodds_parse_multi_FINAL.bat
- DELETED: ingest\theodds_parse_multi_FINAL.py
- MODIFIED: db\debug\442_save_run_112_full.sql
- MODIFIED: MatchMatrix-platform\.dbeaver\project-metadata.json
- MODIFIED: workers\436_auto_safe_seeder_v3.py
- NEW: db\debug\445_audit_auto_multi_run_last_batch.sql
- NEW: db\debug\446_add_safe02_odds_cap.sql
- NEW: db\debug\465_audit_pattern_fix5_bl2_1_1_t7.sql
- NEW: db\migrations\454_create_ticket_strategy_catalog.sql
- NEW: db\migrations\457_create_ticket_pattern_catalog.sql
- NEW: db\migrations\459_upsert_ticket_pattern_catalog_from_runs.sql
- NEW: db\migrations\461_upsert_generated_run_pattern_map.sql
- NEW: db\migrations\462_alter_ticket_history_base_add_pattern.sql
- NEW: db\migrations\463_update_ticket_history_with_pattern.sql
- NEW: db\migrations\472_upsert_ticket_pattern_settlements.sql
- NEW: db\migrations\Script-1.sql
- NEW: db\views\448_strategy_comparison_view.sql
- NEW: db\views\449_strategy_ranking_view.sql
- NEW: db\views\450_strategy_recommendation_view.sql

## Git
- Branch: main
- Last commit: 38bf38e | 2026-03-31 16:52:13 +0200 | update players pipeline
```
M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
 M MatchMatrix-platform/.dbeaver/project-metadata.json
 D ingest/run_theodds_parse_multi_FINAL.bat
 D ingest/theodds_parse_multi_FINAL.py
 D reports/audit/2026-03-17/09-48-14/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-17/09-48-14/changes.csv
 D reports/audit/2026-03-17/09-48-14/files.csv
 D reports/audit/2026-03-17/09-48-14/run_meta.json
 D reports/audit/2026-03-17/09-48-14/snapshot.json
 D reports/audit/2026-03-17/09-56-27/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-17/09-56-27/changes.csv
 D reports/audit/2026-03-17/09-56-27/files.csv
 D reports/audit/2026-03-17/09-56-27/run_meta.json
 D reports/audit/2026-03-17/09-56-27/snapshot.json
 D reports/audit/2026-03-17/10-11-43/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-17/10-28-12/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-17/10-28-12/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-17/10-28-12/changes.csv
 D reports/audit/2026-03-17/10-28-12/files.csv
 D reports/audit/2026-03-17/10-28-12/snapshot.json
 D reports/audit/2026-03-17/11-10-19/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-17/11-10-19/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-17/11-10-19/changes.csv
 D reports/audit/2026-03-17/11-10-19/files.csv
 D reports/audit/2026-03-17/11-10-19/snapshot.json
 D reports/audit/2026-03-17/12-44-22/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-17/12-44-22/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-17/12-44-22/changes.csv
 D reports/audit/2026-03-17/12-44-22/files.csv
 D reports/audit/2026-03-17/12-44-22/snapshot.json
 D reports/audit/2026-03-17/12-44-41/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-17/12-44-41/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-17/12-44-41/changes.csv
 D reports/audit/2026-03-17/12-44-41/files.csv
 D reports/audit/2026-03-17/12-44-41/snapshot.json
 D reports/audit/2026-03-17/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-17/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-18/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-18/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-19/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-19/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-20/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-20/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-22/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-22/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-23/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-23/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-24/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-24/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-25/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-25/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-26/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-26/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-27/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-27/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-29/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-29/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-30/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-30/MATCHMATRIX_PROGRESS.md
 D reports/audit/2026-03-31/MATCHMATRIX_AUDIT_REPORT.md
 D reports/audit/2026-03-31/MATCHMATRIX_PROGRESS.md
 M reports/audit/latest_audit_report.md
 M reports/audit/latest_progress_report.md
 M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
 D reports/audit/system_tree_2026-03-23_110914.txt
 D reports/audit/system_tree_2026-03-23_203905.txt
 D reports/audit/system_tree_2026-03-24_071848.txt
 D reports/audit/system_tree_2026-03-24_204041.txt
 D reports/audit/system_tree_2026-03-24_232620.txt
 D reports/audit/system_tree_2026-03-25_123722.txt
 D reports/audit/system_tree_2026-03-25_201624.txt
 D reports/audit/system_tree_2026-03-26_091238.txt
 D reports/audit/system_tree_2026-03-27_160114.txt
 D reports/audit/system_tree_2026-03-29_090423.txt
 D reports/audit/system_tree_2026-03-30_202733.txt
 D reports/audit/system_tree_2026-03-31_071441.txt
 D reports/audit/system_tree_2026-03-31_124918.txt
?? MatchMatrix-platform/Scripts/11_ops/415_audit_ticket_history_structure.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/416_audit_auto_ticket_flow.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/418_create_auto_ticket_strategies.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/419_create_v_auto_ticket_candidates_safe.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/420_preview_safe_01_builder.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/421_build_template_safe_01_fix.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/423_generate_template_201.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/424_check_run_105.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/425_save_run_105_full.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/426_prepare_auto_safe_pipeline_notes.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/428_audit_ticket_generation_runs.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/430_preview_safe_02_builder.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/431_build_template_safe_02.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/432_preview_template_202.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/433_generate_template_202.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/434_check_run_109.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/435_save_run_109_full.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/437_preview_safe_03_builder.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/438_build_template_safe_03.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/439_preview_template_203.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/440_generate_template_203.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/441_check_run_112.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/442_save_run_112_full.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/445_audit_auto_multi_run_last_batch.sql
?? MatchMatrix-platform/Scripts/15_ticket_history/446_add_safe02_odds_cap.sql
?? "MatchMatrix-platform/Scripts/16_ticket_vyhodnocen\303\255/"
?? db/audit/415_audit_ticket_history_structure.sql
?? db/audit/416_audit_auto_ticket_flow.sql
?? db/debug/420_preview_safe_01_builder.sql
?? db/debug/421_build_template_safe_01_fix.sql
?? db/debug/423_generate_template_201.sql
?? db/debug/424_check_run_105.sql
?? db/debug/425_save_run_105_full.sql
?? db/debug/426_prepare_auto_safe_pipeline_notes.sql
?? db/debug/428_audit_ticket_generation_runs.sql
?? db/debug/430_preview_safe_02_builder.sql
?? db/debug/431_build_template_safe_02.sql
?? db/debug/432_preview_template_202.sql
?? db/debug/433_generate_template_202.sql
?? db/debug/434_check_run_109.sql
?? db/debug/435_save_run_109_full.sql
?? db/debug/437_preview_safe_03_builder.sql
?? db/debug/438_build_template_safe_03.sql
?? db/debug/439_preview_template_203.sql
?? db/debug/440_generate_template_203.sql
?? db/debug/441_check_run_112.sql
?? db/debug/442_save_run_112_full.sql
?? db/debug/445_audit_auto_multi_run_last_batch.sql
?? db/debug/446_add_safe02_odds_cap.sql
?? db/debug/465_audit_pattern_fix5_bl2_1_1_t7.sql
?? db/migrations/418_create_auto_ticket_strategies.sql
?? db/migrations/454_create_ticket_strategy_catalog.sql
?? db/migrations/457_create_ticket_pattern_catalog.sql
?? db/migrations/459_upsert_ticket_pattern_catalog_from_runs.sql
?? db/migrations/461_upsert_generated_run_pattern_map.sql
?? db/migrations/462_alter_ticket_history_base_add_pattern.sql
?? db/migrations/463_update_ticket_history_with_pattern.sql
?? db/migrations/472_upsert_ticket_pattern_settlements.sql
?? db/migrations/Script-1.sql
?? db/views/419_create_v_auto_ticket_candidates_safe.sql
?? db/views/448_strategy_comparison_view.sql
?? db/views/449_strategy_ranking_view.sql
?? db/views/450_strategy_recommendation_view.sql
?? db/views/451_strategy_recommendation_current.sql
?? db/views/455_strategy_recommendation_by_catalog.sql
?? db/views/458_create_v_generated_run_pattern_candidates.sql
?? db/views/464_create_v_ticket_pattern_history_summary.sql
?? db/views/466_create_v_ticket_pattern_history_quality.sql
?? db/views/467_create_v_ticket_pattern_history_summary_normalized.sql
?? db/views/468_create_v_ticket_pattern_settlement_ready.sql
?? db/views/470_create_v_ticket_pattern_settlement_source.sql
?? db/views/471_create_v_ticket_pattern_settlement_aggregate.sql
?? "docs/komunikace s chatGPT/03_2026/20260329/ticket_history_base.txt"
?? "docs/komunikace s chatGPT/04_2026/"
?? ingest/Football-Data/
?? ingest/TheOdds/
?? ingest/unmatched_theodds_155.csv
?? ingest/unmatched_theodds_155.sql
?? launchers/453_run_recommended_strategy.vbs
?? launchers/run_matchmatrix_panel_v11.vbs
?? reports/audit/03_2026/
?? reports/audit/2026-04-01/
?? reports/audit/system_tree_2026-03-31_165503.txt
?? reports/audit/system_tree_2026-04-01_103734.txt
?? reports/audit/system_tree_2026-04-01_205300.txt
?? tools/matchmatrix_control_panel_V11.py
?? unmatched_theodds_156.csv
?? unmatched_theodds_156.sql
?? unmatched_theodds_158.csv
?? unmatched_theodds_158.sql
?? workers/417_auto_ticket_seeder_v1.py
?? workers/427_auto_safe_seeder_v2.py
?? workers/429_update_auto_safe_seeder_logging.py
?? workers/436_auto_safe_seeder_v3.py
?? workers/443_auto_safe_seeder_v3.py
?? workers/444_auto_multi_run.py
?? workers/452_auto_run_recommended_strategy.py
?? workers/run_football_data_ingest_v1.py
?? workers/run_theodds_ingest_v1.py
?? workers/run_theodds_ingest_v2.py
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2986
  - matches: 105603
  - players: 1490
  - teams: 5430
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