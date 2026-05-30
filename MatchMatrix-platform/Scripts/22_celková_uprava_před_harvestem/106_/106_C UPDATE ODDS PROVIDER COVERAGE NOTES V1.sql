-- =============================================================================
-- MATCHMATRIX 106_C UPDATE ODDS PROVIDER COVERAGE NOTES V1
-- =============================================================================
-- Co skript dělá:
-- Zpřesňuje strategii ODDS providerů v ops.provider_entity_coverage.
--
-- Výsledek:
-- DB bude jasně rozlišovat:
-- - THEODDS jako TOP football provider
-- - API-Sport/API-* jako budoucí multi-sport provider po PRO
-- - premium future providery jako Pinnacle / Betfair
-- - Football-Data jako blocked pro odds
-- =============================================================================

BEGIN;

UPDATE ops.provider_entity_coverage
SET
    coverage_status = 'runtime_tested',
    quality_rating = 'high',
    expected_depth = 'extended',
    notes = 'THEODDS je aktuálně hlavní TOP football odds provider pro MatchMatrix.',
    limitations = 'Pokrytí hlavně TOP football lig, evropských pohárů a velkých soutěží. Není vhodný jako jediný globální odds provider pro všechny ligy.',
    next_action = 'Používat pro FB TOP odds. Paralelně připravit API-Sport odds jako multi-sport/global coverage provider.',
    updated_at = NOW()
WHERE provider = 'theodds'
  AND sport_code = 'FB'
  AND entity = 'odds';

UPDATE ops.provider_entity_coverage
SET
    notes = 'API-Sport/API-* odds jsou kandidát na globální multi-sport odds coverage po aktivaci PRO/paid plánu.',
    limitations = 'Free/limited režim může vracet prázdné odds pro historické nebo neaktuální zápasy. Reálnou coverage ověřit na aktuálních SCHEDULED zápasech a po PRO.',
    next_action = 'Po aktivaci PRO spustit smoke test odds pro aktuální scheduled zápasy a založit API_SPORT_ODDS_BACKFILL + API_SPORT_ODDS_LIVE_REFRESH.',
    updated_at = NOW()
WHERE entity = 'odds'
  AND provider LIKE 'api_%'
  AND provider <> 'api_football';

UPDATE ops.provider_entity_coverage
SET
    notes = 'API-Football odds jsou doplňkový football odds provider pro širší coverage mimo THEODDS.',
    limitations = 'Paid/PRO ověření nutné. Nepřebírá roli hlavního TOP odds providera, dokud nebude porovnána kvalita coverage.',
    next_action = 'Po PRO porovnat API-Football odds coverage s THEODDS podle lig, trhů, bookmakerů a attach úspěšnosti.',
    updated_at = NOW()
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'odds';

UPDATE ops.provider_entity_coverage
SET
    coverage_status = 'planned',
    notes = 'Premium/sharp odds provider kandidát pro budoucí rozšíření MatchMatrix odds layeru.',
    limitations = 'Vyžaduje samostatný účet, obchodní ověření, cenu a technickou integraci.',
    next_action = 'Později vyhodnotit business value proti THEODDS/API-Sport odds.',
    updated_at = NOW()
WHERE entity = 'odds'
  AND provider IN ('pinnacle', 'betfair', 'sportdataapi');

UPDATE ops.provider_entity_coverage
SET
    coverage_status = 'blocked',
    is_enabled = false,
    notes = 'Football-Data není odds provider pro MatchMatrix.',
    limitations = 'Nepoužívat pro odds ingestion.',
    next_action = 'Ponechat pouze pro fixtures/leagues/teams fallback, nikoliv odds.',
    updated_at = NOW()
WHERE provider = 'football_data'
  AND sport_code = 'FB'
  AND entity = 'odds';

COMMIT;