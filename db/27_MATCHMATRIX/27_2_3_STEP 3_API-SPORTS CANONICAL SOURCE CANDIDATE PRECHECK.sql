/* =============================================================================
CO:
    HB SOURCE EVIDENCE INVENTORY
    STEP 3 — API-SPORTS CANONICAL SOURCE CANDIDATE PRECHECK

K ČEMU:
    READ ONLY ověření před případným založením nové canonical source identity
    pro provider brand API-Sports.

NAVRHOVANÁ IDENTITA:
    source_code     = api_sports
    canonical_name  = API-Sports
    canonical_domain= api-sports.io

BEZPEČNOST:
    pouze SELECT
============================================================================= */


/* ============================================================================
1. SOURCE_MASTER PHYSICAL CONTRACT
============================================================================ */

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'source_master'
ORDER BY ordinal_position;


/* ============================================================================
2. SOURCE_MASTER CONSTRAINTS
============================================================================ */

SELECT
    c.conname AS constraint_name,
    c.contype AS constraint_type,
    pg_get_constraintdef(c.oid, true) AS definition
FROM pg_constraint c
WHERE c.conrelid = 'ops.source_master'::regclass
ORDER BY c.conname;


/* ============================================================================
3. POSSIBLE CANONICAL COLLISION
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
WHERE lower(source_code) IN (
        'api_sports',
        'api-sports',
        'apisports',
        'api_sport',
        'api_handball'
    )
   OR lower(canonical_name) LIKE '%api-sport%'
   OR lower(canonical_name) LIKE '%api sport%'
   OR lower(COALESCE(canonical_domain, '')) = 'api-sports.io'
ORDER BY source_id;


/* ============================================================================
4. POSSIBLE ALIAS COLLISION
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
    sa.valid_to
FROM ops.source_alias sa
JOIN ops.source_master sm
  ON sm.source_id = sa.source_id
WHERE lower(sa.normalized_alias) IN (
        'api-sports',
        'api-sports.io',
        'api sports',
        'api-handball',
        'api_handball'
    )
   OR lower(sa.alias_value) LIKE '%api-sport%'
   OR lower(sa.alias_value) LIKE '%api handball%'
   OR lower(sa.alias_value) LIKE '%api-handball%'
ORDER BY sa.source_id, sa.source_alias_id;


/* ============================================================================
5. EXISTING HB SOURCE RELATION
============================================================================ */

SELECT
    ss.source_sport_id,
    ss.source_id,
    sm.source_code,
    sm.canonical_name,
    ss.sport_code,
    ss.relationship_status,
    ss.sport_specific_url,
    ss.notes
FROM ops.source_sport ss
JOIN ops.source_master sm
  ON sm.source_id = ss.source_id
WHERE ss.sport_code = 'HB'
ORDER BY ss.source_id;


/* ============================================================================
6. API-HANDBALL RUNTIME ADAPTER
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
WHERE adapter_code = 'api_handball';


/* ============================================================================
7. EXISTING BINDING COLLISION
============================================================================ */

SELECT
    sab.source_adapter_binding_id,
    sab.source_id,
    sm.source_code,
    sab.adapter_id,
    ra.adapter_code,
    sab.sport_code,
    sab.entity,
    sab.binding_status,
    sab.is_active,
    sab.notes
FROM ops.source_adapter_binding sab
JOIN ops.source_master sm
  ON sm.source_id = sab.source_id
JOIN ops.runtime_adapter ra
  ON ra.adapter_id = sab.adapter_id
WHERE ra.adapter_code = 'api_handball'
   OR sab.sport_code = 'HB'
ORDER BY sab.source_adapter_binding_id;


/* ============================================================================
8. EXTERNAL PROVIDER EVIDENCE
============================================================================ */

SELECT
    id,
    provider,
    account_name,
    plan_code,
    is_active,
    api_base_url,
    notes
FROM ops.provider_accounts
WHERE provider = 'api_handball';


/* ============================================================================
9. FINAL PRECHECK
============================================================================ */

WITH collision AS (
    SELECT COUNT(*) AS cnt
    FROM ops.source_master
    WHERE lower(source_code) IN (
            'api_sports',
            'api-sports',
            'apisports'
        )
       OR lower(COALESCE(canonical_domain, '')) = 'api-sports.io'
),

alias_collision AS (
    SELECT COUNT(*) AS cnt
    FROM ops.source_alias
    WHERE valid_to IS NULL
      AND lower(normalized_alias) IN (
          'api-sports',
          'api-sports.io',
          'api sports'
      )
),

adapter AS (
    SELECT COUNT(*) AS cnt
    FROM ops.runtime_adapter
    WHERE adapter_code = 'api_handball'
      AND runtime_status = 'REGISTERED'
),

account_evidence AS (
    SELECT COUNT(*) AS cnt
    FROM ops.provider_accounts
    WHERE provider = 'api_handball'
      AND is_active = true
      AND lower(COALESCE(api_base_url, ''))
          LIKE '%handball.api-sports.io%'
),

binding AS (
    SELECT COUNT(*) AS cnt
    FROM ops.source_adapter_binding sab
    JOIN ops.runtime_adapter ra
      ON ra.adapter_id = sab.adapter_id
    WHERE ra.adapter_code = 'api_handball'
      AND sab.is_active = true
)

SELECT
    'API_SPORTS_CANONICAL_SOURCE_CANDIDATE' AS check_id,

    CASE
        WHEN (SELECT cnt FROM collision) > 0
            THEN 'BLOCKER_SOURCE_ALREADY_EXISTS'

        WHEN (SELECT cnt FROM alias_collision) > 0
            THEN 'BLOCKER_ALIAS_ALREADY_EXISTS'

        WHEN (SELECT cnt FROM adapter) <> 1
            THEN 'BLOCKER_RUNTIME_ADAPTER'

        WHEN (SELECT cnt FROM account_evidence) <> 1
            THEN 'BLOCKER_PROVIDER_EVIDENCE'

        WHEN (SELECT cnt FROM binding) > 0
            THEN 'BLOCKER_BINDING_ALREADY_EXISTS'

        ELSE 'READY_FOR_CONTROLLED_SOURCE_CREATE'
    END AS status,

    format(
        'source_collision=%s; alias_collision=%s; registered_adapter=%s; provider_evidence=%s; active_binding=%s',
        (SELECT cnt FROM collision),
        (SELECT cnt FROM alias_collision),
        (SELECT cnt FROM adapter),
        (SELECT cnt FROM account_evidence),
        (SELECT cnt FROM binding)
    ) AS detail;