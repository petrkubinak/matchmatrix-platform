/*
MATCHMATRIX SQL 18_2_C Match Safe Merge Plan V1

CO TO JE:
- Bezpečný plán slučování duplicitních zápasů.

K ČEMU TO JE:
- Určí master_match_id a duplicate_match_ids.

KDE TO UVIDÍME:
- OPS Governance.

JAK SE TO VYUŽIJE:
- Zatím nic nemaže.
- Pouze připraví plán pro pozdější bezpečný merge.
*/

CREATE OR REPLACE VIEW ops.v_match_safe_merge_plan_v1 AS

WITH ranked AS (
    SELECT
        a.*,

        ROW_NUMBER() OVER (
            PARTITION BY
                sport_id,
                match_date,
                team_low,
                team_high
            ORDER BY
                CASE
                    WHEN ext_source = 'api_football' THEN 1
                    WHEN ext_source = 'football_data' THEN 2
                    WHEN ext_source = 'football_data_uk' THEN 3
                    WHEN ext_source = 'api_sport' THEN 4
                    ELSE 9
                END,
                id
        ) AS master_rank
    FROM ops.v_match_duplicate_governance_audit_v1 a
    WHERE governance_status = 'PROVIDER_DUPLICATE'
)

SELECT
    sport_id,
    match_date,
    team_low,
    team_high,

    MIN(id) FILTER (WHERE master_rank = 1) AS master_match_id,

    STRING_AGG(
        id::text,
        ', '
        ORDER BY master_rank, id
    ) FILTER (WHERE master_rank > 1) AS duplicate_match_ids,

    COUNT(*) AS rows_in_group,

    STRING_AGG(
        COALESCE(ext_source, '?') || ':' || COALESCE(ext_match_id, '?'),
        ' | '
        ORDER BY master_rank, id
    ) AS provider_refs

FROM ranked
GROUP BY
    sport_id,
    match_date,
    team_low,
    team_high

HAVING COUNT(*) > 1;