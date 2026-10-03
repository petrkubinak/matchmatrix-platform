-- ============================================================
-- MATCHMATRIX
-- DATA ACQUISITION CHECKLIST DEFINITION V2
-- VALIDATE_ONLY PRECHECK
--
-- CO:
-- Ověří připravenost databáze pro založení centrální definice
-- automatického Data Acquisition checklistu.
--
-- K ČEMU:
-- Kontroluje:
--   1) kolizi názvu cílového objektu,
--   2) existenci povinných zdrojových auditních objektů,
--   3) existenci všech 14 aktivních sportů,
--   4) podporované stavové kódy návrhu V2,
--   5) základní integritu budoucího modelu.
--
-- KDE:
-- PostgreSQL matchmatrix / schema ops
--
-- JAK:
-- READ ONLY.
-- Nic nevytváří, nemaže ani neupravuje.
--
-- MODE:
-- VALIDATE_ONLY
-- ============================================================


WITH expected_sports AS (
    SELECT *
    FROM (
        VALUES
            ('FB'),
            ('HK'),
            ('BK'),
            ('TN'),
            ('MMA'),
            ('VB'),
            ('HB'),
            ('BSB'),
            ('RGB'),
            ('CK'),
            ('FH'),
            ('AFB'),
            ('ESP'),
            ('DRT')
    ) v(sport_code)
),

required_objects AS (
    SELECT *
    FROM (
        VALUES
            ('ops', 'runtime_entity_audit'),
            ('ops', 'provider_audit_registry'),
            ('ops', 'provider_entity_coverage'),
            ('ops', 'source_coverage_matrix'),
            ('ops', 'source_commercial_model'),
            ('ops', 'source_legal_audit'),
            ('ops', 'sport_completion_audit'),
            ('ops', 'harvest_readiness_snapshot')
    ) v(schema_name, object_name)
),

existing_objects AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
),

object_check AS (
    SELECT
        r.schema_name,
        r.object_name,
        CASE
            WHEN e.object_name IS NOT NULL THEN 'OK'
            ELSE 'MISSING'
        END AS result
    FROM required_objects r
    LEFT JOIN existing_objects e
      ON e.schema_name = r.schema_name
     AND e.object_name = r.object_name
),

target_collision AS (
    SELECT COUNT(*) AS collision_count
    FROM existing_objects
    WHERE schema_name = 'ops'
      AND object_name = 'data_acquisition_checklist_definition'
),

sport_check AS (
    SELECT
        e.sport_code,
        CASE
            WHEN s.code IS NOT NULL THEN 'OK'
            ELSE 'MISSING'
        END AS result
    FROM expected_sports e
    LEFT JOIN public.sports s
      ON s.code = e.sport_code
     AND s.is_active = true
),

v2_codes AS (
    SELECT *
    FROM (
        VALUES
            ('TIME_MODE', 'ALL'),
            ('TIME_MODE', 'HISTORY_FAN'),
            ('TIME_MODE', 'HISTORY_PREDICTION'),
            ('TIME_MODE', 'CURRENT'),
            ('TIME_MODE', 'FUTURE'),
            ('TIME_MODE', 'LIVE'),

            ('REQUIREMENT_LEVEL', 'REQUIRED'),
            ('REQUIREMENT_LEVEL', 'OPTIONAL'),
            ('REQUIREMENT_LEVEL', 'NOT_APPLICABLE'),

            ('GAP_POLICY', 'NOT_ALLOWED'),
            ('GAP_POLICY', 'APPROVED_GAP_ALLOWED'),

            ('CHECK_CODE', 'ENTITY_DEFINED'),
            ('CHECK_CODE', 'COVERAGE'),
            ('CHECK_CODE', 'PRIMARY_PROVIDER'),
            ('CHECK_CODE', 'FALLBACK_PROVIDER'),
            ('CHECK_CODE', 'ENDPOINT'),
            ('CHECK_CODE', 'TECHNICAL_PIPELINE'),
            ('CHECK_CODE', 'CANONICAL_MAPPING'),
            ('CHECK_CODE', 'DATA_QUALITY'),
            ('CHECK_CODE', 'COMMERCIAL'),
            ('CHECK_CODE', 'LEGAL'),
            ('CHECK_CODE', 'SMOKE_TEST'),
            ('CHECK_CODE', 'HISTORICAL_PILOT'),
            ('CHECK_CODE', 'HEALTH_MONITORING'),
            ('CHECK_CODE', 'REFRESH_CADENCE'),
            ('CHECK_CODE', 'EVIDENCE')
    ) v(code_group, code_value)
),

summary AS (
    SELECT
        (SELECT collision_count FROM target_collision) AS target_collision_count,

        (
            SELECT COUNT(*)
            FROM object_check
            WHERE result = 'MISSING'
        ) AS missing_required_objects,

        (
            SELECT COUNT(*)
            FROM sport_check
            WHERE result = 'MISSING'
        ) AS missing_active_sports,

        (
            SELECT COUNT(*)
            FROM v2_codes
        ) AS defined_v2_codes
)

SELECT
    'PRECHECK' AS phase,
    'TARGET_NAME_FREE' AS check_code,
    CASE
        WHEN target_collision_count = 0 THEN 'OK'
        ELSE 'BLOCKED'
    END AS result,
    target_collision_count::text AS actual_value,
    '0' AS expected_value,
    CASE
        WHEN target_collision_count = 0
            THEN 'Cílový název ops.data_acquisition_checklist_definition je volný.'
        ELSE 'Cílový objekt již existuje. APPLY se nesmí spustit.'
    END AS note
FROM summary

UNION ALL

SELECT
    'PRECHECK',
    'REQUIRED_SOURCE_OBJECTS',
    CASE
        WHEN missing_required_objects = 0 THEN 'OK'
        ELSE 'BLOCKED'
    END,
    missing_required_objects::text,
    '0',
    CASE
        WHEN missing_required_objects = 0
            THEN 'Všechny očekávané auditní zdroje existují.'
        ELSE 'Některé zdrojové auditní objekty chybí.'
    END
FROM summary

UNION ALL

SELECT
    'PRECHECK',
    'ACTIVE_SPORTS_14',
    CASE
        WHEN missing_active_sports = 0 THEN 'OK'
        ELSE 'BLOCKED'
    END,
    (14 - missing_active_sports)::text,
    '14',
    CASE
        WHEN missing_active_sports = 0
            THEN 'Všech 14 očekávaných sportů je aktivních.'
        ELSE 'Některý očekávaný sport chybí nebo není aktivní.'
    END
FROM summary

UNION ALL

SELECT
    'PRECHECK',
    'V2_CODESET_DEFINED',
    CASE
        WHEN defined_v2_codes > 0 THEN 'OK'
        ELSE 'BLOCKED'
    END,
    defined_v2_codes::text,
    '>0',
    'Definována sada TIME_MODE, REQUIREMENT_LEVEL, GAP_POLICY a CHECK_CODE.'
FROM summary

ORDER BY check_code;