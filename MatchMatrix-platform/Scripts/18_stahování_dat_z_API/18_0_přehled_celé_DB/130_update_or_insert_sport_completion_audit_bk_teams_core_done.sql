-- 130_update_or_insert_sport_completion_audit_bk_teams_core_done.sql

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ops.sport_completion_audit
        WHERE sport_code = 'BK'
          AND entity = 'teams'
          AND layer_type = 'core'
    ) THEN
        UPDATE ops.sport_completion_audit
        SET
            current_status       = 'DONE',
            production_readiness = 'READY',
            provider_primary     = 'api_sport',
            provider_fallback    = 'api_basketball',
            db_layer_ready       = TRUE,
            planner_ready        = TRUE,
            queue_ready          = TRUE,
            public_ready         = TRUE,
            key_gap              = 'Stejny sport-safe identity pattern zafixovat do finalniho reusable skriptu.',
            next_step            = 'Prevest BK teams canonical seed + provider map fix do opakovatelneho pipeline skriptu.',
            evidence_note        = 'BK teams canonical identity a team_provider_map jsou potvrzene v public vrstve pres ext_source=api_sport_basketball.',
            priority_rank        = 29,
            updated_at           = NOW()
        WHERE sport_code = 'BK'
          AND entity = 'teams'
          AND layer_type = 'core';
    ELSE
        INSERT INTO ops.sport_completion_audit (
            sport_code,
            entity,
            layer_type,
            current_status,
            production_readiness,
            provider_primary,
            provider_fallback,
            db_layer_ready,
            planner_ready,
            queue_ready,
            public_ready,
            key_gap,
            next_step,
            evidence_note,
            priority_rank,
            created_at,
            updated_at
        )
        VALUES (
            'BK',
            'teams',
            'core',
            'DONE',
            'READY',
            'api_sport',
            'api_basketball',
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            'Stejny sport-safe identity pattern zafixovat do finalniho reusable skriptu.',
            'Prevest BK teams canonical seed + provider map fix do opakovatelneho pipeline skriptu.',
            'BK teams canonical identity a team_provider_map jsou potvrzene v public vrstve pres ext_source=api_sport_basketball.',
            29,
            NOW(),
            NOW()
        );
    END IF;
END $$;

SELECT
    sport_code,
    entity,
    layer_type,
    current_status,
    production_readiness,
    db_layer_ready,
    public_ready,
    key_gap,
    next_step
FROM ops.sport_completion_audit
WHERE sport_code = 'BK'
  AND entity = 'teams'
  AND layer_type = 'core';