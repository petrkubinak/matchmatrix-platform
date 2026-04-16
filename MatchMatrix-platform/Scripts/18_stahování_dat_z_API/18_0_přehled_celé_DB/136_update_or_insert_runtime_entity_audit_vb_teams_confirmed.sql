-- 136_update_or_insert_runtime_entity_audit_vb_teams_confirmed.sql

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ops.runtime_entity_audit
        WHERE provider = 'api_volleyball'
          AND sport_code = 'VB'
          AND entity = 'teams'
    ) THEN
        UPDATE ops.runtime_entity_audit
        SET
            current_state            = 'CONFIRMED',
            state_reason             = 'VB teams jsou potvrzene az do canonical public vrstvy vcetne provider map.',
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
            last_log_summary         = 'VB teams canonical identity a provider map potvrzeny.',
            db_evidence_summary      = 'public.teams ext_source=api_volleyball count=12 | team_provider_map api_volleyball count=12',
            next_action              = 'Navazat finalnim VB pipeline balikem a dalsimi VB entitami.',
            audit_note               = 'VB teams jsou potvrzene v public vrstve bez multisport kolizi.',
            updated_at               = NOW()
        WHERE provider = 'api_volleyball'
          AND sport_code = 'VB'
          AND entity = 'teams';
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
            'teams',
            'CONFIRMED',
            'VB teams jsou potvrzene az do canonical public vrstvy vcetne provider map.',
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
            'VB teams canonical identity a provider map potvrzeny.',
            'public.teams ext_source=api_volleyball count=12 | team_provider_map api_volleyball count=12',
            'Navazat finalnim VB pipeline balikem a dalsimi VB entitami.',
            'VB teams jsou potvrzene v public vrstve bez multisport kolizi.',
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
  AND entity = 'teams';