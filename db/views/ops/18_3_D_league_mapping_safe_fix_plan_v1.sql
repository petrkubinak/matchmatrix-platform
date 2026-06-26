/*
MATCHMATRIX SQL 18_3_D League Mapping Safe Fix Plan V1

CO TO JE:
- Bezpečný plán opravy league_id u duplicitních zápasů.

K ČEMU TO JE:
- Určí, které match_id mají dostat master_league_id.

KDE TO UVIDÍME:
- OPS Governance.

JAK SE TO VYUŽIJE:
- Další krok ověří závislosti a potom bezpečně přepíše league_id.
*/

CREATE OR REPLACE VIEW ops.v_league_mapping_safe_fix_plan_v1 AS

WITH ranked AS (
    SELECT
        d.*,
        s.master_match_id,
        s.master_league_id,
        s.master_league_name,
        s.master_ext_source,

        CASE
            WHEN d.league_id = s.master_league_id THEN 'KEEP_MASTER_LEAGUE'
            ELSE 'UPDATE_TO_MASTER_LEAGUE'
        END AS proposed_action

    FROM ops.v_league_mapping_conflict_detail_v1 d
    JOIN ops.v_league_mapping_master_suggestion_v1 s
        ON s.sport_id = d.sport_id
       AND s.match_date = d.match_date
       AND s.team_low = d.team_low
       AND s.team_high = d.team_high
)

SELECT
    sport_id,
    match_date,
    team_low,
    team_high,
    match_id,
    ext_source,
    ext_match_id,
    league_id AS current_league_id,
    league_name AS current_league_name,
    master_match_id,
    master_league_id,
    master_league_name,
    master_ext_source,
    home_team,
    away_team,
    home_score,
    away_score,
    proposed_action
FROM ranked;