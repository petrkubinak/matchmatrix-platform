SELECT COUNT(*) AS player_external_identity_count
FROM public.player_external_identity;

SELECT
    provider,
    COUNT(*) AS rows_count
FROM public.player_external_identity
GROUP BY provider
ORDER BY rows_count DESC;

SELECT *
FROM public.player_external_identity
ORDER BY updated_at DESC
LIMIT 50;