-- 137_update_or_insert_runtime_entity_audit_vb_leagues_confirmed.sql

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ops.runtime_entity_audit
        WHERE provider = 'api_volleyball'
          AND sport_code = 'VB'
          AND entity = 'leagues'
    ) THEN
        UPDATE ops.runtime_entity_audit
        SET
            current_state            = 'CONFIRMED',
            state_reason             = 'VB leagues jsou potvrzene az do canonical public vrstvy vcetne mapovani na public.leagues a napojeni na public.matches.',
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
            last_log_summary         = 'VB leagues merge probehl OK: canonical league SuperLega vytvorena a napojena na VB matches.',
            db_evidence_summary      = 'public.leagues ext_source=api_volleyball ext_league_id=97 -> SuperLega | matches.league_id naplneno pro 178 rows',
            next_action              = 'Pokračovat finalnim VB pipeline balikem a auditnim zafixovanim.',
            audit_note               = 'VB leagues jsou soucasti kompletniho core merge chainu.',
            updated_at               = NOW()
        WHERE provider = 'api_volleyball'
          AND sport_code = 'VB'
          AND entity = 'leagues';
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
            'leagues',
            'CONFIRMED',
            'VB leagues jsou potvrzene az do canonical public vrstvy vcetne mapovani na public.leagues a napojeni na public.matches.',
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
            'VB leagues merge probehl OK: canonical league SuperLega vytvorena a napojena na VB matches.',
            'public.leagues ext_source=api_volleyball ext_league_id=97 -> SuperLega | matches.league_id naplneno pro 178 rows',
            'Pokračovat finalnim VB pipeline balikem a auditnim zafixovanim.',
            'VB leagues jsou soucasti kompletniho core merge chainu.',
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
  AND entity = 'leagues';