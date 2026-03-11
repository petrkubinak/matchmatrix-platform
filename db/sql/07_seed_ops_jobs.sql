INSERT INTO ops.jobs (code, name, description, recommended, enabled, default_params)
VALUES
(
    'refresh_ticket_run_settlements',
    'Refresh ticket run settlements',
    'Spustí DB refresh runtime settlementů tiketů.',
    'Po každém ticket generation runu nebo po změně výsledků zápasů.',
    true,
    '{}'::jsonb
),
(
    'daily_pipeline',
    'Daily pipeline',
    'Spustí ratings, predictions a refresh settlementů.',
    '1x denně nebo po větším ingestu dat.',
    true,
    '{}'::jsonb
),
(
    'ticket_generation',
    'Ticket generation',
    'Spustí preview + generování tiketů s coverage guardem.',
    'Pouštět jen pokud jsou k dispozici odds.',
    true,
    '{}'::jsonb
)
ON CONFLICT (code) DO UPDATE
SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    recommended = EXCLUDED.recommended,
    enabled = EXCLUDED.enabled,
    default_params = EXCLUDED.default_params,
    updated_at = now();