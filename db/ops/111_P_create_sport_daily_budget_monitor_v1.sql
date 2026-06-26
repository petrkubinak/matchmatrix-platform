/*
MATCHMATRIX SQL 111_P
SPORT DAILY BUDGET MONITOR V1

CO TO JE:
- Přehled denního API budgetu podle sportů.

K ČEMU TO JE:
- Aby historical harvest viděl, kolik requestů každý sport dnes použil.
- Aby automat později nepouštěl sport, který vyčerpal limit.

KDE TO UVIDÍME:
- OPS panel
- AI OPS
- Historical harvest dashboard

JAK SE TO VYUŽIJE:
- řízení denního harvestu
- přepínání sportů po vyčerpání limitu
- kontrola FREE / PRO režimu
*/

CREATE OR REPLACE VIEW ops.v_sport_daily_budget_monitor_v1 AS
SELECT
    abs.sport_code,
    sip.sport_name,
    sip.mode,
    abs.request_day,
    abs.requests_used,
    abs.requests_limit,
    abs.requests_remaining,
    ROUND(
        CASE
            WHEN abs.requests_limit > 0
                THEN (abs.requests_used::numeric / abs.requests_limit::numeric) * 100
            ELSE 0
        END,
        2
    ) AS used_pct,
    CASE
        WHEN abs.requests_remaining <= 0 THEN 'LIMIT_VYCERPAN'
        WHEN abs.requests_remaining <= GREATEST(5, abs.requests_limit * 0.1) THEN 'DOCHAZI_LIMIT'
        ELSE 'OK'
    END AS budget_status,
    abs.last_updated
FROM ops.api_budget_status abs
LEFT JOIN ops.sports_import_plan sip
    ON LOWER(sip.sport_code) = LOWER(abs.sport_code)
WHERE abs.request_day = CURRENT_DATE
ORDER BY
    used_pct DESC,
    abs.sport_code;