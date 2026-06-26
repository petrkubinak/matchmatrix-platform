/*
================================================================================
MATCHMATRIX 104_O - PLAYERS SPORT_ID BACKFILL AUDIT V1
================================================================================

Co skript dělá:
- neprovádí žádnou změnu v DB
- ověří, kolik hráčů lze bezpečně napojit na sport_id
- hledá sport_id přes:
  1) public.player_match_statistics -> public.matches
  2) public.player_season_statistics -> public.leagues

Proč:
- public.players zatím nemá sport_id
- pro PEOPLE / MEDIA / AI vrstvu je sport_id u hráčů nutný
================================================================================
*/

-- 1) Hráči podle ext_source
SELECT
    'PLAYERS_BY_SOURCE' AS section,
    ext_source,
    COUNT(*) AS players_count
FROM public.players
GROUP BY ext_source
ORDER BY players_count DESC;


-- 2) Hráči se sportem podle player_match_statistics
SELECT
    'PLAYERS_FROM_MATCH_STATS' AS section,
    m.sport_id,
    COUNT(DISTINCT pms.player_id) AS players_count
FROM public.player_match_statistics pms
JOIN public.matches m
    ON m.id = pms.match_id
WHERE m.sport_id IS NOT NULL
GROUP BY m.sport_id
ORDER BY m.sport_id;


-- 3) Hráči se sportem podle player_season_statistics -> leagues
SELECT
    'PLAYERS_FROM_SEASON_STATS' AS section,
    l.sport_id,
    COUNT(DISTINCT pss.player_id) AS players_count
FROM public.player_season_statistics pss
JOIN public.leagues l
    ON l.id = pss.league_id
WHERE l.sport_id IS NOT NULL
GROUP BY l.sport_id
ORDER BY l.sport_id;


-- 4) Jednoznačně odvoditelní hráči
WITH player_sports AS (
    SELECT
        pms.player_id,
        m.sport_id
    FROM public.player_match_statistics pms
    JOIN public.matches m
        ON m.id = pms.match_id
    WHERE m.sport_id IS NOT NULL

    UNION

    SELECT
        pss.player_id,
        l.sport_id
    FROM public.player_season_statistics pss
    JOIN public.leagues l
        ON l.id = pss.league_id
    WHERE l.sport_id IS NOT NULL
),
resolved AS (
    SELECT
        player_id,
        COUNT(DISTINCT sport_id) AS sport_count,
        MIN(sport_id) AS resolved_sport_id
    FROM player_sports
    GROUP BY player_id
)
SELECT
    'PLAYERS_RESOLVED_SINGLE_SPORT' AS section,
    resolved_sport_id AS sport_id,
    COUNT(*) AS players_count
FROM resolved
WHERE sport_count = 1
GROUP BY resolved_sport_id
ORDER BY resolved_sport_id;


-- 5) Rizikoví hráči s více sporty
WITH player_sports AS (
    SELECT
        pms.player_id,
        m.sport_id
    FROM public.player_match_statistics pms
    JOIN public.matches m
        ON m.id = pms.match_id
    WHERE m.sport_id IS NOT NULL

    UNION

    SELECT
        pss.player_id,
        l.sport_id
    FROM public.player_season_statistics pss
    JOIN public.leagues l
        ON l.id = pss.league_id
    WHERE l.sport_id IS NOT NULL
),
resolved AS (
    SELECT
        player_id,
        COUNT(DISTINCT sport_id) AS sport_count,
        STRING_AGG(DISTINCT sport_id::text, ', ' ORDER BY sport_id::text) AS sport_ids
    FROM player_sports
    GROUP BY player_id
)
SELECT
    'PLAYERS_MULTI_SPORT_RISK' AS section,
    p.id,
    p.name,
    p.ext_source,
    p.ext_player_id,
    r.sport_ids
FROM resolved r
JOIN public.players p
    ON p.id = r.player_id
WHERE r.sport_count > 1
ORDER BY p.name
LIMIT 100;


-- 6) Hráči bez sport evidence
WITH player_sports AS (
    SELECT player_id
    FROM public.player_match_statistics

    UNION

    SELECT player_id
    FROM public.player_season_statistics
)
SELECT
    'PLAYERS_WITHOUT_SPORT_EVIDENCE' AS section,
    p.ext_source,
    COUNT(*) AS players_count
FROM public.players p
LEFT JOIN player_sports ps
    ON ps.player_id = p.id
WHERE ps.player_id IS NULL
GROUP BY p.ext_source
ORDER BY players_count DESC;