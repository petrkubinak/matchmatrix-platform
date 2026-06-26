/*
===============================================================================
MATCHMATRIX 19_8_B1 – PEOPLE SOURCE DISCOVERY SEED
===============================================================================

CO TO JE:
První naplnění People Source Discovery Registry.

K ČEMU TO JE:
Zapíše všechny aktuálně známé providery People Layer.

KDE TO UVIDÍME:
OPS → PEOPLE → SOURCE DISCOVERY

JAK SE TO VYUŽIJE:
Provider Matrix
PC2 Planning
People Layer Roadmap
Source Discovery

NAVAZUJE NA:
19_8_A
19_8_B

DALŠÍ KROK:
19_8_C People Provider Scorecard
===============================================================================
*/

INSERT INTO ops.people_source_discovery_registry
(
    sport_code,
    entity_type,
    provider_name,
    access_type,
    status,
    quality_score,

    supports_players,
    supports_coaches,
    supports_photos,
    supports_birth_date,
    supports_nationality,
    supports_position,

    notes
)
VALUES

('FB','PLAYERS','api_football',
 'FREE_LIMITED','ACTIVE',95,
 TRUE,TRUE,FALSE,TRUE,TRUE,TRUE,
 'Hlavní football people provider'),

('BK','PLAYERS','api_sport',
 'FREE_LIMITED','ACTIVE',70,
 TRUE,FALSE,FALSE,FALSE,TRUE,TRUE,
 'Basketball players částečně'),

('BK','PLAYERS','sportsdataio',
 'PAID','ACTIVE',90,
 TRUE,FALSE,TRUE,TRUE,TRUE,TRUE,
 'Nejlepší zdroj BK profilů'),

('HK','PLAYERS','sportsdataio',
 'PAID','RESEARCH',75,
 TRUE,FALSE,FALSE,FALSE,FALSE,TRUE,
 'Hockey profile gap'),

('AFB','PLAYERS','api_american_football',
 'FREE_LIMITED','ACTIVE',80,
 TRUE,FALSE,FALSE,FALSE,FALSE,TRUE,
 'NFL people data'),

('BSB','PLAYERS','sportsdataio',
 'PAID','ACTIVE',88,
 TRUE,FALSE,FALSE,FALSE,TRUE,TRUE,
 'MLB profiles'),

('CK','PLAYERS','api_cricket',
 'FREE_LIMITED','ACTIVE',70,
 TRUE,FALSE,FALSE,FALSE,FALSE,TRUE,
 'Cricket partial profile'),

('TN','PLAYERS','api_tennis',
 'FREE_LIMITED','SOURCE_GAP',40,
 TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,
 'Nutný nový provider'),

('MMA','PLAYERS','sportsdataio',
 'PAID','SOURCE_GAP',50,
 TRUE,FALSE,FALSE,FALSE,FALSE,TRUE,
 'Nutné rozšíření profilu'),

('ALL','PHOTOS','wikimedia',
 'FREE','ACTIVE',85,
 FALSE,FALSE,TRUE,FALSE,FALSE,FALSE,
 'Photo fallback'),

('ALL','PHOTOS','wikidata',
 'FREE','ACTIVE',80,
 FALSE,FALSE,TRUE,FALSE,FALSE,FALSE,
 'Identity + photo fallback');