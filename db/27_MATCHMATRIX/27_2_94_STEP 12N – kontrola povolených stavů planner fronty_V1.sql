
/*
CO:
  STEP 12N – kontrola struktury a povolených stavů fronty.

K ČEMU:
  Připravit způsob odložení jobů pro nepotvrzenou sezónu 2024
  podle skutečného databázového schématu.

KDE:
  DBeaver / databáze matchmatrix na PC2.

JAK:
  Spustit celý dotaz. Pouze čtení.
*/

WITH inspection AS (
    SELECT
        'COLUMN'::text AS category,
        'ops.' || c.table_name AS object_name,
        c.column_name::text AS item,
        CONCAT(
            'type=', c.data_type,
            '; udt=', c.udt_schema, '.', c.udt_name,
            '; nullable=', c.is_nullable,
            '; default=', COALESCE(c.column_default, '<NULL>')
        ) AS detail
    FROM information_schema.columns c
    WHERE c.table_schema = 'ops'
      AND c.table_name IN (
          'ingest_planner',
          'ingest_targets'
      )

    UNION ALL

    SELECT
        'CHECK_CONSTRAINT',
        n.nspname || '.' || r.relname,
        c.conname::text,
        pg_get_constraintdef(c.oid, true)
    FROM pg_constraint c
    JOIN pg_class r ON r.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = r.relnamespace
    WHERE n.nspname = 'ops'
      AND r.relname IN (
          'ingest_planner',
          'ingest_targets'
      )
      AND c.contype = 'c'

    UNION ALL

    SELECT
        'STATUS_ENUM',
        n.nspname || '.' || r.relname,
        e.enumlabel::text,
        'Povolena hodnota enum typu sloupce status'
    FROM pg_attribute a
    JOIN pg_class r ON r.oid = a.attrelid
    JOIN pg_namespace n ON n.oid = r.relnamespace
    JOIN pg_type t ON t.oid = a.atttypid
    JOIN pg_enum e ON e.enumtypid = CASE
        WHEN t.typtype = 'd' THEN t.typbasetype
        ELSE t.oid
    END
    WHERE n.nspname = 'ops'
      AND r.relname = 'ingest_planner'
      AND a.attname = 'status'
      AND a.attnum > 0
      AND NOT a.attisdropped

    UNION ALL

    SELECT
        'EXISTING_STATUS',
        'ops.ingest_planner',
        COALESCE(p.status::text, '<NULL>'),
        'rows=' || COUNT(*)::text
    FROM ops.ingest_planner p
    GROUP BY p.status
)
SELECT
    category,
    object_name,
    item,
    detail
FROM inspection
ORDER BY category, object_name, item;