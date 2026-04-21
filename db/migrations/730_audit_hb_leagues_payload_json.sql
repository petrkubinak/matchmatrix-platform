-- 730_audit_hb_leagues_payload_json.sql
-- Cíl:
-- 1) podívat se přímo do raw leagues payload JSON
-- 2) ověřit, zda provider vrací jen 3 ligy, nebo víc a parser je ořezává

-- 1) poslední HB leagues payloady s velikostí JSON
SELECT
    id,
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    parse_status,
    created_at,
    LENGTH(payload_json::text) AS payload_len
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
  AND entity_type = 'leagues'
ORDER BY created_at DESC;

-- 2) poslední HB leagues payload - surový JSON náhled
SELECT
    id,
    created_at,
    LEFT(payload_json::text, 4000) AS payload_json_preview
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
  AND entity_type = 'leagues'
ORDER BY created_at DESC
LIMIT 1;

-- 3) všechny HB leagues payloady - rychlý náhled
SELECT
    id,
    created_at,
    LEFT(payload_json::text, 1000) AS payload_json_preview
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
  AND entity_type = 'leagues'
ORDER BY created_at DESC;

-- 4) kontrola, zda payload obsahuje známé league id
SELECT
    id,
    created_at,
    (payload_json::text ILIKE '%131%') AS has_131,
    (payload_json::text ILIKE '%145%') AS has_145,
    (payload_json::text ILIKE '%183%') AS has_183
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
  AND entity_type = 'leagues'
ORDER BY created_at DESC;

-- 5) kontrola, zda payload zřejmě obsahuje víc league objektů
SELECT
    id,
    created_at,
    regexp_count(payload_json::text, '"id"') AS approx_id_tokens,
    regexp_count(payload_json::text, '"name"') AS approx_name_tokens,
    regexp_count(payload_json::text, '"country"') AS approx_country_tokens
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
  AND entity_type = 'leagues'
ORDER BY created_at DESC;