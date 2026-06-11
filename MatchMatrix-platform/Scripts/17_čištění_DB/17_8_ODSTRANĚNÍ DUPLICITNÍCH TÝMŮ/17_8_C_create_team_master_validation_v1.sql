/*
MATCHMATRIX SQL 17_8_C
TEAM MASTER VALIDATION V1

CO TO JE:
- Validace navržených MASTER týmů z duplicit.

K ČEMU TO JE:
- Ověří, jestli zvolený MASTER_TEAM není slabší než jiný kandidát.
- Reprezentace a mládežnické reprezentace drží v režimu HOLD_REVIEW.

KDE TO UVIDÍME:
- OPS Panel -> ČIŠTĚNÍ DB
- DBeaver audit před merge plánem.

JAK SE TO VYUŽIJE:
- Další krok 17_8_D vytvoří bezpečný merge plán jen pro validní klubové duplicity.
*/

CREATE OR REPLACE VIEW ops.v_team_master_validation_v1 AS
WITH group_stats AS (
    SELECT
        lower(trim(team_name)) AS team_name_norm,
        MAX(master_candidate_score) AS best_score,
        MAX(matches_count) AS best_matches_count,
        MAX(provider_maps_count) AS best_provider_maps_count,
        COUNT(*) FILTER (WHERE candidate_status = 'MASTER_TEAM') AS master_rows
    FROM ops.v_team_master_candidates_v1
    GROUP BY lower(trim(team_name))
),
master_rows AS (
    SELECT
        c.*
    FROM ops.v_team_master_candidates_v1 c
    WHERE c.candidate_status = 'MASTER_TEAM'
)
SELECT
    m.team_name,
    m.team_id AS master_team_id,
    m.duplicate_type,
    m.duplicate_count,

    m.matches_count AS master_matches_count,
    m.provider_maps_count AS master_provider_maps_count,
    m.article_links_count AS master_article_links_count,
    m.master_candidate_score AS master_score,

    gs.best_score,
    gs.best_matches_count,
    gs.best_provider_maps_count,
    gs.master_rows,

    CASE
        WHEN m.duplicate_type IN ('NATIONAL_TEAM','YOUTH_NATIONAL_TEAM')
            THEN 'HOLD_REVIEW'

        WHEN gs.master_rows <> 1
            THEN 'INVALID_MASTER_COUNT'

        WHEN m.master_candidate_score < gs.best_score
            THEN 'MASTER_NOT_BEST_SCORE'

        WHEN m.matches_count = 0
          AND gs.best_matches_count > 0
            THEN 'MASTER_HAS_NO_MATCHES_BUT_OTHER_HAS'

        WHEN m.provider_maps_count = 0
          AND gs.best_provider_maps_count > 0
            THEN 'MASTER_HAS_NO_PROVIDER_MAP_BUT_OTHER_HAS'

        ELSE 'VALID_MASTER'
    END AS validation_status,

    CASE
        WHEN m.duplicate_type IN ('NATIONAL_TEAM','YOUTH_NATIONAL_TEAM')
            THEN 'Reprezentace zatím neslučovat automaticky. Držet na ruční kontrolu.'

        WHEN gs.master_rows <> 1
            THEN 'Chyba: pro duplicitní skupinu není přesně jeden MASTER.'

        WHEN m.master_candidate_score < gs.best_score
            THEN 'Zvolený MASTER nemá nejlepší skóre.'

        WHEN m.matches_count = 0
          AND gs.best_matches_count > 0
            THEN 'Zvolený MASTER nemá zápasy, ale jiný kandidát je má.'

        WHEN m.provider_maps_count = 0
          AND gs.best_provider_maps_count > 0
            THEN 'Zvolený MASTER nemá provider mapu, ale jiný kandidát ji má.'

        ELSE 'MASTER je validní pro další merge plán.'
    END AS recommendation_cz,

    now() AS generated_at

FROM master_rows m
JOIN group_stats gs
    ON gs.team_name_norm = lower(trim(m.team_name))
ORDER BY
    validation_status,
    m.team_name;