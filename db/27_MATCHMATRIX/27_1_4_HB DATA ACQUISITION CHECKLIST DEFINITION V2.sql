-- ============================================================
-- MATCHMATRIX
-- HB DATA ACQUISITION CHECKLIST DEFINITION V2
-- APPLY
--
-- CO:
-- Vloží normativní checklist pro Handball (HB).
--
-- K ČEMU:
-- Definuje povinné kontroly pro:
-- SPORT × LAYER × ENTITY × TIME_MODE × CHECK.
--
-- KDE:
-- ops.data_acquisition_checklist_definition
--
-- JAK:
-- Idempotentní INSERT.
-- Při opakovaném spuštění nevzniknou duplicity.
--
-- MODE:
-- APPLY
-- ============================================================

BEGIN;

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

    ('CORE', 'leagues', 'HISTORY_FAN',         'REQUIRED', 'Soutěže a ligy – hluboká historie'),
    ('CORE', 'leagues', 'HISTORY_PREDICTION',  'REQUIRED', 'Soutěže a ligy – modelová historie'),
    ('CORE', 'leagues', 'CURRENT',              'REQUIRED', 'Aktuální soutěže'),
    ('CORE', 'leagues', 'FUTURE',               'REQUIRED', 'Budoucí soutěže a ročníky'),

    ('CORE', 'seasons', 'HISTORY_FAN',          'REQUIRED', 'Historické sezony'),
    ('CORE', 'seasons', 'HISTORY_PREDICTION',   'REQUIRED', 'Sezony použitelné pro modely'),
    ('CORE', 'seasons', 'CURRENT',               'REQUIRED', 'Aktuální sezona'),
    ('CORE', 'seasons', 'FUTURE',                'REQUIRED', 'Budoucí sezony, pokud jsou publikované'),

    ('CORE', 'teams', 'HISTORY_FAN',             'REQUIRED', 'Historické týmy'),
    ('CORE', 'teams', 'HISTORY_PREDICTION',      'REQUIRED', 'Historické týmové identity pro modely'),
    ('CORE', 'teams', 'CURRENT',                  'REQUIRED', 'Aktuální týmy'),
    ('CORE', 'teams', 'FUTURE',                   'REQUIRED', 'Budoucí účastníci soutěží'),

    ('CORE', 'fixtures', 'HISTORY_FAN',           'REQUIRED', 'Historické zápasy'),
    ('CORE', 'fixtures', 'HISTORY_PREDICTION',    'REQUIRED', 'Historické zápasy pro modely'),
    ('CORE', 'fixtures', 'CURRENT',                'REQUIRED', 'Aktuální zápasy'),
    ('CORE', 'fixtures', 'FUTURE',                 'REQUIRED', 'Budoucí program'),
    ('CORE', 'fixtures', 'LIVE',                   'REQUIRED', 'Živý stav probíhajících zápasů'),

    ('CORE', 'results', 'HISTORY_FAN',            'REQUIRED', 'Historické výsledky'),
    ('CORE', 'results', 'HISTORY_PREDICTION',     'REQUIRED', 'Výsledky pro modely'),
    ('CORE', 'results', 'CURRENT',                 'REQUIRED', 'Aktuální a finální výsledky'),
    ('CORE', 'results', 'LIVE',                    'REQUIRED', 'Průběžný výsledek'),

    ('CORE', 'standings', 'HISTORY_FAN',          'REQUIRED', 'Historické tabulky'),
    ('CORE', 'standings', 'HISTORY_PREDICTION',   'REQUIRED', 'Historické tabulky pro modely'),
    ('CORE', 'standings', 'CURRENT',               'REQUIRED', 'Aktuální tabulky'),

    ('CORE', 'venues', 'HISTORY_FAN',             'OPTIONAL', 'Historická sportoviště'),
    ('CORE', 'venues', 'CURRENT',                  'REQUIRED', 'Aktuální sportoviště'),
    ('CORE', 'venues', 'FUTURE',                   'OPTIONAL', 'Sportoviště budoucích zápasů'),


    -- ========================================================
    -- PEOPLE
    -- ========================================================

    ('PEOPLE', 'players', 'HISTORY_FAN',          'REQUIRED', 'Historické profily a hráčské identity'),
    ('PEOPLE', 'players', 'HISTORY_PREDICTION',   'REQUIRED', 'Historie hráčů pro modely'),
    ('PEOPLE', 'players', 'CURRENT',               'REQUIRED', 'Aktuální hráči'),

    ('PEOPLE', 'coaches', 'HISTORY_FAN',          'REQUIRED', 'Historie trenérů'),
    ('PEOPLE', 'coaches', 'CURRENT',               'REQUIRED', 'Aktuální trenéři'),

    ('PEOPLE', 'staff', 'HISTORY_FAN',            'OPTIONAL', 'Historický realizační tým'),
    ('PEOPLE', 'staff', 'CURRENT',                 'OPTIONAL', 'Aktuální realizační tým'),

    ('PEOPLE', 'referees', 'HISTORY_FAN',         'OPTIONAL', 'Historie rozhodčích'),
    ('PEOPLE', 'referees', 'HISTORY_PREDICTION',  'OPTIONAL', 'Rozhodčí pro analytické použití'),
    ('PEOPLE', 'referees', 'CURRENT',              'OPTIONAL', 'Aktuální rozhodčí'),

    ('PEOPLE', 'profiles', 'HISTORY_FAN',         'REQUIRED', 'Biografické a profilové údaje'),
    ('PEOPLE', 'profiles', 'CURRENT',              'REQUIRED', 'Aktuální profilové údaje'),

    ('PEOPLE', 'career_history', 'HISTORY_FAN',   'REQUIRED', 'Klubová a reprezentační kariéra'),

    ('PEOPLE', 'season_statistics', 'HISTORY_PREDICTION', 'REQUIRED', 'Historické sezonní statistiky'),
    ('PEOPLE', 'season_statistics', 'CURRENT',             'REQUIRED', 'Aktuální sezonní statistiky'),


    -- ========================================================
    -- MATCH DETAIL
    -- ========================================================

    ('MATCH_DETAIL', 'lineups', 'HISTORY_FAN',         'OPTIONAL', 'Historické sestavy'),
    ('MATCH_DETAIL', 'lineups', 'HISTORY_PREDICTION',  'REQUIRED', 'Historické sestavy pro modely'),
    ('MATCH_DETAIL', 'lineups', 'CURRENT',              'REQUIRED', 'Aktuální sestavy'),
    ('MATCH_DETAIL', 'lineups', 'FUTURE',               'REQUIRED', 'Předzápasové / potvrzené sestavy'),
    ('MATCH_DETAIL', 'lineups', 'LIVE',                 'REQUIRED', 'Aktivní sestava při zápase'),

    ('MATCH_DETAIL', 'incidents', 'HISTORY_FAN',        'OPTIONAL', 'Historické zápasové události'),
    ('MATCH_DETAIL', 'incidents', 'HISTORY_PREDICTION', 'OPTIONAL', 'Události pro analytické použití'),
    ('MATCH_DETAIL', 'incidents', 'CURRENT',            'REQUIRED', 'Aktuální zápasové události'),
    ('MATCH_DETAIL', 'incidents', 'LIVE',               'REQUIRED', 'Live zápasové události'),

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

    ('ODDS', 'live_odds', 'HISTORY_PREDICTION',      'OPTIONAL', 'Historie live kurzů, pokud je licenčně dostupná'),
    ('ODDS', 'live_odds', 'CURRENT',                  'OPTIONAL', 'Aktuální live kurzy'),
    ('ODDS', 'live_odds', 'LIVE',                     'OPTIONAL', 'Live odds během zápasu'),

    ('ODDS', 'markets_bookmakers', 'HISTORY_PREDICTION', 'OPTIONAL', 'Historie trhů a bookmakerů'),
    ('ODDS', 'markets_bookmakers', 'CURRENT',             'REQUIRED', 'Aktuální trhy a bookmakeři'),
    ('ODDS', 'markets_bookmakers', 'FUTURE',              'REQUIRED', 'Trhy pro budoucí zápasy'),


    -- ========================================================
    -- MEDIA / FAN
    -- ========================================================

    ('MEDIA_FAN', 'news_articles', 'HISTORY_FAN', 'REQUIRED', 'Historické články a zprávy'),
    ('MEDIA_FAN', 'news_articles', 'CURRENT',      'REQUIRED', 'Aktuální články'),
    ('MEDIA_FAN', 'news_articles', 'FUTURE',       'OPTIONAL', 'Preview a předzápasové články'),

    ('MEDIA_FAN', 'photos', 'HISTORY_FAN',         'OPTIONAL', 'Historické fotografie s doloženými právy'),
    ('MEDIA_FAN', 'photos', 'CURRENT',              'OPTIONAL', 'Aktuální fotografie s doloženými právy'),

    ('MEDIA_FAN', 'video_metadata', 'HISTORY_FAN', 'OPTIONAL', 'Metadata historického videoobsahu'),
    ('MEDIA_FAN', 'video_metadata', 'CURRENT',      'OPTIONAL', 'Metadata aktuálního videoobsahu'),

    ('MEDIA_FAN', 'honours_records', 'HISTORY_FAN', 'REQUIRED', 'Tituly, úspěchy a rekordy'),
    ('MEDIA_FAN', 'honours_records', 'CURRENT',      'REQUIRED', 'Aktualizace titulů a rekordů'),

    ('MEDIA_FAN', 'historical_squads', 'HISTORY_FAN', 'REQUIRED', 'Historické soupisky')
),

checks (
    check_code,
    priority_rank,
    default_blocking,
    evidence_required,
    manual_approval_required,
    decision_required,
    historical,
    operational
) AS (

    VALUES
        ('ENTITY_DEFINED',       10,  true,  true, false, false, true,  true),
        ('COVERAGE',             20,  true,  true, false, false, true,  true),
        ('PRIMARY_PROVIDER',     30,  true,  true, false, true,  true,  true),
        ('FALLBACK_PROVIDER',    40,  false, true, false, true,  true,  true),
        ('ENDPOINT',             50,  true,  true, false, false, true,  true),
        ('COMMERCIAL',           60,  true,  true, true,  true,  true,  true),
        ('LEGAL',                70,  true,  true, true,  true,  true,  true),
        ('TECHNICAL_PIPELINE',   80,  true,  true, false, false, true,  true),
        ('CANONICAL_MAPPING',    90,  true,  true, false, false, true,  true),
        ('DATA_QUALITY',        100,  true,  true, false, false, true,  true),
        ('SMOKE_TEST',          110,  true,  true, false, false, true,  true),
        ('HISTORICAL_PILOT',    120,  true,  true, false, false, true,  false),
        ('HEALTH_MONITORING',   130,  true,  true, false, false, false, true),
        ('REFRESH_CADENCE',     140,  true,  true, false, false, false, true),
        ('EVIDENCE',            150,  true,  true, false, false, true,  true)
),

generated AS (

    SELECT
        'HB'::text AS sport_code,
        s.layer_type,
        s.entity,
        s.time_mode,
        c.check_code,
        s.requirement_level,

        CASE
            WHEN s.requirement_level = 'OPTIONAL'
                THEN false
            ELSE c.default_blocking
        END AS is_blocking,

        c.priority_rank,
        c.evidence_required,
        c.manual_approval_required,
        c.decision_required,

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
            WHEN 'COMMERCIAL'
                THEN 'source_commercial_model / verified tariff evidence'
            WHEN 'LEGAL'
                THEN 'source_legal_audit / MM-PRV-006'
            WHEN 'TECHNICAL_PIPELINE'
                THEN 'runtime_entity_audit'
            WHEN 'CANONICAL_MAPPING'
                THEN 'provider map / canonical governance audit'
            WHEN 'DATA_QUALITY'
                THEN 'runtime audit / quality audit / post-import verification'
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
        END AS source_rule_note,

        CASE
            -- OPTIONAL scope nikdy neblokuje dokončení sportu.
            WHEN s.requirement_level = 'OPTIONAL'
                THEN 'APPROVED_GAP_ALLOWED'

            -- Fallback musí být rozhodnut, ale nemusí vždy existovat.
            WHEN c.check_code = 'FALLBACK_PROVIDER'
                THEN 'APPROVED_GAP_ALLOWED'

            -- Historická dostupnost může být objektivně omezená.
            WHEN s.time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
             AND c.check_code IN (
                    'COVERAGE',
                    'PRIMARY_PROVIDER',
                    'ENDPOINT',
                    'DATA_QUALITY',
                    'HISTORICAL_PILOT'
                 )
                THEN 'APPROVED_GAP_ALLOWED'

            ELSE 'NOT_ALLOWED'
        END AS gap_policy

    FROM hb_scope s
    CROSS JOIN checks c

    WHERE
        (
            s.time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
            AND c.historical = true
        )
        OR
        (
            s.time_mode IN ('CURRENT', 'FUTURE', 'LIVE')
            AND c.operational = true
        )
)

INSERT INTO ops.data_acquisition_checklist_definition
(
    sport_code,
    layer_type,
    entity,
    time_mode,
    check_code,
    requirement_level,
    is_blocking,
    priority_rank,
    evidence_required,
    manual_approval_required,
    description_cz,
    source_rule_note,
    is_active,
    gap_policy,
    decision_required
)

SELECT
    sport_code,
    layer_type,
    entity,
    time_mode,
    check_code,
    requirement_level,
    is_blocking,
    priority_rank,
    evidence_required,
    manual_approval_required,
    description_cz,
    source_rule_note,
    true,
    gap_policy,
    decision_required
FROM generated

ON CONFLICT (
    sport_code,
    layer_type,
    entity,
    time_mode,
    check_code
)
DO NOTHING;

COMMIT;


-- ============================================================
-- POSTCHECK 1 – ZÁKLADNÍ POČTY
-- ============================================================

SELECT
    sport_code,
    COUNT(*) AS checklist_rows,
    COUNT(DISTINCT layer_type) AS layers,
    COUNT(DISTINCT entity) AS entities,
    COUNT(DISTINCT (layer_type, entity, time_mode)) AS entity_time_scopes,
    COUNT(*) FILTER (WHERE requirement_level = 'REQUIRED') AS required_rows,
    COUNT(*) FILTER (WHERE requirement_level = 'OPTIONAL') AS optional_rows,
    COUNT(*) FILTER (WHERE is_blocking = true) AS blocking_rows,
    COUNT(*) FILTER (
        WHERE gap_policy = 'APPROVED_GAP_ALLOWED'
    ) AS approved_gap_allowed_rows,
    COUNT(*) FILTER (
        WHERE decision_required = true
    ) AS decision_required_rows
FROM ops.data_acquisition_checklist_definition
WHERE sport_code = 'HB'
GROUP BY sport_code;


-- ============================================================
-- POSTCHECK 2 – DUPLICITY
-- Očekáváno: 0 řádků
-- ============================================================

SELECT
    sport_code,
    layer_type,
    entity,
    time_mode,
    check_code,
    COUNT(*) AS duplicate_count
FROM ops.data_acquisition_checklist_definition
WHERE sport_code = 'HB'
GROUP BY
    sport_code,
    layer_type,
    entity,
    time_mode,
    check_code
HAVING COUNT(*) > 1;


-- ============================================================
-- POSTCHECK 3 – STRUKTURA PODLE VRSTEV
-- ============================================================

SELECT
    layer_type,
    COUNT(DISTINCT entity) AS entities,
    COUNT(DISTINCT (entity, time_mode)) AS entity_time_scopes,
    COUNT(*) AS checklist_rows,
    COUNT(*) FILTER (
        WHERE requirement_level = 'REQUIRED'
    ) AS required_rows,
    COUNT(*) FILTER (
        WHERE requirement_level = 'OPTIONAL'
    ) AS optional_rows
FROM ops.data_acquisition_checklist_definition
WHERE sport_code = 'HB'
GROUP BY layer_type
ORDER BY layer_type;