/*
===============================================================================
MATCHMATRIX 19_7_C – PEOPLE PC2 WORK QUEUE
===============================================================================

CO TO JE:
Pracovní fronta People Layer úkolů určených pro druhý server (PC2).

K ČEMU TO JE:
Převádí výsledky People Provider Roadmap do konkrétní pořadové fronty prací
pro Source Discovery, Profile Enrichment, Photo Enrichment a Profile Backfill.

KDE TO UVIDÍME:
OPS Panel
→ PEOPLE
→ PC2 WORK QUEUE

Databáze:
ops.v_people_pc2_work_queue_v1

JAK SE TO VYUŽIJE:
- plánování PC2 harvestů
- plánování enrichment workerů
- Photo Layer 2.0
- Source Discovery Layer
- People Layer roadmap

NAVAZUJE NA:
19_6_A Player Profile Quality Audit
19_6_B Player Profile Quality Dashboard
19_6_C Player Enrichment Priority Queue
19_7_A People Source Gap Analysis
19_7_B People Provider Roadmap

DALŠÍ KROK:
19_7_D People Source Discovery Registry

===============================================================================
*/

DROP VIEW IF EXISTS ops.v_people_pc2_work_queue_v1;

CREATE VIEW ops.v_people_pc2_work_queue_v1 AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY priority_score DESC, total_players DESC
    ) AS queue_rank,

    sport_code,
    sport_name,
    total_players,
    profile_quality_pct,
    gap_type,
    priority_score,
    recommended_provider_path,
    pc2_work_type,
    next_action,

    CASE
        WHEN pc2_work_type = 'PC2_SOURCE_DISCOVERY' THEN 'Připravit discovery zdrojů a ověřit dostupnost profilových dat.'
        WHEN pc2_work_type = 'PC2_PROFILE_ENRICHMENT' THEN 'Doplnit birth_date, nationality a profilové údaje z fallback zdroje.'
        WHEN pc2_work_type = 'PC2_PHOTO_ENRICHMENT' THEN 'Spustit Photo Layer 2.0 pro existující hráče.'
        WHEN pc2_work_type = 'PC2_PROFILE_BACKFILL' THEN 'Rozšířit existující provider profil a opravit team mapping.'
        ELSE 'Monitorovat.'
    END AS pc2_instruction,

    'READY_FOR_PLANNING' AS queue_status

FROM ops.v_people_provider_roadmap_v1;