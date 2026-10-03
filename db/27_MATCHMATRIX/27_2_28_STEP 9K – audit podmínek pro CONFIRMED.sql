/*
CO:
STEP 9K – API-SPORTS HB COVERAGE CONFIRMATION READINESS AUDIT

K ČEMU:
Zjistit, zda jsou kromě runtime testu k dispozici také
legal / commercial / quality / discovery / legacy coverage důkazy,
které mohou podpořit budoucí přechod:

RUNTIME_TESTED -> CONFIRMED

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
Žádný INSERT / UPDATE / DELETE / DDL.
*/


-- =========================================================
-- 1. AKTUÁLNÍ CANONICAL COVERAGE
-- =========================================================

SELECT
    c.*,
    s.canonical_name
FROM ops.source_entity_time_coverage c
JOIN ops.source_master s
  ON s.source_id = c.source_id
WHERE c.source_id = 18
  AND c.sport_code = 'HB'
ORDER BY
    c.layer_type,
    c.entity,
    c.time_mode;


/* =========================================================
   2. PERSISTENTNÍ RUNTIME DŮKAZ
   ========================================================= */

SELECT
    *
FROM ops.source_audit_evidence
WHERE source_id = 18
ORDER BY audit_evidence_id;


/* =========================================================
   3. INVENTORY SPECIALIZOVANÝCH SOURCE AUDIT TABULEK
   ========================================================= */

SELECT
    table_name,
    COUNT(*) OVER () AS found_objects
FROM information_schema.tables
WHERE table_schema = 'ops'
  AND table_name IN (
      'source_legal_audit',
      'source_commercial_model',
      'source_quality_score',
      'source_discovery_audit_tracker',
      'source_coverage_matrix',
      'provider_entity_coverage'
  )
ORDER BY table_name;


/* =========================================================
   4. JEJICH FYZICKÉ SLOUPCE
   ========================================================= */

SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name IN (
      'source_legal_audit',
      'source_commercial_model',
      'source_quality_score',
      'source_discovery_audit_tracker',
      'source_coverage_matrix',
      'provider_entity_coverage'
  )
ORDER BY
    table_name,
    ordinal_position;


/* =========================================================
   5. LEGAL – API-SPORTS / API_HANDALL / HB
   ========================================================= */

SELECT
    to_jsonb(x) AS legal_evidence
FROM ops.source_legal_audit x
WHERE to_jsonb(x)::text ILIKE '%api-sports%'
   OR to_jsonb(x)::text ILIKE '%api_sports%'
   OR to_jsonb(x)::text ILIKE '%api_handball%'
ORDER BY 1;


/* =========================================================
   6. COMMERCIAL
   ========================================================= */

SELECT
    to_jsonb(x) AS commercial_evidence
FROM ops.source_commercial_model x
WHERE to_jsonb(x)::text ILIKE '%api-sports%'
   OR to_jsonb(x)::text ILIKE '%api_sports%'
   OR to_jsonb(x)::text ILIKE '%api_handball%'
ORDER BY 1;


/* =========================================================
   7. QUALITY
   ========================================================= */

SELECT
    to_jsonb(x) AS quality_evidence
FROM ops.source_quality_score x
WHERE to_jsonb(x)::text ILIKE '%api-sports%'
   OR to_jsonb(x)::text ILIKE '%api_sports%'
   OR to_jsonb(x)::text ILIKE '%api_handball%'
ORDER BY 1;


/* =========================================================
   8. DISCOVERY / TECHNICAL AUDIT
   ========================================================= */

SELECT
    to_jsonb(x) AS discovery_evidence
FROM ops.source_discovery_audit_tracker x
WHERE to_jsonb(x)::text ILIKE '%api-sports%'
   OR to_jsonb(x)::text ILIKE '%api_sports%'
   OR to_jsonb(x)::text ILIKE '%api_handball%'
ORDER BY 1;


/* =========================================================
   9. LEGACY SOURCE COVERAGE MATRIX

   Pouze jako evidence.
   NESMÍ se automaticky překlopit do canonical coverage.
   ========================================================= */

SELECT
    to_jsonb(x) AS legacy_source_coverage
FROM ops.source_coverage_matrix x
WHERE to_jsonb(x)::text ILIKE '%api-sports%'
   OR to_jsonb(x)::text ILIKE '%api_sports%'
   OR to_jsonb(x)::text ILIKE '%api_handball%'
ORDER BY 1;


/* =========================================================
   10. LEGACY PROVIDER ENTITY COVERAGE

   Opět pouze podpůrný důkaz.
   ========================================================= */

SELECT
    to_jsonb(x) AS legacy_provider_coverage
FROM ops.provider_entity_coverage x
WHERE to_jsonb(x)::text ILIKE '%api_handball%'
ORDER BY 1;