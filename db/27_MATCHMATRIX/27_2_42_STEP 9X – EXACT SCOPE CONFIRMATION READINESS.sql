/*
CO:
STEP 9X – EXACT SCOPE CONFIRMATION READINESS AUDIT

K ČEMU:
Rozhodnout, zda dva konkrétní exact coverage scope:

HB / CORE / fixtures
league 24881
API-Sports league 131
source season 2024

splňují podmínky pro změnu:

scope_status
RUNTIME_TESTED -> CONFIRMED

DŮLEŽITÉ:
Tento audit NEHODNOTÍ parent coverage jako CONFIRMED.

Parent:
HB / CORE / fixtures / HISTORY_FAN
HB / CORE / fixtures / HISTORY_PREDICTION

zůstává zatím RUNTIME_TESTED.

JAK:
Pouze SELECT.
*/


WITH exact_scope AS
(
    SELECT
        d.scope_coverage_id,
        d.coverage_id,

        c.source_id,
        c.sport_code,
        c.layer_type,
        c.entity,
        c.time_mode,
        c.coverage_status AS parent_status,

        d.canonical_league_id,
        d.source_competition_key,
        d.source_season_key,
        d.season_resolution_status,
        d.scope_status,

        d.audit_evidence_id,

        e.audit_dimension,
        e.evidence_key,
        e.evidence_version,
        e.result_status,

        e.result_detail::jsonb AS detail

    FROM ops.source_entity_time_scope_coverage d

    JOIN ops.source_entity_time_coverage c
      ON c.coverage_id = d.coverage_id

    JOIN ops.source_audit_evidence e
      ON e.audit_evidence_id = d.audit_evidence_id

    WHERE c.source_id = 18
      AND c.sport_code = 'HB'
      AND c.layer_type = 'CORE'
      AND c.entity = 'fixtures'
      AND c.time_mode IN (
          'HISTORY_FAN',
          'HISTORY_PREDICTION'
      )
),

audit AS
(
    SELECT
        *,

        /* ---------------------------------------------
           A. PARENT + EXACT STATUS
           --------------------------------------------- */

        (
            parent_status = 'RUNTIME_TESTED'
        ) AS parent_runtime_tested,

        (
            scope_status = 'RUNTIME_TESTED'
        ) AS scope_runtime_tested,


        /* ---------------------------------------------
           B. EVIDENCE IDENTITY
           --------------------------------------------- */

        (
            audit_evidence_id = 58
            AND audit_dimension = 'RUNTIME_COVERAGE_TEST'
            AND result_status = 'PASS'
        ) AS evidence_pass,


        /* ---------------------------------------------
           C. SCOPE IDENTITY
           --------------------------------------------- */

        (
            canonical_league_id = 24881
            AND source_competition_key = '131'
            AND source_season_key = '2024'
        ) AS exact_scope_identity_ok,


        /* ---------------------------------------------
           D. EVIDENCE ↔ SCOPE CONSISTENCY
           --------------------------------------------- */

        (
            (detail ->> 'public_league_id')::bigint
                = canonical_league_id

            AND
            (detail ->> 'provider_league_id')
                = source_competition_key

            AND
            (detail ->> 'season')
                = source_season_key
        ) AS evidence_scope_match,


        /* ---------------------------------------------
           E. RUNTIME RESULT
           --------------------------------------------- */

        (
            (detail ->> 'api_returned_matches')::integer > 0

            AND
            (detail ->> 'api_returned_matches')::integer
                =
            (detail ->> 'db_expected_matches')::integer
        ) AS runtime_count_match,


        /* ---------------------------------------------
           F. HISTORICAL DATA QUALITY
           --------------------------------------------- */

        (
            (detail ->> 'db_finished')::integer
                =
            (detail ->> 'db_expected_matches')::integer

            AND
            (detail ->> 'db_finished_with_score')::integer
                =
            (detail ->> 'db_finished')::integer

            AND
            (detail ->> 'db_scheduled')::integer = 0

            AND
            (detail ->> 'db_cancelled')::integer = 0
        ) AS historical_quality_ok,


        /* ---------------------------------------------
           G. TEST SAFETY
           --------------------------------------------- */

        (
            (detail ->> 'dry_run')::boolean = true
            AND
            (detail ->> 'db_modified')::boolean = false
        ) AS runtime_test_safe,


        /* ---------------------------------------------
           H. PAYLOAD PROVENANCE
           --------------------------------------------- */

        (
            COALESCE(
                btrim(detail ->> 'payload_sha256'),
                ''
            ) <> ''
        ) AS payload_hash_present,


        /* ---------------------------------------------
           I. SEASON RESOLUTION

           UNRESOLVED zde není blocker.
           Coverage availability a season canonicalization
           jsou oddělené odpovědnosti.
           --------------------------------------------- */

        (
            season_resolution_status IN (
                'DIRECT',
                'COMPACT_MAPPED',
                'UNRESOLVED'
            )
        ) AS season_state_allowed

    FROM exact_scope
)

SELECT
    scope_coverage_id,
    coverage_id,
    time_mode,

    parent_status,
    scope_status,

    parent_runtime_tested,
    scope_runtime_tested,
    evidence_pass,
    exact_scope_identity_ok,
    evidence_scope_match,
    runtime_count_match,
    historical_quality_ok,
    runtime_test_safe,
    payload_hash_present,
    season_state_allowed,

    CASE
        WHEN
            parent_runtime_tested
            AND scope_runtime_tested
            AND evidence_pass
            AND exact_scope_identity_ok
            AND evidence_scope_match
            AND runtime_count_match
            AND historical_quality_ok
            AND runtime_test_safe
            AND payload_hash_present
            AND season_state_allowed
        THEN 'EXACT_SCOPE_CONFIRMATION_READY'

        ELSE 'HOLD'
    END AS confirmation_readiness

FROM audit

ORDER BY
    scope_coverage_id;