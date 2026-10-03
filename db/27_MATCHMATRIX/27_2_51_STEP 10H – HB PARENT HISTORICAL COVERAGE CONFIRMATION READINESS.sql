/*
CO:
STEP 10H – HB PARENT HISTORICAL COVERAGE CONFIRMATION READINESS

K ČEMU:
Připravit jednoznačný snapshot před rozhodnutím,
zda parent coverage:

HB / CORE / fixtures / HISTORY_FAN
HB / CORE / fixtures / HISTORY_PREDICTION

může přejít z RUNTIME_TESTED na CONFIRMED.

DŮLEŽITÉ:
Nic se nemění.
Žádný routing.
Žádná aktivace bindingu.

JAK:
Pouze SELECT.
*/


WITH historical_scopes AS
(
    SELECT
        m.league_id,
        lpm.provider_league_id,
        m.season::text AS season,

        COUNT(DISTINCT m.id) AS matches,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'FINISHED'
        ) AS finished,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'FINISHED'
              AND m.home_score IS NOT NULL
              AND m.away_score IS NOT NULL
        ) AS finished_with_score,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'SCHEDULED'
        ) AS scheduled,

        COUNT(DISTINCT m.id) FILTER (
            WHERE m.status = 'CANCELLED'
        ) AS cancelled

    FROM public.matches m

    JOIN public.match_provider_map mpm
      ON mpm.match_id = m.id
     AND mpm.provider = 'api_handball'

    LEFT JOIN public.league_provider_map lpm
      ON lpm.league_id = m.league_id
     AND lpm.provider = 'api_handball'

    WHERE m.kickoff < CURRENT_DATE

    GROUP BY
        m.league_id,
        lpm.provider_league_id,
        m.season::text
),

scope_quality AS
(
    SELECT
        *,

        CASE
            WHEN finished = matches
             AND finished_with_score = matches
             AND scheduled = 0
             AND cancelled = 0
            THEN 'CLEAN'
            ELSE 'EXCEPTION'
        END AS quality_state

    FROM historical_scopes
),

confirmed_exact AS
(
    SELECT DISTINCT
        d.canonical_league_id,
        d.source_competition_key,
        d.source_season_key

    FROM ops.source_entity_time_scope_coverage d

    JOIN ops.source_entity_time_coverage c
      ON c.coverage_id = d.coverage_id

    WHERE c.source_id = 18
      AND c.sport_code = 'HB'
      AND c.layer_type = 'CORE'
      AND c.entity = 'fixtures'
      AND c.time_mode IN (
          'HISTORY_FAN',
          'HISTORY_PREDICTION'
      )
      AND d.scope_status = 'CONFIRMED'
),

runtime_evidence AS
(
    SELECT
        COUNT(*) AS evidence_rows,
        COUNT(DISTINCT evidence_key) AS distinct_tested_scopes
    FROM ops.source_audit_evidence
    WHERE source_id = 18
      AND audit_dimension = 'RUNTIME_COVERAGE_TEST'
      AND result_status = 'PASS'
),

parent AS
(
    SELECT
        coverage_id,
        time_mode,
        coverage_status
    FROM ops.source_entity_time_coverage
    WHERE source_id = 18
      AND sport_code = 'HB'
      AND layer_type = 'CORE'
      AND entity = 'fixtures'
      AND time_mode IN (
          'HISTORY_FAN',
          'HISTORY_PREDICTION'
      )
)

SELECT
    /* celkový historický footprint */
    (SELECT COUNT(*) FROM scope_quality)
        AS historical_scopes,

    (SELECT COUNT(*) FROM scope_quality
      WHERE quality_state = 'CLEAN')
        AS clean_scopes,

    (SELECT COUNT(*) FROM scope_quality
      WHERE quality_state = 'EXCEPTION')
        AS exception_scopes,

    (SELECT SUM(matches) FROM scope_quality)
        AS historical_matches,

    /* exact potvrzení */
    (SELECT COUNT(DISTINCT
        canonical_league_id::text
        || '|'
        || source_competition_key
        || '|'
        || source_season_key
     )
     FROM confirmed_exact)
        AS confirmed_competition_season_scopes,

    /* persistentní runtime evidence */
    (SELECT evidence_rows FROM runtime_evidence)
        AS runtime_evidence_rows,

    (SELECT distinct_tested_scopes FROM runtime_evidence)
        AS runtime_tested_scopes,

    /* parent status */
    (SELECT COUNT(*) FROM parent)
        AS parent_rows,

    (SELECT COUNT(*) FROM parent
      WHERE coverage_status = 'RUNTIME_TESTED')
        AS parent_runtime_tested,

    (SELECT COUNT(*) FROM parent
      WHERE coverage_status = 'CONFIRMED')
        AS parent_confirmed,

    /* governance */
    (SELECT COUNT(*)
     FROM ops.source_adapter_binding
     WHERE source_id = 18
       AND is_active = true)
        AS active_bindings,

    (SELECT COUNT(*)
     FROM ops.data_acquisition_source_routing
     WHERE source_id = 18)
        AS routes;
   