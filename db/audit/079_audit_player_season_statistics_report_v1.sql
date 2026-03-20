-- ============================================================
-- MatchMatrix
-- 079_audit_player_season_statistics_report_v1.sql
--
-- Účel:
-- textový audit public.player_season_statistics pro spuštění přes psql
-- vhodné pro export do .txt reportu
-- ============================================================

SET client_encoding = 'UTF8';

\pset pager off
\pset border 1
\pset linestyle ASCII
\pset null '(null)'

\echo
\echo ============================================================
\echo MATCHMATRIX - PLAYER SEASON STATISTICS AUDIT REPORT
\echo ============================================================
\echo

\echo ------------------------------------------------------------
\echo 1) ZAKLADNI POCETY
\echo ------------------------------------------------------------
SELECT 'public.player_season_statistics' AS metric, COUNT(*)::bigint AS value
FROM public.player_season_statistics
UNION ALL
SELECT 'distinct players', COUNT(DISTINCT player_id)::bigint
FROM public.player_season_statistics
UNION ALL
SELECT 'distinct teams', COUNT(DISTINCT team_id)::bigint
FROM public.player_season_statistics
UNION ALL
SELECT 'distinct leagues', COUNT(DISTINCT league_id)::bigint
FROM public.player_season_statistics
UNION ALL
SELECT 'distinct seasons', COUNT(DISTINCT season)::bigint
FROM public.player_season_statistics
ORDER BY metric;

\echo
\echo ------------------------------------------------------------
\echo 2) ROZPAD PODLE SEZONY
\echo ------------------------------------------------------------
SELECT
    season,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT player_id) AS players_count,
    COUNT(DISTINCT team_id) AS teams_count,
    COUNT(DISTINCT league_id) AS leagues_count
FROM public.player_season_statistics
GROUP BY season
ORDER BY season DESC;

\echo
\echo ------------------------------------------------------------
\echo 3) ROZPAD PODLE LIGY
\echo ------------------------------------------------------------
SELECT
    l.id AS league_id,
    l.name AS league_name,
    pss.season,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT pss.player_id) AS players_count
FROM public.player_season_statistics pss
LEFT JOIN public.leagues l
    ON l.id = pss.league_id
GROUP BY l.id, l.name, pss.season
ORDER BY rows_count DESC, league_name, pss.season DESC;

\echo
\echo ------------------------------------------------------------
\echo 4) ROZPAD PODLE TYMU
\echo ------------------------------------------------------------
SELECT
    t.id AS team_id,
    t.name AS team_name,
    pss.season,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT pss.player_id) AS players_count
FROM public.player_season_statistics pss
LEFT JOIN public.teams t
    ON t.id = pss.team_id
GROUP BY t.id, t.name, pss.season
ORDER BY rows_count DESC, team_name, pss.season DESC;

\echo
\echo ------------------------------------------------------------
\echo 5) HRACI S NEJVICE MINUTAMI
\echo ------------------------------------------------------------
SELECT
    p.id AS player_id,
    p.name AS player_name,
    t.name AS team_name,
    l.name AS league_name,
    pss.season,
    pss.minutes_played,
    pss.appearances,
    pss.lineups,
    pss.rating
FROM public.player_season_statistics pss
LEFT JOIN public.players p
    ON p.id = pss.player_id
LEFT JOIN public.teams t
    ON t.id = pss.team_id
LEFT JOIN public.leagues l
    ON l.id = pss.league_id
ORDER BY COALESCE(pss.minutes_played, 0) DESC,
         COALESCE(pss.appearances, 0) DESC,
         p.name
LIMIT 25;

\echo
\echo ------------------------------------------------------------
\echo 6) NEJLEPSI STRELCI
\echo ------------------------------------------------------------
SELECT
    p.id AS player_id,
    p.name AS player_name,
    t.name AS team_name,
    l.name AS league_name,
    pss.season,
    pss.goals,
    pss.assists,
    pss.shots_total,
    pss.shots_on_target,
    pss.minutes_played
FROM public.player_season_statistics pss
LEFT JOIN public.players p
    ON p.id = pss.player_id
LEFT JOIN public.teams t
    ON t.id = pss.team_id
LEFT JOIN public.leagues l
    ON l.id = pss.league_id
ORDER BY COALESCE(pss.goals, 0) DESC,
         COALESCE(pss.assists, 0) DESC,
         COALESCE(pss.minutes_played, 0) DESC,
         p.name
LIMIT 25;

\echo
\echo ------------------------------------------------------------
\echo 7) NEJVICE ASISTENCI
\echo ------------------------------------------------------------
SELECT
    p.id AS player_id,
    p.name AS player_name,
    t.name AS team_name,
    l.name AS league_name,
    pss.season,
    pss.assists,
    pss.goals,
    pss.passes_key,
    pss.passes_total,
    pss.passes_accuracy
FROM public.player_season_statistics pss
LEFT JOIN public.players p
    ON p.id = pss.player_id
LEFT JOIN public.teams t
    ON t.id = pss.team_id
LEFT JOIN public.leagues l
    ON l.id = pss.league_id
ORDER BY COALESCE(pss.assists, 0) DESC,
         COALESCE(pss.passes_key, 0) DESC,
         p.name
LIMIT 25;

\echo
\echo ------------------------------------------------------------
\echo 8) NEJLEPSI RATING
\echo ------------------------------------------------------------
SELECT
    p.id AS player_id,
    p.name AS player_name,
    t.name AS team_name,
    l.name AS league_name,
    pss.season,
    pss.rating,
    pss.minutes_played,
    pss.appearances,
    pss.goals,
    pss.assists
FROM public.player_season_statistics pss
LEFT JOIN public.players p
    ON p.id = pss.player_id
LEFT JOIN public.teams t
    ON t.id = pss.team_id
LEFT JOIN public.leagues l
    ON l.id = pss.league_id
WHERE COALESCE(pss.minutes_played, 0) >= 300
  AND pss.rating IS NOT NULL
ORDER BY pss.rating DESC,
         COALESCE(pss.minutes_played, 0) DESC,
         p.name
LIMIT 25;

\echo
\echo ------------------------------------------------------------
\echo 9) DEFENZIVNI CONTRIBUTION
\echo ------------------------------------------------------------
SELECT
    p.id AS player_id,
    p.name AS player_name,
    t.name AS team_name,
    l.name AS league_name,
    pss.season,
    COALESCE(pss.tackles_total, 0) AS tackles_total,
    COALESCE(pss.tackles_interceptions, 0) AS interceptions,
    COALESCE(pss.tackles_blocks, 0) AS blocks,
    COALESCE(pss.duels_won, 0) AS duels_won,
    COALESCE(pss.fouls_committed, 0) AS fouls_committed,
    COALESCE(pss.yellow_cards, 0) AS yellow_cards,
    COALESCE(pss.red_cards, 0) AS red_cards
FROM public.player_season_statistics pss
LEFT JOIN public.players p
    ON p.id = pss.player_id
LEFT JOIN public.teams t
    ON t.id = pss.team_id
LEFT JOIN public.leagues l
    ON l.id = pss.league_id
ORDER BY
    (COALESCE(pss.tackles_total, 0)
   + COALESCE(pss.tackles_interceptions, 0)
   + COALESCE(pss.tackles_blocks, 0)
   + COALESCE(pss.duels_won, 0)) DESC,
    p.name
LIMIT 25;

\echo
\echo ------------------------------------------------------------
\echo 10) DISCIPLINARNI AUDIT
\echo ------------------------------------------------------------
SELECT
    p.id AS player_id,
    p.name AS player_name,
    t.name AS team_name,
    l.name AS league_name,
    pss.season,
    COALESCE(pss.yellow_cards, 0) AS yellow_cards,
    COALESCE(pss.red_cards, 0) AS red_cards,
    COALESCE(pss.fouls_committed, 0) AS fouls_committed,
    COALESCE(pss.fouls_drawn, 0) AS fouls_drawn
FROM public.player_season_statistics pss
LEFT JOIN public.players p
    ON p.id = pss.player_id
LEFT JOIN public.teams t
    ON t.id = pss.team_id
LEFT JOIN public.leagues l
    ON l.id = pss.league_id
ORDER BY COALESCE(pss.red_cards, 0) DESC,
         COALESCE(pss.yellow_cards, 0) DESC,
         COALESCE(pss.fouls_committed, 0) DESC,
         p.name
LIMIT 25;

\echo
\echo ------------------------------------------------------------
\echo 11) NULL / COVERAGE
\echo ------------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE appearances IS NOT NULL) AS appearances_filled,
    COUNT(*) FILTER (WHERE minutes_played IS NOT NULL) AS minutes_filled,
    COUNT(*) FILTER (WHERE rating IS NOT NULL) AS rating_filled,
    COUNT(*) FILTER (WHERE goals IS NOT NULL) AS goals_filled,
    COUNT(*) FILTER (WHERE assists IS NOT NULL) AS assists_filled,
    COUNT(*) FILTER (WHERE shots_total IS NOT NULL) AS shots_total_filled,
    COUNT(*) FILTER (WHERE passes_total IS NOT NULL) AS passes_total_filled,
    COUNT(*) FILTER (WHERE tackles_total IS NOT NULL) AS tackles_total_filled
FROM public.player_season_statistics;

\echo
\echo ------------------------------------------------------------
\echo 12) DUPLICITY PODLE BUSINESS KLICE
\echo ------------------------------------------------------------
SELECT
    player_id,
    league_id,
    season,
    COUNT(*) AS dup_count
FROM public.player_season_statistics
GROUP BY player_id, league_id, season
HAVING COUNT(*) > 1
ORDER BY dup_count DESC, player_id, league_id, season;

\echo
\echo ------------------------------------------------------------
\echo 13) RYCHLY DETAIL NAHLEDU
\echo ------------------------------------------------------------
SELECT
    pss.id,
    p.name AS player_name,
    t.name AS team_name,
    l.name AS league_name,
    pss.season,
    pss.appearances,
    pss.lineups,
    pss.minutes_played,
    pss.rating,
    pss.goals,
    pss.assists,
    pss.shots_total,
    pss.shots_on_target,
    pss.passes_total,
    pss.passes_key,
    pss.tackles_total,
    pss.yellow_cards,
    pss.red_cards
FROM public.player_season_statistics pss
LEFT JOIN public.players p
    ON p.id = pss.player_id
LEFT JOIN public.teams t
    ON t.id = pss.team_id
LEFT JOIN public.leagues l
    ON l.id = pss.league_id
ORDER BY pss.id DESC
LIMIT 50;

\echo
\echo ============================================================
\echo KONEC REPORTU
\echo ============================================================
\echo