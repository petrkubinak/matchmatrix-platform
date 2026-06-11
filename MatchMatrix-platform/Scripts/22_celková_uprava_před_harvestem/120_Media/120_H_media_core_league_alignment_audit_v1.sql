/*
MATCHMATRIX SQL 120_H Media Core League Alignment Audit V1

CO TO JE:
- Audit napojení Media lig na Core ligy v public.matches.

K ČEMU TO JE:
- Zjistí, jestli liga z článku má reálné zápasy ve stejné public.leagues.id.

KDE TO UVIDÍME:
- OPS / Media Command Center / Match Context Engine.

JAK SE TO VYUŽIJE:
- Připraví mapování La Liga -> Primera Division a další canonical league vazby.
*/

CREATE OR REPLACE VIEW ops.v_media_core_league_alignment_audit_v1 AS
WITH media_leagues AS (
    SELECT
        alm.league_id AS media_league_id,
        l.name AS media_league_name,
        COUNT(DISTINCT alm.article_id) AS article_count
    FROM public.article_league_map alm
    JOIN public.leagues l
        ON l.id = alm.league_id
    GROUP BY alm.league_id, l.name
),
match_leagues AS (
    SELECT
        m.league_id AS core_league_id,
        l.name AS core_league_name,
        COUNT(*) AS match_count,
        MIN(m.kickoff) AS first_match,
        MAX(m.kickoff) AS last_match
    FROM public.matches m
    JOIN public.leagues l
        ON l.id = m.league_id
    GROUP BY m.league_id, l.name
)
SELECT
    ml.media_league_id,
    ml.media_league_name,
    ml.article_count,

    cl.core_league_id,
    cl.core_league_name,
    cl.match_count,
    cl.first_match,
    cl.last_match,

    CASE
        WHEN cl.core_league_id IS NULL THEN 'NO_CORE_MATCH_LEAGUE'
        WHEN ml.media_league_id = cl.core_league_id THEN 'DIRECT_MATCH'
        WHEN lower(ml.media_league_name) = lower(cl.core_league_name) THEN 'SAME_NAME_DIFFERENT_ID'
        ELSE 'POSSIBLE_CANONICAL_ALIAS'
    END AS alignment_status,

    now() AS audited_at
FROM media_leagues ml
LEFT JOIN match_leagues cl
    ON ml.media_league_id = cl.core_league_id
    OR lower(ml.media_league_name) = lower(cl.core_league_name)
ORDER BY
    ml.article_count DESC,
    cl.match_count DESC NULLS LAST;