-- =====================================================================
-- 580_fb_provider_reality.sql
-- Účel:
-- reálný pohled na FB providery + entity + coverage
-- =====================================================================

DROP VIEW IF EXISTS ops.v_fb_provider_reality;

CREATE VIEW ops.v_fb_provider_reality AS
SELECT
    pec.provider,
    pec.sport_code,
    pec.entity,

    pec.coverage_status,
    pec.is_enabled,

    pec.is_primary_source,
    pec.is_fallback_source,

    pec.free_plan_supported,
    pec.paid_plan_supported,

    pec.provider_priority,
    pec.fetch_priority,
    pec.merge_priority,

    pec.source_endpoint,
    pec.worker_script,
    pec.target_table,

    pec.notes,
    pec.limitations,
    pec.next_action

FROM ops.provider_entity_coverage pec
WHERE pec.sport_code = 'FB'
ORDER BY
    pec.entity,
    pec.provider_priority,
    pec.fetch_priority;