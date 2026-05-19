-- ============================================================
-- 882_seed_people_media_jobs_v1.sql
-- MatchMatrix - seed OPS jobs for people/media automation
--
-- Kam uložit:
-- C:\MatchMatrix-platform\db\audit\882_seed_people_media_jobs_v1.sql
--
-- Spustit v DBeaveru.
-- ============================================================

BEGIN;

INSERT INTO ops.jobs
(
    code,
    name,
    description,
    recommended,
    enabled,
    default_params,
    created_at,
    updated_at
)
VALUES
(
    'people_media_cycle_v1',
    'People + Media Cycle V1',
    'Runs MatchMatrix people/media automation wrapper. People can execute known workers, media/highlights are safe placeholders until provider workers exist.',
    'Use first with --dry-run. Then run only filtered provider/sport/entity.',
    TRUE,
    '{}'::jsonb,
    NOW(),
    NOW()
),
(
    'full_harvest_cycle_v1',
    'Full Harvest Cycle V1',
    'Runs core ingest cycle and optionally people/media cycle.',
    'Use first with --dry-run. Then enable people/media explicitly.',
    TRUE,
    '{}'::jsonb,
    NOW(),
    NOW()
)
ON CONFLICT (code)
DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    recommended = EXCLUDED.recommended,
    enabled = EXCLUDED.enabled,
    default_params = EXCLUDED.default_params,
    updated_at = NOW();

COMMIT;

SELECT
    code,
    name,
    enabled,
    recommended
FROM ops.jobs
WHERE code IN (
    'people_media_cycle_v1',
    'full_harvest_cycle_v1'
)
ORDER BY code;