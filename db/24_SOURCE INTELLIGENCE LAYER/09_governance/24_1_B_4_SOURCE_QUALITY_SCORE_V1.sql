/*
===============================================================================
MATCHMATRIX SQL 24_1_B_4
SOURCE QUALITY SCORE V1
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

- Centrální hodnocení kvality zdrojů MatchMatrix.
- Spojuje Coverage, Legal a Commercial vrstvu do jednoho skóre.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby bylo možné objektivně porovnávat zdroje.
- Aby AI Orchestrator věděl, který zdroj použít jako první.
- Aby bylo možné rozhodovat o nákupu placených providerů.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_quality_score
- SOURCE INTELLIGENCE DASHBOARD
- SOURCE COMMAND CENTER
- OPS PANEL

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Výběr nejlepšího zdroje pro hráče.
- Výběr nejlepšího zdroje pro trenéry.
- Výběr nejlepšího zdroje pro fotografie.
- Výběr nejlepšího zdroje pro historii.
- Výběr nejlepšího zdroje pro média.
- Budoucí AI Harvest Routing.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytváří centrální tabulku quality score.
- Zakládá první hodnocení pro EHF.
- Připravuje strukturu pro všechny sporty.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_quality_score
(
    quality_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    source_name TEXT NOT NULL,

    people_score NUMERIC(5,2),
    coach_score NUMERIC(5,2),
    photo_score NUMERIC(5,2),
    media_score NUMERIC(5,2),
    history_score NUMERIC(5,2),

    coverage_score NUMERIC(5,2),
    legal_score NUMERIC(5,2),
    commercial_score NUMERIC(5,2),

    overall_score NUMERIC(5,2),

    source_tier TEXT,

    recommendation TEXT,

    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_source_quality_score_sport
ON ops.source_quality_score (sport_code);

CREATE INDEX IF NOT EXISTS ix_source_quality_score_source
ON ops.source_quality_score (source_name);

COMMENT ON TABLE ops.source_quality_score IS
'Centrální hodnocení kvality zdrojů MatchMatrix.';


INSERT INTO ops.source_quality_score
(
    sport_code,
    source_name,

    people_score,
    coach_score,
    photo_score,
    media_score,
    history_score,

    coverage_score,
    legal_score,
    commercial_score,

    overall_score,

    source_tier,

    recommendation,

    notes
)
SELECT
    'HB',
    'European Handball Federation',

    98,
    95,
    95,
    80,
    95,

    78,
    70,
    90,

    88,

    'TIER_1',

    'USE_NOW_AFTER_LEGAL_REVIEW',

    'Tier 1 zdroj pro evropskou házenou. Výborný pro hráče, trenéry, fotografie, historii a evropské soutěže. Národní ligy pouze částečně.'
WHERE NOT EXISTS
(
    SELECT 1
    FROM ops.source_quality_score
    WHERE sport_code = 'HB'
      AND source_name = 'European Handball Federation'
);

SELECT
    sport_code,
    source_name,
    people_score,
    coach_score,
    photo_score,
    media_score,
    history_score,
    coverage_score,
    legal_score,
    commercial_score,
    overall_score,
    source_tier,
    recommendation
FROM ops.source_quality_score
ORDER BY overall_score DESC NULLS LAST;