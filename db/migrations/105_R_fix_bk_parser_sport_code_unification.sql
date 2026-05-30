/*
MATCHMATRIX BK STAGING FIXTURE SCORE FIX V1

Co to je:
- Opraví už vložené BK fixtures ve staging.stg_provider_fixtures.

K čemu to je:
- Starý parser vložil sport_code jako basketball
  a score uložil jako celý JSON objekt místo čísel.

Kde se výsledek projeví:
- staging.stg_provider_fixtures

Jak se využije na webu:
- Následný BK merge bude moct aktualizovat public.matches
  na FINISHED a doplnit skóre.
*/

UPDATE staging.stg_provider_fixtures f
SET
    sport_code = 'BK',
    home_score = p.game #>> '{scores,home,total}',
    away_score = p.game #>> '{scores,away,total}',
    status_text = p.game #>> '{status,short}',
    updated_at = NOW()
FROM (
    SELECT
        jsonb_array_elements(payload_json -> 'response') AS game
    FROM staging.stg_api_payloads
    WHERE id = 1319
) p
WHERE f.provider = 'api_sport'
  AND f.external_fixture_id = p.game ->> 'id'
  AND f.raw_payload_id = 1319;

SELECT
    sport_code,
    status_text,
    COUNT(*) AS rows_count,
    COUNT(home_score) AS home_scores,
    COUNT(away_score) AS away_scores
FROM staging.stg_provider_fixtures
WHERE provider = 'api_sport'
  AND raw_payload_id = 1319
GROUP BY sport_code, status_text
ORDER BY rows_count DESC;