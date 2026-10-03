/* =============================================================================
CO:
    HB SOURCE EVIDENCE INVENTORY
    STEP 1 — READ ONLY FACT INVENTORY

K ČEMU:
    Shromáždí existující důkazy pro sport HB bez vytváření jakékoliv nové vazby.

    Kontrolované vrstvy:
      - canonical source identity
      - source ↔ sport
      - canonical audit evidence
      - runtime adapters
      - provider sport registry
      - provider entity coverage
      - provider workers
      - provider jobs
      - legacy source coverage evidence
      - existing canonical binding / coverage / routing

KDE:
    PostgreSQL
    database: matchmatrix
    sport: HB

BEZPEČNOST:
    - pouze SELECT
    - žádný INSERT
    - žádný UPDATE
    - žádný DELETE
    - žádný ALTER
    - žádný APPLY

ZÁSADNÍ PRAVIDLO:
    Shodný sport nebo podobný název NENÍ důkaz source ↔ adapter bindingu.
============================================================================= */


/* ============================================================================
1. HB CANONICAL SOURCES
   Co je explicitně evidováno v SOURCE_SPORT.
============================================================================ */

SELECT
    sm.source_id,
    sm.source_code,
    sm.canonical_name,
    sm.source_type,
    sm.lifecycle_status,
    sm.canonical_domain,
    ss.sport_code,
    ss.relationship_status,
    ss.sport_specific_url,
    ss.notes
FROM ops.source_sport ss
JOIN ops.source_master sm
  ON sm.source_id = ss.source_id
WHERE ss.sport_code = 'HB'
ORDER BY sm.source_id;


/* ============================================================================
2. HB SOURCE ALIASES

   Alias je identitní důkaz.
   Není to důkaz runtime adapter bindingu.
============================================================================ */

SELECT
    sm.source_id,
    sm.source_code,
    sm.canonical_name,
    sa.source_alias_id,
    sa.alias_type,
    sa.alias_value,
    sa.normalized_alias,
    sa.is_preferred,
    sa.valid_from,
    sa.valid_to,
    sa.evidence_ref
FROM ops.source_sport ss
JOIN ops.source_master sm
  ON sm.source_id = ss.source_id
JOIN ops.source_alias sa
  ON sa.source_id = sm.source_id
WHERE ss.sport_code = 'HB'
ORDER BY
    sm.source_id,
    sa.alias_type,
    sa.normalized_alias;


/* ============================================================================
3. HB CANONICAL AUDIT EVIDENCE

   Zobrazí všechny canonical audit evidence rows patřící zdrojům,
   které mají explicitní SOURCE_SPORT vztah k HB.
============================================================================ */

SELECT
    sm.source_id,
    sm.source_code,
    sm.canonical_name,
    sae.audit_evidence_id,
    sae.audit_dimension,
    sae.evidence_key,
    sae.evidence_version,
    sae.result_status,
    sae.evidence_date,
    sae.evidence_url,
    sae.result_detail,
    sae.valid_until,
    sae.reviewer,
    sae.evidence_hash
FROM ops.source_sport ss
JOIN ops.source_master sm
  ON sm.source_id = ss.source_id
JOIN ops.source_audit_evidence sae
  ON sae.source_id = sm.source_id
WHERE ss.sport_code = 'HB'
ORDER BY
    sm.source_id,
    sae.audit_dimension,
    sae.audit_evidence_id;


/* ============================================================================
4. HB PROVIDER SPORT MATRIX + RUNTIME ADAPTER

   Explicitně zjišťujeme pouze:
       provider
       ↔ sport HB
       ↔ runtime adapter stejného technického provider code

   POZOR:
   ani tento exact provider ↔ adapter match NENÍ source binding.
============================================================================ */

SELECT
    psm.id AS provider_sport_matrix_id,
    psm.provider,
    psm.sport_code,
    psm.sport_name,
    psm.is_enabled,

    psm.supports_leagues,
    psm.supports_teams,
    psm.supports_fixtures,
    psm.supports_players,
    psm.supports_player_stats,
    psm.supports_odds,
    psm.supports_coaches,
    psm.supports_standings,

    psm.notes AS provider_sport_notes,

    ra.adapter_id,
    ra.adapter_code,
    ra.adapter_type,
    ra.runtime_status,
    ra.provider_class,
    ra.base_worker,
    ra.account_ref,
    ra.notes AS adapter_notes,

    CASE
        WHEN ra.adapter_id IS NOT NULL
            THEN 'EXPLICITLY_EVIDENCED_RUNTIME_ADAPTER'
        ELSE 'HOLD_RUNTIME_ADAPTER_NOT_FOUND'
    END AS classification

FROM ops.provider_sport_matrix psm

LEFT JOIN ops.runtime_adapter ra
  ON ra.adapter_code = psm.provider

WHERE psm.sport_code = 'HB'

ORDER BY
    psm.provider;


/* ============================================================================
5. HB PROVIDER ENTITY COVERAGE

   Toto jsou legacy provider/runtime coverage fakta.

   Záměrně zde NEVYTVÁŘÍME source_id ani time_mode.
============================================================================ */

SELECT
    pec.id AS provider_entity_coverage_id,
    pec.provider,
    pec.sport_code,
    pec.entity,
    pec.coverage_status,
    pec.is_enabled,

    ra.adapter_id,
    ra.adapter_code,
    ra.runtime_status,

    CASE
        WHEN ra.adapter_id IS NULL
            THEN 'HOLD_RUNTIME_ADAPTER_NOT_FOUND'

        WHEN sab.source_adapter_binding_id IS NOT NULL
            THEN 'EXPLICITLY_EVIDENCED_BINDING'

        ELSE 'HOLD_NO_SOURCE_ADAPTER_BINDING'
    END AS binding_classification,

    CASE
        WHEN sab.source_adapter_binding_id IS NULL
            THEN NULL
        ELSE sab.source_id
    END AS bound_source_id,

    to_jsonb(pec) AS legacy_coverage_record

FROM ops.provider_entity_coverage pec

LEFT JOIN ops.runtime_adapter ra
  ON ra.adapter_code = pec.provider

LEFT JOIN ops.source_adapter_binding sab
  ON sab.adapter_id = ra.adapter_id
 AND sab.is_active = true
 AND (
        sab.sport_code IS NULL
        OR sab.sport_code = pec.sport_code
     )
 AND (
        sab.entity IS NULL
        OR sab.entity = pec.entity
     )

WHERE pec.sport_code = 'HB'

ORDER BY
    pec.provider,
    pec.entity,
    pec.id;


/* ============================================================================
6. HB PROVIDER WORKERS

   Technická evidence skutečně registrovaných workerů.

   Worker existence:
       != source identity
       != source binding
       != coverage confirmation
============================================================================ */

SELECT
    to_jsonb(pwr) AS provider_worker_record
FROM ops.provider_worker_registry pwr
WHERE pwr.sport_code = 'HB'
ORDER BY
    pwr.provider,
    pwr.entity,
    pwr.id;


/* ============================================================================
7. HB PROVIDER JOBS

   Zde sledujeme zejména:
       provider
       endpoint
       ingest_mode
       days_back
       days_forward

   Tyto hodnoty mohou později pomoci s time-mode evidence,
   ale samy o sobě zatím NEVYTVÁŘEJÍ canonical coverage.
============================================================================ */

SELECT
    pj.id,
    pj.provider,
    pj.sport_code,
    pj.job_code,
    pj.endpoint_code,
    pj.ingest_mode,
    pj.enabled,
    pj.priority,
    pj.batch_size,
    pj.max_requests_per_run,
    pj.retry_limit,
    pj.cooldown_seconds,
    pj.days_back,
    pj.days_forward,
    pj.notes,
    pj.created_at,
    pj.updated_at
FROM ops.provider_jobs pj
WHERE pj.sport_code = 'HB'
ORDER BY
    pj.provider,
    pj.job_code,
    pj.id;


/* ============================================================================
8. HB LEGACY SOURCE COVERAGE MATRIX

   Source name smíme rozpoznat přes canonical SOURCE_ALIAS.
   Coverage ale stále nesmí dostat exact time_mode odhadem.
============================================================================ */

SELECT
    scm.coverage_id,
    scm.source_name,
    scm.sport_code,
    scm.coverage_domain,
    scm.entity_type,
    scm.coverage_status,
    scm.coverage_score,
    scm.quality_score,
    scm.history_depth_score,
    scm.automation_score,
    scm.free_available,
    scm.paid_required,
    scm.legal_status,
    scm.commercial_status,
    scm.evidence_note,
    scm.next_action,

    sa.source_id AS resolved_source_id,
    sm.source_code AS resolved_source_code,
    sm.canonical_name AS resolved_canonical_name,

    CASE
        WHEN sa.source_id IS NULL
            THEN 'HOLD_SOURCE_ID_UNRESOLVED'

        WHEN scm.coverage_domain = 'HISTORY'
            THEN 'HOLD_HISTORY_TIME_MODE_AMBIGUOUS'

        ELSE 'HOLD_NO_EXACT_TIME_MODE'
    END AS classification

FROM ops.source_coverage_matrix scm

LEFT JOIN ops.source_alias sa
  ON sa.alias_type = 'SOURCE_NAME'
 AND sa.valid_to IS NULL
 AND sa.normalized_alias =
     lower(
         regexp_replace(
             btrim(scm.source_name),
             '\s+',
             ' ',
             'g'
         )
     )

LEFT JOIN ops.source_master sm
  ON sm.source_id = sa.source_id

WHERE scm.sport_code = 'HB'

ORDER BY
    scm.coverage_id;


/* ============================================================================
9. EXISTING CANONICAL HB BINDINGS

   Očekáváme 0.
============================================================================ */

SELECT
    sab.source_adapter_binding_id,
    sab.source_id,
    sm.source_code,
    sm.canonical_name,
    sab.adapter_id,
    ra.adapter_code,
    sab.sport_code,
    sab.entity,
    sab.binding_status,
    sab.is_active,
    sab.account_id,
    sab.worker_binding_id,
    sab.notes
FROM ops.source_adapter_binding sab

JOIN ops.source_master sm
  ON sm.source_id = sab.source_id

JOIN ops.runtime_adapter ra
  ON ra.adapter_id = sab.adapter_id

WHERE sab.sport_code = 'HB'
   OR sab.sport_code IS NULL

ORDER BY
    sab.source_id,
    sab.adapter_id,
    sab.entity;


/* ============================================================================
10. EXISTING CANONICAL HB COVERAGE

    Očekáváme 0.
============================================================================ */

SELECT
    c.coverage_id,
    c.source_id,
    sm.source_code,
    sm.canonical_name,
    c.sport_code,
    c.layer_type,
    c.entity,
    c.time_mode,
    c.coverage_status,
    c.history_from,
    c.history_to,
    c.quality_level,
    c.evidence_status,
    c.tested_at,
    c.notes
FROM ops.source_entity_time_coverage c

JOIN ops.source_master sm
  ON sm.source_id = c.source_id

WHERE c.sport_code = 'HB'

ORDER BY
    c.source_id,
    c.layer_type,
    c.entity,
    c.time_mode;


/* ============================================================================
11. EXISTING CANONICAL HB ROUTING

    Očekáváme 0.
============================================================================ */

SELECT
    r.route_id,
    r.sport_code,
    r.layer_type,
    r.entity,
    r.time_mode,
    r.source_role,
    r.source_id,
    sm.source_code,
    sm.canonical_name,
    r.route_priority,
    r.decision_status,
    r.decision_note,
    r.approved_by,
    r.approved_at,
    r.is_active
FROM ops.data_acquisition_source_routing r

JOIN ops.source_master sm
  ON sm.source_id = r.source_id

WHERE r.sport_code = 'HB'

ORDER BY
    r.layer_type,
    r.entity,
    r.time_mode,
    r.source_role,
    r.route_priority;


/* ============================================================================
12. HB SOURCE ↔ ADAPTER READINESS MATRIX

    Toto je klíčový bezpečnostní výstup.

    Pokud explicitní SOURCE_ADAPTER_BINDING neexistuje, samotná skutečnost,
    že source i adapter patří k HB, nestačí.

    Proto jsou takové kombinace AMBIGUOUS, nikoli READY.
============================================================================ */

WITH hb_sources AS (
    SELECT
        sm.source_id,
        sm.source_code,
        sm.canonical_name
    FROM ops.source_sport ss
    JOIN ops.source_master sm
      ON sm.source_id = ss.source_id
    WHERE ss.sport_code = 'HB'
),

hb_adapters AS (
    SELECT DISTINCT
        ra.adapter_id,
        ra.adapter_code,
        ra.runtime_status
    FROM ops.provider_sport_matrix psm
    JOIN ops.runtime_adapter ra
      ON ra.adapter_code = psm.provider
    WHERE psm.sport_code = 'HB'
),

matrix AS (
    SELECT
        s.source_id,
        s.source_code,
        s.canonical_name,

        a.adapter_id,
        a.adapter_code,
        a.runtime_status,

        sab.source_adapter_binding_id,
        sab.binding_status,
        sab.is_active

    FROM hb_sources s
    CROSS JOIN hb_adapters a

    LEFT JOIN ops.source_adapter_binding sab
      ON sab.source_id = s.source_id
     AND sab.adapter_id = a.adapter_id
     AND sab.is_active = true
     AND (
            sab.sport_code IS NULL
            OR sab.sport_code = 'HB'
         )
)

SELECT
    source_id,
    source_code,
    canonical_name,
    adapter_id,
    adapter_code,
    runtime_status,

    CASE
        WHEN source_adapter_binding_id IS NOT NULL
            THEN 'EXPLICITLY_EVIDENCED'

        ELSE 'AMBIGUOUS'
    END AS classification,

    CASE
        WHEN source_adapter_binding_id IS NOT NULL
            THEN 'Existing canonical SOURCE_ADAPTER_BINDING.'

        ELSE
            'Source and adapter both relate to HB, but no explicit source-adapter binding exists.'
    END AS reason

FROM matrix

ORDER BY
    source_id,
    adapter_id;


/* ============================================================================
13. FINAL SUMMARY
============================================================================ */

SELECT *
FROM (

    SELECT
        10 AS sort_order,
        'HB_CANONICAL_SOURCES' AS check_id,
        COUNT(*)::text AS value,
        'EXPLICITLY_EVIDENCED source↔sport relations' AS interpretation
    FROM ops.source_sport
    WHERE sport_code = 'HB'


    UNION ALL


    SELECT
        20,
        'HB_PROVIDER_SPORT_ROWS',
        COUNT(*)::text,
        'legacy/runtime provider↔sport facts'
    FROM ops.provider_sport_matrix
    WHERE sport_code = 'HB'


    UNION ALL


    SELECT
        30,
        'HB_PROVIDER_ENTITY_COVERAGE_ROWS',
        COUNT(*)::text,
        'legacy entity coverage facts; no exact time_mode implied'
    FROM ops.provider_entity_coverage
    WHERE sport_code = 'HB'


    UNION ALL


    SELECT
        40,
        'HB_PROVIDER_WORKERS',
        COUNT(*)::text,
        'registered worker facts'
    FROM ops.provider_worker_registry
    WHERE sport_code = 'HB'


    UNION ALL


    SELECT
        50,
        'HB_PROVIDER_JOBS',
        COUNT(*)::text,
        'configured job facts'
    FROM ops.provider_jobs
    WHERE sport_code = 'HB'


    UNION ALL


    SELECT
        60,
        'HB_SOURCE_COVERAGE_EVIDENCE_ROWS',
        COUNT(*)::text,
        'legacy source coverage evidence'
    FROM ops.source_coverage_matrix
    WHERE sport_code = 'HB'


    UNION ALL


    SELECT
        70,
        'HB_CANONICAL_BINDINGS',
        COUNT(*)::text,
        CASE
            WHEN COUNT(*) = 0
                THEN 'HOLD — no canonical source↔adapter binding'
            ELSE 'REVIEW'
        END
    FROM ops.source_adapter_binding
    WHERE sport_code = 'HB'
       OR sport_code IS NULL


    UNION ALL


    SELECT
        80,
        'HB_CANONICAL_COVERAGE',
        COUNT(*)::text,
        CASE
            WHEN COUNT(*) = 0
                THEN 'HOLD — exact source/entity/time coverage not established'
            ELSE 'REVIEW'
        END
    FROM ops.source_entity_time_coverage
    WHERE sport_code = 'HB'


    UNION ALL


    SELECT
        90,
        'HB_CANONICAL_ROUTING',
        COUNT(*)::text,
        CASE
            WHEN COUNT(*) = 0
                THEN 'PASS_EXPECTED — no route without confirmed coverage'
            ELSE 'REVIEW'
        END
    FROM ops.data_acquisition_source_routing
    WHERE sport_code = 'HB'


    UNION ALL


    SELECT
        100,
        'HB_STEP1_STATUS',
        'READ_ONLY_COMPLETE',
        'Facts inventoried only; no binding, coverage or routing created.'

) q

ORDER BY sort_order;