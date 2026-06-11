/*
MATCHMATRIX SQL 18_4_A
LEAGUE CANONICAL GOVERNANCE AUDIT V1 - FIX
*/

CREATE SCHEMA IF NOT EXISTS ops;

DROP VIEW IF EXISTS ops.v_league_canonical_governance_summary_v1;
DROP VIEW IF EXISTS ops.v_league_canonical_governance_audit_v1;

CREATE OR REPLACE VIEW ops.v_league_canonical_governance_audit_v1 AS
WITH base AS (
    SELECT
        l.id AS league_id,
        l.sport_id,
        l.name AS league_name,
        l.country,
        l.ext_source,
        l.ext_league_id,
        l.ext_csv_code,
        l.theodds_key,
        l.tier,
        l.is_cup,
        l.is_international,
        l.is_active,
        lower(regexp_replace(coalesce(l.name, ''), '[^a-zA-Z0-9]+', '', 'g')) AS norm_league_name,
        lower(regexp_replace(coalesce(l.country, ''), '[^a-zA-Z0-9]+', '', 'g')) AS norm_country
    FROM public.leagues l
),
group_stats AS (
    SELECT
        sport_id,
        norm_league_name,
        norm_country,
        count(*) AS duplicate_group_size,
        count(DISTINCT coalesce(ext_source, 'UNKNOWN')) AS provider_count,
        min(league_id) AS suggested_master_league_id
    FROM base
    GROUP BY sport_id, norm_league_name, norm_country
),
ranked AS (
    SELECT
        b.*,
        gs.duplicate_group_size,
        gs.provider_count,
        gs.suggested_master_league_id,
        row_number() OVER (
            PARTITION BY b.sport_id, b.norm_league_name, b.norm_country
            ORDER BY
                CASE
                    WHEN b.ext_source = 'api_football' THEN 1
                    WHEN b.ext_source = 'api_sport' THEN 2
                    WHEN b.ext_source = 'football_data_uk' THEN 3
                    WHEN b.ext_source = 'football_data' THEN 4
                    ELSE 9
                END,
                b.is_active DESC NULLS LAST,
                b.league_id
        ) AS master_rank
    FROM base b
    JOIN group_stats gs
      ON gs.sport_id = b.sport_id
     AND gs.norm_league_name = b.norm_league_name
     AND gs.norm_country = b.norm_country
)
SELECT
    md5(
        coalesce(sport_id::text, '') || '|' ||
        coalesce(norm_country, '') || '|' ||
        coalesce(norm_league_name, '')
    ) AS audit_group_key,
    league_id,
    sport_id,
    league_name,
    country,
    ext_source,
    ext_league_id,
    ext_csv_code,
    theodds_key,
    tier,
    is_cup,
    is_international,
    is_active,
    norm_league_name,
    norm_country,
    duplicate_group_size,
    provider_count,
    suggested_master_league_id,
    CASE
        WHEN duplicate_group_size = 1 THEN 'SINGLE_OK'
        WHEN master_rank = 1 THEN 'MASTER_CANDIDATE'
        ELSE 'CANONICAL_MERGE_CANDIDATE'
    END AS canonical_role,
    CASE
        WHEN duplicate_group_size = 1 THEN 'OK'
        WHEN provider_count > 1 THEN 'PROVIDER_DUPLICATE_LEAGUE'
        ELSE 'SAME_PROVIDER_DUPLICATE_LEAGUE'
    END AS governance_issue,
    now() AS audited_at
FROM ranked;

CREATE OR REPLACE VIEW ops.v_league_canonical_governance_summary_v1 AS
SELECT
    governance_issue,
    canonical_role,
    count(*) AS row_count,
    count(DISTINCT audit_group_key) AS group_count
FROM ops.v_league_canonical_governance_audit_v1
GROUP BY governance_issue, canonical_role
ORDER BY row_count DESC;