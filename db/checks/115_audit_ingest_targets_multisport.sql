-- =========================================================
-- 115_audit_ingest_targets_multisport.sql
-- Audit reálného pokrytí ops.ingest_targets pro multisport
-- =========================================================

WITH expected_sports AS (
    SELECT *
    FROM (
        VALUES
            ('FB',  'football'),
            ('HK',  'hockey'),
            ('BK',  'basketball'),
            ('TN',  'tennis'),
            ('MMA', 'mma'),
            ('DRT', 'darts'),
            ('VB',  'volleyball'),
            ('HB',  'handball'),
            ('BSB', 'baseball'),
            ('RGB', 'rugby'),
            ('CK',  'cricket'),
            ('FH',  'field_hockey'),
            ('AFB', 'american_football'),
            ('ESP', 'esports')
    ) AS t(sport_code, sport_key)
),
targets AS (
    SELECT
        sport_code,
        COUNT(*) AS targets_total,
        COUNT(*) FILTER (WHERE enabled = TRUE) AS targets_enabled,
        COUNT(DISTINCT provider) AS providers_count,
        COUNT(DISTINCT canonical_league_id) AS canonical_leagues_count,
        COUNT(DISTINCT provider_league_id) AS provider_leagues_count
    FROM ops.ingest_targets
    GROUP BY sport_code
)
SELECT
    e.sport_code,
    e.sport_key,
    COALESCE(t.targets_total, 0) AS targets_total,
    COALESCE(t.targets_enabled, 0) AS targets_enabled,
    COALESCE(t.providers_count, 0) AS providers_count,
    COALESCE(t.canonical_leagues_count, 0) AS canonical_leagues_count,
    COALESCE(t.provider_leagues_count, 0) AS provider_leagues_count,
    CASE
        WHEN COALESCE(t.targets_total, 0) = 0 THEN 'MISSING_TARGETS'
        WHEN COALESCE(t.targets_enabled, 0) = 0 THEN 'ONLY_DISABLED'
        ELSE 'OK'
    END AS target_status
FROM expected_sports e
LEFT JOIN targets t
       ON t.sport_code = e.sport_code
ORDER BY e.sport_code;