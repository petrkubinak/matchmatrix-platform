/*
===============================================================================
MATCHMATRIX STANDARDNÍ HLAVIČKA
===============================================================================

DOCUMENT ID:
25_1_A_25

NÁZEV:
EXTEND DOCUMENTATION HISTORY CONSTRAINTS V1

CO:
Synchronizuje databázová validační pravidla tabulky
`documentation.documents` se standardem MM-STD-007.

K ČEMU:
- zachová stávající identifikátory dokumentace;
- povolí denní zápisy ve formátu `MM-DL-YYYYMMDD`;
- povolí dokumenty NAVÁZÁNÍ ve formátu `MM-NAV-YYYYMMDD-PP`;
- povolí databázové typy dokumentů `DL` a `NAV`;
- ověří všechna existující data před i po změně;
- umožní následný import přes A24.

KDE:
C:\MatchMatrix-platform\db\migrations\
25_1_A_25_EXTEND_DOCUMENTATION_HISTORY_CONSTRAINTS_V1.sql

JAK:
1. Uložit tento soubor do uvedené složky.
2. Zařadit migraci do Git:
   git add -- "db\migrations\25_1_A_25_EXTEND_DOCUMENTATION_HISTORY_CONSTRAINTS_V1.sql"
   git commit -m "db: align documentation history constraints with MM-STD-007"
   git push origin main
3. Spustit celý SQL soubor v DBeaveru nad databází `matchmatrix`.
4. Zkontrolovat závěrečné ověřovací výpisy.
5. Znovu spustit A24 nejprve jako DRY RUN.
6. `--apply` spustit pouze po úspěšném DRY RUN.

VSTUPNÍ STANDARD:
MM-STD-007 – Identifikace a číslování dokumentů MatchMatrix

NOVÉ IDENTIFIKÁTORY:
- MM-DL-YYYYMMDD
- MM-NAV-YYYYMMDD-PP

NOVÉ DOCUMENT TYPES:
- DL
- NAV

BEZPEČNOST:
- migrace běží v jedné transakci;
- při jakékoliv chybě se změny vrátí zpět;
- dokumentační obsah se nemění;
- žádné dokumenty se nevkládají ani nemažou;
- existující hodnoty jsou validovány před změnou;
- constrainty jsou po vytvoření explicitně validovány;
- používá se transakční advisory lock proti souběžnému spuštění.

ROLLBACK:
Případný rollback musí obnovit původní constrainty z databázové
dokumentace před A25. Rollback nespouštět automaticky po úspěšném importu
MM-DL nebo MM-NAV, protože by jejich záznamy přestaly splňovat pravidla.

VERZE:
V1

DATUM:
2026-07-01

===============================================================================
*/

BEGIN;

SET LOCAL lock_timeout = '15s';
SET LOCAL statement_timeout = '5min';

-- Zabrání souběžnému spuštění stejné MatchMatrix migrace.
SELECT pg_advisory_xact_lock(
    hashtext('MatchMatrix:A25:documentation-history-constraints')
);

-- ---------------------------------------------------------------------------
-- 1. PRE-FLIGHT: existence schématu, tabulky a požadovaných sloupců
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    missing_items text[];
BEGIN
    missing_items := ARRAY[]::text[];

    IF NOT EXISTS (
        SELECT 1
        FROM pg_namespace
        WHERE nspname = 'documentation'
    ) THEN
        missing_items := array_append(
            missing_items,
            'schema documentation'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'documentation'
          AND table_name = 'documents'
    ) THEN
        missing_items := array_append(
            missing_items,
            'table documentation.documents'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'documentation'
          AND table_name = 'documents'
          AND column_name = 'document_id'
    ) THEN
        missing_items := array_append(
            missing_items,
            'column documentation.documents.document_id'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'documentation'
          AND table_name = 'documents'
          AND column_name = 'document_type'
    ) THEN
        missing_items := array_append(
            missing_items,
            'column documentation.documents.document_type'
        );
    END IF;

    IF cardinality(missing_items) > 0 THEN
        RAISE EXCEPTION
            'A25 BLOCKED: missing database objects: %',
            array_to_string(missing_items, ', ');
    END IF;
END
$$;

LOCK TABLE documentation.documents
    IN SHARE ROW EXCLUSIVE MODE;

-- ---------------------------------------------------------------------------
-- 2. PRE-FLIGHT: kontrola existujících Document ID
--
-- Zachovaný původní formát:
--   MM-<TYP>-NNN
--   MM-<TYP>-NNNN
--   volitelně jedno koncové písmeno
--
-- Nové formáty podle MM-STD-007:
--   MM-DL-YYYYMMDD
--   MM-NAV-YYYYMMDD-PP
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    invalid_count bigint;
    invalid_samples text;
BEGIN
    SELECT
        count(*),
        string_agg(document_id, ', ' ORDER BY document_id)
    INTO
        invalid_count,
        invalid_samples
    FROM (
        SELECT document_id
        FROM documentation.documents
        WHERE document_id IS NOT NULL
          AND NOT (
              document_id ~ '^MM-[A-Z]{2,10}-[0-9]{3,4}[A-Z]?$'
              OR document_id ~ '^MM-DL-[0-9]{8}$'
              OR document_id ~ '^MM-NAV-[0-9]{8}-[0-9]{2}$'
          )
        ORDER BY document_id
        LIMIT 20
    ) AS invalid_ids;

    IF invalid_count > 0 THEN
        RAISE EXCEPTION
            'A25 BLOCKED: % existing document_id values are invalid. Samples: %',
            invalid_count,
            coalesce(invalid_samples, '<none>');
    END IF;
END
$$;

-- ---------------------------------------------------------------------------
-- 3. PRE-FLIGHT: kontrola existujících typů dokumentů
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    invalid_count bigint;
    invalid_samples text;
BEGIN
    SELECT
        count(*),
        string_agg(document_type, ', ' ORDER BY document_type)
    INTO
        invalid_count,
        invalid_samples
    FROM (
        SELECT DISTINCT document_type
        FROM documentation.documents
        WHERE document_type IS NOT NULL
          AND document_type <> ALL (
              ARRAY[
                  'DOC'::text,
                  'STD'::text,
                  'REF'::text,
                  'BOOK'::text,
                  'MST'::text,
                  'GOV'::text,
                  'ARC'::text,
                  'DB'::text,
                  'PRV'::text,
                  'LAY'::text,
                  'OPS'::text,
                  'DEV'::text,
                  'HIS'::text,
                  'VIS'::text,
                  'TPL'::text,
                  'EXP'::text,
                  'DRF'::text,
                  'ARCV'::text,
                  'DL'::text,
                  'NAV'::text,
                  'OTHER'::text
              ]
          )
        ORDER BY document_type
        LIMIT 20
    ) AS invalid_types;

    IF invalid_count > 0 THEN
        RAISE EXCEPTION
            'A25 BLOCKED: % existing document_type values are invalid. Samples: %',
            invalid_count,
            coalesce(invalid_samples, '<none>');
    END IF;
END
$$;

-- ---------------------------------------------------------------------------
-- 4. ZMĚNA CONSTRAINTU PRO DOCUMENT ID
-- ---------------------------------------------------------------------------

ALTER TABLE documentation.documents
    DROP CONSTRAINT IF EXISTS ck_documentation_documents_id;

ALTER TABLE documentation.documents
    ADD CONSTRAINT ck_documentation_documents_id
    CHECK (
        document_id ~ '^MM-[A-Z]{2,10}-[0-9]{3,4}[A-Z]?$'
        OR document_id ~ '^MM-DL-[0-9]{8}$'
        OR document_id ~ '^MM-NAV-[0-9]{8}-[0-9]{2}$'
    )
    NOT VALID;

ALTER TABLE documentation.documents
    VALIDATE CONSTRAINT ck_documentation_documents_id;

COMMENT ON CONSTRAINT ck_documentation_documents_id
    ON documentation.documents
IS
    'MatchMatrix Document ID: původní MM-<TYPE>-NNN/NNNN, '
    'MM-DL-YYYYMMDD a MM-NAV-YYYYMMDD-PP podle MM-STD-007.';

-- ---------------------------------------------------------------------------
-- 5. ZMĚNA CONSTRAINTU PRO DOCUMENT TYPE
-- ---------------------------------------------------------------------------

ALTER TABLE documentation.documents
    DROP CONSTRAINT IF EXISTS ck_documentation_documents_type;

ALTER TABLE documentation.documents
    ADD CONSTRAINT ck_documentation_documents_type
    CHECK (
        document_type = ANY (
            ARRAY[
                'DOC'::text,
                'STD'::text,
                'REF'::text,
                'BOOK'::text,
                'MST'::text,
                'GOV'::text,
                'ARC'::text,
                'DB'::text,
                'PRV'::text,
                'LAY'::text,
                'OPS'::text,
                'DEV'::text,
                'HIS'::text,
                'VIS'::text,
                'TPL'::text,
                'EXP'::text,
                'DRF'::text,
                'ARCV'::text,
                'DL'::text,
                'NAV'::text,
                'OTHER'::text
            ]
        )
    )
    NOT VALID;

ALTER TABLE documentation.documents
    VALIDATE CONSTRAINT ck_documentation_documents_type;

COMMENT ON CONSTRAINT ck_documentation_documents_type
    ON documentation.documents
IS
    'Povolené MatchMatrix typy dokumentů včetně DL a NAV podle MM-STD-007.';

-- ---------------------------------------------------------------------------
-- 6. TRANSAKČNÍ POST-CHECK
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    id_constraint_validated boolean;
    type_constraint_validated boolean;
BEGIN
    SELECT convalidated
    INTO id_constraint_validated
    FROM pg_constraint
    WHERE conname = 'ck_documentation_documents_id'
      AND conrelid = 'documentation.documents'::regclass;

    SELECT convalidated
    INTO type_constraint_validated
    FROM pg_constraint
    WHERE conname = 'ck_documentation_documents_type'
      AND conrelid = 'documentation.documents'::regclass;

    IF id_constraint_validated IS DISTINCT FROM true THEN
        RAISE EXCEPTION
            'A25 BLOCKED: ck_documentation_documents_id is not validated.';
    END IF;

    IF type_constraint_validated IS DISTINCT FROM true THEN
        RAISE EXCEPTION
            'A25 BLOCKED: ck_documentation_documents_type is not validated.';
    END IF;
END
$$;

COMMIT;

-- ===========================================================================
-- 7. VÝSTUPNÍ AUDIT PO ÚSPĚŠNÉM COMMITU
-- ===========================================================================

SELECT
    con.conname AS constraint_name,
    pg_get_constraintdef(con.oid, true) AS constraint_definition,
    con.convalidated AS is_validated
FROM pg_constraint AS con
JOIN pg_class AS rel
    ON rel.oid = con.conrelid
JOIN pg_namespace AS nsp
    ON nsp.oid = rel.relnamespace
WHERE nsp.nspname = 'documentation'
  AND rel.relname = 'documents'
  AND con.conname IN (
      'ck_documentation_documents_id',
      'ck_documentation_documents_type'
  )
ORDER BY con.conname;

-- ---------------------------------------------------------------------------
-- 8. FUNKČNÍ TEST DOCUMENT ID
-- ---------------------------------------------------------------------------

SELECT
    test_document_id,
    (
        test_document_id ~ '^MM-[A-Z]{2,10}-[0-9]{3,4}[A-Z]?$'
        OR test_document_id ~ '^MM-DL-[0-9]{8}$'
        OR test_document_id ~ '^MM-NAV-[0-9]{8}-[0-9]{2}$'
    ) AS accepted
FROM (
    VALUES
        ('MM-DOC-000'),
        ('MM-STD-007'),
        ('MM-STD-1000'),
        ('MM-REF-001'),
        ('MM-DL-20260630'),
        ('MM-NAV-20260630-01')
) AS tests(test_document_id)
ORDER BY test_document_id;

-- ---------------------------------------------------------------------------
-- 9. FUNKČNÍ TEST DOCUMENT TYPE
-- ---------------------------------------------------------------------------

SELECT
    test_document_type,
    test_document_type = ANY (
        ARRAY[
            'DOC'::text,
            'STD'::text,
            'REF'::text,
            'BOOK'::text,
            'MST'::text,
            'GOV'::text,
            'ARC'::text,
            'DB'::text,
            'PRV'::text,
            'LAY'::text,
            'OPS'::text,
            'DEV'::text,
            'HIS'::text,
            'VIS'::text,
            'TPL'::text,
            'EXP'::text,
            'DRF'::text,
            'ARCV'::text,
            'DL'::text,
            'NAV'::text,
            'OTHER'::text
        ]
    ) AS accepted
FROM (
    VALUES
        ('DOC'),
        ('STD'),
        ('REF'),
        ('DL'),
        ('NAV')
) AS tests(test_document_type)
ORDER BY test_document_type;

-- ---------------------------------------------------------------------------
-- 10. FINÁLNÍ STAV
-- ---------------------------------------------------------------------------

SELECT
    'MM-STD-007_DATABASE_CONSTRAINTS_SYNCHRONIZED'::text
        AS final_status,
    current_database() AS database_name,
    current_schema() AS current_schema,
    clock_timestamp() AS verified_at;
