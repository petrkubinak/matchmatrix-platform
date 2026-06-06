/*
MATCHMATRIX SQL 17_8_F
TEAM SAFE MERGE EXECUTION PLAN V1

CO TO JE:
- Připravuje první skutečný merge plán.
- Zahrnuje pouze SAFE_LOW_USAGE_MERGE kandidáty.
- Nic zatím nemaže ani neupravuje.

K ČEMU TO JE:
- Vytvoří seznam týmů, které lze bezpečně odstranit.
- Vyloučí týmy se zápasy.
- Vyloučí týmy s provider mapami.
- Vyloučí týmy s články.

KDE TO UVIDÍME:
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> TEAM DEDUP
- DBeaver merge audit

JAK SE TO VYUŽIJE:
- Po kontrole vznikne 17_8_G execution skript.
- Ten fyzicky odstraní pouze nejbezpečnější duplicity.
- Žádná data ze zápasů, článků ani provider map nebudou dotčena.
*/

CREATE OR REPLACE VIEW ops.v_team_safe_merge_execution_plan_v1 AS
SELECT
    team_name,
    sport_id,

    old_team_id,
    master_team_id,

    ext_source,
    ext_team_id,

    matches_count,
    article_links_count,
    provider_maps_count,

    master_candidate_score,

    'READY_FOR_DELETE' AS execution_status,

    'Tým nemá zápasy, články ani provider mapy. Bezpečný kandidát na odstranění.' AS recommendation_cz,

    now() AS generated_at

FROM ops.v_team_safe_merge_plan_v1
WHERE merge_status = 'SAFE_LOW_USAGE_MERGE'

ORDER BY
    team_name,
    sport_id,
    master_candidate_score DESC;