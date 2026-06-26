/*
===============================================================================
MATCHMATRIX SQL 24_1_A_14
HB NATIONAL LEAGUES DISCOVERY V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_6_SOURCE DISCOVERY AUTOMATION

SPORT:
HB - HANDBALL

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Evidence hlavních národních házenkářských soutěží.
- Základ budoucího HB Master Source Map.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Zjistit které soutěže EHF nepokrývá.
- Najít oficiální zdroje jednotlivých lig.
- Najít zdroje pro hráče, trenéry, statistiky a historii.

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.hb_national_league_discovery
(
    discovery_id BIGSERIAL PRIMARY KEY,

    country_name TEXT NOT NULL,
    league_name TEXT NOT NULL,

    priority_score INTEGER,

    official_site TEXT,

    players_available TEXT,
    coaches_available TEXT,
    photos_available TEXT,
    statistics_available TEXT,
    history_available TEXT,

    api_available TEXT,

    source_status TEXT DEFAULT 'DISCOVERY_REQUIRED',

    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO ops.hb_national_league_discovery
(
    country_name,
    league_name,
    priority_score
)
VALUES

('Germany','Handball Bundesliga',100),
('France','LNH Starligue',98),
('Spain','Liga ASOBAL',97),
('Denmark','Herreligaen',96),
('Poland','Superliga',94),
('Hungary','NB I',93),
('Sweden','Handbollsligan',92),
('Norway','REMA 1000 Ligaen',91),
('Croatia','Premijer Liga',90),
('Romania','Liga Națională',89);

SELECT
    country_name,
    league_name,
    priority_score,
    source_status
FROM ops.hb_national_league_discovery
ORDER BY priority_score DESC;