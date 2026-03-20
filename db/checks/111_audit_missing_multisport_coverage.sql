-- =========================================================
-- 111_audit_missing_multisport_coverage.sql
-- Audit: které sporty už máme v OPS a které ještě chybí
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
)
SELECT
    e.sport_code,
    e.sport_key,
    CASE WHEN s.code IS NOT NULL THEN TRUE ELSE FALSE END AS exists_in_public_sports,
    CASE WHEN ser.sport_code IS NOT NULL THEN TRUE ELSE FALSE END AS exists_in_sport_entity_rules,
    CASE WHEN sdr.sport_code IS NOT NULL THEN TRUE ELSE FALSE END AS exists_in_sport_dimension_rules,
    CASE WHEN psm.sport_code IS NOT NULL THEN TRUE ELSE FALSE END AS exists_in_provider_sport_matrix,
    CASE WHEN iep.sport_code IS NOT NULL THEN TRUE ELSE FALSE END AS exists_in_ingest_entity_plan
FROM expected_sports e
LEFT JOIN public.sports s
       ON s.code = e.sport_code
LEFT JOIN (SELECT DISTINCT sport_code FROM ops.sport_entity_rules) ser
       ON ser.sport_code = e.sport_code
LEFT JOIN (SELECT DISTINCT sport_code FROM ops.sport_dimension_rules) sdr
       ON sdr.sport_code = e.sport_code
LEFT JOIN (SELECT DISTINCT sport_code FROM ops.provider_sport_matrix) psm
       ON psm.sport_code = e.sport_code
LEFT JOIN (SELECT DISTINCT sport_code FROM ops.ingest_entity_plan) iep
       ON iep.sport_code = e.sport_code
ORDER BY e.sport_code;