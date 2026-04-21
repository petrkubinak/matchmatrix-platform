-- 127_update_or_insert_runtime_entity_audit_bk_teams_confirmed.sql

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ops.runtime_entity_audit
        WHERE provider = 'api_sport'
          AND sport_code = 'BK'
          AND entity = 'teams'
    ) THEN
        UPDATE ops.runtime_entity_audit
        SET
            current_state            = 'CONFIRMED',
            state_reason             = 'BK teams jsou potvrzene az do canonical public vrstvy vcetne provider map. Byla opravena sport-safe canonical identity pro multisport api_sport.',
            panel_runner_exists      = TRUE,
            planner_target_exists    = TRUE,
            batch_target_exists      = TRUE,
            pull_confirmed           = TRUE,
            raw_confirmed            = TRUE,
            staging_confirmed        = TRUE,
            provider_map_confirmed   = TRUE,
            public_merge_confirmed   = TRUE,
            downstream_confirmed     = FALSE,
            last_run_group           = 'BK_TOP',
            last_run_at              = NOW(),
            last_check_at            = NOW(),
            last_log_summary         = 'BK teams end-to-end potvrzeno: pull -> raw -> staging -> provider_map -> public teams',
            db_evidence_summary      = 'stg_provider_teams BK potvrzeno | public.teams ext_source=api_sport_basketball potvrzeno | team_provider_map BK potvrzeno',
            next_action              = 'Navazat BK fixtures downstream validaci a finalnim pipeline skriptem.',
            audit_note               = 'BK teams byly oddeleny od ostatnich sportu pres sport-safe canonical identity pattern pro api_sport.',
            updated_at               = NOW()
        WHERE provider = 'api_sport'
          AND sport_code = 'BK'
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
            'api_sport',
            'BK',
            'teams',
            'CONFIRMED',
            'BK teams jsou potvrzene az do canonical public vrstvy vcetne provider map. Byla opravena sport-safe canonical identity pro multisport api_sport.',
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            FALSE,
            'BK_TOP',
            NOW(),
            NOW(),
            'BK teams end-to-end potvrzeno: pull -> raw -> staging -> provider_map -> public teams',
            'stg_provider_teams BK potvrzeno | public.teams ext_source=api_sport_basketball potvrzeno | team_provider_map BK potvrzeno',
            'Navazat BK fixtures downstream validaci a finalnim pipeline skriptem.',
            'BK teams byly oddeleny od ostatnich sportu pres sport-safe canonical identity pattern pro api_sport.',
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
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'teams';