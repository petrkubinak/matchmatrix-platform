/*
MATCHMATRIX SQL 18_4_D
LEAGUE DEPENDENCY HOLD DETAIL V1

CO TO JE:
- Detailní audit lig, které byly označeny jako
  HOLD_DEPENDENCY_REVIEW během League Governance.

K ČEMU TO JE:
- Zjistit proč nelze ligu bezpečně sloučit.
- Identifikovat zda na lize visí:
    - zápasy
    - kurzy (odds)
    - statistiky hráčů
- Rozdělit ligy na:
    SAFE_PROVIDER_MAP
    HOLD_DEPENDENCY
    MANUAL_REVIEW

KDE TO UVIDÍME:
- ops.v_league_dependency_hold_detail_v1
- OPS Panel → Governance
- OPS Panel → League Governance
- Budoucí League Canonical Dashboard

JAK SE TO VYUŽIJE:
- Rozhodnutí zda:
    1) přesunout provider mapy
    2) vytvořit canonical league
    3) přesunout závislosti
    4) ponechat ligu v HOLD

- Podklad pro:
    18_4_E League Merge Plan
    18_4_F League Provider Map Migration
    18_4_G League Canonical Registry

VÝSTUP:
- Seznam všech blokovaných lig
- Typ blokace
- Počet zápasů
- Počet kurzů
- Počet statistik
- Doporučená akce
*/

DROP VIEW IF EXISTS ops.v_league_dependency_hold_detail_v1;

CREATE OR REPLACE VIEW ops.v_league_dependency_hold_detail_v1 AS
SELECT
    audit_group_key,
    league_id,
    sport_id,
    league_name,
    country,
    ext_source,
    ext_league_id,
    canonical_role,

    match_rows,
    finished_match_rows,
    non_finished_match_rows,

    odds_rows,
    player_season_stats_rows,

    total_dependency_rows,

    dependency_status,
    recommended_action,

    CASE
        WHEN match_rows > 0
         AND odds_rows > 0
            THEN 'MATCH_AND_ODDS_DEPENDENCY'

        WHEN match_rows > 0
            THEN 'MATCH_DEPENDENCY'

        WHEN odds_rows > 0
            THEN 'ODDS_DEPENDENCY'

        WHEN player_season_stats_rows > 0
            THEN 'PLAYER_STATS_DEPENDENCY'

        ELSE 'UNKNOWN'
    END AS hold_reason

FROM ops.v_league_dependency_audit_v1
WHERE recommended_action = 'HOLD_DEPENDENCY_REVIEW'
ORDER BY
    total_dependency_rows DESC,
    country,
    league_name;