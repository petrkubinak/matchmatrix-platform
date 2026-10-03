/*
CO:
  STEP 12Q – kontrola registru jobů a auditní tabulky.

K ČEMU:
  Zjistit skutečnou strukturu tabulky odkazované cizím klíčem
  job_runs_job_code_fkey před opravou STEP 12P.

KDE:
  PC2 / PostgreSQL matchmatrix / DBeaver.

JAK:
  Spustit celý dotaz a poslat celý výsledek.
  READ ONLY – bez změn dat.
*/

WITH relations AS (
    SELECT to_regclass('ops.job_runs')::oid AS relation_oid

    UNION

    SELECT c.confrelid
    FROM pg_constraint c
    WHERE c.conrelid = to_regclass('ops.job_runs')
      AND c.contype = 'f'
      AND c.conname = 'job_runs_job_code_fkey'
),
objects AS (
    SELECT
        c.oid AS relation_oid,
        format('%I.%I', n.nspname, c.relname) AS object_name
    FROM relations r
    JOIN pg_class c
      ON c.oid = r.relation_oid
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
),
report AS (
    SELECT
        'ENVIRONMENT'::text AS section,
        current_database()::text AS object_name,
        'database_user'::text AS item,
        current_user::text AS detail

    UNION ALL

    SELECT
        'COLUMN',
        o.object_name,
        a.attname::text,
        format(
            'type=%s; nullable=%s; default=%s; identity=%s; generated=%s',
            format_type(a.atttypid, a.atttypmod),
            CASE WHEN a.attnotnull THEN 'NO' ELSE 'YES' END,
            COALESCE(
                pg_get_expr(d.adbin, d.adrelid),
                '<NULL>'
            ),
            COALESCE(NULLIF(a.attidentity::text, ''), '<NONE>'),
            COALESCE(NULLIF(a.attgenerated::text, ''), '<NONE>')
        )
    FROM objects o
    JOIN pg_attribute a
      ON a.attrelid = o.relation_oid
    LEFT JOIN pg_attrdef d
      ON d.adrelid = a.attrelid
     AND d.adnum = a.attnum
    WHERE a.attnum > 0
      AND NOT a.attisdropped

    UNION ALL

    SELECT
        'CONSTRAINT',
        o.object_name,
        c.conname::text,
        pg_get_constraintdef(c.oid, true)
    FROM objects o
    JOIN pg_constraint c
      ON c.conrelid = o.relation_oid

    UNION ALL

    SELECT
        'TRIGGER',
        o.object_name,
        t.tgname::text,
        pg_get_triggerdef(t.oid, true)
    FROM objects o
    JOIN pg_trigger t
      ON t.tgrelid = o.relation_oid
    WHERE NOT t.tgisinternal

    UNION ALL

    SELECT
        'STEP12P_AUDIT',
        'ops.job_runs',
        '27_2_96',
        format('rows=%s', COUNT(*))
    FROM ops.job_runs j
    WHERE j.params ->> 'script_prefix' = '27_2_96'
)
SELECT section, object_name, item, detail
FROM report
ORDER BY section, object_name, item;