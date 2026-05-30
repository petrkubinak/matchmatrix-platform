/*
===============================================================================
MATCHMATRIX 105_I - FB PRO PROVIDER READINESS AUDIT V2
SINGLE RESULTSET VERSION
===============================================================================

Enterprise audit style:
- jeden unified output
- snadný export do CSV/XLSX
- vhodné pro dashboardy a reporting
===============================================================================
*/

SELECT
    'CORE_MATCHES' AS area,
    'FB matches in public.matches' AS check_name,
    COUNT(*)::text AS value,
    CASE WHEN COUNT(*) > 50000 THEN 'READY' ELSE 'PARTIAL' END AS readiness
FROM public.matches
WHERE sport_id = 1

UNION ALL

SELECT
    'CORE_MATCHES',
    'FB finished matches',
    COUNT(*)::text,
    CASE WHEN COUNT(*) > 10000 THEN 'READY' ELSE 'PARTIAL' END
FROM public.matches
WHERE sport_id = 1
  AND status = 'FINISHED'

UNION ALL

SELECT
    'CORE_MAPPING',
    'FB matches missing team mapping',
    COUNT(*)::text,
    CASE WHEN COUNT(*) = 0 THEN 'READY' ELSE 'BLOCKED' END
FROM public.matches
WHERE sport_id = 1
  AND (home_team_id IS NULL OR away_team_id IS NULL)

UNION ALL

SELECT
    'CORE_MAPPING',
    'FB matches missing league mapping',
    COUNT(*)::text,
    CASE WHEN COUNT(*) = 0 THEN 'READY' ELSE 'BLOCKED' END
FROM public.matches
WHERE sport_id = 1
  AND league_id IS NULL

UNION ALL

SELECT
    'PEOPLE_PLAYERS',
    'FB canonical players with sport_id',
    COUNT(*)::text,
    CASE WHEN COUNT(*) > 2000 THEN 'READY' ELSE 'PARTIAL' END
FROM public.players
WHERE sport_id = 1

UNION ALL

SELECT
    'PEOPLE_PLAYERS',
    'FB player provider maps',
    COUNT(*)::text,
    CASE WHEN COUNT(*) > 2000 THEN 'READY' ELSE 'PARTIAL' END
FROM public.player_provider_map ppm
JOIN public.players p
    ON p.id = ppm.player_id
WHERE p.sport_id = 1

UNION ALL

SELECT
    'PEOPLE_STATS',
    'FB player match statistics rows',
    COUNT(*)::text,
    CASE
        WHEN COUNT(*) > 100000 THEN 'READY'
        WHEN COUNT(*) > 10000 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END
FROM public.player_match_statistics pms
JOIN public.matches m
    ON m.id = pms.match_id
WHERE m.sport_id = 1

UNION ALL

SELECT
    'PEOPLE_ANALYTICS',
    'FB player form rows',
    COUNT(*)::text,
    CASE
        WHEN COUNT(*) > 2000 THEN 'READY'
        WHEN COUNT(*) > 100 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END
FROM public.player_form
WHERE sport_id = 1

UNION ALL

SELECT
    'TEAM_POWER',
    'FB high confidence teams',
    COUNT(*)::text,
    CASE
        WHEN COUNT(*) > 100 THEN 'READY'
        WHEN COUNT(*) > 20 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END
FROM public.v_fb_team_power_v2
WHERE power_confidence_tier = 'HIGH'

UNION ALL

SELECT
    'TEAM_POWER',
    'FB results only teams',
    COUNT(*)::text,
    CASE
        WHEN COUNT(*) < 100 THEN 'READY'
        WHEN COUNT(*) < 500 THEN 'PARTIAL'
        ELSE 'NEEDS_PLAYER_DATA'
    END
FROM public.v_fb_team_power_v2
WHERE power_confidence_tier = 'RESULTS_ONLY'

UNION ALL

SELECT
    'MEDIA',
    'FB media articles',
    COUNT(*)::text,
    CASE
        WHEN COUNT(*) > 1000 THEN 'READY'
        WHEN COUNT(*) > 100 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END
FROM public.articles a
JOIN public.article_league_map alm
    ON alm.article_id = a.id
JOIN public.leagues l
    ON l.id = alm.league_id
WHERE l.sport_id = 1

UNION ALL

SELECT
    'AUTOMATION',
    'FB player stats queue rows',
    COUNT(*)::text,
    CASE
        WHEN COUNT(*) > 0 THEN 'READY'
        ELSE 'NOT_READY'
    END
FROM ops.fixture_player_stats_queue
WHERE provider = 'api_football'
  AND sport_id = 1

UNION ALL

SELECT
    'AUTOMATION',
    'FB queue done rows',
    COUNT(*)::text,
    CASE
        WHEN COUNT(*) > 0 THEN 'READY'
        ELSE 'NOT_READY'
    END
FROM ops.fixture_player_stats_queue
WHERE provider = 'api_football'
  AND sport_id = 1
  AND status = 'done'

UNION ALL

SELECT
    'AUTOMATION',
    'FB queue empty rows',
    COUNT(*)::text,
    CASE
        WHEN COUNT(*) > 0 THEN 'PROVIDER_LIMITATION_VISIBLE'
        ELSE 'OK'
    END
FROM ops.fixture_player_stats_queue
WHERE provider = 'api_football'
  AND sport_id = 1
  AND status = 'empty'

UNION ALL

SELECT
    'AI_READY',
    'FB leagues with >=40% player stats coverage',
    COUNT(*)::text,
    CASE
        WHEN COUNT(*) > 20 THEN 'READY'
        WHEN COUNT(*) > 0 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END
FROM (
    SELECT
        l.id AS league_id,
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
WHERE x.coverage_pct >= 40

UNION ALL

SELECT
    'SUMMARY',
    'FB PRO provider readiness conclusion',
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
    END,
    'INFO';