/*
===============================================================================
MATCHMATRIX SQL 24_2_A_2
GLOBAL SOURCE SEED V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_2_A_GLOBAL SOURCE DISCOVERY

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- První naplnění Source Discovery Master registru.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Vytvoření základního katalogu zdrojů pro všechny sporty.
- Příprava na Source Audit.
- Příprava na Coverage Matrix.
- Příprava na Legal Audit.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_discovery_master
- SOURCE COMMAND CENTER
- SOURCE INTELLIGENCE DASHBOARD

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Centrální katalog zdrojů MatchMatrix.
- Základ pro budoucí AI Discovery Engine.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Zakládá první ověřené zdroje pro hlavní sporty.
- Nevytváří duplicity.
- Připravuje globální katalog zdrojů.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

INSERT INTO ops.source_discovery_master
(
    sport_code,
    source_name,
    source_category,
    source_type,
    source_url,
    priority_score,
    source_scope
)
SELECT *
FROM
(
VALUES

-- FOOTBALL

('FB','FIFA','FEDERATION','GLOBAL_FEDERATION','https://www.fifa.com',100,'GLOBAL'),
('FB','UEFA','FEDERATION','CONTINENTAL_FEDERATION','https://www.uefa.com',100,'EUROPE'),
('FB','Transfermarkt','KNOWLEDGE','KNOWLEDGE_BASE','https://www.transfermarkt.com',95,'GLOBAL'),

-- HANDBALL

('HB','European Handball Federation','FEDERATION','CONTINENTAL_FEDERATION','https://www.eurohandball.com',100,'EUROPE'),
('HB','International Handball Federation','FEDERATION','GLOBAL_FEDERATION','https://www.ihf.info',100,'GLOBAL'),

-- HOCKEY

('HK','IIHF','FEDERATION','GLOBAL_FEDERATION','https://www.iihf.com',100,'GLOBAL'),

-- BASKETBALL

('BK','FIBA','FEDERATION','GLOBAL_FEDERATION','https://www.fiba.basketball',100,'GLOBAL'),
('BK','EuroLeague','LEAGUE_OPERATOR','CONTINENTAL_OPERATOR','https://www.euroleaguebasketball.net',95,'EUROPE'),

-- TENNIS

('TN','ATP Tour','FEDERATION','TOUR_OPERATOR','https://www.atptour.com',100,'GLOBAL'),
('TN','WTA','FEDERATION','TOUR_OPERATOR','https://www.wtatennis.com',100,'GLOBAL'),

-- VOLLEYBALL

('VB','FIVB','FEDERATION','GLOBAL_FEDERATION','https://www.fivb.com',100,'GLOBAL'),

-- BASEBALL

('BSB','WBSC','FEDERATION','GLOBAL_FEDERATION','https://www.wbsc.org',100,'GLOBAL'),

-- MMA

('MMA','UFC','LEAGUE_OPERATOR','GLOBAL_OPERATOR','https://www.ufc.com',100,'GLOBAL'),

-- AMERICAN FOOTBALL

('AFB','NFL','LEAGUE_OPERATOR','GLOBAL_OPERATOR','https://www.nfl.com',100,'GLOBAL'),

-- CRICKET

('CK','ICC','FEDERATION','GLOBAL_FEDERATION','https://www.icc-cricket.com',100,'GLOBAL')

) AS x
(
sport_code,
source_name,
source_category,
source_type,
source_url,
priority_score,
source_scope
)
WHERE NOT EXISTS
(
    SELECT 1
    FROM ops.source_discovery_master d
    WHERE d.sport_code = x.sport_code
      AND d.source_name = x.source_name
);

SELECT
    sport_code,
    COUNT(*) AS source_count
FROM ops.source_discovery_master
GROUP BY sport_code
ORDER BY sport_code;