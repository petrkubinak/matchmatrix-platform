/*
MATCHMATRIX SQL 17_8_A
TEAM DUPLICATE AUDIT V1

CO TO JE:
- Audit duplicitních týmů v public.teams podle názvu.

K ČEMU TO JE:
- Najde duplicitní team_id.
- Ukáže, které duplicity mají zápasy, články a provider mapy.
- Připraví podklad pro bezpečné čištění DB.

KDE TO UVIDÍME:
- OPS Panel -> ČIŠTĚNÍ DB
- DBeaver audit duplicit

JAK SE TO VYUŽIJE:
- Další krok vybere MASTER team_id.
- Teprve potom se připraví bezpečný merge plán.
*/

CREATE OR REPLACE VIEW ops.v_team_duplicate_audit_v1 AS
WITH dup_names AS (
    SELECT
        lower(trim(name)) AS team_name_norm,
        COUNT(*) AS duplicate_count
    FROM public.teams
    GROUP BY lower(trim(name))
    HAVING COUNT(*) > 1
),
team_usage AS (
    SELECT
        t.id AS team_id,
        lower(trim(t.name)) AS team_name_norm,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.home_team_id = t.id OR m.away_team_id = t.id
        ) AS matches_count,

        COUNT(DISTINCT atm.article_id) AS article_links_count,
        COUNT(DISTINCT ppm.player_id) AS player_provider_links_count,
        COUNT(DISTINCT tpm.provider || ':' || tpm.provider_team_id) AS provider_maps_count

    FROM public.teams t
    LEFT JOIN public.matches m
        ON m.home_team_id = t.id
        OR m.away_team_id = t.id
    LEFT JOIN public.article_team_map atm
        ON atm.team_id = t.id
    LEFT JOIN public.player_provider_map ppm
        ON ppm.provider_team_id = t.ext_team_id
    LEFT JOIN public.team_provider_map tpm
        ON tpm.team_id = t.id
    GROUP BY
        t.id,
        lower(trim(t.name))
)
SELECT
    t.id AS team_id,
    t.name AS team_name,
    t.ext_source,
    t.ext_team_id,
    t.sport_id,

    d.duplicate_count,

    COALESCE(u.matches_count,0) AS matches_count,
    COALESCE(u.article_links_count,0) AS article_links_count,
    COALESCE(u.player_provider_links_count,0) AS player_provider_links_count,
    COALESCE(u.provider_maps_count,0) AS provider_maps_count,

    (
        COALESCE(u.matches_count,0) * 10
        + COALESCE(u.article_links_count,0) * 3
        + COALESCE(u.player_provider_links_count,0) * 2
        + COALESCE(u.provider_maps_count,0) * 5
    ) AS master_candidate_score,

    CASE
        WHEN COALESCE(u.matches_count,0) > 0 THEN 'HAS_MATCHES'
        WHEN COALESCE(u.provider_maps_count,0) > 0 THEN 'HAS_PROVIDER_MAP'
        WHEN COALESCE(u.article_links_count,0) > 0 THEN 'HAS_ARTICLES'
        ELSE 'LOW_USAGE'
    END AS usage_status,

    now() AS generated_at

FROM public.teams t
JOIN dup_names d
    ON d.team_name_norm = lower(trim(t.name))
LEFT JOIN team_usage u
    ON u.team_id = t.id
ORDER BY
    lower(trim(t.name)),
    master_candidate_score DESC,
    t.id;