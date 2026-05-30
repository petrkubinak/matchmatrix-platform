/*
MATCHMATRIX BK PARSER SPORT CODE FIX V1

Co to je:
- Oprava BK parser pipeline pro nový unified sport_code.

K čemu to je:
- BK parser dříve očekával:
    sport_code = 'basketball'

- nový unified ingest používá:
    sport_code = 'BK'

- kvůli tomu parser neviděl nové RAW payloady.

Co tato oprava dělá:
- sjednotí parser na oba formáty:
    'BK'
    'basketball'

Kde se výsledek projeví:
- staging.stg_provider_fixtures
- public.matches
- finished/live statusy
- score updates
- AI/statistiky

Jak se využije na webu:
- BK výsledky a live data začnou fungovat přes novou pipeline.
*/

-- =========================================================
-- BK RAW PAYLOAD CHECK
-- =========================================================

SELECT
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    COUNT(*) AS payloads_count
FROM staging.stg_api_payloads
WHERE provider = 'api_sport'
  AND sport_code IN ('BK', 'basketball')
GROUP BY
    provider,
    sport_code,
    entity_type,
    endpoint_name
ORDER BY payloads_count DESC;

-- =========================================================
-- TEST PARSER SOURCE
-- =========================================================

WITH latest_payload AS (
    SELECT
        id,
        provider,
        sport_code,
        entity_type,
        endpoint_name,
        fetched_at
    FROM staging.stg_api_payloads
    WHERE provider = 'api_sport'
      AND sport_code IN ('BK', 'basketball')
      AND entity_type = 'fixtures'
      AND endpoint_name = 'games'
    ORDER BY fetched_at DESC
    LIMIT 1
)

SELECT *
FROM latest_payload;