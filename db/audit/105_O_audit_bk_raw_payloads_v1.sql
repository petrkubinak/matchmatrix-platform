/*
MATCHMATRIX BK RAW PAYLOADS AUDIT V1

Co to je:
- Kontrola BK raw payloadů v staging.stg_api_payloads.

K čemu to je:
- Zjistíme, jestli máme stažená BK fixture data v RAW vrstvě.

Kde výsledek uvidíme:
- V DBeaveru jako přehled payloadů podle typu entity.

Jak se využije na webu:
- Pokud RAW existuje, opravíme parser/merge.
- Pokud RAW neexistuje, musíme znovu spustit BK pull přes řízený ingest.
*/

SELECT
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    COUNT(*) AS payloads_count,
    MIN(fetched_at) AS first_fetched_at,
    MAX(fetched_at) AS last_fetched_at,
    COUNT(*) FILTER (WHERE parse_status IS NULL) AS parse_status_null,
    COUNT(*) FILTER (WHERE parse_status = 'parsed') AS parsed_count,
    COUNT(*) FILTER (WHERE parse_status = 'error') AS error_count
FROM staging.stg_api_payloads
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
GROUP BY
    provider,
    sport_code,
    entity_type,
    endpoint_name
ORDER BY payloads_count DESC;