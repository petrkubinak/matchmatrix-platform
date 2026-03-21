# TicketMatrixPlatform – technický audit

Datum a čas: 2026-03-22 00:06:31
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 1119
- NEW: 37
- MODIFIED: 2
- DELETED: 0

## Nejvýznamnější změny
- MODIFIED: tools\matchmatrix_control_panel_V7.py
- MODIFIED: workers\run_ingest_planner_jobs.py
- NEW: db\ops\190_seed_hk_full_provider_jobs.sql
- NEW: db\ops\194_seed_hk_core_provider_jobs.sql
- NEW: db\ops\197_seed_bk_top_provider_jobs.sql
- NEW: db\ops\200_seed_bk_core_provider_jobs.sql
- NEW: db\ops\203_seed_hk_top_ingest_planner.sql
- NEW: db\views\188_create_v_ops_hk_top_full_execution_order.sql
- NEW: db\views\189_create_v_ops_hk_full_job_catalog.sql
- NEW: db\views\191_create_v_ops_hk_full_runnable_jobs.sql
- NEW: db\views\193_create_v_ops_hk_core_full_job_catalog.sql
- NEW: db\views\195_create_v_ops_hk_core_runnable_jobs.sql
- NEW: db\views\196_create_v_ops_bk_top_full_job_catalog.sql
- NEW: db\views\198_create_v_ops_bk_top_runnable_jobs.sql
- NEW: db\views\199_create_v_ops_bk_core_full_job_catalog.sql
- NEW: db\views\201_create_v_ops_bk_core_runnable_jobs.sql
- NEW: db\views\202_create_v_ops_hk_top_full_runnable_jobs.sql
- NEW: docs\komunikace s chatGPT\20260320\MatchMatrix – pracovní zápis.md
- NEW: docs\komunikace s chatGPT\20260321\MatchMatrix – navazovací zápis.txt
- NEW: MatchMatrix-platform\Dump\dump-matchmatrix-202603220005.sql

## Git
- Branch: main
- Last commit: f2cefba | 2026-03-20 22:00:43 +0100 | update players pipeline
```
M reports/audit/latest_snapshot.txt
 M tools/matchmatrix_control_panel_V7.py
 M workers/run_ingest_planner_jobs.py
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_basket/
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/188_create_v_ops_hk_top_full_execution_order.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/189_create_v_ops_hk_full_job_catalog.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/190_seed_hk_full_provider_jobs.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/191_create_v_ops_hk_full_runnable_jobs.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/193_create_v_ops_hk_core_full_job_catalog.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/194_seed_hk_core_provider_jobs.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/195_create_v_ops_hk_core_runnable_jobs.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/202_create_v_ops_hk_top_full_runnable_jobs.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/203_seed_hk_top_ingest_planner.sql
?? MatchMatrix-platform/Scripts/12_multisport/13_multisport_ingest_hokej/Script.sql
?? db/ops/190_seed_hk_full_provider_jobs.sql
?? db/ops/194_seed_hk_core_provider_jobs.sql
?? db/ops/197_seed_bk_top_provider_jobs.sql
?? db/ops/200_seed_bk_core_provider_jobs.sql
?? db/ops/203_seed_hk_top_ingest_planner.sql
?? db/views/188_create_v_ops_hk_top_full_execution_order.sql
?? db/views/189_create_v_ops_hk_full_job_catalog.sql
?? db/views/191_create_v_ops_hk_full_runnable_jobs.sql
?? db/views/193_create_v_ops_hk_core_full_job_catalog.sql
?? db/views/195_create_v_ops_hk_core_runnable_jobs.sql
?? db/views/196_create_v_ops_bk_top_full_job_catalog.sql
?? db/views/198_create_v_ops_bk_top_runnable_jobs.sql
?? db/views/199_create_v_ops_bk_core_full_job_catalog.sql
?? db/views/201_create_v_ops_bk_core_runnable_jobs.sql
?? db/views/202_create_v_ops_hk_top_full_runnable_jobs.sql
?? "docs/komunikace s chatGPT/20260320/MatchMatrix \342\200\223 pracovn\303\255 z\303\241pis.md"
?? "docs/komunikace s chatGPT/20260321/"
?? tools/matchmatrix_control_panel_V7_fixed.py
?? tools/matchmatrix_control_panel_V8.py
?? tools/matchmatrix_control_panel_V9.py
?? tools/run_matchmatrix_panel_v7.vbs
?? tools/run_matchmatrix_panel_v8.vbs
?? tools/run_matchmatrix_panel_v9.vbs
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2713
  - matches: 107089
  - players: 779
  - teams: 5238
- OPS counts:
  - ingest_planner: 215
  - job_runs: 181
  - provider_jobs: 78
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