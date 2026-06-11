/*
MATCHMATRIX SQL 17_9_F
EXECUTE MISSING CANONICAL TEAM MERGE V1

CO TO JE:
- Bezpečný transakční merge týmů z api_football_missing_canonical na api_football.

K ČEMU TO JE:
- Přepíše reference z missing_team_id na canonical_team_id.
- Potom smaže duplicitní missing_canonical týmy.

KDE TO UVIDÍME:
- OPS / DATA QUALITY / TEAM DUPLICATE PREVENTION.

JAK SE TO VYUŽIJE:
- Opraví 118 potvrzených duplicit.
- Po opravě má SUSPECT_MISSING_CANONICAL spadnout na 0.
*/

BEGIN;

CREATE TABLE IF NOT EXISTS ops.team_missing_canonical_merge_run_log (
    id bigserial PRIMARY KEY,
    run_at timestamptz DEFAULT now(),
    table_schema text,
    table_name text,
    column_name text,
    affected_rows bigint
);

CREATE TEMP TABLE tmp_missing_canonical_team_map AS
SELECT
    canonical_team_id::bigint,
    missing_team_id::bigint
FROM ops.v_missing_canonical_team_fix_plan_v1;

-- Kontrola očekávaného počtu
DO $$
DECLARE
    v_count bigint;
BEGIN
    SELECT COUNT(*) INTO v_count FROM tmp_missing_canonical_team_map;

    IF v_count <> 118 THEN
        RAISE EXCEPTION 'STOP: očekáváno 118 merge párů, nalezeno %', v_count;
    END IF;
END $$;

-- Přepis referencí ve skutečných tabulkách, ne ve view.
DO $$
DECLARE
    r record;
    v_sql text;
    v_rows bigint;
BEGIN
    FOR r IN
        SELECT
            c.table_schema,
            c.table_name,
            c.column_name
        FROM information_schema.columns c
        JOIN information_schema.tables t
          ON t.table_schema = c.table_schema
         AND t.table_name = c.table_name
        WHERE c.table_schema IN ('public', 'staging', 'ops')
          AND t.table_type = 'BASE TABLE'
          AND c.data_type IN ('integer', 'bigint')
          AND c.column_name IN (
                'team_id',
                'home_team_id',
                'away_team_id',
                'canonical_team_id',
                'public_team_id',
                'mapped_team_id',
                'source_team_id',
                'target_team_id',
                'master_team_id',
                'old_team_id',
                'from_team_id',
                'to_team_id',
                'primary_team_id',
                'sample_team_id'
          )
          AND NOT (c.table_schema = 'public' AND c.table_name = 'teams' AND c.column_name = 'id')
        ORDER BY c.table_schema, c.table_name, c.column_name
    LOOP
        v_sql := format(
            'UPDATE %I.%I x
             SET %I = m.canonical_team_id
             FROM tmp_missing_canonical_team_map m
             WHERE x.%I = m.missing_team_id',
            r.table_schema,
            r.table_name,
            r.column_name,
            r.column_name
        );

        EXECUTE v_sql;
        GET DIAGNOSTICS v_rows = ROW_COUNT;

        INSERT INTO ops.team_missing_canonical_merge_run_log (
            table_schema,
            table_name,
            column_name,
            affected_rows
        )
        VALUES (
            r.table_schema,
            r.table_name,
            r.column_name,
            v_rows
        );
    END LOOP;
END $$;

-- Kontrola, jestli ještě někde zůstaly missing team_id reference.
CREATE TEMP TABLE tmp_remaining_missing_team_refs (
    table_schema text,
    table_name text,
    column_name text,
    remaining_rows bigint
);

DO $$
DECLARE
    r record;
    v_sql text;
    v_rows bigint;
BEGIN
    FOR r IN
        SELECT
            c.table_schema,
            c.table_name,
            c.column_name
        FROM information_schema.columns c
        JOIN information_schema.tables t
          ON t.table_schema = c.table_schema
         AND t.table_name = c.table_name
        WHERE c.table_schema IN ('public', 'staging', 'ops')
          AND t.table_type = 'BASE TABLE'
          AND c.data_type IN ('integer', 'bigint')
          AND c.column_name IN (
                'team_id',
                'home_team_id',
                'away_team_id',
                'canonical_team_id',
                'public_team_id',
                'mapped_team_id',
                'source_team_id',
                'target_team_id',
                'master_team_id',
                'old_team_id',
                'from_team_id',
                'to_team_id',
                'primary_team_id',
                'sample_team_id'
          )
          AND NOT (c.table_schema = 'public' AND c.table_name = 'teams' AND c.column_name = 'id')
        ORDER BY c.table_schema, c.table_name, c.column_name
    LOOP
        v_sql := format(
            'SELECT COUNT(*)
             FROM %I.%I x
             JOIN tmp_missing_canonical_team_map m
               ON x.%I = m.missing_team_id',
            r.table_schema,
            r.table_name,
            r.column_name
        );

        EXECUTE v_sql INTO v_rows;

        IF v_rows > 0 THEN
            INSERT INTO tmp_remaining_missing_team_refs
            VALUES (r.table_schema, r.table_name, r.column_name, v_rows);
        END IF;
    END LOOP;
END $$;

-- Stop, pokud někde reference zůstaly.
DO $$
DECLARE
    v_remaining bigint;
BEGIN
    SELECT COALESCE(SUM(remaining_rows), 0)
    INTO v_remaining
    FROM tmp_remaining_missing_team_refs;

    IF v_remaining > 0 THEN
        RAISE EXCEPTION 'STOP: stále existují reference na missing_team_id: %', v_remaining;
    END IF;
END $$;

-- Smazání duplicitních missing_canonical týmů.
DELETE FROM public.teams t
USING tmp_missing_canonical_team_map m
WHERE t.id = m.missing_team_id
  AND t.ext_source = 'api_football_missing_canonical';

COMMIT;