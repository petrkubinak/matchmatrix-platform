/*
===============================================================================
MATCHMATRIX SQL 24_1_A_11
HB SOURCE VERIFICATION LOG V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_5_SOURCE GOVERNANCE

SPORT:
HB - HANDBALL

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Auditní log skutečných ověření zdrojů.
- Historie všech kontrol provedených nad zdroji.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby bylo dohledatelné kdo, kdy a co ověřil.
- Aby bylo možné sledovat změny zdrojů v čase.
- Aby bylo možné opakovaně ověřovat zdroje.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_verification_log
- SOURCE GOVERNANCE
- SOURCE COMMAND CENTER
- OPS Panel

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Historie kontrol.
- Monitoring změn.
- Automatické re-audity.
- Zdroj pro Source Monitoring.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytváří auditní log.
- Připravuje evidenci reálných ověření.
- Připravuje budoucí monitoring.

===============================================================================
VSTUP:
===============================================================================

- Ruční audit
- Discovery audit
- Automatické kontroly

===============================================================================
VÝSTUP:
===============================================================================

- Auditní historie ověření zdrojů.

===============================================================================
BUDOUCÍ VYUŽITÍ:
===============================================================================

SOURCE MONITORING
SOURCE GOVERNANCE
SOURCE COMMAND CENTER
AUTONOMOUS DISCOVERY

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_verification_log
(
    verification_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    source_name TEXT NOT NULL,

    verification_area TEXT NOT NULL,
    verification_item TEXT NOT NULL,

    verification_result TEXT NOT NULL,

    evidence_url TEXT,
    evidence_note TEXT,

    verified_by TEXT DEFAULT 'MATCHMATRIX',

    verification_date TIMESTAMPTZ DEFAULT now(),

    valid_until TIMESTAMPTZ,

    next_action TEXT,

    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_source_verification_log_sport
ON ops.source_verification_log (sport_code);

CREATE INDEX IF NOT EXISTS ix_source_verification_log_source
ON ops.source_verification_log (source_name);

COMMENT ON TABLE ops.source_verification_log IS
'Historie skutečných ověření zdrojů v Source Intelligence Layer.';


/*
První zakládací záznamy.
NEJSOU výsledkem skutečného ověření.
Pouze zakládají workflow.
*/

INSERT INTO ops.source_verification_log
(
    sport_code,
    source_name,
    verification_area,
    verification_item,
    verification_result,
    evidence_note,
    next_action
)
VALUES

(
    'HB',
    'European Handball Federation',
    'LEGAL',
    'Terms of use',
    'NOT_VERIFIED',
    'Čeká na první skutečné ověření.',
    'RUN_FIRST_AUDIT'
),

(
    'HB',
    'European Handball Federation',
    'LEGAL',
    'Robots.txt',
    'NOT_VERIFIED',
    'Čeká na první skutečné ověření.',
    'RUN_FIRST_AUDIT'
),

(
    'HB',
    'International Handball Federation',
    'LEGAL',
    'Terms of use',
    'NOT_VERIFIED',
    'Čeká na první skutečné ověření.',
    'RUN_FIRST_AUDIT'
),

(
    'HB',
    'International Handball Federation',
    'LEGAL',
    'Robots.txt',
    'NOT_VERIFIED',
    'Čeká na první skutečné ověření.',
    'RUN_FIRST_AUDIT'
);

SELECT
    source_name,
    verification_area,
    verification_item,
    verification_result,
    next_action,
    verification_date
FROM ops.source_verification_log
WHERE sport_code = 'HB'
ORDER BY source_name, verification_area, verification_item;