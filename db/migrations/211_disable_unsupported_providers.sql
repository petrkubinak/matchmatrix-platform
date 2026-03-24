-- Disable unsupported providers (no ingest implementation yet)

UPDATE ops.ingest_targets
SET enabled = false
WHERE provider IN (
    'api_cricket',
    'api_field_hockey',
    'api_esports',
    'api_american_football',
    'api_sport' -- (basket zatím nemá runner)
);