/*
MATCHMATRIX SQL 117_W
MEDIA MATCH LINK GAP REASON AUDIT V1
*/

CREATE OR REPLACE VIEW ops.v_media_match_link_gap_reason_audit_v1 AS
WITH article_match_base AS (
    SELECT
        v.article_id,
        v.title,
        v.published_at,
        v.primary_league_id,
        v.primary_team_id,
        v.linked_leagues,
        v.linked_teams,
        v.linked_players,
        v.linked_matches,
        v.match_link_status,
        v.candidate_matches_count
    FROM ops.v_media_match_link_priority_v1 v
),
league_match_range AS (
    SELECT
        league_id,
        COUNT(*) AS matches_count,
        MIN(kickoff) AS min_kickoff,
        MAX(kickoff) AS max_kickoff
    FROM public.matches
    GROUP BY league_id
)
SELECT
    b.article_id,
    b.title,
    b.published_at,
    b.primary_league_id,
    b.primary_team_id,
    b.linked_leagues,
    b.linked_teams,
    b.linked_players,
    b.linked_matches,
    b.candidate_matches_count,

    COALESCE(lmr.matches_count,0) AS league_matches_count,
    lmr.min_kickoff,
    lmr.max_kickoff,

    CASE
        WHEN b.linked_teams = 0
            THEN 'TEAM_LINK_MISSING'

        WHEN COALESCE(lmr.matches_count,0) = 0
            THEN 'NO_MATCHES_IN_LEAGUE'

        WHEN b.published_at IS NOT NULL
          AND lmr.max_kickoff IS NOT NULL
          AND b.published_at > lmr.max_kickoff + INTERVAL '14 days'
            THEN 'ARTICLE_AFTER_MATCH_DATE_RANGE'

        WHEN b.published_at IS NOT NULL
          AND lmr.min_kickoff IS NOT NULL
          AND b.published_at < lmr.min_kickoff - INTERVAL '14 days'
            THEN 'ARTICLE_BEFORE_MATCH_DATE_RANGE'

        WHEN b.candidate_matches_count > 0
            THEN 'READY_FOR_MATCH_LINK'

        ELSE 'MATCH_NOT_FOUND_IN_WINDOW'
    END AS gap_reason,

    CASE
        WHEN b.linked_teams = 0
            THEN 'Nejdřív doplnit article_team_map.'

        WHEN COALESCE(lmr.matches_count,0) = 0
            THEN 'V této lize zatím nejsou zápasy v public.matches.'

        WHEN b.published_at IS NOT NULL
          AND lmr.max_kickoff IS NOT NULL
          AND b.published_at > lmr.max_kickoff + INTERVAL '14 days'
            THEN 'Článek je novější než poslední dostupný zápas. Doplnit novější sezonu / fixtures.'

        WHEN b.published_at IS NOT NULL
          AND lmr.min_kickoff IS NOT NULL
          AND b.published_at < lmr.min_kickoff - INTERVAL '14 days'
            THEN 'Článek je starší než první dostupný zápas. Doplnit historická data.'

        WHEN b.candidate_matches_count > 0
            THEN 'Kandidát pro article_match_map.'

        ELSE 'Zápas se nenašel v časovém okně. Zkontrolovat datum, tým nebo ligu.'
    END AS recommendation_cz,

    now() AS generated_at

FROM article_match_base b
LEFT JOIN league_match_range lmr
    ON lmr.league_id = b.primary_league_id
WHERE b.linked_matches = 0;