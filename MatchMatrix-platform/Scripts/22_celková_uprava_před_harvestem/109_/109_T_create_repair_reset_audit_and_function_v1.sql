/*
MATCHMATRIX SQL 109_T Create Repair Reset Audit And Function V1

CO TO JE:
- Auditní tabulka a bezpečná funkce pro reset jedné opravené planner položky.

K ČEMU TO JE:
- Aby bylo dohledatelné, kdo/co resetoval.
- Aby šlo zjistit původní attempts/status/next_run.
- Aby bylo možné se k opravě vrátit.

KDE TO UVIDÍME:
- Panel V18
- AI OPS
- OPRAVY / BLOKOVANÉ
- Historie resetů

JAK SE TO VYUŽIJE:
- Admin ověří blokovanou položku.
- Potom zavolá funkci pro reset jedné konkrétní položky.
- Funkce zapíše audit a vrátí položku do pending.
*/


CREATE TABLE IF NOT EXISTS ops.repair_reset_audit (
    id bigserial PRIMARY KEY,

    provider text NOT NULL,
    sport_code text NOT NULL,
    entity text NOT NULL,
    provider_league_id text,
    season text,
    run_group text,

    old_status text,
    old_attempts integer,
    old_next_run timestamptz,
    old_last_attempt timestamptz,

    new_status text NOT NULL DEFAULT 'pending',
    new_attempts integer NOT NULL DEFAULT 0,
    new_next_run timestamptz NOT NULL DEFAULT now(),

    reset_reason text,
    reset_by text NOT NULL DEFAULT current_user,

    created_at timestamptz NOT NULL DEFAULT now()
);


CREATE OR REPLACE FUNCTION ops.fn_reset_repaired_planner_item_v1(
    p_provider text,
    p_sport_code text,
    p_entity text,
    p_provider_league_id text,
    p_season text,
    p_run_group text,
    p_reset_reason text DEFAULT 'Ruční ověření dokončeno'
)
RETURNS TABLE (
    reset_ok boolean,
    affected_rows integer,
    message text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_old record;
    v_count integer;
BEGIN

    SELECT *
    INTO v_old
    FROM ops.ingest_planner ip
    WHERE ip.provider = p_provider
      AND ip.sport_code = p_sport_code
      AND ip.entity = p_entity
      AND COALESCE(ip.provider_league_id, '') = COALESCE(p_provider_league_id, '')
      AND COALESCE(ip.season, '') = COALESCE(p_season, '')
      AND COALESCE(ip.run_group, '') = COALESCE(p_run_group, '')
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            false,
            0,
            'Planner položka nebyla nalezena.'::text;
        RETURN;
    END IF;

    INSERT INTO ops.repair_reset_audit (
        provider,
        sport_code,
        entity,
        provider_league_id,
        season,
        run_group,
        old_status,
        old_attempts,
        old_next_run,
        old_last_attempt,
        new_status,
        new_attempts,
        new_next_run,
        reset_reason
    )
    VALUES (
        v_old.provider,
        v_old.sport_code,
        v_old.entity,
        v_old.provider_league_id,
        v_old.season,
        v_old.run_group,
        v_old.status,
        v_old.attempts,
        v_old.next_run,
        v_old.last_attempt,
        'pending',
        0,
        now(),
        p_reset_reason
    );

    UPDATE ops.ingest_planner ip
    SET
        status = 'pending',
        attempts = 0,
        next_run = now(),
        updated_at = now()
    WHERE ip.id = v_old.id;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN QUERY
    SELECT
        true,
        v_count,
        'Planner položka byla resetována a zapsána do auditní historie.'::text;

END;
$$;


CREATE OR REPLACE VIEW ops.v_repair_reset_audit_recent_v1 AS
SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id AS league_id,
    season,
    run_group,
    old_status,
    old_attempts,
    old_next_run,
    old_last_attempt,
    new_status,
    new_attempts,
    new_next_run,
    reset_reason,
    reset_by,
    created_at
FROM ops.repair_reset_audit
ORDER BY created_at DESC, id DESC;