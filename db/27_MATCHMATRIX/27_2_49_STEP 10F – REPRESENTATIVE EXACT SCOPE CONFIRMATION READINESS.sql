/*
CO:
STEP 10F – REPRESENTATIVE EXACT SCOPE CONFIRMATION READINESS

K ČEMU:
Ověřit, zda 10 exact coverage scope vytvořených ve STEP 10E
splňuje stejné podmínky jako původní league 131 před změnou:

RUNTIME_TESTED -> CONFIRMED

ROZSAH:
provider leagues:
34, 104, 145, 154, 155

time modes:
HISTORY_FAN
HISTORY_PREDICTION

DŮLEŽITÉ:
Parent coverage se tímto krokem NEMĚNÍ.

JAK:
Pouze SELECT.
*/


WITH exact_scope AS (
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
        d.canonical_season_id,

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

      AND d.source_competition_key IN (
          '34',
          '104',
          '145',
          '154',
          '155'
      )

      AND d.source_season_key = '2024'

      AND d.audit_evidence_id BETWEEN 59 AND 63
),

audit AS (
    SELECT
        *,

        /* 1. Parent musí zůstat RUNTIME_TESTED */
        (
            parent_status = 'RUNTIME_TESTED'
        ) AS parent_runtime_tested,


        /* 2. Exact scope musí být RUNTIME_TESTED */
        (
            scope_status = 'RUNTIME_TESTED'
        ) AS scope_runtime_tested,


        /* 3. Evidence musí být PASS */
        (
            audit_dimension = 'RUNTIME_COVERAGE_TEST'
            AND result_status = 'PASS'
        ) AS evidence_pass,


        /* 4. Evidence musí přesně odpovídat scope */
        (
            (detail ->> 'canonical_league_id')::integer
                = canonical_league_id

            AND

            (detail ->> 'provider_league_id')
                = source_competition_key

            AND

            (detail ->> 'season')
                = source_season_key
        ) AS evidence_scope_match,


        /* 5. API count = DB count */
        (
            (detail ->> 'api_returned_matches')::integer > 0

            AND

            (detail ->> 'api_returned_matches')::integer
                =
            (detail ->> 'db_expected_matches')::integer
        ) AS runtime_count_match,


        /* 6. Historický scope je celý dokončený a se skóre */
        (
            (detail ->> 'db_finished')::integer
                =
            (detail ->> 'db_expected_matches')::integer

            AND

            (detail ->> 'db_finished_with_score')::integer
                =
            (detail ->> 'db_expected_matches')::integer

            AND

            (detail ->> 'db_scheduled')::integer = 0

            AND

            (detail ->> 'db_cancelled')::integer = 0
        ) AS historical_quality_ok,


        /* 7. STEP 10C reconciliation */
        (
            detail ->> 'reconciliation_status' = 'PASS'
        ) AS reconciliation_pass,


        /* 8. DryRun nesměl měnit DB */
        (
            (detail ->> 'dry_run')::boolean = true
            AND
            (detail ->> 'db_modified')::boolean = false
        ) AS runtime_test_safe,


        /* 9. Payload provenance */
        (
            COALESCE(
                btrim(detail ->> 'payload_sha256'),
                ''
            ) <> ''
        ) AS payload_hash_present,


        /* 10. Season resolution může být zatím UNRESOLVED */
        (
            season_resolution_status IN (
                'DIRECT',
                'COMPACT_MAPPED',
                'UNRESOLVED'
            )
        ) AS season_state_allowed

    FROM exact_scope
),

final AS (
    SELECT
        *,

        CASE
            WHEN
                parent_runtime_tested
                AND scope_runtime_tested
                AND evidence_pass
                AND evidence_scope_match
                AND runtime_count_match
                AND historical_quality_ok
                AND reconciliation_pass
                AND runtime_test_safe
                AND payload_hash_present
                AND season_state_allowed

            THEN 'EXACT_SCOPE_CONFIRMATION_READY'

            ELSE 'HOLD'
        END AS confirmation_readiness

    FROM audit
)


/* =========================================================
   DETAIL – očekáváme 10 × READY
   ========================================================= */

SELECT
    scope_coverage_id,
    coverage_id,
    time_mode,

    canonical_league_id,
    source_competition_key,
    source_season_key,

    audit_evidence_id,

    parent_status,
    scope_status,

    parent_runtime_tested,
    scope_runtime_tested,
    evidence_pass,
    evidence_scope_match,
    runtime_count_match,
    historical_quality_ok,
    reconciliation_pass,
    runtime_test_safe,
    payload_hash_present,
    season_state_allowed,

    confirmation_readiness

FROM final

ORDER BY
    source_competition_key::integer,
    time_mode;