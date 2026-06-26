/*
===============================================================================
MATCHMATRIX SQL 24_1_C_3
GLOBAL SOURCE UPDATE V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_1_GLOBAL_SOURCE_REGISTRY

CO TO JE:
První seed hlavního globálního registru zdrojů.

K ČEMU TO JE:
Založí základní ověřené kandidáty zdrojů pro další discovery,
legal audit, coverage audit a budoucí harvest.

VÝSTUP:
ops.global_source_registry

NÁVAZNOST:
Navazuje na:
24_1_C_1_GLOBAL_SOURCE_REGISTRY_V1.sql

AUTOR:
MATCHMATRIX
===============================================================================
*/

INSERT INTO ops.global_source_registry (
    sport_code,
    source_name,
    source_type,
    source_level,
    source_url,
    source_status,
    discovery_status,
    verification_status,
    commercial_status,
    people_supported,
    coaches_supported,
    photos_supported,
    statistics_supported,
    history_supported,
    media_supported,
    priority_score,
    notes
)
VALUES
('HB', 'European Handball Federation', 'FEDERATION', 'CONTINENTAL', 'https://www.eurohandball.com', 'DISCOVERED', 'OPEN', 'NOT_VERIFIED', 'UNKNOWN', true, true, true, true, true, true, 95, 'EHF – hlavní evropský zdroj pro házenou.'),
('HB', 'International Handball Federation', 'FEDERATION', 'GLOBAL', 'https://www.ihf.info', 'DISCOVERED', 'OPEN', 'NOT_VERIFIED', 'UNKNOWN', true, true, true, true, true, true, 90, 'IHF – globální zdroj pro házenou.'),
('FB', 'FIFA', 'FEDERATION', 'GLOBAL', 'https://www.fifa.com', 'DISCOVERED', 'OPEN', 'NOT_VERIFIED', 'UNKNOWN', true, true, true, true, true, true, 95, 'FIFA – globální fotbalový zdroj.'),
('FB', 'UEFA', 'FEDERATION', 'CONTINENTAL', 'https://www.uefa.com', 'DISCOVERED', 'OPEN', 'NOT_VERIFIED', 'UNKNOWN', true, true, true, true, true, true, 95, 'UEFA – evropský fotbalový zdroj.'),
('BK', 'FIBA', 'FEDERATION', 'GLOBAL', 'https://www.fiba.basketball', 'DISCOVERED', 'OPEN', 'NOT_VERIFIED', 'UNKNOWN', true, true, true, true, true, true, 90, 'FIBA – globální basketbalový zdroj.'),
('HK', 'International Ice Hockey Federation', 'FEDERATION', 'GLOBAL', 'https://www.iihf.com', 'DISCOVERED', 'OPEN', 'NOT_VERIFIED', 'UNKNOWN', true, true, true, true, true, true, 90, 'IIHF – globální hokejový zdroj.')
ON CONFLICT DO NOTHING;