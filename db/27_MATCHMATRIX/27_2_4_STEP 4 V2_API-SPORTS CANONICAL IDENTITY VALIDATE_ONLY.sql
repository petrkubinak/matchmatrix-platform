/* =============================================================================
CO:
    HB SOURCE EVIDENCE INVENTORY
    STEP 4 V2 — API-SPORTS CANONICAL IDENTITY VALIDATE_ONLY

K ČEMU:
    Bez trvalé změny ověří vytvoření nové canonical source identity:

        source_code       = api_sports
        canonical_name    = API-Sports
        source_type       = DATA_PROVIDER
        lifecycle_status  = FROZEN
        canonical_domain  = api-sports.io

    Současně ověří:
        - SOURCE_NAME alias
        - DOMAIN alias
        - explicitní SOURCE_SPORT vztah API-Sports ↔ HB

    Tento krok NEVYTVÁŘÍ:
        - SOURCE_ADAPTER_BINDING
        - SOURCE_ENTITY_TIME_COVERAGE
        - SOURCE_ROUTING

KDE:
    PostgreSQL / matchmatrix / PC2

BEZPEČNOST:
    VALIDATE_ONLY
    na konci ROLLBACK
    explicitní testovací ID neposouvají identity sekvence
============================================================================= */

BEGIN;


/* ============================================================================
1. CANDIDATE IDS

Explicitní testovací ID zabrání tomu, aby VALIDATE_ONLY spotřeboval hodnoty
identity sekvencí.
============================================================================ */

CREATE TEMP TABLE g4e_api_sports_candidate
ON COMMIT DROP
AS
SELECT
    COALESCE(
        (SELECT MAX(source_id) FROM ops.source_master),
        0
    ) + 1 AS candidate_source_id,

    COALESCE(
        (SELECT MAX(source_alias_id) FROM ops.source_alias),
        0
    ) + 1 AS candidate_alias_id_1,

    COALESCE(
        (SELECT MAX(source_alias_id) FROM ops.source_alias),
        0
    ) + 2 AS candidate_alias_id_2,

    COALESCE(
        (SELECT MAX(source_sport_id) FROM ops.source_sport),
        0
    ) + 1 AS candidate_source_sport_id;


/* ============================================================================
2. PRECHECK
============================================================================ */

SELECT *
FROM (

    SELECT
        10 AS sort_order,
        'BASELINE_SOURCE_MASTER' AS check_id,
        CASE
            WHEN COUNT(*) = 17 THEN 'PASS'
            ELSE 'BLOCKER'
        END AS status,
        'rows=' || COUNT(*)::text AS detail
    FROM ops.source_master


    UNION ALL


    SELECT
        20,
        'BASELINE_SOURCE_ALIAS',
        CASE
            WHEN COUNT(*) = 35 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_alias


    UNION ALL


    SELECT
        30,
        'BASELINE_SOURCE_SPORT',
        CASE
            WHEN COUNT(*) = 17 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_sport


    UNION ALL


    SELECT
        40,
        'SOURCE_COLLISION',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_master
    WHERE lower(source_code) IN (
        'api_sports',
        'api-sports',
        'apisports'
    )
       OR lower(COALESCE(canonical_domain,'')) = 'api-sports.io'


    UNION ALL


    SELECT
        50,
        'ALIAS_COLLISION',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_alias
    WHERE valid_to IS NULL
      AND (
            (alias_type = 'SOURCE_NAME'
             AND lower(normalized_alias) = 'api-sports')

         OR (alias_type = 'DOMAIN'
             AND lower(normalized_alias) = 'api-sports.io')
      )


    UNION ALL


    SELECT
        60,
        'API_HANDBALL_ADAPTER',
        CASE
            WHEN COUNT(*) = 1 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.runtime_adapter
    WHERE adapter_code = 'api_handball'
      AND runtime_status = 'REGISTERED'


    UNION ALL


    SELECT
        70,
        'API_HANDBALL_PROVIDER_ACCOUNT',
        CASE
            WHEN COUNT(*) = 1 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.provider_accounts
    WHERE provider = 'api_handball'
      AND is_active = true
      AND lower(COALESCE(api_base_url,''))
            LIKE '%handball.api-sports.io%'


    UNION ALL


    SELECT
        80,
        'EXISTING_API_HANDBALL_BINDING',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_adapter_binding sab
    JOIN ops.runtime_adapter ra
      ON ra.adapter_id = sab.adapter_id
    WHERE ra.adapter_code = 'api_handball'
      AND sab.is_active = true

) q

ORDER BY sort_order;


/* ============================================================================
3. TEMPORARY SOURCE_MASTER INSERT
============================================================================ */

INSERT INTO ops.source_master
(
    source_id,
    source_code,
    canonical_name,
    source_type,
    lifecycle_status,
    canonical_domain,
    owner_org,
    notes
)
SELECT
    c.candidate_source_id,
    'api_sports',
    'API-Sports',
    'DATA_PROVIDER',
    'FROZEN',
    'api-sports.io',
    NULL,
    'HB controlled source identity validation. '
    || 'Upstream identity evidenced by active api_handball provider account '
    || 'using handball.api-sports.io. '
    || 'Identity only; no adapter binding, coverage or routing implied.'
FROM g4e_api_sports_candidate c
WHERE

    (SELECT COUNT(*) FROM ops.source_master) = 17

AND (SELECT COUNT(*) FROM ops.source_alias) = 35

AND (SELECT COUNT(*) FROM ops.source_sport) = 17

AND NOT EXISTS (
    SELECT 1
    FROM ops.source_master
    WHERE lower(source_code) IN (
        'api_sports',
        'api-sports',
        'apisports'
    )
       OR lower(COALESCE(canonical_domain,'')) = 'api-sports.io'
)

AND NOT EXISTS (
    SELECT 1
    FROM ops.source_alias
    WHERE valid_to IS NULL
      AND (
            (alias_type = 'SOURCE_NAME'
             AND lower(normalized_alias) = 'api-sports')

         OR (alias_type = 'DOMAIN'
             AND lower(normalized_alias) = 'api-sports.io')
      )
)

AND (
    SELECT COUNT(*)
    FROM ops.runtime_adapter
    WHERE adapter_code = 'api_handball'
      AND runtime_status = 'REGISTERED'
) = 1

AND (
    SELECT COUNT(*)
    FROM ops.provider_accounts
    WHERE provider = 'api_handball'
      AND is_active = true
      AND lower(COALESCE(api_base_url,''))
          LIKE '%handball.api-sports.io%'
) = 1

AND (
    SELECT COUNT(*)
    FROM ops.source_adapter_binding sab
    JOIN ops.runtime_adapter ra
      ON ra.adapter_id = sab.adapter_id
    WHERE ra.adapter_code = 'api_handball'
      AND sab.is_active = true
) = 0;


/* ============================================================================
4A. TEMPORARY SOURCE_NAME ALIAS

Samostatný INSERT — žádný UNION ALL a tedy žádná nejednoznačnost typu DATE.
============================================================================ */

INSERT INTO ops.source_alias
(
    source_alias_id,
    source_id,
    alias_type,
    alias_value,
    normalized_alias,
    valid_from,
    valid_to,
    evidence_ref,
    is_preferred
)
SELECT
    c.candidate_alias_id_1,
    sm.source_id,
    'SOURCE_NAME',
    'API-Sports',
    'api-sports',
    NULL::date,
    NULL::date,
    'HB_SOURCE_EVIDENCE_STEP_2_PROVIDER_ACCOUNT',
    true
FROM g4e_api_sports_candidate c

JOIN ops.source_master sm
  ON sm.source_id = c.candidate_source_id
 AND sm.source_code = 'api_sports';


/* ============================================================================
4B. TEMPORARY DOMAIN ALIAS
============================================================================ */

INSERT INTO ops.source_alias
(
    source_alias_id,
    source_id,
    alias_type,
    alias_value,
    normalized_alias,
    valid_from,
    valid_to,
    evidence_ref,
    is_preferred
)
SELECT
    c.candidate_alias_id_2,
    sm.source_id,
    'DOMAIN',
    'api-sports.io',
    'api-sports.io',
    NULL::date,
    NULL::date,
    'HB_SOURCE_EVIDENCE_STEP_2_PROVIDER_ACCOUNT',
    false
FROM g4e_api_sports_candidate c

JOIN ops.source_master sm
  ON sm.source_id = c.candidate_source_id
 AND sm.source_code = 'api_sports';


/* ============================================================================
5. TEMPORARY SOURCE_SPORT INSERT

relationship_status používáme stejný jako u současných HB canonical sources:
OBSERVED_IN_CURRENT_DATA
============================================================================ */

INSERT INTO ops.source_sport
(
    source_sport_id,
    source_id,
    sport_code,
    relationship_status,
    sport_specific_url,
    notes
)
SELECT
    c.candidate_source_sport_id,
    sm.source_id,
    'HB',
    'OBSERVED_IN_CURRENT_DATA',
    'https://v1.handball.api-sports.io',
    'Explicit HB relationship evidenced by active api_handball provider '
    || 'account and registered HB runtime adapter. '
    || 'This relation does not imply source-adapter binding, '
    || 'entity coverage or routing.'
FROM g4e_api_sports_candidate c

JOIN ops.source_master sm
  ON sm.source_id = c.candidate_source_id
 AND sm.source_code = 'api_sports';


/* ============================================================================
6. VALIDATE CREATED SOURCE IDENTITY
============================================================================ */

SELECT
    sm.source_id,
    sm.source_code,
    sm.canonical_name,
    sm.source_type,
    sm.lifecycle_status,
    sm.canonical_domain,
    ss.source_sport_id,
    ss.sport_code,
    ss.relationship_status,
    ss.sport_specific_url
FROM ops.source_master sm

LEFT JOIN ops.source_sport ss
  ON ss.source_id = sm.source_id

WHERE sm.source_code = 'api_sports';


/* ============================================================================
7. VALIDATE CREATED ALIASES
============================================================================ */

SELECT
    sm.source_code,
    sa.source_alias_id,
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

WHERE sm.source_code = 'api_sports'

ORDER BY
    sa.alias_type,
    sa.source_alias_id;


/* ============================================================================
8. VALIDATION SUMMARY
============================================================================ */

SELECT *
FROM (

    SELECT
        10 AS sort_order,
        'SOURCE_MASTER_AFTER_TEMP_INSERT' AS check_id,
        CASE
            WHEN COUNT(*) = 18 THEN 'PASS'
            ELSE 'BLOCKER'
        END AS status,
        'rows=' || COUNT(*)::text AS detail
    FROM ops.source_master


    UNION ALL


    SELECT
        20,
        'SOURCE_ALIAS_AFTER_TEMP_INSERT',
        CASE
            WHEN COUNT(*) = 37 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_alias


    UNION ALL


    SELECT
        30,
        'SOURCE_SPORT_AFTER_TEMP_INSERT',
        CASE
            WHEN COUNT(*) = 18 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_sport


    UNION ALL


    SELECT
        40,
        'API_SPORTS_MASTER_ROW',
        CASE
            WHEN COUNT(*) = 1 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_master
    WHERE source_code = 'api_sports'
      AND canonical_name = 'API-Sports'
      AND source_type = 'DATA_PROVIDER'
      AND lifecycle_status = 'FROZEN'
      AND canonical_domain = 'api-sports.io'


    UNION ALL


    SELECT
        50,
        'API_SPORTS_SOURCE_NAME_ALIAS',
        CASE
            WHEN COUNT(*) = 1 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_alias sa

    JOIN ops.source_master sm
      ON sm.source_id = sa.source_id

    WHERE sm.source_code = 'api_sports'
      AND sa.alias_type = 'SOURCE_NAME'
      AND sa.alias_value = 'API-Sports'
      AND sa.normalized_alias = 'api-sports'
      AND sa.valid_to IS NULL
      AND sa.is_preferred = true


    UNION ALL


    SELECT
        60,
        'API_SPORTS_DOMAIN_ALIAS',
        CASE
            WHEN COUNT(*) = 1 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_alias sa

    JOIN ops.source_master sm
      ON sm.source_id = sa.source_id

    WHERE sm.source_code = 'api_sports'
      AND sa.alias_type = 'DOMAIN'
      AND sa.alias_value = 'api-sports.io'
      AND sa.normalized_alias = 'api-sports.io'
      AND sa.valid_to IS NULL
      AND sa.is_preferred = false


    UNION ALL


    SELECT
        70,
        'API_SPORTS_HB_RELATION',
        CASE
            WHEN COUNT(*) = 1 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_sport ss

    JOIN ops.source_master sm
      ON sm.source_id = ss.source_id

    WHERE sm.source_code = 'api_sports'
      AND ss.sport_code = 'HB'
      AND ss.relationship_status = 'OBSERVED_IN_CURRENT_DATA'
      AND ss.sport_specific_url =
          'https://v1.handball.api-sports.io'


    UNION ALL


    SELECT
        80,
        'SOURCE_ADAPTER_BINDING_UNCHANGED',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_adapter_binding


    UNION ALL


    SELECT
        90,
        'SOURCE_ENTITY_TIME_COVERAGE_UNCHANGED',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_entity_time_coverage


    UNION ALL


    SELECT
        100,
        'SOURCE_ROUTING_UNCHANGED',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.data_acquisition_source_routing


    UNION ALL


    SELECT
        110,
        'API_SPORTS_IDENTITY_VALIDATE_ONLY',
        CASE
            WHEN
                (SELECT COUNT(*)
                 FROM ops.source_master
                 WHERE source_code = 'api_sports'
                   AND canonical_name = 'API-Sports'
                   AND canonical_domain = 'api-sports.io') = 1

            AND
                (SELECT COUNT(*)
                 FROM ops.source_alias sa
                 JOIN ops.source_master sm
                   ON sm.source_id = sa.source_id
                 WHERE sm.source_code = 'api_sports') = 2

            AND
                (SELECT COUNT(*)
                 FROM ops.source_sport ss
                 JOIN ops.source_master sm
                   ON sm.source_id = ss.source_id
                 WHERE sm.source_code = 'api_sports'
                   AND ss.sport_code = 'HB'
                   AND ss.relationship_status =
                       'OBSERVED_IN_CURRENT_DATA') = 1

            AND
                (SELECT COUNT(*)
                 FROM ops.source_adapter_binding) = 0

            AND
                (SELECT COUNT(*)
                 FROM ops.source_entity_time_coverage) = 0

            AND
                (SELECT COUNT(*)
                 FROM ops.data_acquisition_source_routing) = 0

            THEN 'VALIDATE_ONLY_PASS'
            ELSE 'BLOCKER'
        END,

        'API-Sports identity + aliases + HB relation validated; '
        || 'no binding, coverage or routing created.'

) q

ORDER BY sort_order;


/* ============================================================================
9. ROLLBACK

Žádná změna nesmí po STEP 4 V2 zůstat v databázi.
============================================================================ */

ROLLBACK;


/* ============================================================================
10. POST-ROLLBACK VERIFICATION
============================================================================ */

SELECT *
FROM (

    SELECT
        10 AS sort_order,
        'SOURCE_MASTER_RESTORED' AS check_id,
        CASE
            WHEN COUNT(*) = 17 THEN 'PASS'
            ELSE 'BLOCKER'
        END AS status,
        'rows=' || COUNT(*)::text AS detail
    FROM ops.source_master


    UNION ALL


    SELECT
        20,
        'SOURCE_ALIAS_RESTORED',
        CASE
            WHEN COUNT(*) = 35 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_alias


    UNION ALL


    SELECT
        30,
        'SOURCE_SPORT_RESTORED',
        CASE
            WHEN COUNT(*) = 17 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_sport


    UNION ALL


    SELECT
        40,
        'API_SPORTS_NOT_PERSISTED',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_master
    WHERE source_code = 'api_sports'


    UNION ALL


    SELECT
        50,
        'API_SPORTS_ALIASES_NOT_PERSISTED',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM ops.source_alias
    WHERE normalized_alias IN (
        'api-sports',
        'api-sports.io'
    )


    UNION ALL


    SELECT
        60,
        'POST_ROLLBACK_COMPLETE',
        CASE
            WHEN
                (SELECT COUNT(*) FROM ops.source_master) = 17

            AND (SELECT COUNT(*) FROM ops.source_alias) = 35

            AND (SELECT COUNT(*) FROM ops.source_sport) = 17

            AND NOT EXISTS (
                SELECT 1
                FROM ops.source_master
                WHERE source_code = 'api_sports'
            )

            THEN 'PASS'
            ELSE 'BLOCKER'
        END,

        'Database restored to pre-validation state.'

) q

ORDER BY sort_order;