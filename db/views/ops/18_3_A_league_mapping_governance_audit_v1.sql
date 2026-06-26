/*
MATCHMATRIX SQL 18_3_A League Mapping Governance Audit V1

CO TO JE:
- Audit league mapping chyb nalezených při Match Duplicate Governance.

K ČEMU TO JE:
- Rozpozná případy, kdy stejný zápas má stejné týmy, datum a skóre,
  ale různé league_id / league_name.

KDE TO UVIDÍME:
- OPS Governance.
- Budoucí OPS panel.

JAK SE TO VYUŽIJE:
- Připraví podklad pro League Mapping Fix Plan.
*/

CREATE OR REPLACE VIEW ops.v_league_mapping_governance_audit_v1 AS

WITH src AS (
    SELECT *
    FROM ops.v_match_duplicate_governance_audit_v1
    WHERE governance_status = 'LEAGUE_MAPPING_ERROR'
),

grouped AS (
    SELECT
        sport_id,
        match_date,
        team_low,
        team_high,
        COUNT(*) AS rows_in_group,
        COUNT(DISTINCT league_id) AS distinct_league_count,
        COUNT(DISTINCT league_name) AS distinct_league_name_count,
        COUNT(DISTINCT ext_source) AS distinct_source_count,
        COUNT(DISTINCT COALESCE(home_score::text, '?') || ':' || COALESCE(away_score::text, '?')) AS distinct_score_count,

        MIN(kickoff) AS first_kickoff,
        MAX(kickoff) AS last_kickoff,

        STRING_AGG(id::text, ', ' ORDER BY kickoff, id) AS match_ids,
        STRING_AGG(COALESCE(ext_source, '?') || ':' || COALESCE(ext_match_id, '?'), ' | ' ORDER BY kickoff, id) AS provider_refs,
        STRING_AGG(COALESCE(league_id::text, '?') || ':' || COALESCE(league_name, '?'), ' || ' ORDER BY kickoff, id) AS league_refs,
        STRING_AGG(home_team || ' vs ' || away_team, ' || ' ORDER BY kickoff, id) AS match_names,
        STRING_AGG(COALESCE(home_score::text, '?') || ':' || COALESCE(away_score::text, '?'), ' | ' ORDER BY kickoff, id) AS scores
    FROM src
    GROUP BY
        sport_id,
        match_date,
        team_low,
        team_high
)

SELECT
    *,
    CASE
        WHEN distinct_score_count > 1 THEN 'HOLD_SCORE_CONFLICT'
        WHEN distinct_league_count > 1 AND distinct_source_count > 1 THEN 'PROVIDER_LEAGUE_MAPPING_CONFLICT'
        WHEN distinct_league_count > 1 THEN 'LEAGUE_CANONICAL_CONFLICT'
        ELSE 'REVIEW_REQUIRED'
    END AS league_mapping_status
FROM grouped;