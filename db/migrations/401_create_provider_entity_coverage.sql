-- ============================================
-- MATCHMATRIX
-- 401_create_provider_entity_coverage.sql
-- Účel:
-- Centrální coverage + priority tabulka pro:
-- provider × sport × entity
-- ============================================

CREATE TABLE IF NOT EXISTS ops.provider_entity_coverage (
    id                  bigserial PRIMARY KEY,

    -- Provider / sport / entity
    provider            text        NOT NULL,
    sport_code          text        NOT NULL,
    entity              text        NOT NULL,

    -- Stav coverage
    coverage_status     text        NOT NULL DEFAULT 'planned',
    -- planned / tech_ready / runtime_tested / production_ready / blocked / deprecated

    is_enabled          boolean     NOT NULL DEFAULT true,

    -- Priority pro použití v merge / scheduleru / panelu
    provider_priority   integer     NOT NULL DEFAULT 100,
    -- 1 = nejlepší / hlavní zdroj pro entitu
    -- vyšší číslo = doplňkový / fallback zdroj

    merge_priority      integer     NOT NULL DEFAULT 100,
    -- priorita při merge do canonical vrstvy

    fetch_priority      integer     NOT NULL DEFAULT 100,
    -- priorita pro plánování stahování

    -- Kvalita a použitelnost
    quality_rating      text        NOT NULL DEFAULT 'unknown',
    -- high / medium / low / unknown

    availability_scope  text        NOT NULL DEFAULT 'unknown',
    -- full / partial / limited_free / paid_only / unknown

    -- Free vs paid realita
    free_plan_supported boolean     NOT NULL DEFAULT false,
    paid_plan_supported boolean     NOT NULL DEFAULT false,

    -- Co reálně čekáme od provideru
    expected_depth      text        NOT NULL DEFAULT 'unknown',
    -- basic / extended / deep / unknown

    -- Použití v systému
    is_primary_source   boolean     NOT NULL DEFAULT false,
    is_fallback_source  boolean     NOT NULL DEFAULT false,
    is_merge_source     boolean     NOT NULL DEFAULT true,

    -- Technické a provozní poznámky
    source_endpoint     text,
    target_table        text,
    worker_script       text,

    notes               text,
    limitations         text,
    next_action         text,

    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_provider_entity_coverage
        UNIQUE (provider, sport_code, entity),

    CONSTRAINT chk_provider_entity_coverage_status
        CHECK (coverage_status IN (
            'planned',
            'tech_ready',
            'runtime_tested',
            'production_ready',
            'blocked',
            'deprecated'
        )),

    CONSTRAINT chk_provider_entity_quality
        CHECK (quality_rating IN (
            'high',
            'medium',
            'low',
            'unknown'
        )),

    CONSTRAINT chk_provider_entity_scope
        CHECK (availability_scope IN (
            'full',
            'partial',
            'limited_free',
            'paid_only',
            'unknown'
        )),

    CONSTRAINT chk_provider_entity_depth
        CHECK (expected_depth IN (
            'basic',
            'extended',
            'deep',
            'unknown'
        ))
);

-- --------------------------------------------
-- Updated_at trigger
-- --------------------------------------------
CREATE OR REPLACE FUNCTION ops.set_updated_at_provider_entity_coverage()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_provider_entity_coverage_updated_at
ON ops.provider_entity_coverage;

CREATE TRIGGER trg_provider_entity_coverage_updated_at
BEFORE UPDATE ON ops.provider_entity_coverage
FOR EACH ROW
EXECUTE FUNCTION ops.set_updated_at_provider_entity_coverage();

-- --------------------------------------------
-- Indexy
-- --------------------------------------------
CREATE INDEX IF NOT EXISTS ix_provider_entity_coverage_sport_entity
    ON ops.provider_entity_coverage (sport_code, entity);

CREATE INDEX IF NOT EXISTS ix_provider_entity_coverage_status
    ON ops.provider_entity_coverage (coverage_status);

CREATE INDEX IF NOT EXISTS ix_provider_entity_coverage_enabled
    ON ops.provider_entity_coverage (is_enabled, provider_priority, fetch_priority);

-- --------------------------------------------
-- Seed z ingest_entity_plan
-- Přenese technický základ, aby ses nevyplňoval od nuly
-- --------------------------------------------
INSERT INTO ops.provider_entity_coverage (
    provider,
    sport_code,
    entity,
    coverage_status,
    is_enabled,
    provider_priority,
    merge_priority,
    fetch_priority,
    quality_rating,
    availability_scope,
    free_plan_supported,
    paid_plan_supported,
    expected_depth,
    is_primary_source,
    is_fallback_source,
    is_merge_source,
    source_endpoint,
    target_table,
    worker_script,
    notes,
    limitations,
    next_action
)
SELECT
    iep.provider,
    iep.sport_code,
    iep.entity,

    CASE
        WHEN iep.source_endpoint IS NOT NULL
         AND iep.target_table IS NOT NULL
        THEN 'tech_ready'
        ELSE 'planned'
    END AS coverage_status,

    iep.enabled AS is_enabled,

    100 AS provider_priority,
    100 AS merge_priority,
    COALESCE(iep.priority, 100) AS fetch_priority,

    'unknown' AS quality_rating,
    'unknown' AS availability_scope,
    false AS free_plan_supported,
    false AS paid_plan_supported,
    'unknown' AS expected_depth,

    false AS is_primary_source,
    false AS is_fallback_source,
    true  AS is_merge_source,

    iep.source_endpoint,
    iep.target_table,
    iep.worker_script,
    iep.notes,
    NULL AS limitations,
    'Vyplnit realitu provideru a priority.' AS next_action
FROM ops.ingest_entity_plan iep
WHERE iep.enabled = true
ON CONFLICT (provider, sport_code, entity) DO NOTHING;