/*
MATCHMATRIX SQL 120_P_B_4 Create League Canonical Candidates V1

CO TO JE:
- Generátor kandidátů pro League Canonical Governance.

K ČEMU TO JE:
- Najde ligy, které vypadají jako stejná soutěž vedená různými providery.

KDE TO UVIDÍME:
- OPS / League Governance Dashboard.

JAK SE TO VYUŽIJE:
- Podklad pro budoucí INSERT do canonical_league_map.
*/

CREATE OR REPLACE VIEW ops.v_league_canonical_candidates_v1 AS
WITH duplicates AS (

    SELECT
        lower(trim(name)) AS league_name_key,
        sport_id,
        country,
        COUNT(*) AS league_count
    FROM public.leagues
    GROUP BY
        lower(trim(name)),
        sport_id,
        country
    HAVING COUNT(*) = 2

)

SELECT
    d.league_name_key,
    d.sport_id,
    d.country,

    l.id AS league_id,
    l.name AS league_name,
    l.ext_source,
    l.ext_league_id,

    MIN(l.id) OVER (
        PARTITION BY
            d.league_name_key,
            d.sport_id,
            d.country
    ) AS suggested_canonical_league_id,

    CASE
        WHEN l.id =
             MIN(l.id) OVER (
                 PARTITION BY
                     d.league_name_key,
                     d.sport_id,
                     d.country
             )
        THEN 'MASTER'

        ELSE 'CANDIDATE'
    END AS governance_role,

    now() AS audited_at

FROM duplicates d
JOIN public.leagues l
    ON lower(trim(l.name)) = d.league_name_key
   AND l.sport_id = d.sport_id
   AND l.country = d.country;