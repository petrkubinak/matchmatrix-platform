# TicketMatrixPlatform – technický audit

Datum a čas: 2026-03-24 07:18:50
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 1206
- NEW: 32
- MODIFIED: 2
- DELETED: 0

## Nejvýznamnější změny
- MODIFIED: ingest\providers\provider_registry.py
- MODIFIED: tools\matchmatrix_control_panel_V9.py
- NEW: db\ops\227_seed_multisport_provider_jobs.sql
- NEW: db\ops\228_fill_default_run_groups_multisport.sql
- NEW: db\ops\229_multisport_planner_test.sql
- NEW: db\ops\230_seed_multisport_ingest_targets.sql
- NEW: db\ops\230a_seed_multisport_leagues.sql
- NEW: db\ops\231_multisport_planner_preview.sql
- NEW: docs\komunikace s chatGPT\20260323\229_ops.ingest_entity_plan.txt
- NEW: docs\komunikace s chatGPT\20260323\229_ops.ingest_entity_plan_4.txt
- NEW: docs\komunikace s chatGPT\20260323\229_ops.ingest_targets.txt
- NEW: docs\komunikace s chatGPT\20260323\229_ops.provider_jobs.txt
- NEW: docs\komunikace s chatGPT\20260323\Aktuální run_group rozpad v ops.ingest_entity_plan.txt
- NEW: docs\komunikace s chatGPT\20260323\Aktuální run_group rozpad v ops.ingest_targets.txt
- NEW: docs\komunikace s chatGPT\20260323\bod 1.txt
- NEW: docs\komunikace s chatGPT\20260323\bod 2.txt
- NEW: docs\komunikace s chatGPT\20260323\bod 3.txt
- NEW: docs\komunikace s chatGPT\20260323\bod 4.txt
- NEW: docs\komunikace s chatGPT\20260323\ingest_entity_plan.txt
- NEW: docs\komunikace s chatGPT\20260323\Jak teď vypadá football rozpad.txt

## Git
- Branch: main
- Last commit: 589e7bd | 2026-03-22 13:10:31 +0100 | update players pipeline
```
M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
 M MatchMatrix-platform/.dbeaver/project-metadata.json
 M ingest/API-Football/pull_api_football_players.ps1
 M ingest/parse_api_football_player_profiles_v1.py
 M ingest/providers/provider_registry.py
 M ops_admin/panel_matchmatrix_audit_v7.py
 M reports/audit/2026-03-22/MATCHMATRIX_AUDIT_REPORT.md
 M reports/audit/2026-03-22/MATCHMATRIX_PROGRESS.md
 M reports/audit/latest_audit_report.md
 D reports/audit/latest_changes.csv
 D reports/audit/latest_files.csv
 D reports/audit/latest_progress.md
 M reports/audit/latest_progress_report.md
 D reports/audit/latest_report.md
 D reports/audit/latest_snapshot.json
 M reports/audit/latest_snapshot.txt
 M tools/matchmatrix_control_panel_V9.py
 M workers/run_ingest_planner_jobs.py
 M workers/run_players_fetch_only_v1.py
 M workers/run_players_parse_only_v1.py
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/206_fix_player_season_statistics_unique.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/207_dedupe_player_season_statistics.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/209_fix_player_season_statistics_key.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/210_add_api_football_player_stats_entity.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/211_bootstrap_ingest_targets_from_existing_leagues_all_sports.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/212_enable_fb_api_football_bootstrap_v1.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/213_build_planner_from_fb_bootstrap_v1.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/215_disable_unsupported_providers.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/216_disable_fb_odds_in_free_mode.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/217_cleanup_fb_odds_errors_free_mode.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/218_build_planner_fb_teams_bootstrap.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/219_build_planner_fb_teams_bootstrap_v2.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/220_check_fb_bootstrap_targets_api_football.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/221_enable_fb_bootstrap_api_football.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/222_build_planner_fb_teams_bootstrap_v3.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/224_check_fb_bootstrap_teams_effect.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/225_check_bootstrap_warning_jobs.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/227_seed_multisport_provider_jobs.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/228_fill_default_run_groups_multisport.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/229_multisport_planner_test.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/230_seed_multisport_ingest_targets.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/230a_seed_multisport_leagues.sql
?? MatchMatrix-platform/Scripts/12_multisport/12_multisport/231_multisport_planner_preview.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest-footbal/212_enable_fb_api_football_bootstrap_v1.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest-footbal/214_check_fb_bootstrap_after_first_run.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest-footbal/226_check_fb_bootstrap_teams_progress.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/204_add_photo_url_to_staging_players_import.sql
?? db/checks/214_check_fb_bootstrap_after_first_run.sql
?? db/checks/220_check_fb_bootstrap_targets_api_football.sql
?? db/checks/224_check_fb_bootstrap_teams_effect.sql
?? db/checks/225_check_bootstrap_warning_jobs.sql
?? db/checks/226_check_fb_bootstrap_teams_progress.sql
?? db/migrations/204_add_photo_url_to_staging_players_import.sql
?? db/migrations/206_fix_player_season_statistics_unique.sql
?? db/migrations/207_dedupe_player_season_statistics.sql
?? db/migrations/209_fix_player_season_statistics_key.sql
?? db/migrations/210_add_api_football_player_stats_entity.sql
?? db/migrations/211_disable_unsupported_providers.sql
?? db/migrations/216_disable_fb_odds_in_free_mode.sql
?? db/migrations/217_cleanup_fb_odds_errors_free_mode.sql
?? db/migrations/221_enable_fb_bootstrap_api_football.sql
?? db/ops/211_bootstrap_ingest_targets_from_existing_leagues_all_sports.sql
?? db/ops/212_enable_fb_api_football_bootstrap_v1.sql
?? db/ops/213_build_planner_from_fb_bootstrap_v1.sql
?? db/ops/218_build_planner_fb_teams_bootstrap.sql
?? db/ops/219_build_planner_fb_teams_bootstrap_v2.sql
?? db/ops/222_build_planner_fb_teams_bootstrap_v3.sql
?? db/ops/227_seed_multisport_provider_jobs.sql
?? db/ops/228_fill_default_run_groups_multisport.sql
?? db/ops/229_multisport_planner_test.sql
?? db/ops/230_seed_multisport_ingest_targets.sql
?? db/ops/230a_seed_multisport_leagues.sql
?? db/ops/231_multisport_planner_preview.sql
?? "docs/komunikace s chatGPT/# MATCHMATRIX \342\200\223 Z\303\201PIS (2026-03-23).md"
?? "docs/komunikace s chatGPT/20260322/MATCHMATRIX \342\200\223 NAVAZOVAC\303\215 Z\303\201PIS .md"
?? "docs/komunikace s chatGPT/20260322/MATCHMATRIX \342\200\223 Z\303\201PIS (DNES).md"
?? "docs/komunikace s chatGPT/20260323/"
?? ingest/API-Football/pull_api_football_player_stats.ps1
?? ingest/API-Football/pull_api_football_players_v5.py
?? ingest/providers/generic_api_sport_provider.py
?? reports/audit/2026-03-23/
?? reports/audit/latest_system_tree.txt
?? reports/audit/system_tree_2026-03-23_110914.txt
?? reports/audit/system_tree_2026-03-23_203905.txt
?? reports/audit/system_tree_2026-03-24_071848.txt
?? tools/export_system_tree_v1.py
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2725
  - matches: 107089
  - players: 839
  - teams: 5369
- OPS counts:
  - ingest_planner: 3062
  - job_runs: 300
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