/*
===============================================================================
MATCHMATRIX SQL 24_2_A_4
SOURCE DISCOVERY AUDIT TRACKER V1
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

- Centrální tracker auditů objevených datových zdrojů.
- Sleduje, zda už byl zdroj prověřen z hlediska obsahu, kvality,
  licence, komerce a technické použitelnosti.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby bylo jasné, které zdroje jsou pouze objevené.
- Aby bylo jasné, které zdroje čekají na audit.
- Aby bylo jasné, které zdroje jsou ověřené.
- Aby bylo možné řídit audity napříč všemi sporty.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_discovery_audit_tracker
- SOURCE COMMAND CENTER
- SOURCE INTELLIGENCE DASHBOARD
- OPS PANEL

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Operátor uvidí, co auditovat jako další.
- AI Discovery Engine bude přesouvat zdroje mezi OPEN / IN_PROGRESS / DONE.
- Source Governance bude z trackeru doplňovat Coverage, Legal,
  Commercial, Quality a Activation vrstvy.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytváří tabulku audit trackeru.
- Zakládá první auditní záznamy podle ops.source_discovery_master.
- Označuje EHF jako již ověřený zdroj.
- Ostatní zdroje připravuje do stavu OPEN.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_discovery_audit_tracker
(
    audit_tracker_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    source_name TEXT NOT NULL,

    source_category TEXT,
    source_type TEXT,
    source_url TEXT,

    audit_status TEXT DEFAULT 'OPEN',

    content_audit_status TEXT DEFAULT 'OPEN',
    legal_audit_status TEXT DEFAULT 'OPEN',
    commercial_audit_status TEXT DEFAULT 'OPEN',
    coverage_audit_status TEXT DEFAULT 'OPEN',
    technical_audit_status TEXT DEFAULT 'OPEN',

    priority_score INTEGER DEFAULT 50,

    audit_result TEXT,
    next_action TEXT,

    evidence_note TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS ix_source_discovery_audit_tracker_sport
ON ops.source_discovery_audit_tracker (sport_code);

CREATE INDEX IF NOT EXISTS ix_source_discovery_audit_tracker_status
ON ops.source_discovery_audit_tracker (audit_status);

CREATE INDEX IF NOT EXISTS ix_source_discovery_audit_tracker_source
ON ops.source_discovery_audit_tracker (source_name);

COMMENT ON TABLE ops.source_discovery_audit_tracker IS
'Tracker auditů objevených datových zdrojů MatchMatrix.';


INSERT INTO ops.source_discovery_audit_tracker
(
    sport_code,
    source_name,
    source_category,
    source_type,
    source_url,
    audit_status,
    content_audit_status,
    legal_audit_status,
    commercial_audit_status,
    coverage_audit_status,
    technical_audit_status,
    priority_score,
    audit_result,
    next_action,
    evidence_note,
    completed_at
)
SELECT
    m.sport_code,
    m.source_name,
    m.source_category,
    m.source_type,
    m.source_url,

    CASE
        WHEN m.sport_code = 'HB'
         AND m.source_name = 'European Handball Federation'
        THEN 'DONE'
        ELSE 'OPEN'
    END AS audit_status,

    CASE
        WHEN m.sport_code = 'HB'
         AND m.source_name = 'European Handball Federation'
        THEN 'DONE'
        ELSE 'OPEN'
    END AS content_audit_status,

    CASE
        WHEN m.sport_code = 'HB'
         AND m.source_name = 'European Handball Federation'
        THEN 'PARTIAL'
        ELSE 'OPEN'
    END AS legal_audit_status,

    CASE
        WHEN m.sport_code = 'HB'
         AND m.source_name = 'European Handball Federation'
        THEN 'DONE'
        ELSE 'OPEN'
    END AS commercial_audit_status,

    CASE
        WHEN m.sport_code = 'HB'
         AND m.source_name = 'European Handball Federation'
        THEN 'DONE'
        ELSE 'OPEN'
    END AS coverage_audit_status,

    CASE
        WHEN m.sport_code = 'HB'
         AND m.source_name = 'European Handball Federation'
        THEN 'DONE'
        ELSE 'OPEN'
    END AS technical_audit_status,

    m.priority_score,

    CASE
        WHEN m.sport_code = 'HB'
         AND m.source_name = 'European Handball Federation'
        THEN 'TIER_1_SOURCE_VERIFIED'
        ELSE NULL
    END AS audit_result,

    CASE
        WHEN m.sport_code = 'HB'
         AND m.source_name = 'European Handball Federation'
        THEN 'REVIEW_TERMS_AND_PHOTO_LICENSE'
        ELSE 'RUN_SOURCE_AUDIT'
    END AS next_action,

    CASE
        WHEN m.sport_code = 'HB'
         AND m.source_name = 'European Handball Federation'
        THEN 'EHF audit ověřil hráče, trenéry, staff, fotky, historii, statistiky a evropské soutěže. Legal status zůstává částečný kvůli Terms/Photo license review.'
        ELSE 'Zdroj vložen ze Source Discovery Master a čeká na audit.'
    END AS evidence_note,

    CASE
        WHEN m.sport_code = 'HB'
         AND m.source_name = 'European Handball Federation'
        THEN now()
        ELSE NULL
    END AS completed_at

FROM ops.source_discovery_master m
WHERE NOT EXISTS
(
    SELECT 1
    FROM ops.source_discovery_audit_tracker t
    WHERE t.sport_code = m.sport_code
      AND t.source_name = m.source_name
);

SELECT
    sport_code,
    source_name,
    audit_status,
    content_audit_status,
    legal_audit_status,
    commercial_audit_status,
    coverage_audit_status,
    technical_audit_status,
    priority_score,
    next_action
FROM ops.source_discovery_audit_tracker
ORDER BY priority_score DESC, sport_code, source_name;