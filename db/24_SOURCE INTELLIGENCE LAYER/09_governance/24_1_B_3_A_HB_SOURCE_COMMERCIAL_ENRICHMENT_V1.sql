/*
===============================================================================
MATCHMATRIX SQL 24_1_B_3_A
HB SOURCE COMMERCIAL ENRICHMENT V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_1_B_SOURCE GOVERNANCE LAYER

SPORT:
HB - HANDBALL

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Doplnění obchodního hodnocení HB zdrojů.
- Navazuje na již existující tabulku ops.source_commercial_model.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby EHF nebyl jen evidovaný jako FREE_SOURCE.
- Aby měl doplněné skóre hráčů, trenérů, fotek, historie a ROI.
- Aby bylo možné porovnávat EHF s IHF, Wikidata, Wikimedia a dalšími zdroji.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_commercial_model
- SOURCE INTELLIGENCE DASHBOARD
- SOURCE COMMAND CENTER
- OPS PANEL

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Pomůže rozhodnout, které zdroje použít hned.
- Pomůže určit zdroje pro People, Coaches, Photos a History Layer.
- Bude podkladem pro budoucí Source Quality Score.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Aktualizuje EHF obchodní záznam.
- Doplní coverage skóre a ROI.
- Nastaví doporučený plán použití.
- Nezakládá novou duplicitní tabulku.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

UPDATE ops.source_commercial_model
SET
    player_coverage_score = 98,
    coach_coverage_score = 95,
    photo_coverage_score = 95,
    media_coverage_score = 80,
    history_coverage_score = 95,
    roi_score = 90,
    recommended_plan = 'USE_NOW_AFTER_LEGAL_REVIEW',
    current_status = 'RESEARCH_REQUIRED',
    notes = 'EHF je bezplatný Tier 1 zdroj pro evropskou házenou: hráči, trenéři, staff, fotky, historie, statistiky a evropské soutěže. Národní ligy pokrývá pouze omezeně. Terms a photo license čekají na právní review.',
    updated_at = now()
WHERE sport_code = 'HB'
  AND source_name = 'European Handball Federation';

SELECT
    sport_code,
    source_name,
    pricing_model,
    free_available,
    paid_available,
    historical_access,
    player_coverage_score,
    coach_coverage_score,
    photo_coverage_score,
    media_coverage_score,
    history_coverage_score,
    roi_score,
    recommended_plan,
    current_status
FROM ops.source_commercial_model
WHERE sport_code = 'HB'
ORDER BY source_name;