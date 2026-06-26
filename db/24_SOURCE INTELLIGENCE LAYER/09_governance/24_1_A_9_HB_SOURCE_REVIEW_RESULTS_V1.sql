/*
===============================================================================
MATCHMATRIX SQL 24_1_A_9
HB SOURCE REVIEW RESULTS V1
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

- Evidence skutečných výsledků auditů zdrojů.
- Ukládání výsledků ověřování EHF, IHF a dalších HB zdrojů.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby MatchMatrix nepracoval s domněnkami.
- Aby bylo jasné co bylo skutečně ověřeno.
- Aby bylo možné opakovat kontroly.
- Aby bylo možné budovat Source Governance.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_review_results
- SOURCE COMMAND CENTER
- OPS Panel
- Source Governance Dashboard

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Historie auditů zdrojů.
- Evidence PASS / PARTIAL / FAIL.
- Podklad pro VERIFIED status.
- Monitoring změn zdrojů v čase.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytváří tabulku auditních výsledků.
- Připravuje první auditní záznamy.
- Zavádí standard ověřování zdrojů.

===============================================================================
VSTUP:
===============================================================================

- source_discovery_review_plan
- ruční audity
- budoucí automatické kontroly

===============================================================================
VÝSTUP:
===============================================================================

- auditní historie zdrojů
- evidence výsledků ověření
- podklad pro governance

===============================================================================
BUDOUCÍ VYUŽITÍ:
===============================================================================

SOURCE GOVERNANCE
SOURCE MONITORING
SOURCE COMMAND CENTER
AUTONOMOUS SOURCE AUDIT

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_review_results
(
    review_result_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    source_name TEXT NOT NULL,

    review_area TEXT NOT NULL,
    review_item TEXT NOT NULL,

    review_result TEXT NOT NULL,

    evidence_url TEXT,
    evidence_note TEXT,

    reviewer TEXT DEFAULT 'MATCHMATRIX',

    review_date DATE DEFAULT CURRENT_DATE,

    next_action TEXT,

    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_source_review_results_sport
ON ops.source_review_results (sport_code);

CREATE INDEX IF NOT EXISTS ix_source_review_results_source
ON ops.source_review_results (source_name);

COMMENT ON TABLE ops.source_review_results IS
'Historie auditních výsledků Source Intelligence Layer.';


/*
První placeholder výsledky.
NEJSOU ověřené.
Pouze zakládají auditní rámec.
*/

INSERT INTO ops.source_review_results
(
    sport_code,
    source_name,
    review_area,
    review_item,
    review_result,
    evidence_note,
    next_action
)
VALUES

(
    'HB',
    'European Handball Federation',
    'LEGAL',
    'Terms of use',
    'PENDING',
    'Čeká na ruční audit.',
    'REVIEW_REQUIRED'
),

(
    'HB',
    'European Handball Federation',
    'LEGAL',
    'Robots.txt',
    'PENDING',
    'Čeká na ruční audit.',
    'REVIEW_REQUIRED'
),

(
    'HB',
    'International Handball Federation',
    'LEGAL',
    'Terms of use',
    'PENDING',
    'Čeká na ruční audit.',
    'REVIEW_REQUIRED'
),

(
    'HB',
    'International Handball Federation',
    'LEGAL',
    'Robots.txt',
    'PENDING',
    'Čeká na ruční audit.',
    'REVIEW_REQUIRED'
);

SELECT
    source_name,
    review_area,
    review_item,
    review_result,
    next_action,
    review_date
FROM ops.source_review_results
WHERE sport_code = 'HB'
ORDER BY source_name, review_area, review_item;