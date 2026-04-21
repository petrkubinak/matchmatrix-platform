-- 138_update_or_insert_sport_completion_audit_vb_fixtures_core_done.sql

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ops.sport_completion_audit
        WHERE sport_code = 'VB'
          AND entity = 'fixtures'
          AND layer_type = 'core'
    ) THEN
        UPDATE ops.sport_completion_audit
        SET
            current_status       = 'DONE',
            production_readiness = 'READY',
            provider_primary     = 'api_volleyball',
            provider_fallback    = '',
            db_layer_ready       = TRUE,
            planner_ready        = TRUE,
            queue_ready          = TRUE,
            public_ready         = TRUE,
            key_gap              = 'Prevest rucni VB merge kroky do finalniho opakovatelneho pipeline skriptu.',
            next_step            = 'Zafixovat VB pipeline jako reusable pattern a navazat dalsim sportem.',
            evidence_note        = 'VB fixtures merge do public.matches potvrzen: 178 rows, status FINISHED, league SuperLega mapped.',
            priority_rank        = 40,
            updated_at           = NOW()
        WHERE sport_code = 'VB'
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
            'VB',
            'fixtures',
            'core',
            'DONE',
            'READY',
            'api_volleyball',
            '',
            TRUE,
            TRUE,
            TRUE,
            TRUE,
            'Prevest rucni VB merge kroky do finalniho opakovatelneho pipeline skriptu.',
            'Zafixovat VB pipeline jako reusable pattern a navazat dalsim sportem.',
            'VB fixtures merge do public.matches potvrzen: 178 rows, status FINISHED, league SuperLega mapped.',
            40,
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
WHERE sport_code = 'VB'
  AND entity = 'fixtures'
  AND layer_type = 'core';