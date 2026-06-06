/*
MATCHMATRIX SQL 111_M
FIX SMART CORE QUOTA QUEUE SPORT MAPPING V1

CO TO JE:
- Opravuje pohled ops.v_smart_core_quota_queue_v1.
- Sjednocuje sport_code z planneru:
  FB/football, HK/hockey, BK/basketball atd.

K ČEMU TO JE:
- Aby SMART CORE fronta neukazovala jen fotbal.
- Aby se do historického harvestu dostaly i HK, BK, HB, VB, BSB, AFB...

KDE TO UVIDÍME:
- OPS panel
- smart core quota fronta
- budoucí automatický režim

JAK SE TO VYUŽIJE:
- CORE nebude pořád tahat jen fotbal.
- Bude možné řídit podíl sportů podle sports_import_plan.
*/

CREATE OR REPLACE VIEW ops.v_smart_core_quota_queue_v1 AS
WITH planner_normalized AS (
    SELECT
        ip.*,
        CASE
            WHEN LOWER(ip.sport_code) IN ('fb', 'football') THEN 'football'
            WHEN LOWER(ip.sport_code) IN ('hk', 'hockey') THEN 'hockey'
            WHEN LOWER(ip.sport_code) IN ('bk', 'basketball') THEN 'basketball'
            WHEN LOWER(ip.sport_code) IN ('hb', 'handball') THEN 'handball'
            WHEN LOWER(ip.sport_code) IN ('vb', 'volleyball') THEN 'volleyball'
            WHEN LOWER(ip.sport_code) IN ('bsb', 'baseball') THEN 'baseball'
            WHEN LOWER(ip.sport_code) IN ('afb', 'american_football') THEN 'american_football'
            WHEN LOWER(ip.sport_code) IN ('ck', 'cricket') THEN 'cricket'
            WHEN LOWER(ip.sport_code) IN ('rgb', 'rugby') THEN 'rugby'
            WHEN LOWER(ip.sport_code) IN ('tn', 'tennis') THEN 'tennis'
            WHEN LOWER(ip.sport_code) IN ('mma') THEN 'mma'
            WHEN LOWER(ip.sport_code) IN ('esp', 'esports') THEN 'esports'
            WHEN LOWER(ip.sport_code) IN ('fh', 'field_hockey') THEN 'field_hockey'
            ELSE LOWER(ip.sport_code)
        END AS normalized_sport_code
    FROM ops.ingest_planner ip
)
SELECT
    pn.normalized_sport_code AS sport_code,
    sip.sport_name,
    pn.entity,
    pn.run_group,
    pn.status,
    sip.mode,
    sip.daily_request_budget,
    sip.priority AS sport_priority,
    COUNT(*) AS pending_count,
    MIN(pn.id) AS first_planner_id,
    MAX(pn.created_at) AS newest_created_at
FROM planner_normalized pn
JOIN ops.sports_import_plan sip
    ON LOWER(sip.sport_code) = pn.normalized_sport_code
WHERE pn.status = 'pending'
  AND sip.enabled = TRUE
  AND sip.mode = 'historical_backfill'
  AND pn.entity IN ('fixtures', 'teams', 'leagues')
GROUP BY
    pn.normalized_sport_code,
    sip.sport_name,
    pn.entity,
    pn.run_group,
    pn.status,
    sip.mode,
    sip.daily_request_budget,
    sip.priority
ORDER BY
    sip.daily_request_budget DESC,
    sip.priority DESC,
    pending_count DESC;