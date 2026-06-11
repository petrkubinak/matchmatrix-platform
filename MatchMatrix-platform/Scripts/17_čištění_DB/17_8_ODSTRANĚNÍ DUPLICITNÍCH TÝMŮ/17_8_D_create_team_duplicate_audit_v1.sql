/*
MATCHMATRIX SQL 17_8_D
TEAM DUPLICATE AUDIT V1 (NAME + SPORT)

CO TO JE:
- Audit skutečných duplicit týmů.
- Duplicitu určuje:
    TEAM_NAME + SPORT_ID

K ČEMU TO JE:
- Odstraní falešné duplicity mezi sporty.
- Připraví podklad pro bezpečný merge plán.

KDE TO UVIDÍME:
- OPS Panel -> ČIŠTĚNÍ DB
- DBeaver audit

JAK SE TO VYUŽIJE:
- Následující krok 17_8_E vytvoří SAFE MERGE PLAN.
- Nebudeme slučovat týmy z různých sportů.
*/

CREATE OR REPLACE VIEW ops.v_team_duplicate_audit_v2 AS

WITH duplicate_groups AS (

    SELECT
        lower(trim(name)) AS team_name_norm,
        COALESCE(sport_id,-1) AS sport_id_norm,
        COUNT(*) AS duplicate_count

    FROM public.teams

    GROUP BY
        lower(trim(name)),
        COALESCE(sport_id,-1)

    HAVING COUNT(*) > 1

),

team_usage AS (

    SELECT
        t.id AS team_id,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.home_team_id = t.id
               OR m.away_team_id = t.id
        ) AS matches_count,

        COUNT(DISTINCT atm.article_id) AS article_links_count,

        COUNT(DISTINCT tpm.provider || ':' || tpm.provider_team_id)
            AS provider_maps_count

    FROM public.teams t

    LEFT JOIN public.matches m
        ON m.home_team_id = t.id
        OR m.away_team_id = t.id

    LEFT JOIN public.article_team_map atm
        ON atm.team_id = t.id

    LEFT JOIN public.team_provider_map tpm
        ON tpm.team_id = t.id

    GROUP BY
        t.id

)

SELECT

    t.id AS team_id,
    t.name AS team_name,

    COALESCE(t.sport_id,-1) AS sport_id,

    t.ext_source,
    t.ext_team_id,

    dg.duplicate_count,

    COALESCE(u.matches_count,0) AS matches_count,
    COALESCE(u.article_links_count,0) AS article_links_count,
    COALESCE(u.provider_maps_count,0) AS provider_maps_count,

    (
        COALESCE(u.matches_count,0) * 10
        + COALESCE(u.article_links_count,0) * 3
        + COALESCE(u.provider_maps_count,0) * 5
    ) AS master_candidate_score,

    CASE

        WHEN COALESCE(u.matches_count,0) > 0
            THEN 'HAS_MATCHES'

        WHEN COALESCE(u.provider_maps_count,0) > 0
            THEN 'HAS_PROVIDER_MAP'

        ELSE 'LOW_USAGE'

    END AS usage_status,

    now() AS generated_at

FROM public.teams t

JOIN duplicate_groups dg
    ON lower(trim(t.name)) = dg.team_name_norm
   AND COALESCE(t.sport_id,-1) = dg.sport_id_norm

LEFT JOIN team_usage u
    ON u.team_id = t.id

ORDER BY
    lower(trim(t.name)),
    COALESCE(t.sport_id,-1),
    master_candidate_score DESC;