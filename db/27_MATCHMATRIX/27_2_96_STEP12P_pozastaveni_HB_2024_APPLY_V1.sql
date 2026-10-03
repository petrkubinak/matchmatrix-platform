/*
CO:
  STEP 12P – dočasné pozastavení 55 HB targetů sezóny 2024.

K ČEMU:
  Pozastavit 110 refresh policy pravidel, vypnout 55 targetů
  a zablokovat přesně 57 ověřených pending planner jobů.
  Uchovat původní řádky pro případné řízené vrácení změny.

KDE:
  PC2 / PostgreSQL / databáze matchmatrix / DBeaver.

JAK:
  Spustit celý skript jako SQL Script.
  Zastavit při první chybě.
  Změny a administrativní audit tvoří jednu transakci.

VSTUP:
  STEP 12O = VALIDATE_ONLY_PASS.
  Pevný seznam 55 targetů a 57 planner jobů.

VÝSTUP:
  Jeden administrativní záznam v ops.job_runs.
  Závěrečný řádek APPLY_PASS.

AUTOR:
  Petr / OpenAI ChatGPT
*/

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $step12p$
DECLARE
    v_target_ids CONSTANT bigint[] := ARRAY[
        4887, 4888, 4892, 4895, 4921, 4924, 4925, 4927,
        4932, 4933, 4937, 4939, 4940, 4941, 4942, 4945,
        4946, 4948, 4950, 4951, 4952, 4953, 4954, 4956,
        4957, 4958, 4959, 4961, 4962, 4963, 4964, 4965,
        4966, 4967, 4969, 4970, 4972, 4974, 4978, 4979,
        4983, 4993, 4997, 4998, 4999, 5003, 5004, 5005,
        5006, 5009, 5016, 5017, 5051, 5063, 5064
    ]::bigint[];

    v_job_ids CONSTANT bigint[] := ARRAY[
        7351, 7429, 7470, 7472, 7519, 7532, 7583, 7589,
        7625, 7634, 7643, 7665, 7666, 7701, 7744, 7773,
        7790, 7791, 7843, 7885, 7903, 7920, 7923, 7943,
        7949, 7962, 8081, 8084, 8091, 8129, 8141, 8164,
        8190, 8192, 8252, 8358, 8403, 8433, 8436, 8454,
        8471, 8477, 8532, 8548, 8630, 8632, 8659, 8672,
        8699, 8709, 8730, 8744, 8759, 8777, 8784, 8892,
        8896
    ]::bigint[];

    v_reason CONSTANT text :=
        '[27_2_96 / STEP 12P] Docasne pozastaveni HB 2024: '
        'sezona neni uvedena v katalogu /leagues ze dne 2026-09-29. '
        'Ceka na rozhodnuti o rozsahu a dalsi overeni; '
        'nejde o dukaz trvale nedostupnosti dat.';

    v_started_at timestamptz := clock_timestamp();
    v_changed_at timestamptz;

    v_league_ids text[];
    v_policy_ids bigint[];
    v_actual_job_ids bigint[];

    v_targets_before jsonb;
    v_policies_before jsonb;
    v_planner_before jsonb;
    v_older_before jsonb;
    v_older_after jsonb;

    v_count bigint;
    v_running bigint;
    v_pending_leagues bigint;
BEGIN
    IF current_database() <> 'matchmatrix' THEN
        RAISE EXCEPTION 'STOP: Ocekavana databaze matchmatrix.';
    END IF;

    -- Krátce zabrání změně fronty nebo rozsahu během transakce.
    LOCK TABLE
        ops.ingest_planner,
        ops.ingest_targets,
        ops.harvest_scope_refresh_policy
    IN SHARE ROW EXCLUSIVE MODE;

    IF EXISTS (
        SELECT 1
        FROM ops.job_runs j
        WHERE j.params ->> 'script_prefix' = '27_2_96'
    ) THEN
        RAISE EXCEPTION
            'STOP: Audit 27_2_96 jiz existuje. Nejprve overit stav.';
    END IF;

    -- Přesně 55 původních, stále aktivních targetů.
    SELECT
        COUNT(*),
        array_agg(t.provider_league_id ORDER BY t.id),
        jsonb_agg(to_jsonb(t) ORDER BY t.id)
    INTO
        v_count,
        v_league_ids,
        v_targets_before
    FROM ops.ingest_targets t
    WHERE t.id = ANY (v_target_ids)
      AND t.provider = 'api_handball'
      AND t.sport_code = 'HB'
      AND t.season = '2024'
      AND t.run_group = 'HB_CORE'
      AND t.enabled = true;

    IF v_count <> 55 THEN
        RAISE EXCEPTION
            'STOP: Ocekavano 55 aktivnich targetu, nalezeno %.',
            v_count;
    END IF;

    IF (
        SELECT COUNT(DISTINCT x.league_id)
        FROM unnest(v_league_ids) AS x(league_id)
    ) <> 55 THEN
        RAISE EXCEPTION 'STOP: Targety nemaji 55 ruznych lig.';
    END IF;

    -- Pravidla musejí přesně odpovídat targetům a sezóně.
    SELECT
        COUNT(*),
        array_agg(r.policy_id ORDER BY r.policy_id),
        jsonb_agg(to_jsonb(r) ORDER BY r.policy_id)
    INTO
        v_count,
        v_policy_ids,
        v_policies_before
    FROM ops.harvest_scope_refresh_policy r
    JOIN ops.ingest_targets t
      ON t.id = r.ingest_target_id
     AND t.provider_league_id = r.source_competition_key
     AND t.season = r.source_season_key
    WHERE t.id = ANY (v_target_ids)
      AND r.source_id = 18
      AND r.sport_code = 'HB'
      AND r.layer_type = 'CORE'
      AND r.entity = 'fixtures'
      AND r.source_season_key = '2024'
      AND r.time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
      AND r.policy_status = 'DRAFT'
      AND r.refresh_mode = 'UNDECIDED';

    IF v_count <> 110 THEN
        RAISE EXCEPTION
            'STOP: Ocekavano 110 DRAFT/UNDECIDED pravidel, nalezeno %.',
            v_count;
    END IF;

    IF EXISTS (
        SELECT r.ingest_target_id
        FROM ops.harvest_scope_refresh_policy r
        WHERE r.policy_id = ANY (v_policy_ids)
        GROUP BY r.ingest_target_id
        HAVING COUNT(*) <> 2
            OR COUNT(DISTINCT r.time_mode) <> 2
    ) THEN
        RAISE EXCEPTION 'STOP: Neplatne dvojice policy pravidel.';
    END IF;

    -- Kontrola celé fronty dotčených lig pro sezónu 2024.
    SELECT
        COUNT(*),
        COUNT(*) FILTER (WHERE p.status = 'running'),
        COUNT(DISTINCT p.provider_league_id)
            FILTER (WHERE p.status = 'pending'),
        array_agg(p.id ORDER BY p.id)
            FILTER (WHERE p.status = 'pending')
    INTO
        v_count,
        v_running,
        v_pending_leagues,
        v_actual_job_ids
    FROM ops.ingest_planner p
    WHERE p.provider = 'api_handball'
      AND p.sport_code = 'HB'
      AND p.entity = 'fixtures'
      AND p.season = '2024'
      AND p.provider_league_id = ANY (v_league_ids);

    IF v_count <> 149
       OR v_running <> 0
       OR v_pending_leagues <> 55
       OR v_actual_job_ids IS DISTINCT FROM v_job_ids
    THEN
        RAISE EXCEPTION
            'STOP: Fronta se lisi od STEP 12O. '
            'Celkem=%, running=%, ligy s pending=%, pending ID=%',
            v_count, v_running, v_pending_leagues, v_actual_job_ids;
    END IF;

    -- Předchozí oprava osiřelého běhu musí zůstat doložená.
    IF NOT EXISTS (
        SELECT 1
        FROM ops.ingest_planner p
        WHERE p.id = 8874
          AND p.provider = 'api_handball'
          AND p.sport_code = 'HB'
          AND p.entity = 'fixtures'
          AND p.provider_league_id = '180'
          AND p.season = '2024'
          AND p.status = 'error'
    ) THEN
        RAISE EXCEPTION 'STOP: Opraveny planner 8874 neodpovida.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM ops.job_runs j
        WHERE j.id IN (1996, 1997)
          AND j.status = 'error'
          AND j.finished_at IS NOT NULL
          AND j.details
              -> 'orphan_run_recovery'
              ->> 'script_prefix' = '27_2_93'
    ) <> 2 THEN
        RAISE EXCEPTION 'STOP: Chybi potvrzeni opravy auditu 1996/1997.';
    END IF;

    SELECT jsonb_agg(to_jsonb(p) ORDER BY p.id)
    INTO v_planner_before
    FROM ops.ingest_planner p
    WHERE p.id = ANY (v_job_ids);

    -- Kontrolní snapshot starších pending jobů mimo změnu.
    SELECT
        COUNT(*),
        jsonb_agg(to_jsonb(p) ORDER BY p.id)
    INTO v_count, v_older_before
    FROM ops.ingest_planner p
    WHERE p.provider = 'api_handball'
      AND p.sport_code = 'HB'
      AND p.entity = 'fixtures'
      AND p.season IN ('2022', '2023')
      AND p.provider_league_id = ANY (v_league_ids)
      AND p.status = 'pending';

    IF v_count <> 110 THEN
        RAISE EXCEPTION
            'STOP: Ocekavano 110 starsich pending jobu, nalezeno %.',
            v_count;
    END IF;

    v_changed_at := clock_timestamp();

    UPDATE ops.harvest_scope_refresh_policy
    SET policy_status = 'PAUSED',
        policy_reason = concat_ws(
            E'\n', NULLIF(policy_reason, ''), v_reason
        ),
        updated_at = v_changed_at
    WHERE policy_id = ANY (v_policy_ids)
      AND policy_status = 'DRAFT'
      AND refresh_mode = 'UNDECIDED';

    GET DIAGNOSTICS v_count = ROW_COUNT;

    IF v_count <> 110 THEN
        RAISE EXCEPTION 'STOP: Zmeneno % pravidel misto 110.', v_count;
    END IF;

    UPDATE ops.ingest_targets
    SET enabled = false,
        notes = concat_ws(E'\n', NULLIF(notes, ''), v_reason),
        updated_at = v_changed_at
    WHERE id = ANY (v_target_ids)
      AND enabled = true;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    IF v_count <> 55 THEN
        RAISE EXCEPTION 'STOP: Zmeneno % targetu misto 55.', v_count;
    END IF;

    UPDATE ops.ingest_planner
    SET status = 'blocked',
        updated_at = v_changed_at
    WHERE id = ANY (v_job_ids)
      AND provider = 'api_handball'
      AND sport_code = 'HB'
      AND entity = 'fixtures'
      AND season = '2024'
      AND status = 'pending';

    GET DIAGNOSTICS v_count = ROW_COUNT;

    IF v_count <> 57 THEN
        RAISE EXCEPTION 'STOP: Zmeneno % jobu misto 57.', v_count;
    END IF;

    -- Ověření výsledných stavů před potvrzením transakce.
    IF (
        SELECT COUNT(*)
        FROM ops.harvest_scope_refresh_policy
        WHERE policy_id = ANY (v_policy_ids)
          AND policy_status = 'PAUSED'
          AND refresh_mode = 'UNDECIDED'
    ) <> 110
    OR (
        SELECT COUNT(*)
        FROM ops.ingest_targets
        WHERE id = ANY (v_target_ids)
          AND enabled = false
    ) <> 55
    OR (
        SELECT COUNT(*)
        FROM ops.ingest_planner
        WHERE id = ANY (v_job_ids)
          AND status = 'blocked'
    ) <> 57 THEN
        RAISE EXCEPTION 'STOP: Vysledne stavy neodpovidaji.';
    END IF;

    SELECT jsonb_agg(to_jsonb(p) ORDER BY p.id)
    INTO v_older_after
    FROM ops.ingest_planner p
    WHERE p.provider = 'api_handball'
      AND p.sport_code = 'HB'
      AND p.entity = 'fixtures'
      AND p.season IN ('2022', '2023')
      AND p.provider_league_id = ANY (v_league_ids)
      AND p.status = 'pending';

    IF v_older_after IS DISTINCT FROM v_older_before THEN
        RAISE EXCEPTION 'STOP: Starsi pending joby byly zmeneny.';
    END IF;

    -- Samostatný administrativní audit, včetně původních řádků.
    INSERT INTO ops.job_runs (
        job_code,
        started_at,
        finished_at,
        status,
        params,
        message,
        details,
        rows_affected
    )
    VALUES (
        'hb_scope_pause_admin',
        v_started_at,
        clock_timestamp(),
        'ok',
        jsonb_build_object(
            'script_prefix', '27_2_96',
            'step', 'STEP 12P',
            'operation', 'ADMINISTRATIVE_SCOPE_PAUSE',
            'source_id', 18,
            'provider', 'api_handball',
            'sport_code', 'HB',
            'entity', 'fixtures',
            'season', '2024',
            'target_ids', to_jsonb(v_target_ids),
            'policy_ids', to_jsonb(v_policy_ids),
            'planner_ids', to_jsonb(v_job_ids)
        ),
        v_reason,
        jsonb_build_object(
            'performed_by', 'Petr',
            'database_user', current_user,
            'changed_at', v_changed_at,
            'verification', 'PASSED_IN_TRANSACTION',
            'counts', jsonb_build_object(
                'policies_paused', 110,
                'targets_disabled', 55,
                'planner_blocked', 57,
                'older_pending_unchanged', 110
            ),
            'before', jsonb_build_object(
                'policies', v_policies_before,
                'targets', v_targets_before,
                'planner', v_planner_before
            )
        ),
        222
    );
END;
$step12p$;

COMMIT;

SELECT
    'APPLY_PASS' AS check_status,
    j.id AS administrative_audit_id,
    j.details -> 'counts' ->> 'policies_paused'
        AS policies_paused,
    j.details -> 'counts' ->> 'targets_disabled'
        AS targets_disabled,
    j.details -> 'counts' ->> 'planner_blocked'
        AS planner_blocked,
    j.details -> 'counts' ->> 'older_pending_unchanged'
        AS older_pending_unchanged,
    j.finished_at
FROM ops.job_runs j
WHERE j.job_code = 'hb_scope_pause_admin'
  AND j.params ->> 'script_prefix' = '27_2_96'
  AND j.status = 'ok'
  AND j.finished_at IS NOT NULL
  AND j.details ->> 'verification' = 'PASSED_IN_TRANSACTION'
ORDER BY j.id DESC
LIMIT 1;