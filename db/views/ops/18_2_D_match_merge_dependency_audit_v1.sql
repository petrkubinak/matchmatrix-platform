/*
MATCHMATRIX SQL 18_2_D Match Merge Dependency Audit V1

CO TO JE:
- Audit vazeb duplicitních zápasů před merge.

K ČEMU TO JE:
- Zjistíme, jestli duplicate_match_id už má návazná data:
  odds, player stats, team stats, články nebo jiné vazby.

KDE TO UVIDÍME:
- OPS Governance / bezpečný merge plán.

JAK SE TO VYUŽIJE:
- Pokud vazby existují, musíme je před delete přesunout na master_match_id.
*/

CREATE OR REPLACE VIEW ops.v_match_merge_dependency_audit_v1 AS

WITH duplicate_ids AS (
    SELECT
        master_match_id,
        TRIM(x)::bigint AS duplicate_match_id
    FROM ops.v_match_safe_merge_plan_v1,
    LATERAL regexp_split_to_table(duplicate_match_ids, ',') AS x
),

deps AS (
    SELECT
        d.master_match_id,
        d.duplicate_match_id,

        (SELECT COUNT(*) FROM public.odds o WHERE o.match_id = d.duplicate_match_id) AS odds_rows,

        (SELECT COUNT(*) FROM public.player_match_statistics pms WHERE pms.match_id = d.duplicate_match_id) AS player_match_statistics_rows,

        (SELECT COUNT(*) FROM public.team_match_statistics tms WHERE tms.match_id = d.duplicate_match_id) AS team_match_statistics_rows,

        (SELECT COUNT(*) FROM public.article_match_map amm WHERE amm.match_id = d.duplicate_match_id) AS article_match_map_rows

    FROM duplicate_ids d
)

SELECT
    *,
    (
        odds_rows
        + player_match_statistics_rows
        + team_match_statistics_rows
        + article_match_map_rows
    ) AS total_dependency_rows,

    CASE
        WHEN (
            odds_rows
            + player_match_statistics_rows
            + team_match_statistics_rows
            + article_match_map_rows
        ) = 0
        THEN 'SAFE_DELETE_AFTER_PROVIDER_MAP_CHECK'
        ELSE 'MOVE_DEPENDENCIES_FIRST'
    END AS dependency_status

FROM deps;