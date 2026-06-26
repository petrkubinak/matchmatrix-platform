/*
===============================================================================
MATCHMATRIX SQL 24_1_A_8
HB SOURCE EHF IHF REVIEW PLAN V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_1_MASTER_SOURCE_MAP

SPORT:
HB - HANDBALL

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Detailní review plán pro ověření EHF a IHF jako zdrojů házené.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Rozpadne velké úkoly CHECK_TERMS_AND_ROBOTS na konkrétní kontrolní body.
- Připraví ověření použitelnosti EHF/IHF pro hráče, trenéry, fotky,
  soutěže, média a historická data.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_discovery_review_plan
- SOURCE COMMAND CENTER
- OPS Panel

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Každý kontrolní bod půjde ručně nebo automaticky ověřit.
- Výsledek rozhodne, zda EHF/IHF přejdou ze stavu CHECK_TERMS do VERIFIED.
- Budoucí discovery worker bude podle těchto úkolů kontrolovat zdroje.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytvoří tabulku source_discovery_review_plan.
- Založí kontrolní body pro EHF a IHF.
- Připraví první skutečný audit zdrojů.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_discovery_review_plan
(
    review_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    source_name TEXT NOT NULL,

    review_area TEXT NOT NULL,
    review_item TEXT NOT NULL,

    priority_score INTEGER DEFAULT 50,
    current_status TEXT DEFAULT 'PENDING',

    expected_result TEXT,
    evidence_url TEXT,
    evidence_note TEXT,

    next_action TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS ix_source_discovery_review_plan_sport
ON ops.source_discovery_review_plan (sport_code);

CREATE INDEX IF NOT EXISTS ix_source_discovery_review_plan_status
ON ops.source_discovery_review_plan (current_status);

INSERT INTO ops.source_discovery_review_plan
(
    sport_code,
    source_name,
    review_area,
    review_item,
    priority_score,
    current_status,
    expected_result,
    next_action
)
VALUES

-- EHF
('HB', 'European Handball Federation', 'LEGAL', 'Terms of use', 100, 'OPEN', 'Najít a posoudit podmínky použití dat.', 'CHECK_TERMS_PAGE'),
('HB', 'European Handball Federation', 'LEGAL', 'Robots.txt', 100, 'OPEN', 'Ověřit pravidla automatického přístupu.', 'CHECK_ROBOTS_TXT'),
('HB', 'European Handball Federation', 'DISCOVERY', 'Sitemap', 90, 'OPEN', 'Ověřit, zda existuje sitemap použitelná pro discovery.', 'CHECK_SITEMAP'),
('HB', 'European Handball Federation', 'PEOPLE', 'Players profiles', 95, 'OPEN', 'Ověřit dostupnost hráčských profilů.', 'CHECK_PLAYER_PROFILES'),
('HB', 'European Handball Federation', 'PEOPLE', 'Coach profiles', 90, 'OPEN', 'Ověřit dostupnost trenérských profilů.', 'CHECK_COACH_PROFILES'),
('HB', 'European Handball Federation', 'MEDIA', 'Articles/news', 85, 'OPEN', 'Ověřit dostupnost článků a novinek.', 'CHECK_NEWS_SECTION'),
('HB', 'European Handball Federation', 'MEDIA', 'Photos/media assets', 85, 'OPEN', 'Ověřit dostupnost fotografií a media assetů.', 'CHECK_MEDIA_ASSETS'),
('HB', 'European Handball Federation', 'HISTORY', 'Historical archive', 95, 'OPEN', 'Ověřit historický archiv soutěží, týmů a hráčů.', 'CHECK_HISTORICAL_ARCHIVE'),
('HB', 'European Handball Federation', 'SPORT_CORE', 'Competitions/leagues', 90, 'OPEN', 'Ověřit seznam soutěží a historických sezón.', 'CHECK_COMPETITIONS'),

-- IHF
('HB', 'International Handball Federation', 'LEGAL', 'Terms of use', 100, 'OPEN', 'Najít a posoudit podmínky použití dat.', 'CHECK_TERMS_PAGE'),
('HB', 'International Handball Federation', 'LEGAL', 'Robots.txt', 100, 'OPEN', 'Ověřit pravidla automatického přístupu.', 'CHECK_ROBOTS_TXT'),
('HB', 'International Handball Federation', 'DISCOVERY', 'Sitemap', 90, 'OPEN', 'Ověřit, zda existuje sitemap použitelná pro discovery.', 'CHECK_SITEMAP'),
('HB', 'International Handball Federation', 'PEOPLE', 'Players profiles', 95, 'OPEN', 'Ověřit dostupnost hráčských profilů.', 'CHECK_PLAYER_PROFILES'),
('HB', 'International Handball Federation', 'PEOPLE', 'Coach profiles', 90, 'OPEN', 'Ověřit dostupnost trenérských profilů.', 'CHECK_COACH_PROFILES'),
('HB', 'International Handball Federation', 'MEDIA', 'Articles/news', 85, 'OPEN', 'Ověřit dostupnost článků a novinek.', 'CHECK_NEWS_SECTION'),
('HB', 'International Handball Federation', 'MEDIA', 'Photos/media assets', 85, 'OPEN', 'Ověřit dostupnost fotografií a media assetů.', 'CHECK_MEDIA_ASSETS'),
('HB', 'International Handball Federation', 'HISTORY', 'Historical archive', 95, 'OPEN', 'Ověřit historický archiv soutěží, týmů a hráčů.', 'CHECK_HISTORICAL_ARCHIVE'),
('HB', 'International Handball Federation', 'SPORT_CORE', 'Competitions/leagues', 90, 'OPEN', 'Ověřit seznam soutěží a historických sezón.', 'CHECK_COMPETITIONS');

SELECT
    source_name,
    review_area,
    review_item,
    priority_score,
    current_status,
    next_action
FROM ops.source_discovery_review_plan
WHERE sport_code = 'HB'
ORDER BY source_name, priority_score DESC, review_area, review_item;