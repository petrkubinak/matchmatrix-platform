/* =============================================================================
CO:
    G4D-3_STEP 4D SAFE SEED PROVENANCE PRECHECK

K ČEMU:
    Získá skutečné zdrojové řádky potřebné pro vytvoření fyzického
    VALIDATE_ONLY seedu bez domýšlení hodnot.

    Zaměřuje se pouze na:
      - canonical source identity evidence,
      - audit evidence,
      - runtime adapter inventory,
      - provider accounts / worker / jobs evidence.

KDE:
    PostgreSQL matchmatrix / PC2

JAK:
    Spustit celý skript.
    Výsledkem je JEDNA tabulka:
        section
        object_name
        row_no
        detail

BEZPEČNOST:
    - pouze SELECT
    - žádný CREATE
    - žádný ALTER
    - žádný INSERT
    - žádný UPDATE
    - žádný DELETE
============================================================================= */


WITH report AS (

/* ============================================================================
01. EXISTENCE ZDROJOVÝCH OBJEKTŮ
============================================================================ */

SELECT
    10 AS sort_group,
    ROW_NUMBER() OVER (ORDER BY x.object_name)::bigint AS sort_item,
    '01_OBJECT_EXISTENCE'::text AS section,
    x.object_name::text AS object_name,
    NULL::bigint AS row_no,
    CASE
        WHEN to_regclass(x.object_name) IS NOT NULL
            THEN 'FOUND'
        ELSE
            'NOT_FOUND'
    END::text AS detail
FROM (
    VALUES
        ('ops.global_source_registry'),
        ('ops.source_discovery_master'),
        ('ops.source_discovery_audit_tracker'),
        ('ops.source_commercial_model'),
        ('ops.source_legal_audit'),
        ('ops.source_activation_roadmap'),
        ('ops.source_intelligence_map'),
        ('ops.source_quality_score'),
        ('ops.source_coverage_matrix'),
        ('ops.provider_worker_registry'),
        ('ops.provider_jobs'),
        ('ops.provider_accounts'),
        ('ops.provider_entity_coverage'),
        ('ops.provider_sport_matrix'),
        ('ops.source_verification_log'),
        ('ops.source_review_results')
) AS x(object_name)


UNION ALL


/* ============================================================================
02. FYZICKÉ SLOUPCE – SOURCE / EVIDENCE / RUNTIME OBJEKTY
============================================================================ */

SELECT
    20,
    ROW_NUMBER() OVER (
        ORDER BY c.table_name, c.ordinal_position
    )::bigint,
    '02_COLUMN'::text,
    ('ops.' || c.table_name)::text,
    c.ordinal_position::bigint,
    concat(
        'column=', c.column_name,
        ' | type=', c.data_type,
        ' | udt=', c.udt_name,
        ' | nullable=', c.is_nullable,
        ' | default=', COALESCE(c.column_default, '<NULL>'),
        ' | identity=', c.is_identity
    )::text
FROM information_schema.columns c
WHERE c.table_schema = 'ops'
  AND c.table_name IN (
      'global_source_registry',
      'source_discovery_master',
      'source_discovery_audit_tracker',
      'source_commercial_model',
      'source_legal_audit',
      'source_activation_roadmap',
      'source_intelligence_map',
      'source_quality_score',
      'source_coverage_matrix',
      'provider_worker_registry',
      'provider_jobs',
      'provider_accounts',
      'provider_entity_coverage',
      'provider_sport_matrix',
      'source_verification_log',
      'source_review_results'
  )


UNION ALL


/* ============================================================================
03. GLOBAL SOURCE REGISTRY – CELÝ OBSAH
============================================================================ */

SELECT
    30,
    ROW_NUMBER() OVER ()::bigint,
    '03_DATA'::text,
    'ops.global_source_registry'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.global_source_registry t


UNION ALL


/* ============================================================================
04. SOURCE DISCOVERY MASTER – CELÝ OBSAH
============================================================================ */

SELECT
    40,
    ROW_NUMBER() OVER ()::bigint,
    '04_DATA'::text,
    'ops.source_discovery_master'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.source_discovery_master t


UNION ALL


/* ============================================================================
05. SOURCE DISCOVERY AUDIT TRACKER – CELÝ OBSAH
============================================================================ */

SELECT
    50,
    ROW_NUMBER() OVER ()::bigint,
    '05_DATA'::text,
    'ops.source_discovery_audit_tracker'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.source_discovery_audit_tracker t


UNION ALL


/* ============================================================================
06. COMMERCIAL MODEL – CELÝ OBSAH
============================================================================ */

SELECT
    60,
    ROW_NUMBER() OVER ()::bigint,
    '06_DATA'::text,
    'ops.source_commercial_model'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.source_commercial_model t


UNION ALL


/* ============================================================================
07. LEGAL AUDIT – CELÝ OBSAH
============================================================================ */

SELECT
    70,
    ROW_NUMBER() OVER ()::bigint,
    '07_DATA'::text,
    'ops.source_legal_audit'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.source_legal_audit t


UNION ALL


/* ============================================================================
08. ACTIVATION ROADMAP – CELÝ OBSAH
============================================================================ */

SELECT
    80,
    ROW_NUMBER() OVER ()::bigint,
    '08_DATA'::text,
    'ops.source_activation_roadmap'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.source_activation_roadmap t


UNION ALL


/* ============================================================================
09. SOURCE INTELLIGENCE MAP – CELÝ OBSAH
============================================================================ */

SELECT
    90,
    ROW_NUMBER() OVER ()::bigint,
    '09_DATA'::text,
    'ops.source_intelligence_map'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.source_intelligence_map t


UNION ALL


/* ============================================================================
10. SOURCE QUALITY SCORE – CELÝ OBSAH
============================================================================ */

SELECT
    100,
    ROW_NUMBER() OVER ()::bigint,
    '10_DATA'::text,
    'ops.source_quality_score'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.source_quality_score t


UNION ALL


/* ============================================================================
11. SOURCE COVERAGE MATRIX – CELÝ OBSAH
============================================================================ */

SELECT
    110,
    ROW_NUMBER() OVER ()::bigint,
    '11_DATA'::text,
    'ops.source_coverage_matrix'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.source_coverage_matrix t


UNION ALL


/* ============================================================================
12. PROVIDER WORKER REGISTRY – CELÝ OBSAH
============================================================================ */

SELECT
    120,
    ROW_NUMBER() OVER ()::bigint,
    '12_DATA'::text,
    'ops.provider_worker_registry'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.provider_worker_registry t


UNION ALL


/* ============================================================================
13. PROVIDER JOBS – CELÝ OBSAH

    Potřebujeme odlišit:
      runtime adapter identity
      runtime sport key
      job / worker konfiguraci
============================================================================ */

SELECT
    130,
    ROW_NUMBER() OVER ()::bigint,
    '13_DATA'::text,
    'ops.provider_jobs'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.provider_jobs t


UNION ALL


/* ============================================================================
14. PROVIDER ACCOUNTS – CELÝ OBSAH
============================================================================ */

SELECT
    140,
    ROW_NUMBER() OVER ()::bigint,
    '14_DATA'::text,
    'ops.provider_accounts'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.provider_accounts t


UNION ALL


/* ============================================================================
15. PROVIDER ENTITY COVERAGE – CELÝ OBSAH

    Pouze evidence.
    NIC z těchto řádků se tímto krokem nemigruje do routing/coverage targetu.
============================================================================ */

SELECT
    150,
    ROW_NUMBER() OVER ()::bigint,
    '15_DATA'::text,
    'ops.provider_entity_coverage'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.provider_entity_coverage t


UNION ALL


/* ============================================================================
16. PROVIDER SPORT MATRIX – CELÝ OBSAH
============================================================================ */

SELECT
    160,
    ROW_NUMBER() OVER ()::bigint,
    '16_DATA'::text,
    'ops.provider_sport_matrix'::text,
    ROW_NUMBER() OVER ()::bigint,
    to_jsonb(t)::text
FROM ops.provider_sport_matrix t


UNION ALL


/* ============================================================================
17. ROW COUNTS – KONTROLA ÚPLNOSTI EXPORTU
============================================================================ */

SELECT
    170,
    x.sort_item,
    '17_ROW_COUNT'::text,
    x.object_name,
    NULL::bigint,
    x.detail
FROM (
    SELECT  1::bigint sort_item,
            'ops.global_source_registry'::text object_name,
            COUNT(*)::text detail
    FROM ops.global_source_registry

    UNION ALL
    SELECT  2, 'ops.source_discovery_master', COUNT(*)::text
    FROM ops.source_discovery_master

    UNION ALL
    SELECT  3, 'ops.source_discovery_audit_tracker', COUNT(*)::text
    FROM ops.source_discovery_audit_tracker

    UNION ALL
    SELECT  4, 'ops.source_commercial_model', COUNT(*)::text
    FROM ops.source_commercial_model

    UNION ALL
    SELECT  5, 'ops.source_legal_audit', COUNT(*)::text
    FROM ops.source_legal_audit

    UNION ALL
    SELECT  6, 'ops.source_activation_roadmap', COUNT(*)::text
    FROM ops.source_activation_roadmap

    UNION ALL
    SELECT  7, 'ops.source_intelligence_map', COUNT(*)::text
    FROM ops.source_intelligence_map

    UNION ALL
    SELECT  8, 'ops.source_quality_score', COUNT(*)::text
    FROM ops.source_quality_score

    UNION ALL
    SELECT  9, 'ops.source_coverage_matrix', COUNT(*)::text
    FROM ops.source_coverage_matrix

    UNION ALL
    SELECT 10, 'ops.provider_worker_registry', COUNT(*)::text
    FROM ops.provider_worker_registry

    UNION ALL
    SELECT 11, 'ops.provider_jobs', COUNT(*)::text
    FROM ops.provider_jobs

    UNION ALL
    SELECT 12, 'ops.provider_accounts', COUNT(*)::text
    FROM ops.provider_accounts

    UNION ALL
    SELECT 13, 'ops.provider_entity_coverage', COUNT(*)::text
    FROM ops.provider_entity_coverage

    UNION ALL
    SELECT 14, 'ops.provider_sport_matrix', COUNT(*)::text
    FROM ops.provider_sport_matrix
) x

)

SELECT
    section,
    object_name,
    row_no,
    detail
FROM report
ORDER BY
    sort_group,
    sort_item,
    object_name,
    row_no;