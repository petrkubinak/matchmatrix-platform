# MATCHMATRIX AUDIT REPORT

- Datum spuštění: 2026-03-17 09:56:27
- Počítač: Kubinak-Petr
- Project root: `C:\MatchMatrix-platform`

## 1. FILE AUDIT

- Vybrané kategorie: workers, ingest, api_football, scripts, dump
- Počet nalezených souborů: 457
- Počet změn oproti minulému běhu: 5

### Souhrn dle kategorií

| Kategorie | Soubory | Velikost (bytes) |
|---|---:|---:|
| api_football | 20 | 80054 |
| dump | 15 | 658530075 |
| ingest | 60 | 21946969 |
| scripts | 322 | 267362 |
| workers | 40 | 428794 |

### Změny oproti minulému běhu

| Typ | Kategorie | Soubor | Stará změna | Nová změna |
|---|---|---|---|---|
| DELETED | ingest | `providers\__pycache__\api_football_provider.cpython-314.pyc` | 2026-03-13 23:08:15 |  |
| DELETED | ingest | `providers\__pycache__\api_hockey_provider.cpython-314.pyc` | 2026-03-11 22:19:46 |  |
| DELETED | ingest | `providers\__pycache__\base_provider.cpython-314.pyc` | 2026-03-11 22:10:03 |  |
| DELETED | ingest | `providers\__pycache__\provider_registry.cpython-314.pyc` | 2026-03-11 22:10:03 |  |
| DELETED | workers | `__pycache__\run_player_profiles_public_merge_v1.cpython-314.pyc` | 2026-03-15 20:31:11 |  |

## 2. GIT / GITHUB AUDIT

- Branch: `main`
- Last commit hash: `0e00769cf33422fc0bf706b3054d2bbf4dbb9406`
- Last commit date: 2026-03-11 20:22:35
- Last commit message: Initial MatchMatrix setup (Docker + ingest + reports)
- Git status summary: `## main...origin/main [ahead 7]`
- Modified files: 36
- Untracked files: 101
- WARNING: **V projektu jsou změny, které ještě nejsou uložené do Git/GitHub.**

### Git status detail

```text
M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
 M MatchMatrix-platform/.dbeaver/project-metadata.json
 D MatchMatrix-platform/Dump/dump-matchmatrix-202602272251_leagues.sql
 D MatchMatrix-platform/Dump/dump-matchmatrix-202602282349.sql
 D MatchMatrix-platform/Dump/dump-matchmatrix-202603012240.sql
 D MatchMatrix-platform/Dump/dump-matchmatrix-202603020927.sql
 D MatchMatrix-platform/Dump/dump-matchmatrix-202603022246.sql
 D MatchMatrix-platform/Dump/dump-matchmatrix-202603091608.sql
 M "docs/komunikace s chatGPT/20260311/MatchMatrix \342\200\223 pracovn\303\255 z\303\241pis.md"
 D "ingest/API-Football/Spou\305\241t\304\233c\303\255 p\305\231\303\255kaz - 009_merge_players.txt"
 D "ingest/API-Football/Spou\305\241t\304\233c\303\255 p\305\231\303\255kaz - fix_teammap_from_fixtures.ps1.txt"
 D "ingest/API-Football/Spou\305\241t\304\233c\303\255 p\305\231\303\255kaz - merge_only.ps1.txt"
 D "ingest/API-Football/Spou\305\241t\304\233c\303\255 p\305\231\303\255kaz - run_ingest_teams.txt"
 D ingest/API-Football/api_football_pull_v1.py
 M ingest/API-Football/pull_api_football_odds.ps1
 M ingest/API-Football/pull_api_football_players.ps1
 D ingest/API-Football/run_api_football_pipeline.ps1
 D ingest/API-Football/run_api_football_pipeline_V1.ps1
 D "ingest/API-Football/spou\305\241t\304\233n\303\255 a odkaz-run_api_football_pipeline.txt"
 D "ingest/API-Football/spou\305\241t\304\233n\303\255 run_ingest_fixtures_all_targets.ps1.txt"
 D "ingest/API-Football/spou\305\241t\304\233n\303\255-run_api_football_pipeline.txt"
 D ingest/predict_matches_V2.py
 D ingest/run_predict_matches.bat
 D ingest/run_theodds_parse.bat
 D ingest/run_theodds_parse_multi.bat
 D ingest/run_train_gbm_v1.bat
 D ingest/run_train_gbm_v2.bat
 D "ingest/spou\305\241t\304\233c\303\255_pull_skript_pro_jednu_ligu.txt"
 D ingest/theodds_parse.py
 D ingest/theodds_parse_multi.py
 D ingest/train_gbm_v1.py
 D ingest/train_gbm_v2.py
 D ingest/unmatched_theodds_105.csv
 D ingest/unmatched_theodds_105.sql
 D ingest/unmatched_theodds_107.csv
 D ingest/unmatched_theodds_107.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603122251.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603122252.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603132305.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603132306.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603150829.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603151432.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603160648.sql
?? MatchMatrix-platform/Dump/dump-matchmatrix-202603162300.sql
?? MatchMatrix-platform/Dump/dump_ops-matchmatrix-202603112252.sql
?? MatchMatrix-platform/Dump/dump_ops-matchmatrix-202603131533.sql
?? MatchMatrix-platform/Scripts/00_Schema/010_staging_api_football.sql/038_alter_stg_provider_player_stats_for_match_merge.sql
?? MatchMatrix-platform/Scripts/00_Schema/010_staging_api_football.sql/039_create_player_season_statistics.sql
?? MatchMatrix-platform/Scripts/00_Schema/020_provider_maps.sql/037_players_multisource_foundation.sql
?? MatchMatrix-platform/Scripts/00_Schema/020_provider_maps.sql/038_players_enrichment_reseed_squads_team_based.sql
?? MatchMatrix-platform/Scripts/00_Schema/030_ingest_schema.sql/035_ops_create_ingest_planner.sql
?? MatchMatrix-platform/Scripts/00_Schema/030_ingest_schema.sql/036_ops_create_worker_locks.sql
?? MatchMatrix-platform/Scripts/00_Schema/030_ingest_schema.sql/037_ops_insert_job_ingest_cycle_v2.sql
?? MatchMatrix-platform/Scripts/00_Schema/030_ingest_schema.sql/038_ops_create_dashboard_views.sql
?? MatchMatrix-platform/Scripts/00_Schema/030_ingest_schema.sql/039_ops_insert_job_unified_staging_to_public_merge.sql
?? MatchMatrix-platform/Scripts/07_audity/078_audit_player_season_statistics_v1.sql
?? MatchMatrix-platform/Scripts/07_audity/079_audit_player_season_statistics_report_v1.sql
?? MatchMatrix-platform/Scripts/07_audity/080_debug_player_stats_merge_mapping_v1.sql
?? MatchMatrix-platform/Scripts/07_audity/081_fix_player_season_statistics_merge_v1.sql
?? MatchMatrix-platform/Scripts/10_sql/sql_players_pipeline_audit_queries.sql
?? MatchMatrix-platform/Scripts/11_ops/
?? MatchMatrix-platform/Scripts/99_playground/099_kontrola_ingest_planneru.sql
?? MatchMatrix-platform/Scripts/99_playground/099_kontrola_running_planneru_a_zruseni.sql
?? "MatchMatrix-platform/Scripts/99_playground/099_vr\303\241cen\303\255_konkr\303\251tn\303\255_jobu_zp\304\233t.sql"
?? MatchMatrix-platform/Scripts/99_playground/cleanup_player_season_stats_scope_95_2024_v1.sql
?? MatchMatrix-platform/Scripts/Script.sql
?? db/audit/
?? db/migrations/024_ops_create_ingest_entity_plan.sql
?? db/migrations/036_ops_extend_stg_provider_players.sql
?? db/migrations/037_players_multisource_foundation.sql
?? db/migrations/038_players_enrichment_reseed_squads_team_based.sql
?? db/ops/
?? db/queries/
?? db/sql/114_sql_players_pipeline_audit_queries.sql
?? "docs/komunikace s chatGPT/20260312/"
?? "docs/komunikace s chatGPT/20260313/"
?? "docs/komunikace s chatGPT/20260314/"
?? "docs/komunikace s chatGPT/20260315/"
?? "docs/komunikace s chatGPT/20260316/"
?? "docs/komunikace s chatGPT/20260317/"
?? docs/visual/
?? ingest/API-Football/pull_api_football_players_squads_v1.py
?? ingest/API-Football/pull_api_football_players_v4.py
?? ingest/API-Football/test_api_football_players_access.py
?? ingest/providers/
?? ingest/run_unified_ingest_batch_v1.py
?? ingest/run_unified_ingest_v1.py
?? "ops_admin/MatchMatrix Audit Panel.bat"
?? ops_admin/MatchMatrix_OPS_Audit_Panel.bat
?? ops_admin/MatchMatrix_OPS_Panel.vbs
?? ops_admin/MatchMatrix_OPS_Panel_V3.vbs
?? "ops_admin/README_CZ (1).txt"
?? ops_admin/README_CZ.md
?? ops_admin/README_CZ.txt
?? ops_admin/README_V3_CZ.txt
?? ops_admin/matchmatrix_file_audit.py
?? ops_admin/panel_audit_matchmatrix_v1.py
?? ops_admin/panel_matchmatrix_audit_v2.py
?? ops_admin/panel_matchmatrix_audit_v3.py
?? ops_admin/run_matchmatrix_file_audit.ps1
?? ops_admin/run_panel_matchmatrix_audit_v2.ps1
?? ops_admin/spustit_panel_audit_matchmatrix_v1.ps1
?? reports/audit/
?? reports/file_audit/
?? reports/player_audit/
?? run_player_audit_report.bat
?? tools/matchmatrix_control_panel_V3.py
?? tools/matchmatrix_control_panel_V4.py
?? tools/run_matchmatrix_control_panel_V3.bat
?? tools/run_matchmatrix_panel_V4.bat
?? workers/build_ingest_planner_jobs.py
?? workers/build_player_enrichment_jobs.py
?? workers/extract_teams_from_fixtures.py
?? workers/extract_teams_from_fixtures_v2.py
?? workers/pull_api_football_players_v4.py
?? workers/run_audit_player_season_statistics_report_docker_v1.ps1
?? workers/run_audit_player_season_statistics_report_v1.ps1
?? workers/run_ingest_cycle_v1.py
?? workers/run_ingest_cycle_v2.py
?? workers/run_ingest_cycle_v3.py
?? workers/run_ingest_planner_jobs.py
?? workers/run_multisport_scheduler_v4.py
?? workers/run_player_match_statistics_public_merge_v1.py
?? workers/run_player_profiles_public_merge_v1.py
?? workers/run_player_season_statistics_public_merge_v1.py
?? workers/run_player_season_statistics_stage_parser_v1.py
?? workers/run_players_bridge_v2.py
?? workers/run_players_bridge_v3.py
?? workers/run_players_bridge_v4.py
?? workers/run_players_public_merge_v1.py
?? workers/run_players_public_merge_v2.py
?? workers/run_players_season_stats_bridge_v1.py
?? workers/run_players_season_stats_bridge_v2.py
?? workers/run_players_season_stats_bridge_v3.py
?? workers/run_unified_staging_to_public_merge_v2.py
?? workers/run_unified_staging_to_public_merge_v3.py
?? workers/test_db_connection.py
```

## 3. DATABASE AUDIT

- Stav: připojení k DB je v pořádku

### Schéma overview

| Schema | Počet tabulek |
|---|---:|
| ops | 19 |
| public | 97 |
| staging | 22 |
| work | 1 |

### Základní row counts

| Schema | Tabulka | Rows |
|---|---|---:|
| public | sports | 13 |
| public | leagues | 2713 |
| public | teams | 5234 |
| public | matches | 107089 |
| public | players | 559 |
| public | odds | 18902 |
| staging | players_import | 540 |
| staging | stg_provider_players | 533 |

### OPS status

| Schema | Tabulka | Rows |
|---|---|---:|
| ops | ingest_targets | 2713 |
| ops | league_import_plan | 175 |
| ops | jobs | 16 |
| ops | job_runs | 117 |

### Player pipeline status

| Schema | Tabulka | Rows |
|---|---|---:|
| staging | players_import | 540 |
| staging | stg_provider_players | 533 |
| public | players | 559 |

## 4. DUMP / SCRIPTS NOTE

- Dump audit je součást file auditu přes kategorii `dump`.
- Scripts audit je součást file auditu přes kategorii `scripts`.

## 6. DOPORUČENÍ PŘED UKONČENÍM PRÁCE

- [ ] zkontrolovat změny ve workers / ingest / scripts
- [ ] uložit SQL skripty
- [ ] uložit Python workery
- [ ] provést `git add .`
- [ ] provést `git commit -m "..."`
- [ ] provést `git push`
- [ ] ověřit, že důležité změny jsou uložené i na GitHub
