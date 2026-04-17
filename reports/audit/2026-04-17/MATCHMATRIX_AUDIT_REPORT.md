# TicketMatrixPlatform – technický audit

Datum a čas: 2026-04-17 21:48:08
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 2898
- NEW: 311
- MODIFIED: 2
- DELETED: 0

## Nejvýznamnější změny
- MODIFIED: reports\614_worker_file_scan_v2.csv
- MODIFIED: workers\run_ingest_cycle_v3.py
- NEW: _scan_ingest.txt
- NEW: _scan_ops.txt
- NEW: _scan_ops_admin.txt
- NEW: _scan_tools.txt
- NEW: _scan_workers.txt
- NEW: db\audit\702_audit_fb_leagues_unmapped_only.sql
- NEW: db\audit\703_audit_fb_leagues_unmapped_relevant.sql
- NEW: db\audit\704_audit_fb_fixtures_team_map_gap.sql
- NEW: db\audit\705_audit_fb_matches_missing.sql
- NEW: db\audit\706_audit_odds_unmatched_match_id.sql
- NEW: db\audit\707a_audit_matches_ext_source_distribution.sql
- NEW: db\audit\708_audit_api_football_fixtures_vs_public_matches.sql
- NEW: db\audit\709_find_public_matches_merge_sources.sql
- NEW: db\audit\713_check_recent_public_matches_after_api_pull.sql
- NEW: db\audit\718_audit_fb_run_group_distribution.sql
- NEW: db\fix\717_move_api_football_targets_to_eu_run_group.sql
- NEW: db\fix\724_fix_planner_sport_code.sql
- NEW: db\fix\726_fix_planner_slice_back_to_FB.sql

## Git
- Branch: main
- Last commit: 0247645 | 2026-04-16 13:54:06 +0200 | %1
```
M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
 M workers/run_ingest_cycle_v3.py
?? MatchMatrix-platform/Scripts/07_audity/615_audit_fb_missing_runs_why_not_merged_v2.sql
?? MatchMatrix-platform/Scripts/07_audity/702_audit_fb_leagues_unmapped_only.sql
?? MatchMatrix-platform/Scripts/07_audity/703_audit_fb_leagues_unmapped_relevant.sql
?? MatchMatrix-platform/Scripts/07_audity/704_audit_fb_fixtures_team_map_gap.sql
?? MatchMatrix-platform/Scripts/07_audity/705_audit_fb_matches_missing.sql
?? MatchMatrix-platform/Scripts/07_audity/706_audit_odds_unmatched_match_id.sql
?? MatchMatrix-platform/Scripts/07_audity/707a_audit_matches_ext_source_distribution.sql
?? MatchMatrix-platform/Scripts/07_audity/708_audit_api_football_fixtures_vs_public_matches.sql
?? MatchMatrix-platform/Scripts/07_audity/709_find_public_matches_merge_sources.sql
?? MatchMatrix-platform/Scripts/07_audity/713_check_recent_public_matches_after_api_pull.sql
?? MatchMatrix-platform/Scripts/07_audity/714_check_ops_ingest_targets_api_football.sql
?? MatchMatrix-platform/Scripts/07_audity/718_audit_fb_run_group_distribution.sql
?? MatchMatrix-platform/Scripts/09_run/700_football/
?? MatchMatrix-platform/Scripts/Script.sql
?? _scan_ingest.txt
?? _scan_ops.txt
?? _scan_ops_admin.txt
?? _scan_tools.txt
?? _scan_workers.txt
?? db/audit/702_audit_fb_leagues_unmapped_only.sql
?? db/audit/703_audit_fb_leagues_unmapped_relevant.sql
?? db/audit/704_audit_fb_fixtures_team_map_gap.sql
?? db/audit/705_audit_fb_matches_missing.sql
?? db/audit/706_audit_odds_unmatched_match_id.sql
?? db/audit/707a_audit_matches_ext_source_distribution.sql
?? db/audit/708_audit_api_football_fixtures_vs_public_matches.sql
?? db/audit/709_find_public_matches_merge_sources.sql
?? db/audit/713_check_recent_public_matches_after_api_pull.sql
?? db/audit/718_audit_fb_run_group_distribution.sql
?? db/fix/717_move_api_football_targets_to_eu_run_group.sql
?? db/fix/724_fix_planner_sport_code.sql
?? db/fix/726_fix_planner_slice_back_to_FB.sql
?? db/migrations/sql/
?? db/ops/723_seed_ingest_planner_from_targets.sql
?? db/sql/615_audit_fb_missing_runs_why_not_merged_v2.sql
?? "docs/komunikace s chatGPT/04_2026/20260416/"
?? logs/api_football_backfill_status_2026-04-17_072251.txt
?? reports/audit/2026-04-16/STG_provider_fixtures.txt
?? reports/audit/2026-04-16/STG_provider_fixtures_2.txt
?? reports/audit/2026-04-16/STG_provider_leagues.txt
?? reports/audit/2026-04-16/ingest_planner.txt
?? reports/audit/2026-04-16/ingest_targets.txt
?? reports/audit/2026-04-17/
?? reports/audit/system_tree_2026-04-17_214806.txt
?? "reports/p\305\231ehled_sloupc\305\257_tabulek_OPS/20260416/"
?? "reports/p\305\231ehled_sloupc\305\257_tabulek_staging/20260416/STG_1.txt"
?? "reports/p\305\231ehled_sloupc\305\257_tabulek_staging/20260416/STG_2.txt"
?? "reports/p\305\231ehled_sloupc\305\257_tabulek_staging/20260416/STG_3.txt"
?? "reports/p\305\231ehled_sloupc\305\257_tabulek_staging/20260416/STG_4.txt"
?? reports/run_project_folder_scan.vbs
?? workers/run_api_football_fixtures_raw_to_public.ps1
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2994
  - matches: 112112
  - players: 2435
  - teams: 6070
- OPS counts:
  - ingest_planner: 4301
  - job_runs: 537
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