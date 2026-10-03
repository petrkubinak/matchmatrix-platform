/* =============================================================================
CO:
    G4D-3 / STEP 4B-3
    FINAL ROUTING PHYSICAL CONTRACT

K ČEMU:
    Definitivní uzavření fyzického kontraktu
    ops.data_acquisition_source_routing.

    Získá v JEDNOM výsledku:
    - transaction mode,
    - všechny fyzické sloupce,
    - všechny constrainty,
    - všechny indexy,
    - všechny triggery,
    - outbound FK,
    - inbound FK,
    - počet routing řádků.

KDE:
    PostgreSQL matchmatrix / PC2

JAK:
    Spustit CELÝ SCRIPT najednou v DBeaveru.
    Exportovat pouze hlavní výsledkovou tabulku.

BEZPEČNOST:
    BEGIN TRANSACTION READ ONLY
    pouze katalogové SELECTy
    ROLLBACK
============================================================================= */

BEGIN TRANSACTION READ ONLY;


/* ============================================================================
JEDEN SPOLEČNÝ REPORT
============================================================================ */

WITH report AS (

    /* ------------------------------------------------------------------------
    01 — TRANSACTION MODE
    ------------------------------------------------------------------------ */

    SELECT
        10 AS sort_group,
        1  AS sort_item,
        'TRANSACTION'::text AS section,
        'transaction_read_only'::text AS object_name,
        current_setting('transaction_read_only')::text AS detail


    UNION ALL


    /* ------------------------------------------------------------------------
    02 — VŠECHNY FYZICKÉ SLOUPCE
    ------------------------------------------------------------------------ */

    SELECT
        20 AS sort_group,
        c.ordinal_position AS sort_item,
        'COLUMN'::text AS section,
        c.column_name::text AS object_name,

        concat(
            'position=', c.ordinal_position,
            ' | data_type=', c.data_type,
            ' | udt=', c.udt_schema, '.', c.udt_name,
            ' | nullable=', c.is_nullable,
            ' | default=', COALESCE(c.column_default, '<NULL>'),
            ' | identity=', c.is_identity,
            ' | identity_generation=',
                COALESCE(c.identity_generation, '<NULL>')
        ) AS detail

    FROM information_schema.columns c

    WHERE c.table_schema = 'ops'
      AND c.table_name = 'data_acquisition_source_routing'


    UNION ALL


    /* ------------------------------------------------------------------------
    03 — VŠECHNY CONSTRAINTY
    ------------------------------------------------------------------------ */

    SELECT
        30 AS sort_group,
        ROW_NUMBER() OVER (ORDER BY con.contype, con.conname)::integer
            AS sort_item,

        'CONSTRAINT'::text AS section,
        con.conname::text AS object_name,

        concat(
            'type=', con.contype,
            ' | deferrable=', con.condeferrable,
            ' | deferred=', con.condeferred,
            ' | validated=', con.convalidated,
            ' | definition=',
            pg_get_constraintdef(con.oid, true)
        ) AS detail

    FROM pg_constraint con

    JOIN pg_class rel
      ON rel.oid = con.conrelid

    JOIN pg_namespace nsp
      ON nsp.oid = rel.relnamespace

    WHERE nsp.nspname = 'ops'
      AND rel.relname = 'data_acquisition_source_routing'


    UNION ALL


    /* ------------------------------------------------------------------------
    04 — VŠECHNY INDEXY
    ------------------------------------------------------------------------ */

    SELECT
        40 AS sort_group,
        ROW_NUMBER() OVER (ORDER BY p.indexname)::integer AS sort_item,

        'INDEX'::text AS section,
        p.indexname::text AS object_name,
        p.indexdef::text AS detail

    FROM pg_indexes p

    WHERE p.schemaname = 'ops'
      AND p.tablename = 'data_acquisition_source_routing'


    UNION ALL


    /* ------------------------------------------------------------------------
    05 — UŽIVATELSKÉ TRIGGERY
    ------------------------------------------------------------------------ */

    SELECT
        50 AS sort_group,
        ROW_NUMBER() OVER (ORDER BY trg.tgname)::integer AS sort_item,

        'TRIGGER'::text AS section,
        trg.tgname::text AS object_name,

        concat(
            'enabled=', trg.tgenabled,
            ' | ',
            pg_get_triggerdef(trg.oid, true)
        ) AS detail

    FROM pg_trigger trg

    JOIN pg_class rel
      ON rel.oid = trg.tgrelid

    JOIN pg_namespace nsp
      ON nsp.oid = rel.relnamespace

    WHERE nsp.nspname = 'ops'
      AND rel.relname = 'data_acquisition_source_routing'
      AND NOT trg.tgisinternal


    UNION ALL


    /* ------------------------------------------------------------------------
    06 — OUTBOUND FOREIGN KEYS
    ------------------------------------------------------------------------ */

    SELECT
        60 AS sort_group,
        ROW_NUMBER() OVER (ORDER BY con.conname)::integer AS sort_item,

        'OUTBOUND_FK'::text AS section,
        con.conname::text AS object_name,
        pg_get_constraintdef(con.oid, true)::text AS detail

    FROM pg_constraint con

    JOIN pg_class rel
      ON rel.oid = con.conrelid

    JOIN pg_namespace nsp
      ON nsp.oid = rel.relnamespace

    WHERE nsp.nspname = 'ops'
      AND rel.relname = 'data_acquisition_source_routing'
      AND con.contype = 'f'


    UNION ALL


    /* ------------------------------------------------------------------------
    07 — INBOUND FOREIGN KEYS
    ------------------------------------------------------------------------ */

    SELECT
        70 AS sort_group,
        ROW_NUMBER() OVER (
            ORDER BY src_ns.nspname, src_rel.relname, con.conname
        )::integer AS sort_item,

        'INBOUND_FK'::text AS section,

        concat(
            src_ns.nspname,
            '.',
            src_rel.relname,
            '.',
            con.conname
        ) AS object_name,

        pg_get_constraintdef(con.oid, true)::text AS detail

    FROM pg_constraint con

    JOIN pg_class src_rel
      ON src_rel.oid = con.conrelid

    JOIN pg_namespace src_ns
      ON src_ns.oid = src_rel.relnamespace

    JOIN pg_class dst_rel
      ON dst_rel.oid = con.confrelid

    JOIN pg_namespace dst_ns
      ON dst_ns.oid = dst_rel.relnamespace

    WHERE con.contype = 'f'
      AND dst_ns.nspname = 'ops'
      AND dst_rel.relname = 'data_acquisition_source_routing'


    UNION ALL


    /* ------------------------------------------------------------------------
    08 — ROUTING ROW COUNT
    ------------------------------------------------------------------------ */

    SELECT
        80 AS sort_group,
        1 AS sort_item,

        'ROW_COUNT'::text AS section,
        'data_acquisition_source_routing'::text AS object_name,

        concat(
            'rows=',
            COUNT(*),
            ' | status=',
            CASE
                WHEN COUNT(*) = 0
                    THEN 'PASS'
                ELSE
                    'BLOCKER_REVIEW_REQUIRED'
            END
        ) AS detail

    FROM ops.data_acquisition_source_routing
)

SELECT
    section,
    object_name,
    detail
FROM report
ORDER BY
    sort_group,
    sort_item,
    object_name;


ROLLBACK;