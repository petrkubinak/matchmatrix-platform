/*
MATCHMATRIX SQL 18_3_B League Mapping Conflict Detail V1

CO TO JE:
- Detail provider league mapping konfliktů.

K ČEMU TO JE:
- Ukáže, které league_id / league_name jsou proti sobě v konfliktu.

KDE TO UVIDÍME:
- OPS Governance.

JAK SE TO VYUŽIJE:
- Další krok 18_3_C navrhne správnou master ligu podle důvěry providerů.
*/

CREATE OR REPLACE VIEW ops.v_league_mapping_conflict_detail_v1 AS

SELECT
    a.sport_id,
    a.match_date,
    a.team_low,
    a.team_high,
    a.id AS match_id,
    a.ext_source,
    a.ext_match_id,
    a.league_id,
    a.league_name,
    a.kickoff,
    a.home_team,
    a.away_team,
    a.home_score,
    a.away_score,

    CASE
        WHEN a.ext_source = 'api_football' THEN 1
        WHEN a.ext_source = 'football_data' THEN 2
        WHEN a.ext_source = 'football_data_uk' THEN 3
        WHEN a.ext_source = 'api_sport' THEN 9
        ELSE 99
    END AS provider_trust_rank

FROM ops.v_match_duplicate_governance_audit_v1 a
JOIN ops.v_league_mapping_governance_audit_v1 g
    ON g.sport_id = a.sport_id
   AND g.match_date = a.match_date
   AND g.team_low = a.team_low
   AND g.team_high = a.team_high
WHERE g.league_mapping_status = 'PROVIDER_LEAGUE_MAPPING_CONFLICT';