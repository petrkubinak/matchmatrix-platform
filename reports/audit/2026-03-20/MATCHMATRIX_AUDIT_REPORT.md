# TicketMatrixPlatform – technický audit

Datum a čas: 2026-03-20 13:08:59
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 1064
- NEW: 6
- MODIFIED: 0
- DELETED: 0

## Nejvýznamnější změny
- NEW: db\ops\178_seed_fb_provider_jobs_from_catalog_FINAL.sql
- NEW: db\views\177_create_v_ops_fb_job_catalog.sql
- NEW: docs\komunikace s chatGPT\20260320\MatchMatrix – podrobný zápis.md
- NEW: MatchMatrix-platform\Dump\dump-matchmatrix-202603201246.sql
- NEW: MatchMatrix-platform\Scripts\13_multisport_ingest\177_create_v_ops_fb_job_catalog.sql
- NEW: MatchMatrix-platform\Scripts\13_multisport_ingest\178_seed_fb_provider_jobs_from_catalog_FINAL.sql

## Git
- Branch: main
- Last commit: a7e8c33 | 2026-03-20 10:25:36 +0100 | update players pipeline
```
M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
 M MatchMatrix-platform/.dbeaver/project-metadata.json
 M reports/audit/2026-03-20/MATCHMATRIX_AUDIT_REPORT.md
 M reports/audit/2026-03-20/MATCHMATRIX_PROGRESS.md
 M reports/audit/latest_audit_report.md
 M reports/audit/latest_progress_report.md
 M reports/audit/latest_snapshot.txt
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603201246.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/147_expand_ingest_entity_plan_to_all_sports.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/147_rebuild_ingest_planner_multisport.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/148_fix_legacy_football_code_SAFE.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/152_seed_fb_eu_run_group.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/154_create_v_ops_fb_eu_ingest_jobs.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/157_seed_football_data_fb_ingest_entity_plan.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/158_fix_v_ops_fb_eu_ingest_jobs_multi_provider.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/160_enable_fb_eu_targets.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/162_create_v_ops_fb_eu_test_mode.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/166_rename_fb_eu_to_fb_fd_core.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/167_create_v_ops_fb_fd_core_ingest_jobs.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/167a_create_v_ops_fb_fd_core_ingest_jobs_test_mode.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/168_seed_fb_api_expansion_run_group.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/170_create_v_ops_fb_api_expansion_ingest_jobs.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/170a_create_v_ops_fb_api_expansion_ingest_jobs_test_mode.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/172_create_v_ops_fb_test_mode_all_layers.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/173_create_v_ops_fb_test_mode_orchestrator.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/174_create_v_ops_fb_test_execution_order.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/176_create_v_ops_fb_test_phase1.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/177_create_v_ops_fb_job_catalog.sql
?? MatchMatrix-platform/Scripts/13_multisport_ingest/178_seed_fb_provider_jobs_from_catalog_FINAL.sql
?? "MatchMatrix-platform/Scripts/99_reports/100_rozsah_sta\305\276en\303\275ch_lig_FB_football_Data.sql"
?? db/ops/147_expand_ingest_entity_plan_to_all_sports.sql
?? db/ops/147_rebuild_ingest_planner_multisport.sql
?? db/ops/148_fix_legacy_football_code_SAFE.sql
?? db/ops/152_seed_fb_eu_run_group.sql
?? db/ops/157_seed_football_data_fb_ingest_entity_plan.sql
?? db/ops/160_enable_fb_eu_targets.sql
?? db/ops/166_rename_fb_eu_to_fb_fd_core.sql
?? db/ops/168_seed_fb_api_expansion_run_group.sql
?? db/ops/178_seed_fb_provider_jobs_from_catalog_FINAL.sql
?? db/views/154_create_v_ops_fb_eu_ingest_jobs.sql
?? db/views/158_fix_v_ops_fb_eu_ingest_jobs_multi_provider.sql
?? db/views/162_create_v_ops_fb_eu_test_mode.sql
?? db/views/167_create_v_ops_fb_fd_core_ingest_jobs.sql
?? db/views/167a_create_v_ops_fb_fd_core_ingest_jobs_test_mode.sql
?? db/views/170_create_v_ops_fb_api_expansion_ingest_jobs.sql
?? db/views/170a_create_v_ops_fb_api_expansion_ingest_jobs_test_mode.sql
?? db/views/172_create_v_ops_fb_test_mode_all_layers.sql
?? db/views/173_create_v_ops_fb_test_mode_orchestrator.sql
?? db/views/174_create_v_ops_fb_test_execution_order.sql
?? db/views/176_create_v_ops_fb_test_phase1.sql
?? db/views/177_create_v_ops_fb_job_catalog.sql
?? "docs/komunikace s chatGPT/20260320/Diagramy/"
?? "docs/komunikace s chatGPT/20260320/MatchMatrix \342\200\223 podrobn\303\275 z\303\241pis.md"
?? "docs/komunikace s chatGPT/20260320/MatchMatrix \342\200\223 z\303\241pis (FB_EU \342\206\222 football_data vrstva + audit historie).md"
?? "docs/komunikace s chatGPT/20260320/MatchMatrix \342\200\223 z\303\241pis (krok 147\342\200\223151 m.txt"
?? "docs/komunikace s chatGPT/20260320/SQL/146_planner.txt"
?? "docs/komunikace s chatGPT/20260320/SQL/provider_sport_matrix.txt"
?? "docs/komunikace s chatGPT/20260320/SQL/sport_entity_rules.txt"
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
  - provider_jobs: 54
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