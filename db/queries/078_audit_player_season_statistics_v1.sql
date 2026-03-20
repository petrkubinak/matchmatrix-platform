-- ============================================================
-- MatchMatrix
-- audit_player_season_statistics_v1.sql
--
-- Účel:
-- rychlý audit naplnění public.player_season_statistics
-- ============================================================

-- ------------------------------------------------------------
-- 1) Základní počty
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 2) Rozpad podle sezony
-- ------------------------------------------------------------
SELECT
    season,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT player_id) AS players_count,
    COUNT(DISTINCT team_id) AS teams_count,
    COUNT(DISTINCT league_id) AS leagues_count
FROM public.player_season_statistics
GROUP BY season
ORDER BY season DESC;

-- ------------------------------------------------------------
-- 3) Rozpad podle ligy
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 4) Rozpad podle týmu
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 5) Hráči s nejvíce minutami
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 6) Nejlepší střelci
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 7) Nejvíce asistencí
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 8) Nejlepší rating
-- filtrujeme jen hráče s rozumným objemem minut
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 9) Defenzivní contribution
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 10) Disciplinární audit
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 11) Kontrola NULL / coverage
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 12) Kontrola duplicit podle business klíče
-- mělo by vrátit 0 řádků
-- ------------------------------------------------------------
SELECT
    player_id,
    league_id,
    season,
    COUNT(*) AS dup_count
FROM public.player_season_statistics
GROUP BY player_id, league_id, season
HAVING COUNT(*) > 1
ORDER BY dup_count DESC, player_id, league_id, season;

-- ------------------------------------------------------------
-- 13) Rychlý detail náhledu
-- ------------------------------------------------------------
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