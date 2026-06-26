/*
MATCHMATRIX SQL 17_9_G
FIX REAL PROVIDER DUPLICATE ARSENAL V2

CO TO JE:
- Bezpečný merge jediné skutečné provider duplicity:
  Arsenal / api_football / 9419.

K ČEMU TO JE:
- Přepíše reference z duplicate_team_id na canonical_team_id.
- Ošetří konflikt v public.team_provider_map.
- Potom smaže duplicitní tým.

KDE TO UVIDÍME:
- OPS / DATA QUALITY / TEAM DUPLICATE PREVENTION.

JAK SE TO VYUŽIJE:
- Po opravě má REAL_PROVIDER_DUPLICATE spadnout z 1 na 0.
*/

BEGIN;

CREATE TABLE IF NOT EXISTS ops.team_real_provider_duplicate_merge_run_log (
    id bigserial PRIMARY KEY,
    run_at timestamptz DEFAULT now(),
    duplicate_group text,
    table_schema text,
    table_name text,
    column_name text,
    affected_rows bigint
);

CREATE TEMP TABLE tmp_real_provider_duplicate_team_map AS
SELECT
    119224::bigint AS canonical_team_id,
    118199::bigint AS duplicate_team_id,
    'arsenal/api_football/9419'::text AS duplicate_group;

-- 1) Nejdřív smažeme duplicitní provider mapu, která by porušila unique constraint.
DELETE FROM public.team_provider_map tpm
USING tmp_real_provider_duplicate_team_map m
WHERE tpm.team_id = m.duplicate_team_id
  AND EXISTS (
      SELECT 1
      FROM public.team_provider_map keep
      WHERE keep.team_id = m.canonical_team_id
        AND keep.provider = tpm.provider
  );

-- 2) Přepis referencí ve skutečných tabulkách.
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
             FROM tmp_real_provider_duplicate_team_map m
             WHERE x.%I = m.duplicate_team_id',
            r.table_schema,
            r.table_name,
            r.column_name,
            r.column_name
        );

        EXECUTE v_sql;
        GET DIAGNOSTICS v_rows = ROW_COUNT;

        INSERT INTO ops.team_real_provider_duplicate_merge_run_log (
            duplicate_group,
            table_schema,
            table_name,
            column_name,
            affected_rows
        )
        SELECT
            duplicate_group,
            r.table_schema,
            r.table_name,
            r.column_name,
            v_rows
        FROM tmp_real_provider_duplicate_team_map;
    END LOOP;
END $$;

-- 3) Kontrola, jestli někde zůstala reference na duplicate_team_id.
CREATE TEMP TABLE tmp_remaining_real_provider_duplicate_refs (
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
             JOIN tmp_real_provider_duplicate_team_map m
               ON x.%I = m.duplicate_team_id',
            r.table_schema,
            r.table_name,
            r.column_name
        );

        EXECUTE v_sql INTO v_rows;

        IF v_rows > 0 THEN
            INSERT INTO tmp_remaining_real_provider_duplicate_refs
            VALUES (r.table_schema, r.table_name, r.column_name, v_rows);
        END IF;
    END LOOP;
END $$;

DO $$
DECLARE
    v_remaining bigint;
BEGIN
    SELECT COALESCE(SUM(remaining_rows), 0)
    INTO v_remaining
    FROM tmp_remaining_real_provider_duplicate_refs;

    IF v_remaining > 0 THEN
        RAISE EXCEPTION 'STOP: stále existují reference na Arsenal duplicate_team_id: %', v_remaining;
    END IF;
END $$;

-- 4) Smazání duplicitního týmu.
DELETE FROM public.teams
WHERE id = 118199;

COMMIT;