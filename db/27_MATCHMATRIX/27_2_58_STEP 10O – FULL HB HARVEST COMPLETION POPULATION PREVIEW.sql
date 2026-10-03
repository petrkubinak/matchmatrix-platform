/*
CO:
STEP 10O – FULL HB HARVEST COMPLETION POPULATION PREVIEW

K ČEMU:
Nasimulovat počáteční obsah budoucího Harvest Completion Registry
pro všech 211 enabled HB targetů a dva historické time modes.

CÍL:
Rozdělit budoucích 422 completion rows na:

COMPLETE
= exact scope CONFIRMED
+ persistent runtime evidence PASS
+ API count = DB count
+ historická data jsou čistá

PARTIAL
= historická data v DB existují,
  ale jejich úplnost vůči aktuálnímu provideru
  nebyla runtime reconciliation testem potvrzena

NOT_STARTED
= pro target nejsou v DB žádná historická api_handball data

DŮLEŽITÉ:
PARTIAL zde NEZNAMENÁ vadná data.
Znamená pouze:
dataset existuje, ale completeness zatím není prokázána.

JAK:
Pouze SELECT.
*/


WITH time_modes AS
(
    SELECT *
    FROM (
        VALUES
            ('HISTORY_FAN'::text),
            ('HISTORY_PREDICTION'::text)
    ) AS x(time_mode)
),

targets AS
(
    SELECT
        t.id AS ingest_target_id,
        t.canonical_league_id,
        t.provider_league_id::text AS provider_league_id,
        t.season::text AS source_season,
        t.tier

    FROM ops.ingest_targets t

    WHERE t.provider = 'api_handball'
      AND t.sport_code = 'HB'
      AND t.season = '2024'
      AND t.enabled = true
),

history AS
(
    SELECT
        m.league_id AS canonical_league_id,
        m.season::text AS source_season,

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

    WHERE m.kickoff < CURRENT_DATE

    GROUP BY
        m.league_id,
        m.season::text
),

exact AS
(
    SELECT
        d.scope_coverage_id,
        d.canonical_league_id,
        d.source_competition_key,
        d.source_season_key,
        d.scope_status,

        c.time_mode,

        d.audit_evidence_id,

        e.result_status AS evidence_result_status,
        e.result_detail::jsonb AS detail

    FROM ops.source_entity_time_scope_coverage d

    JOIN ops.source_entity_time_coverage c
      ON c.coverage_id = d.coverage_id

    LEFT JOIN ops.source_audit_evidence e
      ON e.audit_evidence_id = d.audit_evidence_id

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

universe AS
(
    SELECT
        t.ingest_target_id,
        t.canonical_league_id,
        t.provider_league_id,
        t.source_season,
        t.tier,

        tm.time_mode,

        h.matches,
        h.finished,
        h.finished_with_score,
        h.scheduled,
        h.cancelled,

        x.scope_coverage_id,
        x.audit_evidence_id,
        x.evidence_result_status,
        x.detail,

        CASE
            WHEN
                x.scope_coverage_id IS NOT NULL

                AND x.scope_status = 'CONFIRMED'

                AND x.evidence_result_status = 'PASS'

                AND COALESCE(
                    (x.detail ->> 'api_returned_matches')::bigint,
                    -1
                ) > 0

                AND
                (x.detail ->> 'api_returned_matches')::bigint
                    =
                (x.detail ->> 'db_expected_matches')::bigint

                AND h.matches
                    =
                (x.detail ->> 'db_expected_matches')::bigint

                AND h.finished = h.matches

                AND h.finished_with_score = h.matches

                AND h.scheduled = 0

                AND h.cancelled = 0

            THEN true

            ELSE false
        END AS complete_ready

    FROM targets t

    CROSS JOIN time_modes tm

    LEFT JOIN history h
      ON h.canonical_league_id = t.canonical_league_id
     AND h.source_season = t.source_season

    LEFT JOIN exact x
      ON x.canonical_league_id = t.canonical_league_id
     AND x.source_competition_key = t.provider_league_id
     AND x.source_season_key = t.source_season
     AND x.time_mode = tm.time_mode
),

classified AS
(
    SELECT
        *,

        CASE
            WHEN complete_ready = true
                THEN 'COMPLETE'

            WHEN matches IS NOT NULL
                THEN 'PARTIAL'

            ELSE 'NOT_STARTED'
        END AS preview_completion_status

    FROM universe
),

target_class AS
(
    /*
    Převod zpět na unikátní target úroveň,
    aby se HISTORY_FAN + HISTORY_PREDICTION
    nezapočítaly dvakrát při target souhrnu.
    */
    SELECT
        ingest_target_id,

        MAX(matches) AS matches,

        CASE
            WHEN bool_and(
                preview_completion_status = 'COMPLETE'
            )
                THEN 'COMPLETE'

            WHEN MAX(matches) IS NOT NULL
                THEN 'PARTIAL'

            ELSE 'NOT_STARTED'
        END AS target_completion_status

    FROM classified

    GROUP BY
        ingest_target_id
)

SELECT

    /* =====================================================
       TARGET UNIVERSE
       ===================================================== */

    (SELECT COUNT(*) FROM targets)
        AS enabled_targets,

    (SELECT COUNT(*) FROM time_modes)
        AS historical_time_modes,

    (SELECT COUNT(*) FROM classified)
        AS preview_completion_rows,


    /* =====================================================
       DATA FOOTPRINT
       ===================================================== */

    (SELECT COUNT(*)
     FROM target_class
     WHERE matches IS NOT NULL)
        AS targets_with_history,

    (SELECT COUNT(*)
     FROM target_class
     WHERE matches IS NULL)
        AS targets_without_history,

    (SELECT COALESCE(SUM(matches), 0)
     FROM target_class)
        AS historical_matches,


    /* =====================================================
       EXACT CONFIRMED COVERAGE
       ===================================================== */

    (SELECT COUNT(DISTINCT ingest_target_id)
     FROM classified
     WHERE scope_coverage_id IS NOT NULL)
        AS targets_with_confirmed_exact_coverage,

    (SELECT COUNT(*)
     FROM classified
     WHERE scope_coverage_id IS NOT NULL)
        AS confirmed_exact_rows,


    /* =====================================================
       COMPLETION PREVIEW – ROW LEVEL
       ===================================================== */

    (SELECT COUNT(*)
     FROM classified
     WHERE preview_completion_status = 'COMPLETE')
        AS complete_rows,

    (SELECT COUNT(*)
     FROM classified
     WHERE preview_completion_status = 'PARTIAL')
        AS partial_rows,

    (SELECT COUNT(*)
     FROM classified
     WHERE preview_completion_status = 'NOT_STARTED')
        AS not_started_rows,


    /* =====================================================
       COMPLETION PREVIEW – TARGET LEVEL
       ===================================================== */

    (SELECT COUNT(*)
     FROM target_class
     WHERE target_completion_status = 'COMPLETE')
        AS complete_targets,

    (SELECT COUNT(*)
     FROM target_class
     WHERE target_completion_status = 'PARTIAL')
        AS partial_targets,

    (SELECT COUNT(*)
     FROM target_class
     WHERE target_completion_status = 'NOT_STARTED')
        AS not_started_targets,


    /* =====================================================
       SAFETY CHECKS
       ===================================================== */

    (SELECT COUNT(*)
     FROM classified
     WHERE preview_completion_status = 'COMPLETE'
       AND (
            scope_coverage_id IS NULL
            OR audit_evidence_id IS NULL
            OR complete_ready = false
       ))
        AS bad_complete_rows,

    (SELECT COUNT(*)
     FROM classified
     WHERE preview_completion_status = 'NOT_STARTED'
       AND matches IS NOT NULL)
        AS bad_not_started_rows,

    (SELECT COUNT(*)
     FROM classified
     WHERE preview_completion_status NOT IN (
         'COMPLETE',
         'PARTIAL',
         'NOT_STARTED'
     ))
        AS unclassified_rows;