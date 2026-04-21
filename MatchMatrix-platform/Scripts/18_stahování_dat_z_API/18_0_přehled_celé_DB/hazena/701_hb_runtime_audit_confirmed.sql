-- 701_hb_runtime_audit_confirmed.sql
-- Cíl:
-- Dopsat / updatovat runtime audit pro HB entities:
-- - leagues
-- - teams
-- - fixtures
--
-- Poznámka:
-- Neznáme na 100 % finální strukturu ops.runtime_entity_audit v aktuální DB,
-- proto je skript napsaný robustně:
-- 1) ověří existenci tabulky
-- 2) provede UPDATE podle dostupných sloupců
-- 3) pokud řádek neexistuje a tabulka obsahuje minimální klíčové sloupce, provede INSERT
--
-- Stavová logika:
-- leagues  -> CONFIRMED
-- teams    -> CONFIRMED
-- fixtures -> CONFIRMED
--
-- Pokud chceš být přísnější, můžeš u fixtures změnit current_state na PARTIAL.

DO $$
DECLARE
    v_table_exists boolean;
    v_has_provider boolean;
    v_has_sport_code boolean;
    v_has_entity boolean;
    v_has_current_state boolean;
    v_has_state_reason boolean;
    v_has_last_run_group boolean;
    v_has_db_evidence_summary boolean;
    v_has_pull_confirmed boolean;
    v_has_raw_confirmed boolean;
    v_has_staging_confirmed boolean;
    v_has_provider_map_confirmed boolean;
    v_has_public_merge_confirmed boolean;
    v_has_downstream_confirmed boolean;
    v_has_updated_at boolean;

    r record;
    v_sql text;
    v_exists_row boolean;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'ops'
          AND table_name = 'runtime_entity_audit'
    )
    INTO v_table_exists;

    IF NOT v_table_exists THEN
        RAISE EXCEPTION 'Tabulka ops.runtime_entity_audit neexistuje.';
    END IF;

    -- sloupce
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='provider'
    ) INTO v_has_provider;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='sport_code'
    ) INTO v_has_sport_code;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='entity'
    ) INTO v_has_entity;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='current_state'
    ) INTO v_has_current_state;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='state_reason'
    ) INTO v_has_state_reason;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='last_run_group'
    ) INTO v_has_last_run_group;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='db_evidence_summary'
    ) INTO v_has_db_evidence_summary;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='pull_confirmed'
    ) INTO v_has_pull_confirmed;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='raw_confirmed'
    ) INTO v_has_raw_confirmed;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='staging_confirmed'
    ) INTO v_has_staging_confirmed;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='provider_map_confirmed'
    ) INTO v_has_provider_map_confirmed;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='public_merge_confirmed'
    ) INTO v_has_public_merge_confirmed;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='downstream_confirmed'
    ) INTO v_has_downstream_confirmed;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ops' AND table_name='runtime_entity_audit' AND column_name='updated_at'
    ) INTO v_has_updated_at;

    FOR r IN
        SELECT *
        FROM (
            VALUES
                ('api_handball','HB','leagues','CONFIRMED',
                 'HB leagues smoke test potvrzen: pull/raw/parser/staging funguje pro api_handball.',
                 'HB_CORE_SMOKE',
                 'staging.stg_provider_leagues naplněno; potvrzeny ligy včetně 131 Champions League a 145 EHF European League.'),

                ('api_handball','HB','teams','CONFIRMED',
                 'HB teams smoke test potvrzen: provider_league_id=131, season=2024 vrací data a staging je naplněný.',
                 'HB_CORE_SMOKE',
                 'staging.stg_provider_teams naplněno; potvrzené týmy např. Aalborg, Barcelona, PSG, Veszprem.'),

                ('api_handball','HB','fixtures','CONFIRMED',
                 'HB fixtures smoke test potvrzen: handball používá endpoint games, bez from/to, parser navázán.',
                 'HB_CORE_SMOKE',
                 'staging.stg_provider_fixtures count=132 pro provider_league_id=131 / season=2024.')
        ) AS x(provider, sport_code, entity, current_state, state_reason, last_run_group, db_evidence_summary)
    LOOP
        IF NOT (v_has_provider AND v_has_sport_code AND v_has_entity) THEN
            RAISE EXCEPTION 'ops.runtime_entity_audit nemá minimální klíče provider/sport_code/entity.';
        END IF;

        EXECUTE format(
            'SELECT EXISTS (
                SELECT 1
                FROM ops.runtime_entity_audit
                WHERE provider = %L
                  AND sport_code = %L
                  AND entity = %L
            )',
            r.provider, r.sport_code, r.entity
        )
        INTO v_exists_row;

        IF v_exists_row THEN
            v_sql := 'UPDATE ops.runtime_entity_audit SET ';
            v_sql := v_sql || array_to_string(array_remove(ARRAY[
                CASE WHEN v_has_current_state THEN format('current_state = %L', r.current_state) END,
                CASE WHEN v_has_state_reason THEN format('state_reason = %L', r.state_reason) END,
                CASE WHEN v_has_last_run_group THEN format('last_run_group = %L', r.last_run_group) END,
                CASE WHEN v_has_db_evidence_summary THEN format('db_evidence_summary = %L', r.db_evidence_summary) END,
                CASE WHEN v_has_pull_confirmed THEN 'pull_confirmed = true' END,
                CASE WHEN v_has_raw_confirmed THEN 'raw_confirmed = true' END,
                CASE WHEN v_has_staging_confirmed THEN 'staging_confirmed = true' END,
                CASE WHEN v_has_provider_map_confirmed THEN 'provider_map_confirmed = false' END,
                CASE WHEN v_has_public_merge_confirmed THEN 'public_merge_confirmed = false' END,
                CASE WHEN v_has_downstream_confirmed THEN 'downstream_confirmed = false' END,
                CASE WHEN v_has_updated_at THEN 'updated_at = now()' END
            ], NULL), ', ');

            v_sql := v_sql || format(
                ' WHERE provider = %L AND sport_code = %L AND entity = %L',
                r.provider, r.sport_code, r.entity
            );

            EXECUTE v_sql;
        ELSE
            -- INSERT jen pokud má tabulka očekávatelné sloupce
            v_sql := 'INSERT INTO ops.runtime_entity_audit (';
            v_sql := v_sql || array_to_string(array_remove(ARRAY[
                CASE WHEN v_has_provider THEN 'provider' END,
                CASE WHEN v_has_sport_code THEN 'sport_code' END,
                CASE WHEN v_has_entity THEN 'entity' END,
                CASE WHEN v_has_current_state THEN 'current_state' END,
                CASE WHEN v_has_state_reason THEN 'state_reason' END,
                CASE WHEN v_has_last_run_group THEN 'last_run_group' END,
                CASE WHEN v_has_db_evidence_summary THEN 'db_evidence_summary' END,
                CASE WHEN v_has_pull_confirmed THEN 'pull_confirmed' END,
                CASE WHEN v_has_raw_confirmed THEN 'raw_confirmed' END,
                CASE WHEN v_has_staging_confirmed THEN 'staging_confirmed' END,
                CASE WHEN v_has_provider_map_confirmed THEN 'provider_map_confirmed' END,
                CASE WHEN v_has_public_merge_confirmed THEN 'public_merge_confirmed' END,
                CASE WHEN v_has_downstream_confirmed THEN 'downstream_confirmed' END,
                CASE WHEN v_has_updated_at THEN 'updated_at' END
            ], NULL), ', ');

            v_sql := v_sql || ') VALUES (';
            v_sql := v_sql || array_to_string(array_remove(ARRAY[
                CASE WHEN v_has_provider THEN format('%L', r.provider) END,
                CASE WHEN v_has_sport_code THEN format('%L', r.sport_code) END,
                CASE WHEN v_has_entity THEN format('%L', r.entity) END,
                CASE WHEN v_has_current_state THEN format('%L', r.current_state) END,
                CASE WHEN v_has_state_reason THEN format('%L', r.state_reason) END,
                CASE WHEN v_has_last_run_group THEN format('%L', r.last_run_group) END,
                CASE WHEN v_has_db_evidence_summary THEN format('%L', r.db_evidence_summary) END,
                CASE WHEN v_has_pull_confirmed THEN 'true' END,
                CASE WHEN v_has_raw_confirmed THEN 'true' END,
                CASE WHEN v_has_staging_confirmed THEN 'true' END,
                CASE WHEN v_has_provider_map_confirmed THEN 'false' END,
                CASE WHEN v_has_public_merge_confirmed THEN 'false' END,
                CASE WHEN v_has_downstream_confirmed THEN 'false' END,
                CASE WHEN v_has_updated_at THEN 'now()' END
            ], NULL), ', ');

            v_sql := v_sql || ')';
            EXECUTE v_sql;
        END IF;
    END LOOP;

    RAISE NOTICE 'HB runtime audit byl zapsán/aktualizován.';
END $$;

-- kontrola
SELECT *
FROM ops.runtime_entity_audit
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity IN ('leagues','teams','fixtures')
ORDER BY entity;