-- 135_update_or_insert_runtime_entity_audit_vb_fixtures_confirmed.sql

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ops.runtime_entity_audit
        WHERE provider = 'api_volleyball'
          AND sport_code = 'VB'
          AND entity = 'fixtures'
    ) THEN
        UPDATE ops.runtime_entity_audit
        SET
            current_state            = 'CONFIRMED',
            state_reason             = 'VB fixtures jsou potvrzene od pull/raw/staging az po merge do public.matches a league mapping.',
            panel_runner_exists      = TRUE,
            planner_target_exists    = TRUE,
            batch_target_exists      = TRUE,
            pull_confirmed           = TRUE,
            raw_confirmed            = TRUE,
            staging_confirmed        = TRUE,
            provider_map_confirmed   = TRUE,
            public_merge_confirmed   = TRUE,
            downstream_confirmed     = FALSE,
            last_run_group           = 'VB_CORE',
            last_run_at              = NOW(),
            last_check_at            = NOW(),
            last_log_summary         = 'VB fixtures merge probehl OK: 178 matches inserted, league mapped to SuperLega.',
            db_evidence_summary      = 'stg_provider_fixtures VB=178 | public.matches inserted=178 | public.leagues ext_source=api_volleyball ext_league_id=97 -> SuperLega',
            next_action              = 'Prevest VB rucni SQL kroky do finalniho opakovatelneho pipeline baliku.',
            audit_note               = 'VB fixtures jsou potvrzene v canonical core vrstve vcetne teams resolve, status mapping a league mapping.',
            updated_at               = NOW()
        WHERE provider = 'api_volleyball'
          AND sport_code = 'VB'
          AND entity = 'fixtures';
    ELSE
        INSERT INTO ops.runtime_entity_audit (
            provider,
            sport_code,
            entity,
            current_state,
            state_reason,
            panel_runner_exists,
            planner_target_exists,
            batch_target_exists,
            pull_confirmed,
            raw_confirmed,
            staging_confirmed,
            provider_map_confirmed,
            public_merge_confirmed,
            downstream_confirmed,
            last_run_group,
            last_run_at,
            last_check_at,
            last_log_summary,
            db_evidence_summary,
            next_action,
            audit_note,
            created_at,
            updated_at
        )
        VALUES (
            'api_volleyball',
            'VB',
            'fixtures',
            'CONFIRMED',
            'VB fixtures jsou potvrzene od pull/raw/staging az po merge do public.matches a league mapping.',
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            FALSE,
            'VB_CORE',
            NOW(),
            NOW(),
            'VB fixtures merge probehl OK: 178 matches inserted, league mapped to SuperLega.',
            'stg_provider_fixtures VB=178 | public.matches inserted=178 | public.leagues ext_source=api_volleyball ext_league_id=97 -> SuperLega',
            'Prevest VB rucni SQL kroky do finalniho opakovatelneho pipeline baliku.',
            'VB fixtures jsou potvrzene v canonical core vrstve vcetne teams resolve, status mapping a league mapping.',
            NOW(),
            NOW()
        );
    END IF;
END $$;

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    last_run_group,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity = 'fixtures';