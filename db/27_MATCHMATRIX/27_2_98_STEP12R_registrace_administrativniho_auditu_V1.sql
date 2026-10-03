/*
CO:
  STEP 12R – registrace administrativního auditního typu.

K ČEMU:
  Doplnit ops.jobs.code = hb_scope_pause_admin,
  který vyžaduje cizí klíč v ops.job_runs.

KDE:
  PC2 / PostgreSQL matchmatrix / DBeaver.

JAK:
  Spustit celý skript.
  Registrace bude mít enabled=false.
  Existující záznam se nepřepisuje.
*/

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';

DO $step12r$
BEGIN
    IF current_database() <> 'matchmatrix' THEN
        RAISE EXCEPTION
            'STOP: Ocekavana databaze matchmatrix.';
    END IF;

    INSERT INTO ops.jobs (
        code,
        name,
        description,
        enabled,
        default_params
    )
    VALUES (
        'hb_scope_pause_admin',
        'Administrativni pozastaveni HB scope',
        'Audit rucniho pozastaveni HB pravidel, targetu '
        'a planner jobu vcetne puvodnich hodnot.',
        false,
        jsonb_build_object(
            'purpose', 'ADMINISTRATIVE_SCOPE_PAUSE',
            'execution_mode', 'MANUAL_SQL',
            'registration_script', '27_2_98',
            'source_id', 18,
            'provider', 'api_handball',
            'sport_code', 'HB',
            'entity', 'fixtures'
        )
    )
    ON CONFLICT (code) DO NOTHING;

    PERFORM 1
    FROM ops.jobs j
    WHERE j.code = 'hb_scope_pause_admin'
      AND j.enabled = false
      AND j.default_params ->> 'purpose'
          = 'ADMINISTRATIVE_SCOPE_PAUSE'
      AND j.default_params ->> 'execution_mode'
          = 'MANUAL_SQL'
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'STOP: Registrace chybi nebo ma odlisny ucel ci aktivaci.';
    END IF;
END;
$step12r$;

COMMIT;

SELECT
    'APPLY_PASS' AS check_status,
    j.code,
    j.enabled,
    j.default_params ->> 'purpose' AS purpose
FROM ops.jobs j
WHERE j.code = 'hb_scope_pause_admin'
  AND j.enabled = false
  AND j.default_params ->> 'purpose'
      = 'ADMINISTRATIVE_SCOPE_PAUSE'
  AND j.default_params ->> 'execution_mode'
      = 'MANUAL_SQL';