/*
===============================================================================
MATCHMATRIX SQL 24_1_B_2
SOURCE LEGAL AUDIT V1
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

- Centrální právní audit všech datových zdrojů MatchMatrix.
- Evidence robots.txt, Terms & Conditions, Privacy Policy,
  licenčních omezení a komerční použitelnosti.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby MatchMatrix věděl, které zdroje lze bezpečně používat.
- Aby AI Harvest respektoval robots.txt.
- Aby bylo možné evidovat licenční a právní rizika.
- Aby bylo možné rozhodovat o použití zdrojů
  pro CORE, PEOPLE, MEDIA, HISTORY a ODDS vrstvy.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_legal_audit
- SOURCE INTELLIGENCE DASHBOARD
- SOURCE COMMAND CENTER
- OPS PANEL

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- AI Orchestrator bude kontrolovat právní stav zdroje.
- Harvest nebude spouštěn proti neověřeným zdrojům.
- Panel zobrazí LEGAL READY / REVIEW REQUIRED.
- Source Governance bude řídit použití zdrojů.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytváří tabulku právního auditu zdrojů.
- Eviduje robots.txt.
- Eviduje sitemap.
- Eviduje Privacy Policy.
- Eviduje Terms & Conditions.
- Eviduje licenční omezení.
- Eviduje komerční použitelnost.
- Eviduje právní riziko zdroje.
- Zakládá první audit pro EHF.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_legal_audit
(
    legal_audit_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    source_name TEXT NOT NULL,

    source_url TEXT,

    robots_url TEXT,
    robots_status TEXT DEFAULT 'NOT_CHECKED',
    crawl_delay_seconds INTEGER,

    sitemap_url TEXT,
    sitemap_status TEXT DEFAULT 'NOT_CHECKED',

    privacy_url TEXT,
    privacy_status TEXT DEFAULT 'NOT_CHECKED',

    terms_url TEXT,
    terms_status TEXT DEFAULT 'NOT_CHECKED',

    scraping_status TEXT DEFAULT 'REVIEW_REQUIRED',

    photo_license_status TEXT DEFAULT 'REVIEW_REQUIRED',
    video_license_status TEXT DEFAULT 'REVIEW_REQUIRED',

    commercial_use_status TEXT DEFAULT 'REVIEW_REQUIRED',

    legal_risk_level TEXT DEFAULT 'UNKNOWN',

    evidence_note TEXT,

    next_action TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_source_legal_audit_sport
ON ops.source_legal_audit (sport_code);

CREATE INDEX IF NOT EXISTS ix_source_legal_audit_source
ON ops.source_legal_audit (source_name);

COMMENT ON TABLE ops.source_legal_audit IS
'Centrální právní a licenční audit zdrojů MatchMatrix.';


INSERT INTO ops.source_legal_audit
(
    sport_code,
    source_name,
    source_url,

    robots_url,
    robots_status,
    crawl_delay_seconds,

    sitemap_url,
    sitemap_status,

    privacy_status,

    terms_status,

    scraping_status,

    photo_license_status,
    video_license_status,

    commercial_use_status,

    legal_risk_level,

    evidence_note,

    next_action
)
VALUES
(
    'HB',
    'European Handball Federation',
    'https://www.eurohandball.com',

    'https://www.eurohandball.com/robots.txt',
    'PASS',
    5,

    'https://www.eurohandball.com/sitemap.xml',
    'PASS',

    'PASS',

    'DISCOVERED_PENDING_REVIEW',

    'REVIEW_REQUIRED',

    'REVIEW_REQUIRED',
    'REVIEW_REQUIRED',

    'REVIEW_REQUIRED',

    'MEDIUM',

    'Robots.txt ověřen. Crawl-delay=5. Sitemap ověřena. Privacy Policy ověřena. Terms & Conditions nalezeny a čekají na obsahovou kontrolu. Fotografie a videa vyžadují licenční review.',

    'REVIEW_TERMS_AND_PHOTO_LICENSE'
);

SELECT
    sport_code,
    source_name,
    robots_status,
    crawl_delay_seconds,
    sitemap_status,
    privacy_status,
    terms_status,
    scraping_status,
    photo_license_status,
    commercial_use_status,
    legal_risk_level,
    next_action
FROM ops.source_legal_audit
ORDER BY source_name;