/*
MATCHMATRIX SQL 108_H
Grouped Runtime Alerts V1
*/

CREATE OR REPLACE VIEW ops.v_runtime_alerts_grouped_v1 AS
SELECT
    alert_type,
    source_object,
    alert_category,
    alert_severity,
    alert_color,

    COUNT(*) AS alert_count,
    MAX(alert_time) AS last_alert_time,
    MIN(alert_time) AS first_alert_time,

    MAX(alert_message) AS last_alert_message

FROM ops.v_runtime_alerts_v1
GROUP BY
    alert_type,
    source_object,
    alert_category,
    alert_severity,
    alert_color
ORDER BY
    MAX(alert_time) DESC,
    COUNT(*) DESC;