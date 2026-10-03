-- ============================================================
-- MATCHMATRIX
-- HB DATA ACQUISITION CHECKLIST DEFINITION V1
--
-- CO:
-- Pilotní definice povinných checklistových bodů
-- pro sport HB – Handball.
--
-- K ČEMU:
-- Ověření modelu:
-- SPORT × LAYER × ENTITY × TIME_MODE × CHECK
--
-- KDE:
-- Budoucí tabulka:
-- ops.data_acquisition_checklist_definition
--
-- JAK:
-- Tento skript zatím NESPOUŠTĚT.
-- Slouží k validaci návrhu před vytvořením DB objektů.
-- ============================================================


-- ============================================================
-- 1. ENTITY CATALOGUE – HANDBALL
-- ============================================================

WITH hb_scope (
    layer_type,
    entity,
    time_mode,
    requirement_level,
    entity_description
) AS (

    VALUES

    -- ========================================================
    -- CORE
    -- ========================================================

    ('CORE', 'leagues', 'HISTORY_FAN',        'REQUIRED', 'Soutěže a ligy – hluboká historie'),
    ('CORE', 'leagues', 'HISTORY_PREDICTION', 'REQUIRED', 'Soutěže a ligy – modelová historie'),
    ('CORE', 'leagues', 'CURRENT',             'REQUIRED', 'Aktuální soutěže'),
    ('CORE', 'leagues', 'FUTURE',              'REQUIRED', 'Budoucí soutěže a ročníky'),

    ('CORE', 'seasons', 'HISTORY_FAN',        'REQUIRED', 'Historické sezony'),
    ('CORE', 'seasons', 'HISTORY_PREDICTION', 'REQUIRED', 'Sezony použitelné pro modely'),
    ('CORE', 'seasons', 'CURRENT',             'REQUIRED', 'Aktuální sezona'),
    ('CORE', 'seasons', 'FUTURE',              'REQUIRED', 'Budoucí sezony, pokud jsou publikované'),

    ('CORE', 'teams', 'HISTORY_FAN',        'REQUIRED', 'Historické týmy'),
    ('CORE', 'teams', 'HISTORY_PREDICTION', 'REQUIRED', 'Historické týmové identity pro modely'),
    ('CORE', 'teams', 'CURRENT',             'REQUIRED', 'Aktuální týmy'),
    ('CORE', 'teams', 'FUTURE',              'REQUIRED', 'Budoucí účastníci soutěží'),

    ('CORE', 'fixtures', 'HISTORY_FAN',        'REQUIRED', 'Historické zápasy'),
    ('CORE', 'fixtures', 'HISTORY_PREDICTION', 'REQUIRED', 'Historické zápasy pro modely'),
    ('CORE', 'fixtures', 'CURRENT',             'REQUIRED', 'Aktuální zápasy'),
    ('CORE', 'fixtures', 'FUTURE',              'REQUIRED', 'Budoucí program'),
    ('CORE', 'fixtures', 'LIVE',                'REQUIRED', 'Živý stav probíhajících zápasů'),

    ('CORE', 'results', 'HISTORY_FAN',        'REQUIRED', 'Historické výsledky'),
    ('CORE', 'results', 'HISTORY_PREDICTION', 'REQUIRED', 'Výsledky pro modely'),
    ('CORE', 'results', 'CURRENT',             'REQUIRED', 'Aktuální a finální výsledky'),
    ('CORE', 'results', 'LIVE',                'REQUIRED', 'Průběžný výsledek'),

    ('CORE', 'standings', 'HISTORY_FAN',        'REQUIRED', 'Historické tabulky'),
    ('CORE', 'standings', 'HISTORY_PREDICTION', 'REQUIRED', 'Historické tabulky pro modely'),
    ('CORE', 'standings', 'CURRENT',             'REQUIRED', 'Aktuální tabulky'),

    ('CORE', 'venues', 'HISTORY_FAN', 'OPTIONAL', 'Historická sportoviště'),
    ('CORE', 'venues', 'CURRENT',      'REQUIRED', 'Aktuální sportoviště'),
    ('CORE', 'venues', 'FUTURE',       'OPTIONAL', 'Sportoviště budoucích zápasů'),


    -- ========================================================
    -- PEOPLE
    -- ========================================================

    ('PEOPLE', 'players', 'HISTORY_FAN',        'REQUIRED', 'Historické profily a hráčské identity'),
    ('PEOPLE', 'players', 'HISTORY_PREDICTION', 'REQUIRED', 'Historie hráčů pro modely'),
    ('PEOPLE', 'players', 'CURRENT',             'REQUIRED', 'Aktuální hráči'),

    ('PEOPLE', 'coaches', 'HISTORY_FAN', 'REQUIRED', 'Historie trenérů'),
    ('PEOPLE', 'coaches', 'CURRENT',      'REQUIRED', 'Aktuální trenéři'),

    ('PEOPLE', 'staff', 'HISTORY_FAN', 'OPTIONAL', 'Historický realizační tým'),
    ('PEOPLE', 'staff', 'CURRENT',      'OPTIONAL', 'Aktuální realizační tým'),

    ('PEOPLE', 'referees', 'HISTORY_FAN',        'OPTIONAL', 'Historie rozhodčích'),
    ('PEOPLE', 'referees', 'HISTORY_PREDICTION', 'OPTIONAL', 'Rozhodčí pro analytické použití'),
    ('PEOPLE', 'referees', 'CURRENT',             'OPTIONAL', 'Aktuální rozhodčí'),

    ('PEOPLE', 'profiles', 'HISTORY_FAN', 'REQUIRED', 'Biografické a profilové údaje'),
    ('PEOPLE', 'profiles', 'CURRENT',      'REQUIRED', 'Aktuální profilové údaje'),

    ('PEOPLE', 'career_history', 'HISTORY_FAN', 'REQUIRED', 'Klubová a reprezentační kariéra'),

    ('PEOPLE', 'season_statistics', 'HISTORY_PREDICTION', 'REQUIRED', 'Historické sezonní statistiky'),
    ('PEOPLE', 'season_statistics', 'CURRENT',             'REQUIRED', 'Aktuální sezonní statistiky'),


    -- ========================================================
    -- MATCH DETAIL
    -- ========================================================

    ('MATCH_DETAIL', 'lineups', 'HISTORY_FAN',        'OPTIONAL', 'Historické sestavy'),
    ('MATCH_DETAIL', 'lineups', 'HISTORY_PREDICTION', 'REQUIRED', 'Historické sestavy pro modely'),
    ('MATCH_DETAIL', 'lineups', 'CURRENT',             'REQUIRED', 'Aktuální sestavy'),
    ('MATCH_DETAIL', 'lineups', 'FUTURE',              'REQUIRED', 'Předzápasové / potvrzené sestavy'),
    ('MATCH_DETAIL', 'lineups', 'LIVE',                'REQUIRED', 'Aktivní sestava při zápase'),

    ('MATCH_DETAIL', 'incidents', 'HISTORY_FAN',        'OPTIONAL', 'Historické zápasové události'),
    ('MATCH_DETAIL', 'incidents', 'HISTORY_PREDICTION', 'OPTIONAL', 'Události pro analytické použití'),
    ('MATCH_DETAIL', 'incidents', 'CURRENT',             'REQUIRED', 'Aktuální zápasové události'),
    ('MATCH_DETAIL', 'incidents', 'LIVE',                'REQUIRED', 'Live zápasové události'),

    ('MATCH_DETAIL', 'match_statistics', 'HISTORY_FAN',        'REQUIRED', 'Historické zápasové statistiky'),
    ('MATCH_DETAIL', 'match_statistics', 'HISTORY_PREDICTION', 'REQUIRED', 'Zápasové statistiky pro modely'),
    ('MATCH_DETAIL', 'match_statistics', 'CURRENT',             'REQUIRED', 'Aktuální zápasové statistiky'),
    ('MATCH_DETAIL', 'match_statistics', 'LIVE',                'REQUIRED', 'Live statistiky'),

    ('MATCH_DETAIL', 'player_statistics', 'HISTORY_PREDICTION', 'REQUIRED', 'Historické hráčské statistiky'),
    ('MATCH_DETAIL', 'player_statistics', 'CURRENT',             'REQUIRED', 'Aktuální hráčské statistiky'),
    ('MATCH_DETAIL', 'player_statistics', 'LIVE',                'OPTIONAL', 'Live statistiky jednotlivých hráčů'),

    ('MATCH_DETAIL', 'injuries_absences', 'HISTORY_PREDICTION', 'REQUIRED', 'Historie absencí pro modely'),
    ('MATCH_DETAIL', 'injuries_absences', 'CURRENT',             'REQUIRED', 'Aktuální absence'),
    ('MATCH_DETAIL', 'injuries_absences', 'FUTURE',              'REQUIRED', 'Známé absence před zápasem'),


    -- ========================================================
    -- ODDS
    -- ========================================================

    ('ODDS', 'prematch_odds', 'HISTORY_PREDICTION', 'REQUIRED', 'Historické pre-match kurzy'),
    ('ODDS', 'prematch_odds', 'CURRENT',             'REQUIRED', 'Aktuální pre-match kurzy'),
    ('ODDS', 'prematch_odds', 'FUTURE',              'REQUIRED', 'Kurzy budoucích zápasů'),

    ('ODDS', 'live_odds', 'HISTORY_PREDICTION', 'OPTIONAL', 'Historie live kurzů, pokud je licenčně dostupná'),
    ('ODDS', 'live_odds', 'CURRENT',             'OPTIONAL', 'Aktuální live kurzy'),
    ('ODDS', 'live_odds', 'LIVE',                'OPTIONAL', 'Live odds během zápasu'),

    ('ODDS', 'markets_bookmakers', 'HISTORY_PREDICTION', 'OPTIONAL', 'Historie trhů a bookmakerů'),
    ('ODDS', 'markets_bookmakers', 'CURRENT',             'REQUIRED', 'Aktuální trhy a bookmakeři'),
    ('ODDS', 'markets_bookmakers', 'FUTURE',              'REQUIRED', 'Trhy pro budoucí zápasy'),


    -- ========================================================
    -- MEDIA / FAN
    -- ========================================================

    ('MEDIA_FAN', 'news_articles', 'HISTORY_FAN', 'REQUIRED', 'Historické články a zprávy'),
    ('MEDIA_FAN', 'news_articles', 'CURRENT',      'REQUIRED', 'Aktuální články'),
    ('MEDIA_FAN', 'news_articles', 'FUTURE',       'OPTIONAL', 'Preview a předzápasové články'),

    ('MEDIA_FAN', 'photos', 'HISTORY_FAN', 'OPTIONAL', 'Historické fotografie s doloženými právy'),
    ('MEDIA_FAN', 'photos', 'CURRENT',      'OPTIONAL', 'Aktuální fotografie s doloženými právy'),

    ('MEDIA_FAN', 'video_metadata', 'HISTORY_FAN', 'OPTIONAL', 'Metadata historického videoobsahu'),
    ('MEDIA_FAN', 'video_metadata', 'CURRENT',      'OPTIONAL', 'Metadata aktuálního videoobsahu'),

    ('MEDIA_FAN', 'honours_records', 'HISTORY_FAN', 'REQUIRED', 'Tituly, úspěchy a rekordy'),
    ('MEDIA_FAN', 'honours_records', 'CURRENT',      'REQUIRED', 'Aktualizace titulů a rekordů'),

    ('MEDIA_FAN', 'historical_squads', 'HISTORY_FAN', 'REQUIRED', 'Historické soupisky')
),

checks (
    check_code,
    is_blocking,
    evidence_required,
    manual_approval_required,
    applies_to_historical,
    applies_to_operational
) AS (

    VALUES
    ('ENTITY_DEFINED',       true,  true,  false, true, true),
    ('COVERAGE',             true,  true,  false, true, true),
    ('PRIMARY_PROVIDER',     true,  true,  false, true, true),
    ('FALLBACK_PROVIDER',    false, true,  false, true, true),
    ('ENDPOINT',             true,  true,  false, true, true),
    ('TECHNICAL_PIPELINE',   true,  true,  false, true, true),
    ('CANONICAL_MAPPING',    true,  true,  false, true, true),
    ('DATA_QUALITY',         true,  true,  false, true, true),
    ('COMMERCIAL',           true,  true,  true,  true, true),
    ('LEGAL',                true,  true,  true,  true, true),
    ('SMOKE_TEST',           true,  true,  false, true, true),
    ('HISTORICAL_PILOT',     true,  true,  false, true, false),
    ('HEALTH_MONITORING',    true,  true,  false, false, true),
    ('REFRESH_CADENCE',      true,  true,  false, false, true),
    ('EVIDENCE',             true,  true,  false, true, true)
)

SELECT
    'HB' AS sport_code,
    s.layer_type,
    s.entity,
    s.time_mode,
    c.check_code,
    s.requirement_level,

    CASE
        WHEN s.requirement_level = 'OPTIONAL'
            THEN false
        ELSE c.is_blocking
    END AS is_blocking,

    c.evidence_required,
    c.manual_approval_required,

    s.entity_description AS description_cz,

    CASE c.check_code
        WHEN 'ENTITY_DEFINED'
            THEN 'MM-PRV-010 / Entity Catalogue'
        WHEN 'COVERAGE'
            THEN 'provider_entity_coverage / source_coverage_matrix / runtime audit'
        WHEN 'PRIMARY_PROVIDER'
            THEN 'Provider Matrix / routing decision'
        WHEN 'FALLBACK_PROVIDER'
            THEN 'Provider Matrix / routing and fallback'
        WHEN 'ENDPOINT'
            THEN 'provider documentation + runtime test'
        WHEN 'TECHNICAL_PIPELINE'
            THEN 'runtime_entity_audit'
        WHEN 'CANONICAL_MAPPING'
            THEN 'provider map / canonical governance audit'
        WHEN 'DATA_QUALITY'
            THEN 'runtime audit / quality audit / post-import verification'
        WHEN 'COMMERCIAL'
            THEN 'source_commercial_model / verified tariff evidence'
        WHEN 'LEGAL'
            THEN 'source_legal_audit / MM-PRV-006'
        WHEN 'SMOKE_TEST'
            THEN 'controlled runtime test'
        WHEN 'HISTORICAL_PILOT'
            THEN 'limited historical backfill audit'
        WHEN 'HEALTH_MONITORING'
            THEN 'Provider Health Monitoring'
        WHEN 'REFRESH_CADENCE'
            THEN 'scheduler / job configuration / freshness audit'
        WHEN 'EVIDENCE'
            THEN 'audit evidence registry'
    END AS source_rule_note

FROM hb_scope s
CROSS JOIN checks c

WHERE

    (
        s.time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
        AND c.applies_to_historical = true
    )

    OR

    (
        s.time_mode IN ('CURRENT', 'FUTURE', 'LIVE')
        AND c.applies_to_operational = true
    )

ORDER BY
    s.layer_type,
    s.entity,
    s.time_mode,
    c.check_code;