/*
===============================================================================
MATCHMATRIX SQL 24_1_B_1
SOURCE COVERAGE MATRIX V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_1_B_SOURCE GOVERNANCE LAYER

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Centrální matice pokrytí datových zdrojů.
- Říká, co který zdroj poskytuje pro konkrétní sport a entitu.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby MatchMatrix věděl, odkud brát hráče, trenéry, fotky, statistiky,
  historii, média, kurzy a další datové vrstvy.
- Aby bylo možné zdroje porovnávat mezi sebou.
- Aby bylo možné rozhodnout, co použít hned a co až po placeném tarifu.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_coverage_matrix
- Source Intelligence Dashboard
- OPS Panel
- budoucí Source Command Center

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- AI Orchestrator vybere nejlepší zdroj podle sportu a entity.
- Harvest nebude spouštěn naslepo, ale podle ověřené coverage.
- Panel zobrazí, kde je zdroj READY / PARTIAL / MISSING / PAID_REQUIRED.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytvoří tabulku ops.source_coverage_matrix.
- Vloží první ověřené EHF coverage z dnešního auditu.
- Připraví základ pro další sporty a zdroje.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_coverage_matrix
(
    coverage_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    source_name TEXT NOT NULL,
    source_type TEXT,

    coverage_domain TEXT NOT NULL,
    entity_type TEXT NOT NULL,

    coverage_status TEXT NOT NULL DEFAULT 'UNKNOWN',

    coverage_score NUMERIC(5,2),
    quality_score NUMERIC(5,2),
    history_depth_score NUMERIC(5,2),
    automation_score NUMERIC(5,2),

    free_available BOOLEAN DEFAULT FALSE,
    paid_required BOOLEAN DEFAULT FALSE,

    legal_status TEXT DEFAULT 'REVIEW_REQUIRED',
    commercial_status TEXT DEFAULT 'UNKNOWN',

    evidence_note TEXT,
    next_action TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_source_coverage_matrix_sport
ON ops.source_coverage_matrix (sport_code);

CREATE INDEX IF NOT EXISTS ix_source_coverage_matrix_source
ON ops.source_coverage_matrix (source_name);

CREATE INDEX IF NOT EXISTS ix_source_coverage_matrix_entity
ON ops.source_coverage_matrix (entity_type);

COMMENT ON TABLE ops.source_coverage_matrix IS
'Centrální Source Intelligence matice pokrytí zdrojů podle sportu, entity a kvality dat.';


INSERT INTO ops.source_coverage_matrix
(
    sport_code,
    source_name,
    source_type,
    coverage_domain,
    entity_type,
    coverage_status,
    coverage_score,
    quality_score,
    history_depth_score,
    automation_score,
    free_available,
    paid_required,
    legal_status,
    commercial_status,
    evidence_note,
    next_action
)
VALUES

('HB','European Handball Federation','FEDERATION','PEOPLE','PLAYERS','VERIFIED',95,98,95,85,true,false,'REVIEW_REQUIRED','FREE_SOURCE',
 'Ověřeny hráčské profily, věk, výška, pozice, národnost, klub, góly a historie.',
 'MAP_PLAYER_PROFILE_FIELDS'),

('HB','European Handball Federation','FEDERATION','PEOPLE','COACHES','VERIFIED',90,95,80,80,true,false,'REVIEW_REQUIRED','FREE_SOURCE',
 'Ověřen Head Coach, Coach, Assistant Coach, Goalkeeper Coach a další staff.',
 'MAP_COACH_AND_STAFF_FIELDS'),

('HB','European Handball Federation','FEDERATION','MEDIA','PHOTOS','VERIFIED',90,95,70,75,true,false,'REVIEW_REQUIRED','FREE_SOURCE',
 'Screenshoty potvrzují fotografie hráčů, trenérů a staffu.',
 'REVIEW_PHOTO_LICENSE'),

('HB','European Handball Federation','FEDERATION','HISTORY','COMPETITION_HISTORY','VERIFIED',95,95,95,80,true,false,'REVIEW_REQUIRED','FREE_SOURCE',
 'Ověřena historie reprezentací a soutěží minimálně od roku 1994.',
 'MAP_HISTORY_DEPTH'),

('HB','European Handball Federation','FEDERATION','SPORT_CORE','EUROPEAN_COMPETITIONS','VERIFIED',100,95,95,85,true,false,'REVIEW_REQUIRED','FREE_SOURCE',
 'EHF pokrývá evropské reprezentační a klubové soutěže.',
 'USE_FOR_EUROPEAN_HB_CORE'),

('HB','European Handball Federation','FEDERATION','SPORT_CORE','NATIONAL_LEAGUES','PARTIAL',10,80,20,40,true,false,'REVIEW_REQUIRED','FREE_SOURCE',
 'EHF nepokrývá domácí národní ligy jako samostatné ligové sezóny.',
 'CONTINUE_NATIONAL_LEAGUES_DISCOVERY'),

('HB','European Handball Federation','FEDERATION','DISCOVERY','SITEMAP','VERIFIED',95,95,90,90,true,false,'PASS_ROBOTS_REVIEW_TERMS','FREE_SOURCE',
 'Robots.txt a sitemap ověřeny. Crawl-delay 5.',
 'RESPECT_CRAWL_DELAY_5');

SELECT
    sport_code,
    source_name,
    coverage_domain,
    entity_type,
    coverage_status,
    coverage_score,
    quality_score,
    next_action
FROM ops.source_coverage_matrix
WHERE sport_code = 'HB'
ORDER BY source_name, coverage_domain, entity_type;