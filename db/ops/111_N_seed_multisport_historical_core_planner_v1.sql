/*
MATCHMATRIX SQL 111_N
SEED MULTISPORT HISTORICAL CORE PLANNER V1

CO TO JE:
- Doplní do ops.ingest_planner nové pending CORE úlohy pro non-FB sporty.

K ČEMU TO JE:
- Aby historical_backfill nejel jen football.
- Aby Smart Core Quota měla z čeho vybírat HK/BK/HB/VB/BSB/AFB/CK...

KDE TO UVIDÍME:
- ops.v_smart_core_quota_queue_v1
- OPS panel
- CORE fronta

JAK SE TO VYUŽIJE:
- Automat začne střídat sporty podle kvót.
*/

INSERT INTO ops.ingest_planner (
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run,
    created_at,
    updated_at
)
SELECT DISTINCT
    ip.provider,
    ip.sport_code,
    ip.entity,
    ip.provider_league_id,
    s.season,
    ip.sport_code || '_HISTORICAL_CORE_2022_2024' AS run_group,
    4 AS priority,
    'pending' AS status,
    0 AS attempts,
    NOW() AS next_run,
    NOW() AS created_at,
    NOW() AS updated_at
FROM ops.ingest_planner ip
CROSS JOIN (
    VALUES ('2022'), ('2023'), ('2024')
) AS s(season)
WHERE ip.sport_code IN ('HK','BK','HB','VB','BSB','AFB','CK','RGB','TN','MMA')
  AND ip.entity IN ('fixtures','teams','leagues')
  AND ip.provider_league_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner x
      WHERE x.provider = ip.provider
        AND x.sport_code = ip.sport_code
        AND x.entity = ip.entity
        AND COALESCE(x.provider_league_id,'') = COALESCE(ip.provider_league_id,'')
        AND COALESCE(x.season,'') = s.season
        AND x.run_group = ip.sport_code || '_HISTORICAL_CORE_2022_2024'
  );