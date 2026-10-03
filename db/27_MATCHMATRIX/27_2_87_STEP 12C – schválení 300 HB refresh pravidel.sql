-- CO: STEP 12C – schválení 300 HB refresh pravidel
-- K ČEMU: Nastavit MANUAL pouze u 150 targetů s doloženou sezónou 2024
-- KDE: DBeaver, databáze matchmatrix na PC2
-- JAK: Spustit celý blok jako skript; kontroly při odchylce zruší zápis

BEGIN;
SET LOCAL lock_timeout = '5s';

DO $step12c$
DECLARE
    v_target_ids bigint[] := ARRAY[
        4883,4884,4885,4886,4889,4891,4893,4894,4896,4897,4898,4899,
        4900,4901,4902,4903,4904,4905,4906,4907,4908,4909,4910,4911,
        4912,4913,4914,4915,4916,4917,4918,4919,4920,4922,4923,4926,
        4928,4929,4930,4931,4934,4935,4936,4938,4947,4949,4955,4960,
        4968,4971,4973,4975,4976,4977,4980,4981,4982,4984,4985,4986,
        4987,4988,4989,4990,4991,4992,4994,4995,4996,5000,5001,5002,
        5007,5008,5010,5011,5012,5013,5014,5015,5018,5019,5021,5022,
        5023,5024,5025,5026,5027,5028,5029,5030,5031,5032,5033,5034,
        5035,5036,5037,5038,5039,5040,5041,5042,5043,5044,5045,5046,
        5047,5048,5049,5050,5052,5053,5054,5055,5056,5057,5058,5059,
        5060,5061,5062,5065,5066,5067,5068,5069,5070,5071,5072,5073,
        5074,5075,5076,5077,5078,5079,5080,5081,5082,5083,5084,5085,
        5086,5087,5088,5089,5090,5091
    ]::bigint[];

    v_approved_ids bigint[] :=
        ARRAY[5020,4890,4872,4882,4943,4944]::bigint[];

    v_total bigint;
    v_map_targets bigint;
    v_map_hash text;
    v_approved bigint;
    v_approved_targets bigint;
    v_eligible bigint;
    v_eligible_targets bigint;
    v_held bigint;
    v_held_targets bigint;
    v_updated bigint;
    v_approved_after bigint;
    v_draft_after bigint;
    v_now timestamptz := clock_timestamp();
BEGIN
    LOCK TABLE ops.harvest_scope_refresh_policy
        IN SHARE ROW EXCLUSIVE MODE;
    LOCK TABLE ops.ingest_targets
        IN SHARE MODE;

    SELECT count(*)
    INTO v_total
    FROM ops.harvest_scope_refresh_policy;

    SELECT
        count(*),
        md5(string_agg(
            x.id::text || ':' ||
            x.provider_league_id::text || ':' ||
            x.canonical_league_id::text,
            ',' ORDER BY x.id
        ))
    INTO v_map_targets, v_map_hash
    FROM (
        SELECT DISTINCT
            t.id,
            t.provider_league_id,
            t.canonical_league_id
        FROM ops.harvest_scope_refresh_policy AS p
        JOIN ops.ingest_targets AS t
            ON t.id = p.ingest_target_id
    ) AS x;

    IF v_total <> 422
       OR v_map_targets <> 211
       OR v_map_hash <> '6ef6119c436655559822f685a43ea8f4'
       OR (SELECT count(DISTINCT id)
           FROM unnest(v_target_ids) AS u(id)) <> 150
    THEN
        RAISE EXCEPTION
            'STEP_12C_PRECHECK_FAILED: rows=%, targets=%, map_hash=%',
            v_total, v_map_targets, v_map_hash;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM ops.harvest_scope_refresh_policy AS p
        LEFT JOIN ops.ingest_targets AS t
            ON t.id = p.ingest_target_id
        WHERE t.id IS NULL
           OR p.source_id IS DISTINCT FROM 18
           OR p.sport_code IS DISTINCT FROM 'HB'
           OR p.layer_type IS DISTINCT FROM 'CORE'
           OR p.entity IS DISTINCT FROM 'fixtures'
           OR p.scope_type IS DISTINCT FROM 'COMPETITION_SEASON'
           OR p.time_mode NOT IN
                ('HISTORY_FAN', 'HISTORY_PREDICTION')
           OR t.provider IS DISTINCT FROM 'api_handball'
           OR t.season::text IS DISTINCT FROM '2024'
           OR p.canonical_league_id
                IS DISTINCT FROM t.canonical_league_id
    )
    OR EXISTS (
        SELECT 1
        FROM ops.harvest_scope_refresh_policy
        GROUP BY ingest_target_id
        HAVING count(*) <> 2
            OR count(DISTINCT time_mode) <> 2
    )
    THEN
        RAISE EXCEPTION 'STEP_12C_SCOPE_OR_GRAIN_CHANGED';
    END IF;

    SELECT
        count(*) FILTER (
            WHERE p.ingest_target_id = ANY(v_approved_ids)
              AND p.policy_status = 'APPROVED'
              AND p.refresh_mode = 'MANUAL'
        ),
        count(DISTINCT p.ingest_target_id) FILTER (
            WHERE p.ingest_target_id = ANY(v_approved_ids)
              AND p.policy_status = 'APPROVED'
              AND p.refresh_mode = 'MANUAL'
        ),
        count(*) FILTER (
            WHERE p.ingest_target_id = ANY(v_target_ids)
              AND p.policy_status = 'DRAFT'
              AND p.refresh_mode = 'UNDECIDED'
              AND p.approved_by IS NULL
              AND p.approved_at IS NULL
              AND p.min_refresh_interval_seconds IS NULL
        ),
        count(DISTINCT p.ingest_target_id) FILTER (
            WHERE p.ingest_target_id = ANY(v_target_ids)
              AND p.policy_status = 'DRAFT'
              AND p.refresh_mode = 'UNDECIDED'
              AND p.approved_by IS NULL
              AND p.approved_at IS NULL
              AND p.min_refresh_interval_seconds IS NULL
        ),
        count(*) FILTER (
            WHERE NOT (p.ingest_target_id = ANY(v_approved_ids))
              AND NOT (p.ingest_target_id = ANY(v_target_ids))
              AND p.policy_status = 'DRAFT'
              AND p.refresh_mode = 'UNDECIDED'
        ),
        count(DISTINCT p.ingest_target_id) FILTER (
            WHERE NOT (p.ingest_target_id = ANY(v_approved_ids))
              AND NOT (p.ingest_target_id = ANY(v_target_ids))
              AND p.policy_status = 'DRAFT'
              AND p.refresh_mode = 'UNDECIDED'
        )
    INTO
        v_approved, v_approved_targets,
        v_eligible, v_eligible_targets,
        v_held, v_held_targets
    FROM ops.harvest_scope_refresh_policy AS p;

    IF v_approved <> 12 OR v_approved_targets <> 6
       OR v_eligible <> 300 OR v_eligible_targets <> 150
       OR v_held <> 110 OR v_held_targets <> 55
    THEN
        RAISE EXCEPTION
            'STEP_12C_STATUS_CHANGED: approved=%, eligible=%, held=%',
            v_approved, v_eligible, v_held;
    END IF;

    UPDATE ops.harvest_scope_refresh_policy AS p
    SET policy_status = 'APPROVED',
        refresh_mode = 'MANUAL',
        min_refresh_interval_seconds = NULL,
        policy_reason = concat_ws(
            E'\n',
            NULLIF(p.policy_reason, ''),
            'Manuální obnova historického HB datasetu; sezóna 2024 doložena v katalogu API-Sports dne 2026-09-29.'
        ),
        approved_by = 'Petr',
        approved_at = v_now,
        updated_at = v_now
    WHERE p.ingest_target_id = ANY(v_target_ids)
      AND p.policy_status = 'DRAFT'
      AND p.refresh_mode = 'UNDECIDED';

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    SELECT
        count(*) FILTER (
            WHERE policy_status = 'APPROVED'
              AND refresh_mode = 'MANUAL'
        ),
        count(*) FILTER (
            WHERE policy_status = 'DRAFT'
              AND refresh_mode = 'UNDECIDED'
        )
    INTO v_approved_after, v_draft_after
    FROM ops.harvest_scope_refresh_policy;

    IF v_updated <> 300
       OR v_approved_after <> 312
       OR v_draft_after <> 110
    THEN
        RAISE EXCEPTION
            'STEP_12C_POSTCHECK_FAILED: updated=%, approved=%, draft=%',
            v_updated, v_approved_after, v_draft_after;
    END IF;

    RAISE NOTICE
        'STEP_12C_APPLY_OK: updated=%, approved_manual=%, draft_undecided=%',
        v_updated, v_approved_after, v_draft_after;
END
$step12c$;

COMMIT;

SELECT
    policy_status,
    refresh_mode,
    count(*) AS pravidel,
    count(DISTINCT ingest_target_id) AS targetu
FROM ops.harvest_scope_refresh_policy
GROUP BY policy_status, refresh_mode
ORDER BY policy_status, refresh_mode;