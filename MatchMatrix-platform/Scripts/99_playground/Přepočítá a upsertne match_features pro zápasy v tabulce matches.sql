INSERT INTO ops.jobs (code, name, description, recommended, enabled, default_params)
VALUES
(
    'build_match_features',
    'Build match features',
    'Přepočítá a upsertne match_features pro zápasy v tabulce matches.',
    'Po ingestu fixtures a před predictions.',
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