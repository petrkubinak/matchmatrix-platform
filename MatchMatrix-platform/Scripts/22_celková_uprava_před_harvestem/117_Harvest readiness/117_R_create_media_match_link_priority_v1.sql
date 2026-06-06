/*
MATCHMATRIX SQL 117_R
MEDIA MATCH LINK PRIORITY V1

CO TO JE:
- View pro nalezení článků, které mají vysoký potenciál napojení na konkrétní zápas.

K ČEMU TO JE:
- MEDIA MASTER READINESS ukázal MATCH_LINK_GAP.
- Tento view připraví pracovní frontu pro article_match_map.

KDE TO UVIDÍME:
- OPS Panel -> MEDIA
- OPS Panel -> HARVEST
- Budoucí web -> detail zápasu / související články.

JAK SE TO VYUŽIJE:
- Pomůže vybrat kandidáty pro media match linker worker.
- Nejprve články s ligou + týmem + published_at.
*/

CREATE OR REPLACE VIEW ops.v_media_match_link_priority_v1 AS
WITH article_links AS (
    SELECT
        a.id AS article_id,
        a.title,
        a.url,
        a.published_at,
        a.language_code,
        a.is_video,
        a.video_url,
        a.thumbnail_url,
        COALESCE(a.article_quality_score, a.quality_score, 0) AS quality_score,
        a.is_feed_eligible,

        COUNT(DISTINCT alm.league_id) AS linked_leagues,
        COUNT(DISTINCT atm.team_id) AS linked_teams,
        COUNT(DISTINCT apm.player_id) AS linked_players,
        COUNT(DISTINCT amm.match_id) AS linked_matches,

        MIN(alm.league_id) AS primary_league_id,
        MIN(atm.team_id) AS primary_team_id

    FROM public.articles a
    LEFT JOIN public.article_league_map alm
        ON alm.article_id = a.id
    LEFT JOIN public.article_team_map atm
        ON atm.article_id = a.id
    LEFT JOIN public.article_player_map apm
        ON apm.article_id = a.id
    LEFT JOIN public.article_match_map amm
        ON amm.article_id = a.id
    GROUP BY
        a.id,
        a.title,
        a.url,
        a.published_at,
        a.language_code,
        a.is_video,
        a.video_url,
        a.thumbnail_url,
        COALESCE(a.article_quality_score, a.quality_score, 0),
        a.is_feed_eligible
),
candidate_matches AS (
    SELECT
        al.article_id,
        COUNT(DISTINCT m.id) AS candidate_matches_count,
        MIN(m.id) AS sample_match_id,
        MIN(m.kickoff) AS nearest_kickoff
    FROM article_links al
    JOIN public.matches m
        ON m.league_id = al.primary_league_id
       AND (
            m.home_team_id = al.primary_team_id
         OR m.away_team_id = al.primary_team_id
       )
       AND al.published_at IS NOT NULL
       AND m.kickoff BETWEEN al.published_at - INTERVAL '7 days'
                         AND al.published_at + INTERVAL '7 days'
    WHERE al.linked_matches = 0
    GROUP BY al.article_id
)
SELECT
    al.article_id,
    al.title,
    al.url,
    al.published_at,
    al.language_code,
    al.quality_score,
    al.is_feed_eligible,
    al.is_video,
    al.thumbnail_url,

    al.linked_leagues,
    al.linked_teams,
    al.linked_players,
    al.linked_matches,

    al.primary_league_id,
    al.primary_team_id,

    COALESCE(cm.candidate_matches_count, 0) AS candidate_matches_count,
    cm.sample_match_id,
    cm.nearest_kickoff,

    (
        CASE WHEN al.is_feed_eligible = true THEN 20 ELSE 0 END
        +
        CASE WHEN al.quality_score >= 70 THEN 20 ELSE 0 END
        +
        CASE WHEN al.linked_leagues > 0 THEN 15 ELSE 0 END
        +
        CASE WHEN al.linked_teams > 0 THEN 20 ELSE 0 END
        +
        CASE WHEN al.linked_players > 0 THEN 10 ELSE 0 END
        +
        CASE WHEN COALESCE(cm.candidate_matches_count,0) > 0 THEN 15 ELSE 0 END
    ) AS match_link_priority_score,

    CASE
        WHEN al.linked_matches > 0
            THEN 'ALREADY_LINKED'
        WHEN COALESCE(cm.candidate_matches_count,0) > 0
            THEN 'READY_FOR_MATCH_LINK'
        WHEN al.linked_leagues > 0 AND al.linked_teams > 0
            THEN 'NEEDS_TIME_WINDOW_OR_FIXTURE_MATCH'
        WHEN al.linked_leagues > 0
            THEN 'NEEDS_TEAM_LINK'
        WHEN al.linked_teams > 0
            THEN 'NEEDS_LEAGUE_LINK'
        ELSE 'NOT_READY'
    END AS match_link_status,

    CASE
        WHEN al.linked_matches > 0
            THEN 'Článek už je propojený na zápas.'
        WHEN COALESCE(cm.candidate_matches_count,0) > 0
            THEN 'Kandidát na automatické vložení do article_match_map.'
        WHEN al.linked_leagues > 0 AND al.linked_teams > 0
            THEN 'Má ligu i tým, ale nenašel se zápas v časovém okně.'
        WHEN al.linked_leagues > 0
            THEN 'Chybí napojení na tým.'
        WHEN al.linked_teams > 0
            THEN 'Chybí napojení na ligu.'
        ELSE 'Nejdřív doplnit entity linking.'
    END AS recommendation_cz,

    now() AS generated_at

FROM article_links al
LEFT JOIN candidate_matches cm
    ON cm.article_id = al.article_id
WHERE al.linked_matches = 0
ORDER BY
    match_link_priority_score DESC,
    al.published_at DESC NULLS LAST;