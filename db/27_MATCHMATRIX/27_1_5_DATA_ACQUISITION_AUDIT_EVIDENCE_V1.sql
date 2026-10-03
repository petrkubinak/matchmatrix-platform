-- ============================================================
-- MATCHMATRIX
-- DATA ACQUISITION AUDIT EVIDENCE V1
--
-- CO:
-- Jednotná normalizační vrstva existujících auditních důkazů.
--
-- K ČEMU:
-- Převádí různé auditní tabulky do jednoho formátu.
-- NEPROVÁDÍ ještě mapování na checklist time_mode ani finální gate.
--
-- KDE:
-- ops.v_data_acquisition_audit_evidence_v1
--
-- JAK:
-- CREATE OR REPLACE VIEW
--
-- MODE:
-- APPLY
-- ============================================================

CREATE OR REPLACE VIEW ops.v_data_acquisition_audit_evidence_v1 AS

SELECT
    'provider_entity_coverage'::text AS evidence_source,
    p.id AS evidence_id,
    p.sport_code,
    lower(p.entity) AS entity,
    p.provider AS source_name,
    'COVERAGE'::text AS check_code,
    p.coverage_status AS raw_status,

    CASE lower(p.coverage_status)
        WHEN 'runtime_tested' THEN 'CONFIRMED'
        WHEN 'verified'       THEN 'CONFIRMED'
        WHEN 'partial'        THEN 'PARTIAL'
        WHEN 'planned'        THEN 'PLANNED'
        WHEN 'blocked'        THEN 'BLOCKED'
        ELSE 'UNKNOWN'
    END AS normalized_status,

    p.availability_scope AS source_scope,
    NULL::text AS time_mode,
    p.updated_at AS evidence_at,

    concat_ws(
        ' | ',
        CASE
            WHEN p.quality_rating IS NOT NULL
            THEN 'quality=' || p.quality_rating
        END,
        CASE
            WHEN p.expected_depth IS NOT NULL
            THEN 'depth=' || p.expected_depth
        END,
        p.limitations,
        p.notes,
        p.next_action
    ) AS evidence_note

FROM ops.provider_entity_coverage p


UNION ALL


SELECT
    'source_coverage_matrix',
    s.coverage_id,
    s.sport_code,
    lower(s.entity_type),
    s.source_name,
    'COVERAGE',
    s.coverage_status,

    CASE upper(s.coverage_status)
        WHEN 'VERIFIED' THEN 'CONFIRMED'
        WHEN 'PARTIAL'  THEN 'PARTIAL'
        WHEN 'PLANNED'  THEN 'PLANNED'
        WHEN 'BLOCKED'  THEN 'BLOCKED'
        ELSE 'UNKNOWN'
    END,

    s.coverage_domain,
    NULL::text,
    s.updated_at,

    concat_ws(
        ' | ',
        CASE
            WHEN s.coverage_score IS NOT NULL
            THEN 'coverage_score=' || s.coverage_score::text
        END,
        CASE
            WHEN s.quality_score IS NOT NULL
            THEN 'quality_score=' || s.quality_score::text
        END,
        CASE
            WHEN s.history_depth_score IS NOT NULL
            THEN 'history_depth_score=' || s.history_depth_score::text
        END,
        s.evidence_note,
        s.next_action
    )

FROM ops.source_coverage_matrix s


UNION ALL


SELECT
    'source_commercial_model',
    c.commercial_id,
    c.sport_code,
    NULL::text,
    c.source_name,
    'COMMERCIAL',
    c.current_status,

    CASE upper(c.current_status)
        WHEN 'VERIFIED'          THEN 'CONFIRMED'
        WHEN 'APPROVED'          THEN 'CONFIRMED'
        WHEN 'RESEARCH_REQUIRED' THEN 'REVIEW_REQUIRED'
        WHEN 'REVIEW_REQUIRED'   THEN 'REVIEW_REQUIRED'
        WHEN 'BLOCKED'           THEN 'BLOCKED'
        ELSE 'UNKNOWN'
    END,

    c.pricing_model,
    NULL::text,
    c.updated_at,

    concat_ws(
        ' | ',
        CASE
            WHEN c.free_available IS NOT NULL
            THEN 'free=' || c.free_available::text
        END,
        CASE
            WHEN c.paid_available IS NOT NULL
            THEN 'paid=' || c.paid_available::text
        END,
        CASE
            WHEN c.historical_access IS NOT NULL
            THEN 'history=' || c.historical_access::text
        END,
        CASE
            WHEN c.historical_from_year IS NOT NULL
            THEN 'history_from=' || c.historical_from_year::text
        END,
        CASE
            WHEN c.recommended_plan IS NOT NULL
            THEN 'plan=' || c.recommended_plan
        END,
        c.notes
    )

FROM ops.source_commercial_model c


UNION ALL


SELECT
    'source_legal_audit',
    l.legal_audit_id,
    l.sport_code,
    NULL::text,
    l.source_name,
    'LEGAL',

    concat_ws(
        '/',
        l.legal_risk_level,
        l.scraping_status,
        l.commercial_use_status
    ),

    CASE
        WHEN upper(COALESCE(l.scraping_status, '')) = 'BLOCKED'
          OR upper(COALESCE(l.commercial_use_status, '')) = 'BLOCKED'
            THEN 'BLOCKED'

        WHEN upper(COALESCE(l.scraping_status, '')) = 'REVIEW_REQUIRED'
          OR upper(COALESCE(l.commercial_use_status, '')) = 'REVIEW_REQUIRED'
          OR upper(COALESCE(l.terms_status, '')) = 'REVIEW_REQUIRED'
            THEN 'REVIEW_REQUIRED'

        WHEN upper(COALESCE(l.scraping_status, '')) IN ('PASS', 'APPROVED', 'ALLOWED')
         AND upper(COALESCE(l.commercial_use_status, '')) IN ('PASS', 'APPROVED', 'ALLOWED')
            THEN 'CONFIRMED'

        ELSE 'UNKNOWN'
    END,

    l.legal_risk_level,
    NULL::text,
    l.updated_at,

    concat_ws(
        ' | ',
        l.evidence_note,
        l.next_action
    )

FROM ops.source_legal_audit l


UNION ALL


SELECT
    'runtime_entity_audit',
    r.id,
    r.sport_code,
    lower(r.entity),
    r.provider,
    'TECHNICAL_PIPELINE',
    r.current_state,

    CASE upper(r.current_state)
        WHEN 'CONFIRMED' THEN 'CONFIRMED'
        WHEN 'RUNNABLE'  THEN 'CONFIRMED'
        WHEN 'PARTIAL'   THEN 'PARTIAL'
        WHEN 'PLANNED'   THEN 'PLANNED'
        WHEN 'BLOCKED'   THEN 'BLOCKED'
        ELSE 'UNKNOWN'
    END,

    r.last_run_group,
    NULL::text,
    COALESCE(
        r.last_check_at,
        r.last_run_at,
        r.updated_at
    ),

    concat_ws(
        ' | ',
        r.state_reason,
        r.last_log_summary,
        r.db_evidence_summary,
        r.next_action,
        r.audit_note
    )

FROM ops.runtime_entity_audit r;