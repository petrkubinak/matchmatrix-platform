-- =====================================================================
-- 581_fb_entity_audit_table.sql
-- Účel:
-- auditní tabulka pro FB entity (ručně vyplňovaná během auditu)
-- =====================================================================

CREATE TABLE IF NOT EXISTS ops.fb_entity_audit (
    id bigserial PRIMARY KEY,

    entity text NOT NULL,

    primary_provider text,
    fallback_provider text,

    coverage_status text,
    real_data_flow boolean,

    execution_mode text, 
    -- automatic / validate_only / manual_only / disabled

    automator_ready boolean DEFAULT FALSE,

    requires_pro boolean DEFAULT FALSE,

    staging_table text,
    public_dependency text,

    post_process text,

    known_issues text,
    notes text,

    updated_at timestamptz DEFAULT now()
);

-- základní seed (FB entity)
INSERT INTO ops.fb_entity_audit (entity)
VALUES
('leagues'),
('teams'),
('fixtures'),
('odds'),
('players'),
('player_stats'),
('player_season_stats'),
('coaches'),
('standings')
ON CONFLICT DO NOTHING;