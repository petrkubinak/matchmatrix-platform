/*
MATCHMATRIX 19_6_D – TOP PLAYER ENRICHMENT CANDIDATES

CO TO JE:
TOP seznam konkrétních hráčů k obohacení profilu.

K ČEMU TO JE:
Ukáže první konkrétní hráče, které má systém řešit.

KDE TO UVIDÍME:
OPS Panel -> PEOPLE -> TOP ENRICHMENT CANDIDATES

JAK SE TO VYUŽIJE:
Vstup pro ruční kontrolu, enrichment worker, photo layer a source discovery.
*/

DROP VIEW IF EXISTS ops.v_top_player_enrichment_candidates_v1;

CREATE OR REPLACE VIEW ops.v_top_player_enrichment_candidates_v1 AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            enrichment_score DESC,
            sport_code,
            player_id
    ) AS enrichment_rank,

    player_id,
    sport_code,
    sport_name,
    team_id,
    name,
    first_name,
    last_name,
    ext_source,
    ext_player_id,
    missing_fields,
    enrichment_score,
    priority_level,
    next_action,
    suggested_source,

    CASE
        WHEN sport_code = 'FB' THEN 'FOOTBALL_PROFILE_ENRICHMENT'
        WHEN sport_code IN ('HK','BK','BSB','AFB') THEN 'SPORTSDATAIO_OR_OFFICIAL_SITE_ENRICHMENT'
        WHEN sport_code IN ('TN','MMA','CK') THEN 'SOURCE_DISCOVERY_REQUIRED'
        ELSE 'GENERAL_PLAYER_ENRICHMENT'
    END AS enrichment_task_type

FROM ops.v_player_enrichment_priority_queue_v1
WHERE priority_level = 'HIGH_PRIORITY';