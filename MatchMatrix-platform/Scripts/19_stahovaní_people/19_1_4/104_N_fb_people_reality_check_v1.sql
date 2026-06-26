/*
================================================================================
MATCHMATRIX FB PEOPLE REALITY CHECK V1
================================================================================

Co skript dělá:
- kontroluje skutečný stav FB PEOPLE vrstvy

Kontroluje:
- public.players
- player_provider_map
- player_match_statistics
- player_season_statistics
- coaches
- coverage vůči finished matches

K čemu slouží:
- reality check PEOPLE vrstvy
- příprava pro:
    player form engine
    fantasy scoring
    AI layer
    player detail pages
================================================================================
*/

-- ============================================================================
-- 1. FB PLAYERS
-- ============================================================================

SELECT
    'FB_PLAYERS' AS section,
    ext_source,
    COUNT(*) AS players_count
FROM public.players
WHERE ext_source IN (
    'api_football',
    'football_data',
    'football_data_uk'
)
GROUP BY ext_source
ORDER BY players_count DESC;


-- ============================================================================
-- 2. PLAYER PROVIDER MAP
-- ============================================================================

SELECT
    'FB_PLAYER_PROVIDER_MAP' AS section,
    provider,
    COUNT(*) AS mapped_players
FROM public.player_provider_map
GROUP BY provider
ORDER BY mapped_players DESC;


-- ============================================================================
-- 3. PLAYER MATCH STATISTICS COVERAGE
-- ============================================================================

SELECT
    'FB_PLAYER_MATCH_STATS' AS section,
    COUNT(*) AS stats_rows,
    COUNT(DISTINCT match_id) AS covered_matches,
    COUNT(DISTINCT player_id) AS covered_players
FROM public.player_match_statistics;


-- ============================================================================
-- 4. FINISHED MATCHES WITHOUT PLAYER MATCH STATS
-- ============================================================================

SELECT
    'FB_FINISHED_MATCHES_WITHOUT_PLAYER_STATS' AS section,
    COUNT(*) AS missing_matches
FROM public.matches m
WHERE m.sport_id = 1
  AND m.status = 'FINISHED'
  AND NOT EXISTS (
      SELECT 1
      FROM public.player_match_statistics p
      WHERE p.match_id = m.id
  );


-- ============================================================================
-- 5. PLAYER SEASON STATISTICS
-- ============================================================================

SELECT
    'FB_PLAYER_SEASON_STATS' AS section,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT player_id) AS players_count,
    COUNT(DISTINCT league_id) AS leagues_count,
    COUNT(DISTINCT season) AS seasons_count
FROM public.player_season_statistics;


-- ============================================================================
-- 6. TOP PLAYERS BY SEASON STAT ROWS
-- ============================================================================

SELECT
    'FB_TOP_PLAYERS_BY_SEASON_STATS' AS section,
    p.name,
    COUNT(*) AS stat_rows
FROM public.player_season_statistics s
JOIN public.players p
    ON p.id = s.player_id
GROUP BY p.name
ORDER BY stat_rows DESC
LIMIT 30;


-- ============================================================================
-- 7. COACHES
-- ============================================================================

SELECT
    'FB_COACHES' AS section,
    ext_source,
    COUNT(*) AS coaches_count
FROM public.coaches
GROUP BY ext_source
ORDER BY coaches_count DESC;


-- ============================================================================
-- 8. PLAYER MATCH STATS QUALITY
-- ============================================================================

SELECT
    'FB_PLAYER_MATCH_STATS_QUALITY' AS section,

    COUNT(*) FILTER (
        WHERE rating IS NOT NULL
    ) AS rows_with_rating,

    COUNT(*) FILTER (
        WHERE goals > 0
    ) AS rows_with_goals,

    COUNT(*) FILTER (
        WHERE assists > 0
    ) AS rows_with_assists,

    COUNT(*) FILTER (
        WHERE passes_total > 0
    ) AS rows_with_passes,

    COUNT(*) FILTER (
        WHERE shots_total > 0
    ) AS rows_with_shots

FROM public.player_match_statistics;


-- ============================================================================
-- 9. PLAYER PHOTOS COVERAGE
-- ============================================================================

SELECT
    'FB_PLAYER_PHOTOS' AS section,

    COUNT(*) AS total_players,

    COUNT(*) FILTER (
        WHERE photo_url IS NOT NULL
    ) AS players_with_photo

FROM public.players
WHERE ext_source IN (
    'api_football',
    'football_data',
    'football_data_uk'
);


-- ============================================================================
-- 10. FINAL FB PEOPLE SUMMARY
-- ============================================================================

SELECT
    'FB_PEOPLE_SUMMARY' AS section,

    (
        SELECT COUNT(*)
        FROM public.players
        WHERE ext_source IN (
		    'api_football',
		    'football_data',
		    'football_data_uk'
		)
    ) AS players,

    (
        SELECT COUNT(*)
        FROM public.player_provider_map
    ) AS provider_maps,

    (
        SELECT COUNT(*)
        FROM public.player_match_statistics
    ) AS player_match_stats,

    (
        SELECT COUNT(*)
        FROM public.player_season_statistics
    ) AS player_season_stats,

    (
        SELECT COUNT(*)
        FROM public.coaches
    ) AS coaches;