/*
CO:
  STEP 12M – APPLY uzavření osiřelého HB jobu 8874.

K ČEMU:
  Planner 8874: running → error.
  Audity 1996 a 1997: running → error,
  s doložením administrativního uzavření.

KDE:
  DBeaver / databáze matchmatrix na PC2.

JAK:
  Spustit celý skript.
  Kontroly i změny proběhnou v jedné transakci.
*/

BEGIN;

SET LOCAL lock_timeout = '5s';

DO $mm_step12m$
DECLARE
    v_planner_before jsonb;
    v_rows integer;
    v_closed_at timestamptz;
BEGIN
    IF current_database() <> 'matchmatrix' THEN
        RAISE EXCEPTION 'STOP: nespravna databaze.';
    END IF;

    -- Zamknutí a opakování planner prechecku.
    SELECT to_jsonb(p)
    INTO v_planner_before
    FROM ops.ingest_planner p
    WHERE p.id = 8874
      AND p.provider = 'api_handball'
      AND p.sport_code = 'HB'
      AND p.entity = 'fixtures'
      AND p.provider_league_id::text = '180'
      AND p.season::text = '2024'
      AND p.run_group = 'PC2_CORE_HB'
      AND p.status = 'running'
      AND p.attempts = 2
      AND p.last_attempt < NOW() - INTERVAL '7 days'
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'STOP: planner 8874 neodpovida prechecku.';
    END IF;

    -- Zamknutí a kontrola obou auditů.
    PERFORM j.id
    FROM ops.job_runs j
    WHERE j.id IN (1996, 1997)
      AND j.job_code = 'ingest_planner_worker'
      AND j.status = 'running'
      AND j.finished_at IS NULL
      AND j.started_at < NOW() - INTERVAL '7 days'
      AND (
          j.params ->> 'planner_id' = '8874'
          OR j.details ->> 'planner_id' = '8874'
      )
      AND jsonb_typeof(
          COALESCE(j.details::jsonb, '{}'::jsonb)
      ) = 'object'
      AND NOT (
          COALESCE(j.details::jsonb, '{}'::jsonb)
          ? 'orphan_run_recovery'
      )
    ORDER BY j.id
    FOR UPDATE;

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    IF v_rows <> 2 THEN
        RAISE EXCEPTION
            'STOP: ocekavany pocet auditu 2, skutecnost %.',
            v_rows;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM ops.job_runs j
        WHERE j.id NOT IN (1996, 1997)
          AND j.status = 'running'
          AND j.finished_at IS NULL
          AND (
              j.params ->> 'planner_id' = '8874'
              OR j.details ->> 'planner_id' = '8874'
          )
    ) THEN
        RAISE EXCEPTION
            'STOP: nalezen dalsi otevreny audit jobu 8874.';
    END IF;

    v_closed_at := clock_timestamp();

    UPDATE ops.ingest_planner
    SET
        status = 'error',
        updated_at = v_closed_at
    WHERE id = 8874;

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    IF v_rows <> 1 THEN
        RAISE EXCEPTION
            'STOP: planner UPDATE zasahl % radku.', v_rows;
    END IF;

    UPDATE ops.job_runs j
    SET
        status = 'error',
        finished_at = v_closed_at,
        message =
            'Administrativne uzavren osirely beh; STEP 12M.',
        details =
            COALESCE(j.details::jsonb, '{}'::jsonb)
            || jsonb_build_object(
                'orphan_run_recovery',
                jsonb_build_object(
                    'step', 'STEP 12M',
                    'script_prefix', '27_2_93',
                    'classification', 'ORPHANED_RUN',
                    'reason',
                        'Neuzavreny beh bez dolozeneho vysledku.',
                    'closure_kind', 'ADMINISTRATIVE',
                    'closed_at', v_closed_at,
                    'closed_by', 'Petr',
                    'database_user', current_user,
                    'process_check',
                        'USER_PROVIDED_PC2_NO_MATCHING_INGEST_PROCESSES',
                    'previous_status', j.status,
                    'previous_finished_at', j.finished_at,
                    'previous_message', j.message,
                    'planner_before', v_planner_before
                )
            )
    WHERE j.id IN (1996, 1997);

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    IF v_rows <> 2 THEN
        RAISE EXCEPTION
            'STOP: audit UPDATE zasahl % radku.', v_rows;
    END IF;

    -- Kontrola výsledného stavu před COMMIT.
    IF NOT EXISTS (
        SELECT 1
        FROM ops.ingest_planner
        WHERE id = 8874
          AND status = 'error'
    ) THEN
        RAISE EXCEPTION 'STOP: planner postcheck selhal.';
    END IF;

    SELECT COUNT(*)
    INTO v_rows
    FROM ops.job_runs j
    WHERE j.id IN (1996, 1997)
      AND j.status = 'error'
      AND j.finished_at = v_closed_at
      AND j.details -> 'orphan_run_recovery'
                    ->> 'script_prefix' = '27_2_93';

    IF v_rows <> 2 THEN
        RAISE EXCEPTION 'STOP: audit postcheck selhal.';
    END IF;
END;
$mm_step12m$;

COMMIT;

-- Výpis skutečného stavu po COMMIT.
WITH report AS (
    SELECT
        'PLANNER'::text AS object_type,
        p.id AS record_id,
        p.status,
        p.updated_at AS recorded_at,
        p.status = 'error' AS is_valid
    FROM ops.ingest_planner p
    WHERE p.id = 8874

    UNION ALL

    SELECT
        'JOB_RUN',
        j.id,
        j.status,
        j.finished_at,
        (
            j.status = 'error'
            AND j.finished_at IS NOT NULL
            AND COALESCE(
                j.details -> 'orphan_run_recovery'
                          ->> 'script_prefix',
                ''
            ) = '27_2_93'
        )
    FROM ops.job_runs j
    WHERE j.id IN (1996, 1997)
),
checks AS (
    SELECT
        CASE
            WHEN COUNT(*) = 3 AND BOOL_AND(is_valid)
            THEN 'APPLY_PASS'
            ELSE 'POSTCHECK_REVIEW_REQUIRED'
        END AS check_status
    FROM report
)
SELECT
    c.check_status,
    r.object_type,
    r.record_id,
    r.status,
    r.recorded_at
FROM checks c
LEFT JOIN report r ON TRUE
ORDER BY r.object_type, r.record_id;