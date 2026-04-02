# MATCHMATRIX AUDIT REPORT

- Datum spuštění: 2026-03-17 09:48:14
- Počítač: Kubinak-Petr
- Project root: `C:\MatchMatrix-platform`

## 1. FILE AUDIT

- Vybrané kategorie: workers, ingest, api_football, scripts, dump
- Počet nalezených souborů: 462
- Počet změn oproti minulému běhu: 462

### Souhrn dle kategorií

| Kategorie | Soubory | Velikost (bytes) |
|---|---:|---:|
| api_football | 20 | 80054 |
| dump | 15 | 658530075 |
| ingest | 64 | 21969433 |
| scripts | 322 | 267362 |
| workers | 41 | 436674 |

### Změny oproti minulému běhu

| Typ | Kategorie | Soubor | Stará změna | Nová změna |
|---|---|---|---|---|
| NEW | api_football | `.env` |  | 2026-03-16 17:38:01 |
| NEW | api_football | `api_football_pull_leagues_csv.py` |  | 2026-02-24 16:07:14 |
| NEW | api_football | `api_football_pull_v2.py` |  | 2026-02-25 15:55:41 |
| NEW | api_football | `fix_teammap_from_fixtures.ps1` |  | 2026-03-04 10:09:23 |
| NEW | api_football | `merge_only.ps1` |  | 2026-03-04 10:12:49 |
| NEW | api_football | `pull_api_football_fixtures.ps1` |  | 2026-03-04 14:14:22 |
| NEW | api_football | `pull_api_football_leagues.ps1` |  | 2026-02-24 16:45:43 |
| NEW | api_football | `pull_api_football_odds.ps1` |  | 2026-03-13 22:55:55 |
| NEW | api_football | `pull_api_football_odds_V1.ps1` |  | 2026-02-26 13:31:28 |
| NEW | api_football | `pull_api_football_players.ps1` |  | 2026-03-13 22:48:53 |
| NEW | api_football | `pull_api_football_players_squads_v1.py` |  | 2026-03-15 14:18:17 |
| NEW | api_football | `pull_api_football_players_v4.py` |  | 2026-03-16 18:04:35 |
| NEW | api_football | `pull_api_football_teams.ps1` |  | 2026-02-25 14:26:08 |
| NEW | api_football | `run_api_football_pipeline_v2.ps1` |  | 2026-02-25 15:55:46 |
| NEW | api_football | `run_api_football_pull_v1.bat` |  | 2026-02-23 16:14:31 |
| NEW | api_football | `run_ingest_fixtures.ps1` |  | 2026-02-27 10:22:59 |
| NEW | api_football | `run_ingest_fixtures_all_targets.old.ps1` |  | 2026-02-28 17:12:44 |
| NEW | api_football | `run_ingest_fixtures_all_targets.ps1` |  | 2026-03-03 22:44:55 |
| NEW | api_football | `run_ingest_teams_all_targets.ps1` |  | 2026-03-02 13:18:00 |
| NEW | api_football | `test_api_football_players_access.py` |  | 2026-03-15 10:19:12 |
| NEW | dump | `dump-matchmatrix-202602271537_leagues.sql` |  | 2026-02-27 15:37:36 |
| NEW | dump | `dump-matchmatrix-202603052038.sql` |  | 2026-03-05 20:38:42 |
| NEW | dump | `dump-matchmatrix-202603072347.sql` |  | 2026-03-07 23:47:39 |
| NEW | dump | `dump-matchmatrix-202603092253.sql` |  | 2026-03-09 22:53:48 |
| NEW | dump | `dump-matchmatrix-202603102254.sql` |  | 2026-03-10 22:54:12 |
| NEW | dump | `dump-matchmatrix-202603122251.sql` |  | 2026-03-12 22:51:22 |
| NEW | dump | `dump-matchmatrix-202603122252.sql` |  | 2026-03-12 22:52:47 |
| NEW | dump | `dump-matchmatrix-202603132305.sql` |  | 2026-03-13 23:05:40 |
| NEW | dump | `dump-matchmatrix-202603132306.sql` |  | 2026-03-13 23:06:07 |
| NEW | dump | `dump-matchmatrix-202603150829.sql` |  | 2026-03-15 08:30:00 |
| NEW | dump | `dump-matchmatrix-202603151432.sql` |  | 2026-03-15 14:32:34 |
| NEW | dump | `dump-matchmatrix-202603160648.sql` |  | 2026-03-16 06:48:08 |
| NEW | dump | `dump-matchmatrix-202603162300.sql` |  | 2026-03-16 23:00:43 |
| NEW | dump | `dump_ops-matchmatrix-202603112252.sql` |  | 2026-03-11 22:52:21 |
| NEW | dump | `dump_ops-matchmatrix-202603131533.sql` |  | 2026-03-13 15:33:17 |
| NEW | ingest | `.env` |  | 2026-02-23 12:23:42 |
| NEW | ingest | `API-Football\.env` |  | 2026-03-16 17:38:01 |
| NEW | ingest | `API-Football\api_football_pull_leagues_csv.py` |  | 2026-02-24 16:07:14 |
| NEW | ingest | `API-Football\api_football_pull_v2.py` |  | 2026-02-25 15:55:41 |
| NEW | ingest | `API-Football\fix_teammap_from_fixtures.ps1` |  | 2026-03-04 10:09:23 |
| NEW | ingest | `API-Football\merge_only.ps1` |  | 2026-03-04 10:12:49 |
| NEW | ingest | `API-Football\pull_api_football_fixtures.ps1` |  | 2026-03-04 14:14:22 |
| NEW | ingest | `API-Football\pull_api_football_leagues.ps1` |  | 2026-02-24 16:45:43 |
| NEW | ingest | `API-Football\pull_api_football_odds.ps1` |  | 2026-03-13 22:55:55 |
| NEW | ingest | `API-Football\pull_api_football_odds_V1.ps1` |  | 2026-02-26 13:31:28 |
| NEW | ingest | `API-Football\pull_api_football_players.ps1` |  | 2026-03-13 22:48:53 |
| NEW | ingest | `API-Football\pull_api_football_players_squads_v1.py` |  | 2026-03-15 14:18:17 |
| NEW | ingest | `API-Football\pull_api_football_players_v4.py` |  | 2026-03-16 18:04:35 |
| NEW | ingest | `API-Football\pull_api_football_teams.ps1` |  | 2026-02-25 14:26:08 |
| NEW | ingest | `API-Football\run_api_football_pipeline_v2.ps1` |  | 2026-02-25 15:55:46 |
| NEW | ingest | `API-Football\run_api_football_pull_v1.bat` |  | 2026-02-23 16:14:31 |
| NEW | ingest | `API-Football\run_ingest_fixtures.ps1` |  | 2026-02-27 10:22:59 |
| NEW | ingest | `API-Football\run_ingest_fixtures_all_targets.old.ps1` |  | 2026-02-28 17:12:44 |
| NEW | ingest | `API-Football\run_ingest_fixtures_all_targets.ps1` |  | 2026-03-03 22:44:55 |
| NEW | ingest | `API-Football\run_ingest_teams_all_targets.ps1` |  | 2026-03-02 13:18:00 |
| NEW | ingest | `API-Football\test_api_football_players_access.py` |  | 2026-03-15 10:19:12 |
| NEW | ingest | `API-Hockey\.env` |  | 2026-02-28 20:38:42 |
| NEW | ingest | `API-Hockey\pull_api_hockey_leagues.ps1` |  | 2026-02-28 23:37:13 |
| NEW | ingest | `API-Hockey\pull_api_hockey_teams.ps1` |  | 2026-03-01 19:13:23 |
| NEW | ingest | `artifacts\baseline_logreg.joblib` |  | 2026-02-15 21:41:50 |
| NEW | ingest | `artifacts\baseline_logreg_meta.json` |  | 2026-02-15 21:41:50 |
| NEW | ingest | `artifacts\baseline_logreg_v2.joblib` |  | 2026-02-15 22:53:43 |
| NEW | ingest | `artifacts\baseline_logreg_v2_meta.json` |  | 2026-02-15 22:53:43 |
| NEW | ingest | `artifacts\baseline_logreg_v3.joblib` |  | 2026-02-19 21:01:42 |
| NEW | ingest | `artifacts\baseline_logreg_v3_meta.json` |  | 2026-02-19 21:01:42 |
| NEW | ingest | `artifacts\gbm_v1.joblib` |  | 2026-03-06 07:48:34 |
| NEW | ingest | `artifacts\gbm_v2.joblib` |  | 2026-02-18 10:11:26 |
| NEW | ingest | `artifacts\gbm_v3_calibrated.joblib` |  | 2026-02-19 21:02:50 |
| NEW | ingest | `compute_mmr_ratings.py` |  | 2026-03-11 14:19:28 |
| NEW | ingest | `football_data_pull_V5.py` |  | 2026-02-19 09:51:56 |
| NEW | ingest | `football_data_uk_history_pull.py` |  | 2026-02-15 15:33:43 |
| NEW | ingest | `parse_api_sport_fixtures.py` |  | 2026-03-09 15:14:34 |
| NEW | ingest | `parse_api_sport_leagues.py` |  | 2026-03-08 21:21:23 |
| NEW | ingest | `predict_matches.py` |  | 2026-02-16 15:42:44 |
| NEW | ingest | `predict_matches_V3.py` |  | 2026-03-11 12:24:01 |
| NEW | ingest | `providers\__pycache__\api_football_provider.cpython-314.pyc` |  | 2026-03-13 23:08:15 |
| NEW | ingest | `providers\__pycache__\api_hockey_provider.cpython-314.pyc` |  | 2026-03-11 22:19:46 |
| NEW | ingest | `providers\__pycache__\base_provider.cpython-314.pyc` |  | 2026-03-11 22:10:03 |
| NEW | ingest | `providers\__pycache__\provider_registry.cpython-314.pyc` |  | 2026-03-11 22:10:03 |
| NEW | ingest | `providers\api_football_provider.py` |  | 2026-03-13 23:03:25 |
| NEW | ingest | `providers\api_hockey_provider.py` |  | 2026-03-11 22:19:14 |
| NEW | ingest | `providers\base_provider.py` |  | 2026-03-11 22:01:37 |
| NEW | ingest | `providers\provider_registry.py` |  | 2026-03-11 22:01:59 |
| NEW | ingest | `run_compute_mmr_ratings.bat` |  | 2026-02-16 22:32:40 |
| NEW | ingest | `run_football_data_pull_V5.bat` |  | 2026-02-19 09:52:23 |
| NEW | ingest | `run_football_data_uk_history.bat` |  | 2026-02-15 15:21:01 |
| NEW | ingest | `run_predict_matches_V3.bat` |  | 2026-02-19 10:41:48 |
| NEW | ingest | `run_theodds.bat` |  | 2026-02-19 14:45:37 |
| NEW | ingest | `run_theodds_parse_multi_FINAL.bat` |  | 2026-02-20 23:16:07 |
| NEW | ingest | `run_theodds_parse_multi_V1.bat` |  | 2026-02-20 22:29:48 |
| NEW | ingest | `run_train_baseline_logreg.bat` |  | 2026-02-15 16:14:42 |
| NEW | ingest | `run_train_gbm_v3.bat` |  | 2026-02-18 10:32:17 |
| NEW | ingest | `run_unified_ingest_batch_v1.py` |  | 2026-03-13 22:30:34 |
| NEW | ingest | `run_unified_ingest_v1.py` |  | 2026-03-13 08:46:34 |
| NEW | ingest | `theodds_parse_multi_FINAL.py` |  | 2026-03-08 11:12:08 |
| NEW | ingest | `theodds_parse_multi_V1.py` |  | 2026-02-20 22:28:43 |
| NEW | ingest | `theodds_pull.py` |  | 2026-02-19 15:17:27 |
| NEW | ingest | `train_baseline_logreg.py` |  | 2026-02-15 23:00:28 |
| NEW | ingest | `train_gbm_v3.py` |  | 2026-02-18 10:56:22 |
| NEW | scripts | `00_Schema\001_core_tebles.sql\002_team_aliases.sql` |  | 2026-02-19 18:10:09 |
| NEW | scripts | `00_Schema\001_core_tebles.sql\004_template_block_matches.sql` |  | 2026-02-12 11:13:41 |
| NEW | scripts | `00_Schema\001_core_tebles.sql\006_template_fixed_picks.sql` |  | 2026-02-11 09:06:01 |
| NEW | scripts | `00_Schema\001_core_tebles.sql\009_theodds_teams.sql` |  | 2026-02-19 21:23:33 |
| NEW | scripts | `00_Schema\001_core_tebles.sql\03_trigger_variable_block_1x2.sql` |  | 2026-02-19 14:05:11 |
| NEW | scripts | `00_Schema\001_core_tebles.sql\pomocná_funkce_na_čtení_limitu.sql` |  | 2026-02-12 14:18:27 |
| NEW | scripts | `00_Schema\001_core_tebles.sql\tabulka_nastaveni_limit_5000_tickets.sql` |  | 2026-02-12 13:21:39 |
| NEW | scripts | `00_Schema\001_create_tables\001_create_table_seasons.sql` |  | 2026-03-05 23:06:15 |
| NEW | scripts | `00_Schema\001_create_tables\002_create_table_players.sql` |  | 2026-03-06 10:48:51 |
| NEW | scripts | `00_Schema\001_create_tables\003_create_table_player_provider_map.sql` |  | 2026-03-02 22:47:13 |
| NEW | scripts | `00_Schema\001_create_tables\004_create_table_lineups.sql` |  | 2026-03-06 11:00:01 |
| NEW | scripts | `00_Schema\001_create_tables\005_create_table_injuries.sql` |  | 2026-03-06 11:01:34 |
| NEW | scripts | `00_Schema\001_create_tables\006_create_table_content_sources.sql` |  | 2026-03-06 11:03:18 |
| NEW | scripts | `00_Schema\001_create_tables\007_create_table_articles.sql` |  | 2026-03-06 11:03:27 |
| NEW | scripts | `00_Schema\001_create_tables\008_create_table_article_team_map.sql` |  | 2026-03-06 11:03:25 |
| NEW | scripts | `00_Schema\001_create_tables\009_create_table_article_league_map.sql` |  | 2026-03-06 11:03:23 |
| NEW | scripts | `00_Schema\001_create_tables\010_create_table_article_match_map.sql` |  | 2026-03-06 11:03:22 |
| NEW | scripts | `00_Schema\001_create_tables\011_check_new_core_tables.sql` |  | 2026-03-06 11:16:29 |
| NEW | scripts | `00_Schema\001_create_tables\012_create_table_languages.sql` |  | 2026-03-06 11:22:08 |
| NEW | scripts | `00_Schema\001_create_tables\013_create_table_article_translations.sql` |  | 2026-03-06 11:24:25 |
| NEW | scripts | `00_Schema\001_create_tables\014_create_table_league_translations.sql` |  | 2026-03-06 11:24:22 |
| NEW | scripts | `00_Schema\001_create_tables\015_create_table_team_translations.sql` |  | 2026-03-06 11:32:52 |
| NEW | scripts | `00_Schema\001_create_tables\016_create_table_player_translations.sql` |  | 2026-03-06 11:34:23 |
| NEW | scripts | `00_Schema\001_create_tables\017_create_table_translation_jobs.sql` |  | 2026-03-06 11:36:46 |
| NEW | scripts | `00_Schema\001_create_tables\018_create_table_translation_job_logs.sql` |  | 2026-03-06 11:38:12 |
| NEW | scripts | `00_Schema\001_create_tables\019_create_table_team_social_links.sql` |  | 2026-03-06 11:41:57 |
| NEW | scripts | `00_Schema\001_create_tables\020_create_table_stadiums.sql` |  | 2026-03-06 11:50:22 |
| NEW | scripts | `00_Schema\001_create_tables\021_create_table_team_stadiums.sql` |  | 2026-03-06 11:51:21 |
| NEW | scripts | `00_Schema\001_create_tables\022_create_table_match_events.sql` |  | 2026-03-06 11:53:19 |
| NEW | scripts | `00_Schema\001_create_tables\023_create_table_player_match_statistics.sql` |  | 2026-03-06 11:58:28 |
| NEW | scripts | `00_Schema\001_create_tables\024_create_table_team_match_statistics.sql` |  | 2026-03-06 12:03:42 |
| NEW | scripts | `00_Schema\001_create_tables\025_create_table_coaches.sql` |  | 2026-03-06 11:59:54 |
| NEW | scripts | `00_Schema\001_create_tables\026_create_table_team_coaches.sql` |  | 2026-03-06 12:07:54 |
| NEW | scripts | `00_Schema\001_create_tables\027_create_table_player_team_history.sql` |  | 2026-03-06 12:08:39 |
| NEW | scripts | `00_Schema\001_create_tables\028_create_table_match_officials.sq` |  | 2026-03-06 12:09:22 |
| NEW | scripts | `00_Schema\001_create_tables\029_create_table_team_transfers.sql` |  | 2026-03-06 12:10:19 |
| NEW | scripts | `00_Schema\001_create_tables\030_create_table_player_social_links.sql` |  | 2026-03-06 12:11:12 |
| NEW | scripts | `00_Schema\001_create_tables\031_create_table_competition_rounds.sql` |  | 2026-03-06 12:12:03 |
| NEW | scripts | `00_Schema\001_create_tables\032_create_table_match_weather.sql` |  | 2026-03-06 12:12:39 |
| NEW | scripts | `00_Schema\001_create_tables\033_create_table_users.sql` |  | 2026-03-06 12:15:12 |
| NEW | scripts | `00_Schema\001_create_tables\034_create_table_user_favorite_teams.sql` |  | 2026-03-06 12:15:57 |
| NEW | scripts | `00_Schema\001_create_tables\035_create_table_user_favorite_leagues.sql` |  | 2026-03-06 12:16:51 |
| NEW | scripts | `00_Schema\001_create_tables\036_create_table_user_favorite_players.sql` |  | 2026-03-06 12:16:49 |
| NEW | scripts | `00_Schema\001_create_tables\037_create_table_subscription_plans.sql` |  | 2026-03-06 12:18:22 |
| NEW | scripts | `00_Schema\001_create_tables\038_create_table_subscriptions.sql` |  | 2026-03-06 12:20:20 |
| NEW | scripts | `00_Schema\001_create_tables\039_create_table_user_notifications.sql` |  | 2026-03-06 12:21:22 |
| NEW | scripts | `00_Schema\001_create_tables\040_create_table_notification_queue.sql` |  | 2026-03-06 12:22:42 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\041_create_table_tickets.sql` |  | 2026-03-07 23:17:06 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\042_create_table_ticket_constants.sql` |  | 2026-03-07 23:17:05 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\043_create_table_ticket_blocks.sql` |  | 2026-03-07 23:17:03 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\044_create_table_ticket_block_matches.sql` |  | 2026-03-07 23:17:01 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\045_create_table_ticket_variants.sql` |  | 2026-03-07 23:16:59 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\046_create_table_ticket_variant_block_choices.sql` |  | 2026-03-07 23:16:57 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\047_create_table_ticket_variant_matches.sql` |  | 2026-03-07 23:24:04 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\048_create_table_ticket_settlements.sql` |  | 2026-03-07 23:24:02 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\049_create_table_ticket_pattern_stats.sql` |  | 2026-03-07 23:25:58 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\050_create_table_ticket_league_pattern_stats.sql` |  | 2026-03-07 23:26:44 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\051_create_table_ticket_generation_runs.sql` |  | 2026-03-07 23:27:43 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\052_create_table_ticket_variant_features.sql` |  | 2026-03-07 23:28:34 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\053_create_table_ticket_recommendation_feedback.sql` |  | 2026-03-07 23:28:32 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\054_create_mm_value_bets.sql` |  | 2026-03-08 17:04:39 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\055_create_view_best_match_odds.sql` |  | 2026-03-08 17:04:35 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\056_alter_mm_value_bets_add_unique_match.sql` |  | 2026-03-08 17:17:09 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\057_view_ticket_candidate_matches.sql` |  | 2026-03-08 17:27:21 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\058_view_match_feed_for_user.sql` |  | 2026-03-08 17:35:18 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\059_create_ops_provider_jobs.sql` |  | 2026-03-08 17:53:25 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\061_create_ops_provider_accounts.sql` |  | 2026-03-08 19:29:20 |
| NEW | scripts | `00_Schema\001_create_tables_tickets\063_create_ops_api_request_log.sql` |  | 2026-03-08 19:33:02 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\010_indexes_performance.sql` |  | 2026-02-11 13:54:31 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\011_generated_tickets_is_blocked.sql` |  | 2026-02-12 14:48:58 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\012_generated_runs_params.sql` |  | 2026-02-11 20:48:17 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\013_fill_theodds_keys_missing.sql` |  | 2026-02-19 20:58:05 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\013_generated_ticket_items.sql` |  | 2026-02-11 21:56:03 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\014_generated_ticket_risk.sql` |  | 2026-02-12 20:04:44 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\015_mm_apply_risk_team_max.sql` |  | 2026-02-12 20:01:05 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\016_matches_external_ids_and_result.sql` |  | 2026-02-12 21:23:47 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\017_leagues_external_ids.sql` |  | 2026-02-12 21:25:06 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\018_teams_external_ids.sql` |  | 2026-02-12 21:27:25 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\019_odds_indexes_for_compare.sql` |  | 2026-02-12 21:29:25 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\01_create_mm_ticket_scenarios.sql` |  | 2026-03-09 22:03:19 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\02_create_mm_ticket_scenario_variants.sql` |  | 2026-03-09 22:08:02 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\03_create_mm_ticket_scenario_blocks.sql` |  | 2026-03-09 22:08:00 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\04_create_mm_ticket_scenario_block_matches.sql` |  | 2026-03-09 22:07:53 |
| NEW | scripts | `00_Schema\010_generated_tickets_is_blocked.sql\05_drop_unused_mm_ticket_tables.sql` |  | 2026-03-09 22:32:44 |
| NEW | scripts | `00_Schema\010_staging_api_football.sql\038_alter_stg_provider_player_stats_for_match_merge.sql` |  | 2026-03-15 21:11:28 |
| NEW | scripts | `00_Schema\010_staging_api_football.sql\039_create_player_season_statistics.sql` |  | 2026-03-15 22:19:04 |
| NEW | scripts | `00_Schema\010_staging_api_football.sql\10_staging_api_football.sql` |  | 2026-02-23 15:37:23 |
| NEW | scripts | `00_Schema\010_staging_api_hockey.sql\010_create_api_hockey_teams_raw.sql (volitelné)` |  | 2026-03-01 14:42:27 |
| NEW | scripts | `00_Schema\020_generated_runs_add_bookmaker_id.sql\020_generated_runs_add_bookmaker_id.sql` |  | 2026-02-12 21:42:35 |
| NEW | scripts | `00_Schema\020_generated_runs_add_bookmaker_id.sql\023_matches_updated_at.sql` |  | 2026-02-15 13:46:55 |
| NEW | scripts | `00_Schema\020_generated_runs_add_bookmaker_id.sql\024_matches_normalize_status.sql` |  | 2026-02-15 13:54:35 |
| NEW | scripts | `00_Schema\020_generated_runs_add_bookmaker_id.sql\027_matches_score_status_rules.sql` |  | 2026-02-15 13:55:11 |
| NEW | scripts | `00_Schema\020_generated_runs_add_bookmaker_id.sql\029_leagues_set_csv_codes.sql` |  | 2026-02-15 14:31:16 |
| NEW | scripts | `00_Schema\020_provider_maps.sql\020_provider_maps.sql` |  | 2026-02-23 16:08:23 |
| NEW | scripts | `00_Schema\020_provider_maps.sql\021_migrate_leagues_to_provider_map.sql` |  | 2026-02-23 17:32:05 |
| NEW | scripts | `00_Schema\020_provider_maps.sql\037_players_multisource_foundation.sql` |  | 2026-03-15 12:50:45 |
| NEW | scripts | `00_Schema\020_provider_maps.sql\038_players_enrichment_reseed_squads_team_based.sql` |  | 2026-03-15 14:08:07 |
| NEW | scripts | `00_Schema\030_ingest_schema.sql\030_ingest_schema.sql` |  | 2026-02-12 22:32:08 |
| NEW | scripts | `00_Schema\030_ingest_schema.sql\031_external_ids.sql` |  | 2026-02-12 22:33:32 |
| NEW | scripts | `00_Schema\030_ingest_schema.sql\032_bookmakers_ext_key.sql` |  | 2026-02-12 22:36:44 |
| NEW | scripts | `00_Schema\030_ingest_schema.sql\033_team_aliases.sql` |  | 2026-02-15 14:56:59 |
| NEW | scripts | `00_Schema\030_ingest_schema.sql\034_team_aliases_seed_football_data_uk_epl.sql` |  | 2026-02-15 15:07:31 |
| NEW | scripts | `00_Schema\030_ingest_schema.sql\035_ops_create_ingest_planner.sql` |  | 2026-03-13 15:25:23 |
| NEW | scripts | `00_Schema\030_ingest_schema.sql\036_ops_create_worker_locks.sql` |  | 2026-03-13 15:38:16 |
| NEW | scripts | `00_Schema\030_ingest_schema.sql\037_ops_insert_job_ingest_cycle_v2.sql` |  | 2026-03-13 20:36:39 |
| NEW | scripts | `00_Schema\030_ingest_schema.sql\038_ops_create_dashboard_views.sql` |  | 2026-03-13 20:36:43 |
| NEW | scripts | `00_Schema\030_ingest_schema.sql\039_ops_insert_job_unified_staging_to_public_merge.sql` |  | 2026-03-13 21:05:12 |
| NEW | scripts | `00_Schema\040_match_features\040_match_features.sql` |  | 2026-02-15 13:46:57 |
| NEW | scripts | `00_Schema\050_ml_dataset_view.sql\050_ml_dataset_view.sql` |  | 2026-02-16 22:12:34 |
| NEW | scripts | `00_Schema\050_ml_dataset_view.sql\051_ml_dataset_view_V2.sql` |  | 2026-02-18 10:16:29 |
| NEW | scripts | `00_Schema\050_ml_dataset_view.sql\052_ml_predictions.sql` |  | 2026-02-16 16:00:55 |
| NEW | scripts | `00_Schema\050_ml_dataset_view.sql\053_ml_predict_dataset_view.sql` |  | 2026-02-16 16:00:54 |
| NEW | scripts | `00_Schema\050_ml_dataset_view.sql\054_ml_fair_odds_view.sql` |  | 2026-02-16 16:28:43 |
| NEW | scripts | `00_Schema\050_ml_dataset_view.sql\055_ml_market_odds_view.sql` |  | 2026-02-16 16:56:06 |
| NEW | scripts | `00_Schema\050_ml_dataset_view.sql\056_ml_value_view.sql` |  | 2026-02-16 17:09:35 |
| NEW | scripts | `00_Schema\050_ml_dataset_view.sql\057_ml_value_ev_view.sql` |  | 2026-02-16 17:09:32 |
| NEW | scripts | `00_Schema\050_ml_dataset_view.sql\058_ml_block_candidates_view.sql` |  | 2026-02-16 21:27:15 |
| NEW | scripts | `00_Schema\050_ml_dataset_view.sql\059_ml_feed_value_picks_view.sql` |  | 2026-02-16 21:30:23 |
| NEW | scripts | `00_Schema\060_mmr_ratings.sql\060_mmr_ratings.sql` |  | 2026-02-16 22:13:35 |
| NEW | scripts | `00_Schema\070_ml_predictions.sql\070_ml_predictions.sql` |  | 2026-02-19 10:48:28 |
| NEW | scripts | `00_Schema\210_create_staging_api_hockey.sql` |  | 2026-02-28 20:43:25 |
| NEW | scripts | `01_seed\001_seed_languages_asia.sql` |  | 2026-03-06 14:20:54 |
| NEW | scripts | `01_seed\002_seed_Global_language .sql` |  | 2026-03-06 14:25:26 |
| NEW | scripts | `01_seed\003_seed_data_providers.sql` |  | 2026-03-06 14:29:25 |
| NEW | scripts | `01_seed\004_seed_countries.sql` |  | 2026-03-06 14:43:55 |
| NEW | scripts | `01_seed\005_seed_seasons_from_leagues_smart.sql` |  | 2026-03-06 15:13:11 |
| NEW | scripts | `01_seed\011_seed_jobs_core_pipeline.sql` |  | 2026-02-26 22:41:55 |
| NEW | scripts | `01_seed\012_seed_ingest_targets_top8_api_football.sql` |  | 2026-02-27 22:39:44 |
| NEW | scripts | `01_seed\013_seed_import_plan_eu_exact_v1.sql` |  | 2026-02-27 21:55:07 |
| NEW | scripts | `01_seed\014_apply_import_plan_eu_api_football.sql` |  | 2026-02-27 22:38:25 |
| NEW | scripts | `01_seed\015_seed_import_plan_eu_major_v4.sql` |  | 2026-02-27 22:51:15 |
| NEW | scripts | `01_seed\059_seed_ops_provider_jobs_multi_sport.sql` |  | 2026-03-08 17:54:29 |
| NEW | scripts | `01_seed\061_seed_ops_provider_accounts.sql` |  | 2026-03-08 19:29:18 |
| NEW | scripts | `01_seed\062_trigger_ops_provider_accounts_updated_at.sql` |  | 2026-03-08 19:31:48 |
| NEW | scripts | `01_seed\093_seed_sports_import_plan.sql` |  | 2026-03-10 13:28:13 |
| NEW | scripts | `01_seed\094_api_budget_status.sql` |  | 2026-03-10 13:31:57 |
| NEW | scripts | `01_seed\095_v_api_budget_today.sql` |  | 2026-03-10 13:30:05 |
| NEW | scripts | `01_seed\096_seed_ingest_targets_from_league_import_plan.sql` |  | 2026-03-10 17:49:24 |
| NEW | scripts | `01_seed\100_seed_ingest_targets_from_leagues.sql` |  | 2026-03-10 19:12:47 |
| NEW | scripts | `01_seed\101_prioritize_ingest_targets.sql` |  | 2026-03-10 19:59:17 |
| NEW | scripts | `01_seed\102_scheduler_queue.sql` |  | 2026-03-10 20:11:37 |
| NEW | scripts | `01_seed\104_set_free_mode_budget.sql` |  | 2026-03-10 20:34:06 |
| NEW | scripts | `01_seed\105_prepare_free_test_targets.sql` |  | 2026-03-10 20:36:20 |
| NEW | scripts | `01_seed\106_reduce_football_for_free_mode.sql` |  | 2026-03-10 20:49:14 |
| NEW | scripts | `01_seed\107_mark_football_maintenance_targets.sql` |  | 2026-03-10 20:50:45 |
| NEW | scripts | `01_seed\108_reset_today_scheduler_queue.sql` |  | 2026-03-10 20:51:42 |
| NEW | scripts | `01_seed\109_enable_hockey_basketball_free_targets.sql` |  | 2026-03-10 20:58:59 |
| NEW | scripts | `01_seed\api_football\00_seed_api_football_leagues.sql` |  | 2026-02-23 12:13:50 |
| NEW | scripts | `01_seed\api_football\01_audit_api_football_import.sql` |  | 2026-02-23 15:27:33 |
| NEW | scripts | `02_validation\020_hockey\021_parse_api_hockey_leagues.sql` |  | 2026-02-28 23:49:18 |
| NEW | scripts | `02_validation\020_hockey\021_parse_api_hockey_leagues_raw.sql` |  | 2026-03-01 23:22:34 |
| NEW | scripts | `02_validation\020_hockey\022_parse_api_hockey_teams_raw.sql` |  | 2026-03-01 23:22:34 |
| NEW | scripts | `02_validation\020_hockey\022_parse_api_hockey_teams_raw_V1.sql` |  | 2026-03-01 21:53:43 |
| NEW | scripts | `02_validation\020_hockey\022_view_api_hockey_leagues_latest.sql` |  | 2026-03-01 19:20:57 |
| NEW | scripts | `02_validation\021_check_missing_ingest_targets.sql` |  | 2026-02-27 14:34:34 |
| NEW | scripts | `02_validation\022_check_predict_ml_predictions.sql` |  | 2026-02-19 10:46:55 |
| NEW | scripts | `02_validation\024_show_ml_view_definitions.sql` |  | 2026-02-19 10:55:49 |
| NEW | scripts | `02_validation\025_check_value_ev_latest.sql` |  | 2026-02-19 10:57:18 |
| NEW | scripts | `02_validation\026_check_block_candidates_latest.sql` |  | 2026-02-19 11:04:02 |
| NEW | scripts | `02_validation\check_empty_blocks.sql\010_trg_template_blocks_guard.sql` |  | 2026-02-11 12:06:53 |
| NEW | scripts | `02_validation\check_empty_blocks.sql\011_trg_template_block_matches_not_empty.sql` |  | 2026-02-11 12:08:36 |
| NEW | scripts | `02_validation\check_template_validity.sql\001_mm_validate_template.sql` |  | 2026-02-11 09:11:59 |
| NEW | scripts | `03_generation\002_mm_update_run_probability.sql\002_mm_update_run_probability.sql` |  | 2026-02-11 08:52:19 |
| NEW | scripts | `03_generation\002_mm_update_run_probability.sql\005_mm_template_state.sql` |  | 2026-02-11 14:27:11 |
| NEW | scripts | `03_generation\002_mm_update_run_probability.sql\006_mm_actions_blocks.sql` |  | 2026-02-11 15:28:03 |
| NEW | scripts | `03_generation\002_mm_update_run_probability.sql\007_mm_actions_fixed.sql` |  | 2026-02-11 15:20:52 |
| NEW | scripts | `03_generation\002_mm_update_run_probability.sql\008_mm_ui_preview_and_generate.sql` |  | 2026-02-11 15:20:28 |
| NEW | scripts | `03_generation\011_mm_preview_run.sql\011_mm_preview_run.sql` |  | 2026-02-12 13:47:08 |
| NEW | scripts | `03_generation\011_mm_preview_run.sql\012_mm_generate_run_engine.sql` |  | 2026-02-12 20:11:46 |
| NEW | scripts | `03_generation\011_mm_preview_run.sql\013_mm_generate_tickets_engine.sql` |  | 2026-02-12 10:58:40 |
| NEW | scripts | `03_generation\011_mm_preview_run.sql\014_mm_get_odds_compare.sql` |  | 2026-02-12 21:30:47 |
| NEW | scripts | `03_generation\011_mm_preview_run.sql\015_mm_preview_run_bookmaker.sql` |  | 2026-02-12 21:37:29 |
| NEW | scripts | `03_generation\011_mm_preview_run.sql\016_mm_ui_ticket_detail.sql` |  | 2026-02-11 22:00:12 |
| NEW | scripts | `03_generation\011_mm_preview_run.sql\017_mm_generate_run_engine_bookmaker.sql` |  | 2026-02-12 21:44:20 |
| NEW | scripts | `03_generation\011_mm_preview_run.sql\018_mm_ui_run_tickets.sql` |  | 2026-02-12 22:03:05 |
| NEW | scripts | `03_generation\011_mm_preview_run.sql\019_mm_ui_run_summary.sql` |  | 2026-02-12 22:10:36 |
| NEW | scripts | `03_generation\011_mm_preview_run.sql\mazání mm_generate_run_engine.sql` |  | 2026-02-12 14:17:22 |
| NEW | scripts | `03_generation\011_mm_preview_run.sql\mm_generate_run_engine.sql` |  | 2026-02-12 14:43:26 |
| NEW | scripts | `03_generation\011_mm_preview_run.sql\mm_preview_run.sql` |  | 2026-02-12 11:56:38 |
| NEW | scripts | `03_generation\020_mm_ui_run_tickets_with_stake.sql\020_mm_ui_run_tickets_with_stake.sql` |  | 2026-02-12 22:18:49 |
| NEW | scripts | `03_generation\020_mm_ui_run_tickets_with_stake.sql\021_matches_add_sport_id.sql` |  | 2026-02-15 13:38:52 |
| NEW | scripts | `03_generation\020_mm_ui_run_tickets_with_stake.sql\022_matches_indexes_for_history_and_features.sql` |  | 2026-02-15 13:39:49 |
| NEW | scripts | `03_generation\020_mm_ui_run_tickets_with_stake.sql\023_mm_build_match_features.sql` |  | 2026-02-15 13:54:37 |
| NEW | scripts | `03_generation\030_upsert_api_football.sql\030_ops_admin.sql` |  | 2026-02-23 23:11:04 |
| NEW | scripts | `03_generation\030_upsert_api_football.sql\031_eu_leagues_api_football_apply_FIXED2.sql` |  | 2026-03-02 22:02:18 |
| NEW | scripts | `03_generation\030_upsert_api_football.sql\031_upsert_leagues_api_football.sql` |  | 2026-03-04 09:28:33 |
| NEW | scripts | `03_generation\030_upsert_api_football.sql\032_upsert_teams_api_football.sql` |  | 2026-03-04 09:29:04 |
| NEW | scripts | `03_generation\030_upsert_api_football.sql\033_upsert_league_teams_api_football.sql` |  | 2026-03-04 09:29:33 |
| NEW | scripts | `03_generation\030_upsert_api_football.sql\034_upsert_matches_api_football.sql` |  | 2026-03-04 09:30:58 |
| NEW | scripts | `03_generation\030_upsert_api_football.sql\035_generate_ingest_targets_football_api_football.sql` |  | 2026-02-27 14:34:42 |
| NEW | scripts | `03_generation\030_upsert_api_football.sql\035_merge_teams_api_football.sql` |  | 2026-02-25 21:11:38 |
| NEW | scripts | `03_generation\030_upsert_api_football.sql\036_create_staging_league_views.sql` |  | 2026-02-27 13:09:47 |
| NEW | scripts | `03_generation\030_upsert_api_football.sql\037_cleanup_staging_api_football_leagues.sql` |  | 2026-02-27 14:34:50 |
| NEW | scripts | `03_generation\030_upsert_api_football.sql\038_create_ops_league_import_plan.sql` |  | 2026-02-27 14:34:53 |
| NEW | scripts | `03_generation\030_upsert_api_football.sql\039_import_leagues_from_plan_api_football.sql` |  | 2026-02-27 13:35:34 |
| NEW | scripts | `03_generation\031_upsert_api_hockey.sql\031_upsert_leagues_api_hockey.sql` |  | 2026-03-01 14:35:04 |
| NEW | scripts | `03_generation\031_upsert_api_hockey.sql\033_upsert_league_teams_api_hockey.sql` |  | 2026-03-01 23:22:35 |
| NEW | scripts | `03_generation\036_upsert_league_provider_map.sql` |  | 2026-03-01 14:33:26 |
| NEW | scripts | `03_generation\038_update_ops_ingest_targets.sql` |  | 2026-03-02 08:19:54 |
| NEW | scripts | `03_generation\040_staging\006_create_table_staging_players_import.sql` |  | 2026-03-06 14:49:13 |
| NEW | scripts | `03_generation\040_staging\007_create_table_staging_player_provider_map_import.sql` |  | 2026-03-06 15:22:29 |

_V reportu je zobrazeno prvních 300 změn z celkových 462._

## 2. GIT / GITHUB AUDIT

- Branch: `main`
- Last commit hash: `0e00769cf33422fc0bf706b3054d2bbf4dbb9406`
- Last commit date: 2026-03-11 20:22:35
- Last commit message: Initial MatchMatrix setup (Docker + ingest + reports)
- Git status summary: `## main...origin/main [ahead 7]`
- Modified files: 36
- Untracked files: 97
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
?? "ops_admin/README_CZ (1).txt"
?? ops_admin/README_CZ.md
?? ops_admin/README_CZ.txt
?? ops_admin/matchmatrix_file_audit.py
?? ops_admin/panel_audit_matchmatrix_v1.py
?? ops_admin/panel_matchmatrix_audit_v2.py
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
