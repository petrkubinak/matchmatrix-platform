-- 090_api_football_merge_run.sql
-- Expect psql variable: run_id
-- Example: psql ... -v run_id=123 -f 090_api_football_merge_run.sql

\echo ==== MATCHMATRIX API-FOOTBALL MERGE, run_id = :'run_id' ====

\echo [0/4] (optional) Upsert LEAGUES (api_football -> public.leagues)
\i C:/MatchMatrix-platform/Scripts/03_generation/031_upsert_leagues_api_football.sql

\echo [1/4] Upsert TEAMS (api_football -> public.teams)
\i C:/MatchMatrix-platform/Scripts/03_generation/032_upsert_teams_api_football.sql

\echo [2/4] Upsert LEAGUE_TEAMS (api_football -> public.league_teams)
\i C:/MatchMatrix-platform/Scripts/03_generation/033_upsert_league_teams_api_football.sql

\echo [3/4] Upsert MATCHES (api_football fixtures -> public.matches)
\i C:/MatchMatrix-platform/Scripts/03_generation/034_upsert_matches_api_football.sql

\echo [4/4] (optional) Upsert ODDS
-- \i C:/MatchMatrix-platform/Scripts/03_generation/035_upsert_odds_api_football.sql

\echo ==== DONE ====