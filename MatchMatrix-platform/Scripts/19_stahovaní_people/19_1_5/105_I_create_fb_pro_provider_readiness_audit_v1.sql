/*
===============================================================================
MATCHMATRIX 105_I - FB PRO PROVIDER READINESS AUDIT V1
===============================================================================

Co audit dělá:
- kontroluje, zda je FB vrstva připravena na placený provider / PRO režim
- ověřuje CORE, PEOPLE, MEDIA, ODDS, TEAM POWER a AI readiness

K čemu slouží:
- checklist před aktivací placeného API
- rozhodnutí, co lze po zaplacení ihned spustit
- identifikace slabých míst

Web/app využití:
- interní admin dashboard
- PRO activation readiness
- quality monitoring
===============================================================================
*/


-- 1. CORE READINESS
SELECT
    'CORE_MATCHES' AS area,
    'FB matches in public.matches' AS check_name,
    COUNT(*)::text AS value,
    CASE WHEN COUNT(*) > 50000 THEN 'READY' ELSE 'PARTIAL' END AS readiness
FROM public.matches
WHERE sport_id = 1;


-- 2. FINISHED MATCHES
SELECT
    'CORE_MATCHES' AS area,
    'FB finished matches' AS check_name,
    COUNT(*)::text AS value,
    CASE WHEN COUNT(*) > 10000 THEN 'READY' ELSE 'PARTIAL' END AS readiness
FROM public.matches
WHERE sport_id = 1
  AND status = 'FINISHED';


-- 3. TEAM MAPPING
SELECT
    'CORE_MAPPING' AS area,
    'FB matches missing team mapping' AS check_name,
    COUNT(*)::text AS value,
    CASE WHEN COUNT(*) = 0 THEN 'READY' ELSE 'BLOCKED' END AS readiness
FROM public.matches
WHERE sport_id = 1
  AND (home_team_id IS NULL OR away_team_id IS NULL);


-- 4. LEAGUE MAPPING
SELECT
    'CORE_MAPPING' AS area,
    'FB matches missing league mapping' AS check_name,
    COUNT(*)::text AS value,
    CASE WHEN COUNT(*) = 0 THEN 'READY' ELSE 'BLOCKED' END AS readiness
FROM public.matches
WHERE sport_id = 1
  AND league_id IS NULL;


-- 5. PLAYERS
SELECT
    'PEOPLE_PLAYERS' AS area,
    'FB canonical players with sport_id' AS check_name,
    COUNT(*)::text AS value,
    CASE WHEN COUNT(*) > 2000 THEN 'READY' ELSE 'PARTIAL' END AS readiness
FROM public.players
WHERE sport_id = 1;


-- 6. PLAYER PROVIDER MAP
SELECT
    'PEOPLE_PLAYERS' AS area,
    'FB player provider maps' AS check_name,
    COUNT(*)::text AS value,
    CASE WHEN COUNT(*) > 2000 THEN 'READY' ELSE 'PARTIAL' END AS readiness
FROM public.player_provider_map ppm
JOIN public.players p
    ON p.id = ppm.player_id
WHERE p.sport_id = 1;


-- 7. PLAYER MATCH STATS
SELECT
    'PEOPLE_STATS' AS area,
    'FB player match statistics rows' AS check_name,
    COUNT(*)::text AS value,
    CASE
        WHEN COUNT(*) > 100000 THEN 'READY'
        WHEN COUNT(*) > 10000 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END AS readiness
FROM public.player_match_statistics pms
JOIN public.matches m
    ON m.id = pms.match_id
WHERE m.sport_id = 1;


-- 8. PLAYER FORM
SELECT
    'PEOPLE_ANALYTICS' AS area,
    'FB player form rows' AS check_name,
    COUNT(*)::text AS value,
    CASE
        WHEN COUNT(*) > 2000 THEN 'READY'
        WHEN COUNT(*) > 100 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END AS readiness
FROM public.player_form
WHERE sport_id = 1;


-- 9. TEAM POWER HIGH CONFIDENCE
SELECT
    'TEAM_POWER' AS area,
    'FB high confidence teams' AS check_name,
    COUNT(*)::text AS value,
    CASE
        WHEN COUNT(*) > 100 THEN 'READY'
        WHEN COUNT(*) > 20 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END AS readiness
FROM public.v_fb_team_power_v2
WHERE power_confidence_tier = 'HIGH';


-- 10. TEAM POWER RESULTS ONLY
SELECT
    'TEAM_POWER' AS area,
    'FB results only teams' AS check_name,
    COUNT(*)::text AS value,
    CASE
        WHEN COUNT(*) < 100 THEN 'READY'
        WHEN COUNT(*) < 500 THEN 'PARTIAL'
        ELSE 'NEEDS_PLAYER_DATA'
    END AS readiness
FROM public.v_fb_team_power_v2
WHERE power_confidence_tier = 'RESULTS_ONLY';


-- 11. MEDIA ARTICLES
SELECT
    'MEDIA' AS area,
    'FB media articles' AS check_name,
    COUNT(*)::text AS value,
    CASE
        WHEN COUNT(*) > 1000 THEN 'READY'
        WHEN COUNT(*) > 100 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END AS readiness
FROM public.articles a
JOIN public.article_league_map alm
    ON alm.article_id = a.id
JOIN public.leagues l
    ON l.id = alm.league_id
WHERE l.sport_id = 1;


-- 12. ODDS LEAGUES ENABLED
SELECT
    'ODDS' AS area,
    'FB leagues enabled for TheOdds' AS check_name,
    COUNT(*)::text AS value,
    CASE
        WHEN COUNT(*) > 20 THEN 'READY'
        WHEN COUNT(*) > 0 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END AS readiness
FROM public.leagues
WHERE sport_id = 1
  AND enabled_theodds = true;


-- 13. THEODDS KEYS
SELECT
    'ODDS' AS area,
    'FB leagues with theodds_key' AS check_name,
    COUNT(*)::text AS value,
    CASE
        WHEN COUNT(*) > 20 THEN 'READY'
        WHEN COUNT(*) > 0 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END AS readiness
FROM public.leagues
WHERE sport_id = 1
  AND theodds_key IS NOT NULL;


-- 14. QUEUE SYSTEM
SELECT
    'AUTOMATION' AS area,
    'FB player match stats queue rows' AS check_name,
    COUNT(*)::text AS value,
    CASE
        WHEN COUNT(*) > 0 THEN 'READY'
        ELSE 'NOT_READY'
    END AS readiness
FROM ops.fixture_player_stats_queue
WHERE provider = 'api_football'
  AND sport_id = 1;


-- 15. QUEUE DONE ROWS
SELECT
    'AUTOMATION' AS area,
    'FB player match stats queue done rows' AS check_name,
    COUNT(*)::text AS value,
    CASE
        WHEN COUNT(*) > 0 THEN 'READY'
        ELSE 'NOT_READY'
    END AS readiness
FROM ops.fixture_player_stats_queue
WHERE provider = 'api_football'
  AND sport_id = 1
  AND status = 'done';


-- 16. QUEUE EMPTY ROWS
SELECT
    'AUTOMATION' AS area,
    'FB player match stats queue empty rows' AS check_name,
    COUNT(*)::text AS value,
    CASE
        WHEN COUNT(*) > 0 THEN 'PROVIDER_LIMITATION_VISIBLE'
        ELSE 'OK'
    END AS readiness
FROM ops.fixture_player_stats_queue
WHERE provider = 'api_football'
  AND sport_id = 1
  AND status = 'empty';


-- 17. AI READY LEAGUES
SELECT
    'AI_READY' AS area,
    'FB leagues with >=40% player stats coverage' AS check_name,
    COUNT(*)::text AS value,
    CASE
        WHEN COUNT(*) > 20 THEN 'READY'
        WHEN COUNT(*) > 0 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END AS readiness
FROM (
    SELECT
        l.id AS league_id,
        COUNT(DISTINCT m.id) AS matches_total,
        COUNT(DISTINCT pms.match_id) AS matches_with_player_stats,
        (
            COUNT(DISTINCT pms.match_id)::numeric
            /
            NULLIF(COUNT(DISTINCT m.id), 0)
        ) * 100 AS coverage_pct
    FROM public.matches m
    JOIN public.leagues l
        ON l.id = m.league_id
    LEFT JOIN public.player_match_statistics pms
        ON pms.match_id = m.id
    WHERE m.sport_id = 1
      AND m.status = 'FINISHED'
    GROUP BY l.id
    HAVING COUNT(DISTINCT m.id) >= 20
) x
WHERE x.coverage_pct >= 40;


-- 18. FINAL SUMMARY NOTE
SELECT
    'SUMMARY' AS area,
    'FB PRO provider readiness conclusion' AS check_name,
    CASE
        WHEN (
            SELECT COUNT(*)
            FROM public.player_match_statistics pms
            JOIN public.matches m
                ON m.id = pms.match_id
            WHERE m.sport_id = 1
        ) > 100000
        THEN 'Architecture and data coverage ready for advanced AI.'

        ELSE 'Architecture ready. Data coverage needs PRO backfill, especially player match stats, injuries, odds and media.'
    END AS value,
    'INFO' AS readiness;