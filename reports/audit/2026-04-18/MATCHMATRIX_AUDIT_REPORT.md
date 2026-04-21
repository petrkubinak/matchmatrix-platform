# TicketMatrixPlatform – technický audit

Datum a čas: 2026-04-18 23:32:51
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 2920
- NEW: 25
- MODIFIED: 8
- DELETED: 3

## Nejvýznamnější změny
- DELETED: docs\komunikace s chatGPT\04_2026\20260409\# 614 – CODE WORKER AUDIT CHECKLIST.txt
- DELETED: docs\komunikace s chatGPT\04_2026\20260409\MATCHMATRIX – ZÁPIS (2026-04-09).md
- DELETED: MatchMatrix-platform\Scripts\07_audity\718_audit_fb_run_group_distribution.sql
- MODIFIED: _scan_ingest.txt
- MODIFIED: _scan_ops.txt
- MODIFIED: _scan_ops_admin.txt
- MODIFIED: _scan_tools.txt
- MODIFIED: _scan_workers.txt
- MODIFIED: ingest\API-Sport\pull_api_sport_fixtures.ps1
- MODIFIED: ingest\API-Sport\pull_api_sport_leagues.ps1
- MODIFIED: MatchMatrix-platform\.dbeaver\project-metadata.json
- NEW: db\audit\711_audit_hb_runtime_start_fix1.sql
- NEW: db\audit\712_audit_hb_runtime_reality.sql
- NEW: db\audit\713_audit_hb_worker_binding.sql
- NEW: db\audit\714_seed_runtime_entity_audit_hb_core_fix2.sql
- NEW: db\checks\717_fix_hb_target_ehf_to_champions_league.sql
- NEW: db\checks\718_fix_hb_fixtures_date_window.sql
- NEW: db\checks\Script-6.sql
- NEW: docs\komunikace s chatGPT\04_2026\20260409-audit\# 614 – CODE WORKER AUDIT CHECKLIST.txt
- NEW: docs\komunikace s chatGPT\04_2026\20260409-audit\MATCHMATRIX – ZÁPIS (2026-04-09).md

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
 M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/711_audit_hb_runtime_start_fix1.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/712_audit_hb_runtime_reality.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/713_audit_hb_worker_binding.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/714_seed_runtime_entity_audit_hb_core_fix2.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/718_audit_fb_run_group_distribution.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/718_fix_hb_fixtures_date_window.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_4_kontrola_runn\305\257_/716_check_hb_leagues_after_first_run.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_4_kontrola_runn\305\257_/716_check_hb_leagues_after_first_run_fix.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_4_kontrola_runn\305\257_/717_fix_hb_target_ehf_to_champions_league.sql"
?? db/audit/711_audit_hb_runtime_start_fix1.sql
?? db/audit/712_audit_hb_runtime_reality.sql
?? db/audit/713_audit_hb_worker_binding.sql
?? db/audit/714_seed_runtime_entity_audit_hb_core_fix2.sql
?? db/checks/717_fix_hb_target_ehf_to_champions_league.sql
?? db/checks/718_fix_hb_fixtures_date_window.sql
?? db/checks/Script-6.sql
?? "docs/komunikace s chatGPT/04_2026/20260409-audit/"
?? "docs/komunikace s chatGPT/04_2026/20260417/"
?? "ingest/API-H\303\241zen\303\241/"
?? reports/audit/2026-04-18/
?? reports/audit/system_tree_2026-04-18_233249.txt
?? workers/run_parse_api_sport_leagues_v1.py
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
  - job_runs: 549
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