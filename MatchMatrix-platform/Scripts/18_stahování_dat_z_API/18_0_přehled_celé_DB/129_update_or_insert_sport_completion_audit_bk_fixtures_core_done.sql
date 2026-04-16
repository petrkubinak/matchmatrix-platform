-- 129_update_or_insert_sport_completion_audit_bk_fixtures_core_done.sql

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ops.sport_completion_audit
        WHERE sport_code = 'BK'
          AND entity = 'fixtures'
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
            key_gap              = 'Prevest rucni BK merge kroky do finalniho opakovatelneho pipeline skriptu.',
            next_step            = 'Vytvorit finalni BK pipeline SQL balicek a pak aplikovat stejny pattern na dalsi sport.',
            evidence_note        = 'BK fixtures merge do public.matches potvrzen, vcetne teams resolve, status mapping, score extraction a league mapping.',
            priority_rank        = 30,
            updated_at           = NOW()
        WHERE sport_code = 'BK'
          AND entity = 'fixtures'
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
            'fixtures',
            'core',
            'DONE',
            'READY',
            'api_sport',
            'api_basketball',
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            'Prevest rucni BK merge kroky do finalniho opakovatelneho pipeline skriptu.',
            'Vytvorit finalni BK pipeline SQL balicek a pak aplikovat stejny pattern na dalsi sport.',
            'BK fixtures merge do public.matches potvrzen, vcetne teams resolve, status mapping, score extraction a league mapping.',
            30,
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
  AND entity = 'fixtures'
  AND layer_type = 'core';