# TicketMatrixPlatform – technický audit

Datum a čas: 2026-04-21 22:56:36
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 3138
- NEW: 244
- MODIFIED: 2
- DELETED: 207

## Nejvýznamnější změny
- DELETED: ingest\API-Tennis\param(.txt
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\000_check_hb_leagues_ingest_planner.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\001_check_hb_leagues_public_after_run.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\002_find_hb_leagues_merge_logic.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\004_check_hb_leagues_after_sportcode_fix.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\005_check_hb_teams_fixtures_after_leagues_fix.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\006_check_hb_staging_fixtures_coverage.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\008_check_hb_planner_vs_targets.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\011_check_hb_planner_refill.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\012_show_hb_fixture_targets.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\013_expand_hb_fixture_targets_to_full_scope.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\014_check_hb_targets_after_expand.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\018_check_hb_fixture_team_mapping_after_parse.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\019_check_latest_hb_payload_statuses.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\021_refill_hb_teams_planner_from_targets.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\024b_show_missing_hb_team_map_details.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\025_check_missing_hb_team_ids_in_team_layers.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\113_hk_fixtures_after_run_check_v2.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\115_update_runtime_entity_audit_hk_fixtures_stage_confirmed.sql
- DELETED: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_0_přehled_celé_DB\116_preview_hk_provider_fixtures.sql

## Git
- Branch: main
- Last commit: a174b42 | 2026-04-21 22:56:01 +0200 | update players pipeline
```
M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
?? reports/audit/system_tree_2026-04-21_225633.txt
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 3429
  - matches: 114713
  - players: 2435
  - teams: 6966
- OPS counts:
  - ingest_planner: 4727
  - job_runs: 748
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