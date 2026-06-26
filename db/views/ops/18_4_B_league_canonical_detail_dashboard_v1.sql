/*
MATCHMATRIX SQL 18_4_B
LEAGUE CANONICAL DETAIL DASHBOARD V1
*/

DROP VIEW IF EXISTS ops.v_league_canonical_detail_dashboard_v1;

CREATE OR REPLACE VIEW ops.v_league_canonical_detail_dashboard_v1 AS
SELECT
    audit_group_key,
    sport_id,
    norm_country,
    norm_league_name,

    max(CASE WHEN canonical_role = 'MASTER_CANDIDATE' THEN league_id END) AS master_league_id,
    max(CASE WHEN canonical_role = 'MASTER_CANDIDATE' THEN league_name END) AS master_league_name,
    max(CASE WHEN canonical_role = 'MASTER_CANDIDATE' THEN ext_source END) AS master_source,

    string_agg(
        CASE
            WHEN canonical_role = 'CANONICAL_MERGE_CANDIDATE'
            THEN league_id::text || ':' || league_name || ' [' || coalesce(ext_source, 'UNKNOWN') || ']'
        END,
        ' || '
        ORDER BY league_id
    ) AS merge_candidates,

    count(*) AS group_rows,
    max(provider_count) AS provider_count,
    max(governance_issue) AS governance_issue,

    CASE
        WHEN max(provider_count) > 1 THEN 'SAFE_REVIEW_PROVIDER_DUPLICATE'
        ELSE 'REVIEW'
    END AS recommended_action,

    now() AS created_at
FROM ops.v_league_canonical_governance_audit_v1
WHERE governance_issue <> 'OK'
GROUP BY
    audit_group_key,
    sport_id,
    norm_country,
    norm_league_name
ORDER BY group_rows DESC, norm_country, norm_league_name;