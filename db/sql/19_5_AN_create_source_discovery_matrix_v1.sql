/*
===============================================================================
MATCHMATRIX 19_5_AN
SOURCE DISCOVERY MATRIX V1
===============================================================================

KAM ULOŽIT:
C:\MatchMatrix-platform\sql\governance\

NÁZEV SOUBORU:
19_5_AN_create_source_discovery_matrix_v1.sql

CO TO JE:
Master tabulka typů zdrojů pro hledání dat mimo hlavní API.

K ČEMU TO JE:
Definuje, kde má MatchMatrix hledat náhradní nebo doplňková data.

KDE TO UVIDÍME:
OPS Panel
Source Discovery
Data Gap Engine
Autonomous Brain

JAK SE TO VYUŽIJE:
Když hlavní provider vrátí 0 dat nebo neúplná data, systém podle této matice
navrhne další typ zdroje: official team site, league site, federation, RSS,
sitemap, Wikidata, Wikimedia, CSV/open data nebo paid feed.
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_discovery_matrix (

    id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL DEFAULT 'ALL',
    entity_type TEXT NOT NULL,
    source_type TEXT NOT NULL,

    trust_level INTEGER DEFAULT 50,
    automation_level INTEGER DEFAULT 50,
    license_risk TEXT DEFAULT 'REVIEW',
    priority_order INTEGER DEFAULT 100,

    is_primary_candidate BOOLEAN DEFAULT FALSE,
    is_fallback_candidate BOOLEAN DEFAULT TRUE,
    is_enabled BOOLEAN DEFAULT TRUE,

    discovery_note TEXT,
    expected_data TEXT,
    next_action TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_source_discovery_matrix_01
ON ops.source_discovery_matrix (
    sport_code,
    entity_type,
    priority_order
);

TRUNCATE TABLE ops.source_discovery_matrix;

INSERT INTO ops.source_discovery_matrix
(
    sport_code,
    entity_type,
    source_type,
    trust_level,
    automation_level,
    license_risk,
    priority_order,
    is_primary_candidate,
    is_fallback_candidate,
    discovery_note,
    expected_data,
    next_action
)
VALUES
-- PLAYERS
('ALL','PLAYERS','API_PROVIDER',90,90,'LOW',10,TRUE,TRUE,'Primární strukturovaný zdroj hráčů.','players, team, position, profile','Použít jako první zdroj.'),
('ALL','PLAYERS','OFFICIAL_TEAM_SITE',95,45,'REVIEW',20,FALSE,TRUE,'Oficiální týmové soupisky a profily.','roster, player profile, position, photo','Použít pro fallback nebo enrichment.'),
('ALL','PLAYERS','OFFICIAL_LEAGUE_SITE',90,55,'REVIEW',30,FALSE,TRUE,'Ligové soupisky a profily hráčů.','league roster, player profile','Použít při chybě API nebo pro kontrolu.'),
('ALL','PLAYERS','FEDERATION_SITE',90,40,'REVIEW',40,FALSE,TRUE,'Federace mohou mít oficiální registrace/soupisky.','registered players, national teams','Použít hlavně pro menší sporty.'),
('ALL','PLAYERS','WIKIDATA',70,75,'LOW',50,FALSE,TRUE,'Doplňkový strukturovaný zdroj.','birth date, nationality, identifiers','Použít pro enrichment a identifikaci.'),

-- COACHES
('ALL','COACHES','API_PROVIDER',85,80,'LOW',10,TRUE,TRUE,'API zdroj trenérů.','coach name, team, role','Použít jako první zdroj.'),
('ALL','COACHES','OFFICIAL_TEAM_SITE',95,45,'REVIEW',20,FALSE,TRUE,'Oficiální realizační tým klubu.','coach profile, role, photo','Použít jako hlavní fallback.'),
('ALL','COACHES','OFFICIAL_LEAGUE_SITE',85,50,'REVIEW',30,FALSE,TRUE,'Ligový profil týmu/trenéra.','coach/team staff data','Použít pro ověření.'),
('ALL','COACHES','WIKIDATA',65,70,'LOW',50,FALSE,TRUE,'Doplňkový zdroj identity trenéra.','birth date, nationality','Použít pro enrichment.'),

-- FIXTURES
('ALL','FIXTURES','API_PROVIDER',90,90,'LOW',10,TRUE,TRUE,'Primární strukturovaný zdroj zápasů.','fixtures, scores, status','Použít jako první zdroj.'),
('ALL','FIXTURES','OFFICIAL_LEAGUE_SITE',95,55,'REVIEW',20,FALSE,TRUE,'Oficiální rozpis a výsledky ligy.','schedule, results, standings context','Fallback / validace.'),
('ALL','FIXTURES','FEDERATION_SITE',90,45,'REVIEW',30,FALSE,TRUE,'Federace pro menší sporty a soutěže.','schedule, results','Použít pro sporty bez API.'),
('ALL','FIXTURES','CSV_OPEN_DATA',75,85,'LOW',40,FALSE,TRUE,'CSV/open data pro historická data.','historical fixtures/results','Použít jako historický fallback.'),

-- ODDS
('ALL','ODDS','API_PROVIDER',90,90,'LOW',10,TRUE,TRUE,'Strukturovaný odds provider.','bookmaker, market, outcome, odd','Použít jako primární odds zdroj.'),
('ALL','ODDS','PAID_FEED',95,85,'LOW',20,FALSE,TRUE,'Placený profesionální feed.','deep odds, historical odds, live odds','Použít po business vyhodnocení.'),
('ALL','ODDS','BOOKMAKER_SITE',80,35,'HIGH',50,FALSE,FALSE,'Bookmaker weby mají vysoké právní/licenční riziko.','odds','Nepoužívat bez právní kontroly.'),

-- MEDIA
('ALL','MEDIA','OFFICIAL_LEAGUE_SITE',95,60,'REVIEW',10,TRUE,TRUE,'Oficiální ligové články a novinky.','articles, videos, announcements','Použít jako primární media zdroj.'),
('ALL','MEDIA','OFFICIAL_TEAM_SITE',95,55,'REVIEW',20,FALSE,TRUE,'Klubové články a zprávy.','team news, player news','Použít pro týmový kontext.'),
('ALL','MEDIA','RSS',80,85,'REVIEW',30,FALSE,TRUE,'RSS zdroj, pokud existuje.','articles feed','Použít pro automatický ingest.'),
('ALL','MEDIA','SITEMAP',80,80,'REVIEW',40,FALSE,TRUE,'Sitemap discovery článků.','article URLs','Použít pro official site discovery.'),

-- PHOTOS
('ALL','PHOTOS','WIKIMEDIA',75,75,'LOW',10,TRUE,TRUE,'Volně použitelný zdroj při správné licenci.','photo, license, author','Použít s license checkem.'),
('ALL','PHOTOS','OFFICIAL_TEAM_SITE',90,40,'REVIEW',20,FALSE,TRUE,'Oficiální hráčské/týmové profily.','player photo, coach photo','Použít jen po ověření licence.'),
('ALL','PHOTOS','OFFICIAL_LEAGUE_SITE',85,45,'REVIEW',30,FALSE,TRUE,'Ligové profily hráčů/týmů.','player/team photos','Použít jen po ověření licence.'),
('ALL','PHOTOS','WIKIDATA',65,80,'LOW',40,FALSE,TRUE,'Pomocný zdroj pro nalezení Wikimedia assetu.','image reference, ids','Použít pro discovery, ne jako finální asset.');

ANALYZE ops.source_discovery_matrix;