SELECT
    id,
    endpoint,
    fetched_at,
    payload::text
FROM public.api_raw_payloads
WHERE
    endpoint ILIKE '%odds%'
ORDER BY fetched_at DESC
LIMIT 5;