/*
MATCHMATRIX SQL 18_3_C League Mapping Master Suggestion V1

CO TO JE:
- Návrh správné master ligy pro provider league mapping konflikty.

K ČEMU TO JE:
- Určí, který match_id / league_id má být master podle provider trust rank.

KDE TO UVIDÍME:
- OPS Governance.

JAK SE TO VYUŽIJE:
- Další krok připraví safe merge/fix plán zápasů s rozdílnou ligou.
*/

CREATE OR REPLACE VIEW ops.v_league_mapping_master_suggestion_v1 AS

WITH ranked AS (
    SELECT
        d.*,
        ROW_NUMBER() OVER (
            PARTITION BY sport_id, match_date, team_low, team_high
            ORDER BY provider_trust_rank ASC, match_id ASC
        ) AS master_rank
    FROM ops.v_league_mapping_conflict_detail_v1 d
)

SELECT
    sport_id,
    match_date,
    team_low,
    team_high,

    MIN(match_id) FILTER (WHERE master_rank = 1) AS master_match_id,
    MIN(league_id) FILTER (WHERE master_rank = 1) AS master_league_id,
    MIN(league_name) FILTER (WHERE master_rank = 1) AS master_league_name,
    MIN(ext_source) FILTER (WHERE master_rank = 1) AS master_ext_source,

    STRING_AGG(match_id::text, ', ' ORDER BY master_rank, match_id) AS all_match_ids,
    STRING_AGG(
        match_id::text || ':' || COALESCE(ext_source, '?') || ':' || COALESCE(league_name, '?'),
        ' | '
        ORDER BY master_rank, match_id
    ) AS conflict_detail,

    COUNT(*) AS rows_in_group

FROM ranked
GROUP BY
    sport_id,
    match_date,
    team_low,
    team_high;