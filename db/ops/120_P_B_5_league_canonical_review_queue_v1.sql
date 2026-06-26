/*
MATCHMATRIX SQL 120_P_B_5 League Canonical Review Queue V1

CO TO JE:
- Review fronta pro canonical ligy.

K ČEMU TO JE:
- Rozdělí kandidáty na bezpečné pro auto-approve a na ruční kontrolu.

KDE TO UVIDÍME:
- OPS / League Governance Dashboard.

JAK SE TO VYUŽIJE:
- Další krok připraví bezpečný INSERT do public.canonical_league_map.
*/

CREATE OR REPLACE VIEW ops.v_league_canonical_review_queue_v1 AS
SELECT
    league_name_key,
    sport_id,
    country,
    suggested_canonical_league_id,
    COUNT(*) AS rows_in_group,
    COUNT(*) FILTER (WHERE governance_role = 'MASTER') AS master_rows,
    COUNT(*) FILTER (WHERE governance_role = 'CANDIDATE') AS candidate_rows,
    STRING_AGG(league_id::text, ', ' ORDER BY league_id::text) AS league_ids,
    STRING_AGG(DISTINCT COALESCE(ext_source, 'NULL'), ', ' ORDER BY COALESCE(ext_source, 'NULL')) AS providers,

    CASE
        WHEN COUNT(*) = 2
         AND COUNT(*) FILTER (WHERE governance_role = 'MASTER') = 1
         AND COUNT(*) FILTER (WHERE governance_role = 'CANDIDATE') = 1
         AND COUNT(DISTINCT COALESCE(ext_source, 'NULL')) = 2
        THEN 'AUTO_APPROVE_CANDIDATE'
        ELSE 'REVIEW_REQUIRED'
    END AS review_status,

    now() AS audited_at

FROM ops.v_league_canonical_candidates_v1
GROUP BY
    league_name_key,
    sport_id,
    country,
    suggested_canonical_league_id;