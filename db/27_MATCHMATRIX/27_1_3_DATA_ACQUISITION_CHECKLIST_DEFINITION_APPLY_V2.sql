-- ============================================================
-- MATCHMATRIX
-- DATA ACQUISITION CHECKLIST DEFINITION
-- MIGRATION V1 -> V2
--
-- CO:
-- Rozšíření existující prázdné tabulky
-- ops.data_acquisition_checklist_definition.
--
-- K ČEMU:
-- Přidává řízené výjimky APPROVED_GAP,
-- explicitní rozhodovací gate a nové typy kontrol.
--
-- KDE:
-- PostgreSQL matchmatrix / schema ops
--
-- JAK:
-- ALTER existující tabulky.
-- Bez DELETE, DROP TABLE nebo ztráty dat.
--
-- MODE:
-- APPLY
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. Nové sloupce V2
-- ------------------------------------------------------------

ALTER TABLE ops.data_acquisition_checklist_definition
    ADD COLUMN gap_policy text NOT NULL DEFAULT 'NOT_ALLOWED';

ALTER TABLE ops.data_acquisition_checklist_definition
    ADD COLUMN decision_required boolean NOT NULL DEFAULT false;


-- ------------------------------------------------------------
-- 2. Rozšíření CHECK_CODE
-- ------------------------------------------------------------

ALTER TABLE ops.data_acquisition_checklist_definition
    DROP CONSTRAINT ck_data_acq_checklist_check_code;

ALTER TABLE ops.data_acquisition_checklist_definition
    ADD CONSTRAINT ck_data_acq_checklist_check_code
    CHECK (
        check_code IN (
            'ENTITY_DEFINED',
            'COVERAGE',
            'PRIMARY_PROVIDER',
            'FALLBACK_PROVIDER',
            'ENDPOINT',
            'TECHNICAL_PIPELINE',
            'CANONICAL_MAPPING',
            'DATA_QUALITY',
            'COMMERCIAL',
            'LEGAL',
            'SMOKE_TEST',
            'HISTORICAL_PILOT',
            'HEALTH_MONITORING',
            'REFRESH_CADENCE',
            'EVIDENCE'
        )
    );


-- ------------------------------------------------------------
-- 3. GAP POLICY
-- ------------------------------------------------------------

ALTER TABLE ops.data_acquisition_checklist_definition
    ADD CONSTRAINT ck_data_acq_checklist_gap_policy
    CHECK (
        gap_policy IN (
            'NOT_ALLOWED',
            'APPROVED_GAP_ALLOWED'
        )
    );


-- ------------------------------------------------------------
-- 4. Dokumentační komentáře
-- ------------------------------------------------------------

COMMENT ON TABLE ops.data_acquisition_checklist_definition IS
'Normativní definice Data Acquisition checklistu MatchMatrix. Neobsahuje výsledky auditů; určuje, co musí být splněno pro SPORT × LAYER × ENTITY × TIME_MODE × CHECK.';

COMMENT ON COLUMN ops.data_acquisition_checklist_definition.gap_policy IS
'Určuje, zda lze nesplnitelný požadavek auditně uzavřít jako schválenou řízenou mezeru APPROVED_GAP.';

COMMENT ON COLUMN ops.data_acquisition_checklist_definition.decision_required IS
'Určuje, zda checklistový bod vyžaduje explicitní rozhodnutí, nikoli pouze automatický technický audit.';


COMMIT;


-- ============================================================
-- POSTCHECK
-- ============================================================

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'data_acquisition_checklist_definition'
ORDER BY ordinal_position;