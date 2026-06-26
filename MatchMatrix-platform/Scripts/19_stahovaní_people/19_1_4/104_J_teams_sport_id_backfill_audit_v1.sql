/*
MATCHMATRIX 104_J - TEAMS SPORT_ID BACKFILL AUDIT V1

Co skript dělá:
- neprovádí žádnou změnu v DB
- jen ověří, kolik týmů lze bezpečně napojit na sport_id
- hledá sport_id přes public.matches

Proč:
- public.teams zatím nemá sport_id
- pro multisport platformu je sport_id u týmů důležitý
*/

-- 1) Kolik týmů existuje podle ext_source
SELECT
    'TEAMS_BY_SOURCE' AS section,
    ext_source,
    COUNT(*) AS teams_count
FROM public.teams
GROUP BY ext_source
ORDER BY teams_count DESC;


-- 2) Kolik týmů lze odvodit ze zápasů jako home_team_id
SELECT
    'TEAMS_FROM_HOME_MATCHES' AS section,
    m.sport_id,
    COUNT(DISTINCT m.home_team_id) AS teams_count
FROM public.matches m
WHERE m.home_team_id IS NOT NULL
GROUP BY m.sport_id
ORDER BY m.sport_id;


-- 3) Kolik týmů lze odvodit ze zápasů jako away_team_id
SELECT
    'TEAMS_FROM_AWAY_MATCHES' AS section,
    m.sport_id,
    COUNT(DISTINCT m.away_team_id) AS teams_count
FROM public.matches m
WHERE m.away_team_id IS NOT NULL
GROUP BY m.sport_id
ORDER BY m.sport_id;


-- 4) Týmy, které mají jednoznačně jen jeden sport podle zápasů
WITH team_sports AS (
    SELECT home_team_id AS team_id, sport_id
    FROM public.matches
    WHERE home_team_id IS NOT NULL

    UNION

    SELECT away_team_id AS team_id, sport_id
    FROM public.matches
    WHERE away_team_id IS NOT NULL
),
resolved AS (
    SELECT
        team_id,
        COUNT(DISTINCT sport_id) AS sport_count,
        MIN(sport_id) AS resolved_sport_id
    FROM team_sports
    GROUP BY team_id
)
SELECT
    'TEAMS_RESOLVED_SINGLE_SPORT' AS section,
    resolved_sport_id AS sport_id,
    COUNT(*) AS teams_count
FROM resolved
WHERE sport_count = 1
GROUP BY resolved_sport_id
ORDER BY resolved_sport_id;


-- 5) Rizikové týmy, které se vyskytují ve více sportech podle matches
WITH team_sports AS (
    SELECT home_team_id AS team_id, sport_id
    FROM public.matches
    WHERE home_team_id IS NOT NULL

    UNION

    SELECT away_team_id AS team_id, sport_id
    FROM public.matches
    WHERE away_team_id IS NOT NULL
),
resolved AS (
    SELECT
        team_id,
        COUNT(DISTINCT sport_id) AS sport_count,
        STRING_AGG(DISTINCT sport_id::text, ', ' ORDER BY sport_id::text) AS sport_ids
    FROM team_sports
    GROUP BY team_id
)
SELECT
    'TEAMS_MULTI_SPORT_RISK' AS section,
    t.id,
    t.name,
    t.ext_source,
    t.ext_team_id,
    r.sport_ids
FROM resolved r
JOIN public.teams t
    ON t.id = r.team_id
WHERE r.sport_count > 1
ORDER BY t.name
LIMIT 100;


-- 6) Týmy, které zatím nejdou odvodit ze zápasů
WITH team_sports AS (
    SELECT home_team_id AS team_id
    FROM public.matches
    WHERE home_team_id IS NOT NULL

    UNION

    SELECT away_team_id AS team_id
    FROM public.matches
    WHERE away_team_id IS NOT NULL
)
SELECT
    'TEAMS_WITHOUT_MATCH_SPORT_EVIDENCE' AS section,
    t.ext_source,
    COUNT(*) AS teams_count
FROM public.teams t
LEFT JOIN team_sports ts
    ON ts.team_id = t.id
WHERE ts.team_id IS NULL
GROUP BY t.ext_source
ORDER BY teams_count DESC;