/*
MATCHMATRIX SQL 18_2_B Match Duplicate Group Summary V1

CO TO JE:
- Souhrn duplicitních zápasů po skupinách.

K ČEMU TO JE:
- Rozlišíme počet skutečných duplicitních skupin, ne jen počet řádků.

KDE TO UVIDÍME:
- OPS Governance / budoucí panel.

JAK SE TO VYUŽIJE:
- Další krok 18_2_C vytvoří SAFE MERGE kandidáty.
*/

CREATE OR REPLACE VIEW ops.v_match_duplicate_group_summary_v1 AS

SELECT
    sport_id,
    match_date,
    team_low,
    team_high,
    governance_status,
    duplicate_count,
    distinct_league_count,
    distinct_source_count,
    distinct_score_count,

    MIN(kickoff) AS first_kickoff,
    MAX(kickoff) AS last_kickoff,

    STRING_AGG(id::text, ', ' ORDER BY kickoff, id) AS match_ids,

    STRING_AGG(
        COALESCE(ext_source, '?') || ':' || COALESCE(ext_match_id, '?'),
        ' | '
        ORDER BY kickoff, id
    ) AS provider_refs,

    STRING_AGG(
        home_team || ' vs ' || away_team
        || ' | ' || COALESCE(league_name, '?')
        || ' | ' || COALESCE(status, '?')
        || ' | ' || COALESCE(home_score::text, '?') || ':' || COALESCE(away_score::text, '?'),
        ' || '
        ORDER BY kickoff, id
    ) AS match_detail

FROM ops.v_match_duplicate_governance_audit_v1

GROUP BY
    sport_id,
    match_date,
    team_low,
    team_high,
    governance_status,
    duplicate_count,
    distinct_league_count,
    distinct_source_count,
    distinct_score_count;