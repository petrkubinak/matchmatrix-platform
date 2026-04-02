# TicketMatrixPlatform – technický audit

Datum a čas: 2026-03-30 20:27:35
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 1470
- NEW: 64
- MODIFIED: 1
- DELETED: 0

## Nejvýznamnější změny
- MODIFIED: MatchMatrix-platform\.dbeaver\project-metadata.json
- NEW: CSV výstup\3.csv
- NEW: CSV výstup\4.csv
- NEW: db\cleanup\2026-03-29_14_delete_duplicate_matches_football_data_uk.sql
- NEW: db\debug\debug_ticket_block_A_source.sql
- NEW: db\debug\fix_mm_ui_run_tickets_dedup_odds.sql
- NEW: db\migrations\2026-03-29_01_create_table_standings_rules.sql
- NEW: db\migrations\2026-03-29_02_create_table_league_standings.sql
- NEW: db\migrations\2026-03-29_02_seed_standings_rules.sql
- NEW: db\migrations\2026-03-29_03_create_function_refresh_league_standings.sql
- NEW: db\migrations\2026-03-29_06_create_table_product_active_leagues.sql
- NEW: db\migrations\2026-03-29_11_create_function_refresh_product_league_standings.sql
- NEW: db\migrations\2026-03-29_12_fix_product_standings_season_filter.sql
- NEW: db\sql\315_create_ticket_history_base.sql
- NEW: db\sql\316_insert_ticket_history_from_generated.sql
- NEW: db\sql\317_view_ticket_history_summary.sql
- NEW: db\sql\318_select_ticket_history_prediction.sql
- NEW: db\sql\319_ticket_history_sport_features.sql
- NEW: db\sql\321_mm_ticket_scenario_sport_features.sql
- NEW: db\sql\322_mm_ticket_scenario_rating_view.sql

## Git
- Branch: main
- Last commit: f4c5ec0 | 2026-03-26 09:18:29 +0100 | %1
```
M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
 M MatchMatrix-platform/.dbeaver/project-metadata.json
 D "db/ops/matchmatrix - matchmatrix - ops.png"
 D "db/ops/matchmatrix - matchmatrix - public.png"
 D "db/ops/matchmatrix - matchmatrix - staging.png"
 M ingest/artifacts/baseline_logreg_v3.joblib
 M ingest/artifacts/baseline_logreg_v3_meta.json
 M ingest/artifacts/gbm_v3_calibrated.joblib
 M ingest/run_theodds_parse_multi_FINAL.bat
 M ingest/theodds_parse_multi_FINAL.py
 M reports/audit/latest_audit_report.md
 M reports/audit/latest_progress_report.md
 M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
 D tools/run_check_psql.bat
 D tools/run_matchmatrix_control_panel_V3.bat
 D tools/run_matchmatrix_control_panel_V5.vbs
 D tools/run_matchmatrix_control_panel_V6.vbs
 D tools/run_matchmatrix_control_panel_V7.vbs
 D tools/run_matchmatrix_panel_V4.bat
 D tools/run_matchmatrix_panel_v7.vbs
 D tools/run_matchmatrix_panel_v8.vbs
 D tools/run_matchmatrix_panel_v9.vbs
?? "CSV v\303\275stup/"
?? MatchMatrix-platform/Scripts/13_odds/
?? MatchMatrix-platform/Scripts/14_ticket_studio/
?? MatchMatrix-platform/Scripts/15_ticket_history/
?? db/audit/2026-03-26_audit_bad_theodds_aliases.sql
?? db/audit/2026-03-26_audit_dc_missing_for_matches.sql
?? db/audit/2026-03-26_audit_market_codes_double_chance.sql
?? db/audit/2026-03-26_check_dc_payload_real.sql
?? db/audit/2026-03-26_football_duplicate_team_branches.sql
?? db/audit/2026-03-26_no_match_detail_check.sql
?? db/audit/2026-03-26_odds_coverage_audit.sql
?? db/audit/2026-03-26_odds_coverage_check.sql
?? db/audit/2026-03-26_serie_a_no_match_audit.sql
?? db/audit/Script.sql
?? db/cleanup/
?? db/debug/debug_ticket_block_A_source.sql
?? db/debug/fix_mm_ui_run_tickets_dedup_odds.sql
?? db/fix/
?? db/migrations/2026-03-26_insert_theodds_aliases_auto.sql
?? db/migrations/2026-03-29_01_create_table_standings_rules.sql
?? db/migrations/2026-03-29_02_create_table_league_standings.sql
?? db/migrations/2026-03-29_02_seed_standings_rules.sql
?? db/migrations/2026-03-29_03_create_function_refresh_league_standings.sql
?? db/migrations/2026-03-29_06_create_table_product_active_leagues.sql
?? db/migrations/2026-03-29_11_create_function_refresh_product_league_standings.sql
?? db/migrations/2026-03-29_12_fix_product_standings_season_filter.sql
?? db/migrations/20260326_02_bournemouth_only_safe_merge.sql
?? db/migrations/20260326_03_bournemouth_only_safe_merge_fix_aliases.sql
?? db/migrations/20260326_05_arsenal_belarus_merge_26871_into_13102.sql
?? db/migrations/20260326_08_check_team_1_references.sql
?? db/migrations/20260326_09_cleanup_team_1_into_11910.sql
?? db/sql/315_create_ticket_history_base.sql
?? db/sql/316_insert_ticket_history_from_generated.sql
?? db/sql/317_view_ticket_history_summary.sql
?? db/sql/318_select_ticket_history_prediction.sql
?? db/sql/319_ticket_history_sport_features.sql
?? db/sql/321_mm_ticket_scenario_sport_features.sql
?? db/sql/322_mm_ticket_scenario_rating_view.sql
?? db/sql/323_ticket_history_enrich_full.sql
?? db/sql/324_v_ticket_history_summary_enriched.sql
?? db/sql/326_create_saved_tickets.sql
?? db/sql/327_insert_generated_into_tickets.sql
?? db/sql/328_insert_generated_blocks_into_ticket_blocks.sql
?? db/sql/Script.sql
?? db/views/2026-03-29_04_create_view_v_league_standings_enriched.sql
?? db/views/2026-03-29_08_create_view_v_current_product_standings.sql
?? db/views/2026-03-29_16_recreate_view_v_current_product_standings.sql
?? diagram/
?? "docs/komunikace s chatGPT/20260326/MATCHMATRIX \342\200\223 DENN\303\215 Z\303\201PIS.md"
?? "docs/komunikace s chatGPT/20260326/MatchMatrix \342\200\223 z\303\241pis dne\305\241ka.md"
?? "docs/komunikace s chatGPT/20260326/Run_ID_148.txt"
?? "docs/komunikace s chatGPT/20260326/Teable_name.txt"
?? "docs/komunikace s chatGPT/20260326/audit_teams.txt"
?? "docs/komunikace s chatGPT/20260326/matches.txt"
?? "docs/komunikace s chatGPT/20260326/team_aliases.txt"
?? "docs/komunikace s chatGPT/20260326/team_provider_map.txt"
?? "docs/komunikace s chatGPT/20260327/"
?? "docs/komunikace s chatGPT/20260328/"
?? "docs/komunikace s chatGPT/20260329/"
?? "docs/komunikace s chatGPT/20260330/"
?? "docs/visual/BCO.2bc27bad-0322-4f8c-b005-2f20879a7bc5 (1).png"
?? docs/visual/BCO.2bc27bad-0322-4f8c-b005-2f20879a7bc5.png
?? docs/visual/BCO.6d15acfa-4948-4a86-be52-7480d442a154.png
?? docs/visual/BCO.6e42d907-a22b-4a7b-ac58-f973aa010f0c.png
?? docs/visual/BCO.78ddbc3f-c8e8-4aa7-96dd-5046e27ad12b.png
?? docs/visual/BCO.8934acf9-2e5e-41bc-b415-ccabdeb3f688.png
?? docs/visual/BCO.fdca978e-6ce6-4a83-b891-e7bf79a698ee.png
?? docs/visual/IMG_20260327_080821.jpg
?? "docs/visual/Logo Ticket Matrix b.png"
?? "docs/visual/Temn\304\233 fialov\303\251 pozad\303\255.png"
?? "docs/visual/Upraven\303\251 logo TicketMatrix.png"
?? docs/visual/prilohy_267546/
?? "docs/visual/\304\214tvercov\303\251 logo Ticke.png"
?? "docs/visual/\304\214tvercov\303\251 logo TickeMatrix.png"
?? ingest/API-Hockey/pull_api_hockey_players.ps1
?? ingest/API-Sport/pull_api_basketball_players.ps1
?? ingest/API-Volleyball/
?? ingest/unmatched_theodds_149.csv
?? ingest/unmatched_theodds_149.sql
?? launchers/
?? logs/bk_players_raw/
?? logs/temp_api_hockey_players_players_global_na.json
?? reports/audit/2026-03-27/
?? reports/audit/2026-03-29/
?? reports/audit/system_tree_2026-03-27_160114.txt
?? reports/audit/system_tree_2026-03-29_090423.txt
?? reports/audit/system_tree_2026-03-30_202733.txt
?? tools/check_db_connection.py
?? tools/matchmatrix_ticket_studio_V2_10.py
?? tools/matchmatrix_ticket_studio_V2_10_4.py
?? tools/matchmatrix_ticket_studio_V2_10_5.py
?? tools/matchmatrix_ticket_studio_V2_11.py
?? tools/matchmatrix_ticket_studio_V2_12.py
?? tools/matchmatrix_ticket_studio_V2_13.py
?? tools/matchmatrix_ticket_studio_V2_14.py
?? tools/matchmatrix_ticket_studio_V2_15_fix.py
?? tools/matchmatrix_ticket_studio_V2_16.py
?? tools/matchmatrix_ticket_studio_V2_17.py
?? tools/matchmatrix_ticket_studio_V2_18.py
?? tools/matchmatrix_ticket_studio_V2_19.py
?? tools/matchmatrix_ticket_studio_V2_19_fix.py
?? tools/matchmatrix_ticket_studio_V2_2.py
?? tools/matchmatrix_ticket_studio_V2_20.py
?? tools/matchmatrix_ticket_studio_V2_21.py
?? tools/matchmatrix_ticket_studio_V2_22.py
?? tools/matchmatrix_ticket_studio_V2_22_fix.py
?? tools/matchmatrix_ticket_studio_V2_22_fix2.py
?? tools/matchmatrix_ticket_studio_V2_22_fix3.py
?? tools/matchmatrix_ticket_studio_V2_3.py
?? tools/matchmatrix_ticket_studio_V2_4.py
?? tools/matchmatrix_ticket_studio_V2_5.py
?? tools/matchmatrix_ticket_studio_V2_6.py
?? tools/matchmatrix_ticket_studio_V2_7.py
?? tools/matchmatrix_ticket_studio_V2_9.py
?? tools/matchmatrix_ticket_studio_V3.py
?? tools/matchmatrix_ticket_studio_V3_fix1.py
?? tools/matchmatrix_ticket_studio_V3_fix10.py
?? tools/matchmatrix_ticket_studio_V3_fix11.py
?? tools/matchmatrix_ticket_studio_V3_fix12.py
?? tools/matchmatrix_ticket_studio_V3_fix13.py
?? tools/matchmatrix_ticket_studio_V3_fix3.py
?? tools/matchmatrix_ticket_studio_V3_fix4.py
?? tools/matchmatrix_ticket_studio_V3_fix5.py
?? tools/matchmatrix_ticket_studio_V3_fix6.py
?? tools/matchmatrix_ticket_studio_V3_fix7.py
?? tools/matchmatrix_ticket_studio_V3_fix8.py
?? workers/run_players_fetch_bk_only_v1.py
?? workers/run_players_fetch_hk_only_v1.py
?? workers/run_players_parse_hk_only_v1.py
?? workers/run_players_pipeline_hk_v1.py
?? "zazipovan\303\251_soubory/"
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2986
  - matches: 105499
  - players: 1490
  - teams: 5407
- OPS counts:
  - ingest_planner: 3084
  - job_runs: 446
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