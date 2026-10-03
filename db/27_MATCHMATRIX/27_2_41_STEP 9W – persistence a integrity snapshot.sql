/*
CO:
STEP 9W – EXACT COVERAGE PERSISTENCE + INTEGRITY SNAPSHOT

K ČEMU:
Po STEP 9V potvrdit committed stav nového registru
a ověřit, že nebyla překročena žádná governance hranice.

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. TABULKA EXISTUJE
   ========================================================= */

SELECT
    to_regclass(
        'ops.source_entity_time_scope_coverage'
    ) AS exact_scope_registry;


/* =========================================================
   2. EXACT SCOPE DATA
   ========================================================= */

SELECT
    d.scope_coverage_id,
    d.coverage_id,

    c.source_id,
    sm.canonical_name,

    c.sport_code,
    c.layer_type,
    c.entity,
    c.time_mode,
    c.coverage_status AS parent_coverage_status,

    d.scope_type,
    d.scope_key,

    d.canonical_league_id,
    l.name AS canonical_league_name,

    d.canonical_season_id,
    d.source_competition_key,
    d.source_season_key,
    d.season_resolution_status,

    d.scope_status,
    d.audit_evidence_id,
    d.tested_at,
    d.is_active

FROM ops.source_entity_time_scope_coverage d

JOIN ops.source_entity_time_coverage c
  ON c.coverage_id = d.coverage_id

JOIN ops.source_master sm
  ON sm.source_id = c.source_id

LEFT JOIN public.leagues l
  ON l.id = d.canonical_league_id

ORDER BY
    d.scope_coverage_id;


/* =========================================================
   3. EVIDENCE LINK
   ========================================================= */

SELECT
    d.scope_coverage_id,
    d.audit_evidence_id,

    e.source_id,
    e.audit_dimension,
    e.evidence_key,
    e.evidence_version,
    e.result_status,
    e.evidence_date

FROM ops.source_entity_time_scope_coverage d

JOIN ops.source_audit_evidence e
  ON e.audit_evidence_id = d.audit_evidence_id

ORDER BY
    d.scope_coverage_id;


/* =========================================================
   4. PARENT COVERAGE STÁLE NENÍ CONFIRMED
   ========================================================= */

SELECT
    coverage_id,
    source_id,
    sport_code,
    layer_type,
    entity,
    time_mode,
    coverage_status,
    evidence_status
FROM ops.source_entity_time_coverage
WHERE source_id = 18
ORDER BY coverage_id;


/* =========================================================
   5. SOURCE-ADAPTER BINDING STÁLE NENÍ ACTIVE
   ========================================================= */

SELECT
    source_adapter_binding_id,
    source_id,
    adapter_id,
    sport_code,
    entity,
    binding_status,
    is_active
FROM ops.source_adapter_binding
WHERE source_id = 18
ORDER BY source_adapter_binding_id;


/* =========================================================
   6. ROUTING PRO API-SPORTS STÁLE NENÍ VYTVOŘEN
   ========================================================= */

SELECT *
FROM ops.data_acquisition_source_routing
WHERE source_id = 18;


/* =========================================================
   7. SOUHRN
   ========================================================= */

SELECT
    (SELECT COUNT(*)
     FROM ops.source_entity_time_scope_coverage)
        AS exact_scope_rows,

    (SELECT COUNT(*)
     FROM ops.source_entity_time_coverage
     WHERE source_id = 18)
        AS api_sports_parent_coverage_rows,

    (SELECT COUNT(*)
     FROM ops.source_adapter_binding
     WHERE source_id = 18
       AND is_active = true)
        AS api_sports_active_bindings,

    (SELECT COUNT(*)
     FROM ops.data_acquisition_source_routing
     WHERE source_id = 18)
        AS api_sports_routes;