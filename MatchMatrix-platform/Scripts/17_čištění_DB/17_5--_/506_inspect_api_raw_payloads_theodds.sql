-- 506_inspect_api_raw_payloads_theodds.sql
-- Cíl:
-- zjistit reálnou strukturu TheOdds payloadů v api_raw_payloads

SELECT
    id,
    run_id,
    source,
    endpoint,
    fetched_at,
    jsonb_typeof(payload) AS payload_type,
    left(payload::text, 1000) AS payload_preview
FROM public.api_raw_payloads
WHERE lower(coalesce(source, '')) LIKE '%odds%'
   OR lower(coalesce(endpoint, '')) LIKE '%odds%'
ORDER BY id DESC
LIMIT 20;