/*
MATCHMATRIX SQL 117_S
MEDIA TEAM LINK PRIORITY V1

CO TO JE:
- Fronta článků, které mají ligu, ale chybí jim týmové napojení.

K ČEMU TO JE:
- MEDIA MATCH LINK ukázal, že největší blokátor je NEEDS_TEAM_LINK.
- Tento view připraví kandidáty pro team matcher worker.

KDE TO UVIDÍME:
- OPS Panel -> MEDIA
- Budoucí media matcher worker.
- Detail týmu / detail zápasu na webu.

JAK SE TO VYUŽIJE:
- Nejprve se doplní article_team_map.
- Potom se zlepší article_match_map.
*/

CREATE OR REPLACE VIEW ops.v_media_team_link_priority_v1 AS
WITH article_base AS (
    SELECT
        a.id AS article_id,
        a.title,
        a.url,
        a.published_at,
        a.language_code,
        COALESCE(a.article_quality_score, a.quality_score, 0) AS quality_score,
        COALESCE(a.is_feed_eligible, false) AS is_feed_eligible,
        COUNT(DISTINCT alm.league_id) AS linked_leagues,
        COUNT(DISTINCT atm.team_id) AS linked_teams,
        MIN(alm.league_id) AS primary_league_id
    FROM public.articles a
    LEFT JOIN public.article_league_map alm
        ON alm.article_id = a.id
    LEFT JOIN public.article_team_map atm
        ON atm.article_id = a.id
    GROUP BY
        a.id,
        a.title,
        a.url,
        a.published_at,
        a.language_code,
        COALESCE(a.article_quality_score, a.quality_score, 0),
        COALESCE(a.is_feed_eligible, false)
),
team_candidates AS (
    SELECT
        ab.article_id,
        COUNT(DISTINCT t.id) AS candidate_teams_count,
        MIN(t.id) AS sample_team_id,
        STRING_AGG(
            DISTINCT t.name,
            ', '
            ORDER BY t.name
        ) AS sample_team_names
    FROM article_base ab
    JOIN public.leagues l
        ON l.id = ab.primary_league_id
    JOIN public.teams t
        ON t.sport_id = l.sport_id
    WHERE ab.linked_leagues > 0
      AND ab.linked_teams = 0
    GROUP BY ab.article_id
)
SELECT
    ab.article_id,
    ab.title,
    ab.url,
    ab.published_at,
    ab.language_code,
    ab.quality_score,
    ab.is_feed_eligible,
    ab.linked_leagues,
    ab.linked_teams,
    ab.primary_league_id,

    COALESCE(tc.candidate_teams_count, 0) AS candidate_teams_count,
    tc.sample_team_id,
    tc.sample_team_names,

    (
        CASE WHEN ab.is_feed_eligible THEN 20 ELSE 0 END
        +
        CASE WHEN ab.quality_score >= 70 THEN 20 ELSE 0 END
        +
        CASE WHEN ab.linked_leagues > 0 THEN 20 ELSE 0 END
        +
        CASE WHEN COALESCE(tc.candidate_teams_count,0) > 0 THEN 20 ELSE 0 END
        +
        CASE WHEN ab.title IS NOT NULL AND trim(ab.title) <> '' THEN 20 ELSE 0 END
    ) AS team_link_priority_score,

    CASE
        WHEN ab.linked_teams > 0
            THEN 'ALREADY_TEAM_LINKED'
        WHEN ab.linked_leagues > 0 AND COALESCE(tc.candidate_teams_count,0) > 0
            THEN 'READY_FOR_TEAM_MATCHER'
        WHEN ab.linked_leagues > 0
            THEN 'NO_TEAM_CANDIDATES_IN_LEAGUE'
        ELSE 'NEEDS_LEAGUE_LINK'
    END AS team_link_status,

    CASE
        WHEN ab.linked_teams > 0
            THEN 'Článek už má napojený tým.'
        WHEN ab.linked_leagues > 0 AND COALESCE(tc.candidate_teams_count,0) > 0
            THEN 'Spustit team matcher podle názvu článku a týmů v lize.'
        WHEN ab.linked_leagues > 0
            THEN 'Liga je napojená, ale nejsou dostupné týmy pro tuto ligu.'
        ELSE 'Nejdřív doplnit league linking.'
    END AS recommendation_cz,

    now() AS generated_at

FROM article_base ab
LEFT JOIN team_candidates tc
    ON tc.article_id = ab.article_id
WHERE ab.linked_teams = 0
ORDER BY
    team_link_priority_score DESC,
    ab.published_at DESC NULLS LAST;