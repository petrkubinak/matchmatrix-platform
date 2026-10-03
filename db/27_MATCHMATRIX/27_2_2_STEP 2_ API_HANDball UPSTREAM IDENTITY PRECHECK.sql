/* =============================================================================
CO:
    HB SOURCE EVIDENCE INVENTORY
    STEP 2 — API_HANDball UPSTREAM IDENTITY PRECHECK

K ČEMU:
    Dohledá databázové důkazy o skutečné externí identitě provideru
    api_handball.

    Cíl:
        runtime adapter api_handball
            ↓
        provider account / API base URL / legacy registry
            ↓
        skutečný externí source identity candidate

BEZPEČNOST:
    pouze SELECT
    žádný INSERT / UPDATE / DELETE / ALTER
============================================================================= */


/* ============================================================================
1. PROVIDER ACCOUNT
============================================================================ */

SELECT
    id,
    provider,
    account_name,
    plan_code,
    is_active,
    daily_limit_total,
    daily_limit_per_sport,
    safety_reserve_pct,
    api_base_url,
    notes,
    created_at,
    updated_at
FROM ops.provider_accounts
WHERE provider = 'api_handball'
   OR provider = 'api_sport'
   OR lower(account_name) LIKE '%handball%'
   OR lower(account_name) LIKE '%api-sport%'
   OR lower(account_name) LIKE '%api sport%'
   OR lower(COALESCE(api_base_url, '')) LIKE '%handball%'
   OR lower(COALESCE(api_base_url, '')) LIKE '%api-sport%'
ORDER BY provider, id;


/* ============================================================================
2. RUNTIME ADAPTER
============================================================================ */

SELECT
    adapter_id,
    adapter_code,
    adapter_type,
    runtime_status,
    provider_class,
    base_worker,
    account_ref,
    notes
FROM ops.runtime_adapter
WHERE adapter_code = 'api_handball'
   OR adapter_code = 'api_sport'
ORDER BY adapter_id;


/* ============================================================================
3. LEGACY GLOBAL SOURCE REGISTRY — SEARCH FOR POSSIBLE PROVIDER IDENTITY
============================================================================ */

SELECT
    *
FROM ops.global_source_registry
WHERE lower(source_name) LIKE '%handball%'
   OR lower(source_name) LIKE '%api-sport%'
   OR lower(source_name) LIKE '%api sport%'
   OR lower(COALESCE(source_url, '')) LIKE '%handball%'
   OR lower(COALESCE(source_url, '')) LIKE '%api-sport%'
ORDER BY source_id;


/* ============================================================================
4. CANONICAL SOURCE MASTER — DOES THE PROVIDER ALREADY EXIST?
============================================================================ */

SELECT
    source_id,
    source_code,
    canonical_name,
    source_type,
    lifecycle_status,
    canonical_domain,
    notes
FROM ops.source_master
WHERE lower(source_code) LIKE '%handball%'
   OR lower(source_code) LIKE '%api_sport%'
   OR lower(source_code) LIKE '%apisport%'
   OR lower(canonical_name) LIKE '%api-sport%'
   OR lower(canonical_name) LIKE '%api sport%'
   OR lower(COALESCE(canonical_domain, '')) LIKE '%api-sport%'
ORDER BY source_id;


/* ============================================================================
5. SOURCE ALIASES — POSSIBLE HISTORIC MATCH
============================================================================ */

SELECT
    sa.source_alias_id,
    sa.source_id,
    sm.source_code,
    sm.canonical_name,
    sa.alias_type,
    sa.alias_value,
    sa.normalized_alias,
    sa.is_preferred,
    sa.valid_from,
    sa.valid_to,
    sa.evidence_ref
FROM ops.source_alias sa
JOIN ops.source_master sm
  ON sm.source_id = sa.source_id
WHERE lower(sa.alias_value) LIKE '%api-sport%'
   OR lower(sa.alias_value) LIKE '%api sport%'
   OR lower(sa.alias_value) LIKE '%api_handball%'
   OR lower(sa.alias_value) LIKE '%api-handball%'
ORDER BY sa.source_id, sa.source_alias_id;


/* ============================================================================
6. PROVIDER REFERENCES ACROSS LEGACY HB TABLES
============================================================================ */

SELECT
    'provider_sport_matrix' AS source_table,
    provider,
    COUNT(*) AS rows
FROM ops.provider_sport_matrix
WHERE sport_code = 'HB'
GROUP BY provider

UNION ALL

SELECT
    'provider_entity_coverage',
    provider,
    COUNT(*)
FROM ops.provider_entity_coverage
WHERE sport_code = 'HB'
GROUP BY provider

UNION ALL

SELECT
    'provider_worker_registry',
    provider,
    COUNT(*)
FROM ops.provider_worker_registry
WHERE sport_code = 'HB'
GROUP BY provider

UNION ALL

SELECT
    'provider_jobs',
    provider,
    COUNT(*)
FROM ops.provider_jobs
WHERE sport_code = 'HB'
GROUP BY provider

ORDER BY source_table, provider;


/* ============================================================================
7. FINAL CLASSIFICATION
============================================================================ */

WITH account_evidence AS (
    SELECT COUNT(*) AS cnt
    FROM ops.provider_accounts
    WHERE provider = 'api_handball'
),

canonical_evidence AS (
    SELECT COUNT(*) AS cnt
    FROM ops.source_master
    WHERE lower(source_code) IN (
        'api_handball',
        'api_sport',
        'apisport'
    )
       OR lower(canonical_name) LIKE '%api-sport%'
       OR lower(canonical_name) LIKE '%api sport%'
)

SELECT
    'API_HANDBALL_UPSTREAM_IDENTITY' AS check_id,

    CASE
        WHEN (SELECT cnt FROM account_evidence) > 0
         AND (SELECT cnt FROM canonical_evidence) > 0
            THEN 'CANDIDATE_CANONICAL_IDENTITY_EXISTS'

        WHEN (SELECT cnt FROM account_evidence) > 0
         AND (SELECT cnt FROM canonical_evidence) = 0
            THEN 'UPSTREAM_EVIDENCE_FOUND_CANONICAL_SOURCE_MISSING'

        ELSE
            'HOLD_MORE_EVIDENCE_REQUIRED'
    END AS status,

    'provider_account_rows='
        || (SELECT cnt FROM account_evidence)::text
        || '; canonical_candidate_rows='
        || (SELECT cnt FROM canonical_evidence)::text
        AS detail;