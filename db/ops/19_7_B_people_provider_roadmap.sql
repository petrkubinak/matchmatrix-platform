/*
===============================================================================
MATCHMATRIX 19_7_B – PEOPLE PROVIDER ROADMAP
===============================================================================

CO TO JE:
Roadmapa providerů pro People Layer.

K ČEMU TO JE:
Převádí výsledky Source Gap Analysis
na konkrétní doporučení zdrojů dat
pro jednotlivé sporty.

KDE TO UVIDÍME:

OPS Panel
→ PEOPLE
→ PROVIDER ROADMAP

Databáze:
ops.v_people_provider_roadmap_v1

JAK SE TO VYUŽIJE:

- výběr budoucích providerů
- příprava PC2 harvestů
- plánování placených providerů
- příprava enrichment pipeline
- příprava Photo Layer 2.0

VÝSTUP:

Pro každý sport určuje:

- typ problému
- doporučené zdroje dat
- další akci
- typ práce pro PC2

PŘÍKLADY:

FB
→ Photo Layer 2.0

BK
→ Profile Backfill

BSB
→ Profile Backfill

HK
→ Source Discovery

MMA
→ Source Discovery

TN
→ Source Discovery

CK
→ Partial Source Gap Enrichment

AFB
→ Partial Source Gap Enrichment

NAVAZUJE NA:

19_6_A Player Profile Quality Audit
19_6_B Player Profile Quality Dashboard
19_6_C Player Enrichment Priority Queue
19_6_D Top Player Enrichment Candidates
19_7_A People Source Gap Analysis
19_7_A2 People Source Gap Analysis Fix

DALŠÍ KROK:

19_7_C People PC2 Work Queue
19_7_D People Source Discovery Registry

===============================================================================
*/

DROP VIEW IF EXISTS ops.v_people_provider_roadmap_v1;

CREATE VIEW ops.v_people_provider_roadmap_v1 AS
SELECT
    g.sport_code,
    g.sport_name,
    g.total_players,
    g.profile_quality_pct,
    g.gap_type,
    g.priority_score,

    CASE
        WHEN g.sport_code = 'FB' THEN 'api_football + official club sites + Wikimedia'
        WHEN g.sport_code = 'BK' THEN 'sportsdataio + NBA official + Wikidata'
        WHEN g.sport_code = 'BSB' THEN 'sportsdataio + MLB official + Wikidata'
        WHEN g.sport_code = 'HK' THEN 'sportsdataio / eliteprospects research / official league sites'
        WHEN g.sport_code = 'AFB' THEN 'api_american_football + NFL official + Wikidata'
        WHEN g.sport_code = 'CK' THEN 'api_cricket + Cricbuzz/ESPNCricinfo research + Wikidata'
        WHEN g.sport_code = 'TN' THEN 'tennis provider research + ATP/WTA/ITF + Wikidata'
        WHEN g.sport_code = 'MMA' THEN 'sportsdataio / UFC official / Tapology research + Wikidata'
        ELSE 'source discovery'
    END AS recommended_provider_path,

    CASE
        WHEN g.gap_type = 'SOURCE_GAP' THEN 'Najít nebo ověřit nový zdroj profilových dat.'
        WHEN g.gap_type = 'PARTIAL_SOURCE_GAP' THEN 'Doplnit chybějící datum narození a národnost z fallback zdroje.'
        WHEN g.gap_type = 'PHOTO_GAP' THEN 'Spustit Photo Layer 2.0.'
        WHEN g.gap_type = 'PROFILE_GAP' THEN 'Rozšířit existující provider profil / doplnit team mapping.'
        ELSE 'Monitorovat.'
    END AS next_action,

    CASE
        WHEN g.gap_type = 'SOURCE_GAP' THEN 'PC2_SOURCE_DISCOVERY'
        WHEN g.gap_type = 'PARTIAL_SOURCE_GAP' THEN 'PC2_PROFILE_ENRICHMENT'
        WHEN g.gap_type = 'PHOTO_GAP' THEN 'PC2_PHOTO_ENRICHMENT'
        WHEN g.gap_type = 'PROFILE_GAP' THEN 'PC2_PROFILE_BACKFILL'
        ELSE 'MONITOR'
    END AS pc2_work_type

FROM ops.v_people_source_gap_analysis_v1 g;