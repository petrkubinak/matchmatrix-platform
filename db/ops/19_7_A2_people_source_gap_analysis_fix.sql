/*
===============================================================================
MATCHMATRIX 19_7_A2 – PEOPLE SOURCE GAP ANALYSIS FIX
===============================================================================

CO TO JE:
Rozšířená analýza chybějících dat hráčských profilů napříč všemi sporty.

K ČEMU TO JE:
Rozlišuje jednotlivé typy problémů:

- SOURCE_GAP
- PARTIAL_SOURCE_GAP
- PROFILE_GAP
- PHOTO_GAP
- READY

a určuje prioritu řešení.

KDE TO UVIDÍME:

OPS Panel
→ PEOPLE
→ SOURCE GAP ANALYSIS

Databáze:
ops.v_people_source_gap_analysis_v1

JAK SE TO VYUŽIJE:

- identifikace sportů bez dostatečných profilových dat
- příprava nových providerů
- plánování PC2 harvestů
- plánování enrichment workerů
- plánování Photo Layer 2.0

VÝSTUP:

Každý sport je zařazen do jedné z kategorií:

SOURCE_GAP
PARTIAL_SOURCE_GAP
PROFILE_GAP
PHOTO_GAP
READY

NAVAZUJE NA:

19_6_A Player Profile Quality Audit
19_6_B Player Profile Quality Dashboard
19_6_C Player Enrichment Priority Queue
19_6_D Top Player Enrichment Candidates

DALŠÍ KROK:

19_7_B People Provider Roadmap

===============================================================================
*/

DROP VIEW IF EXISTS ops.v_people_source_gap_analysis_v1;

CREATE VIEW ops.v_people_source_gap_analysis_v1 AS
SELECT
    sport_code,
    sport_name,
    total_players,
    profile_quality_pct,

    birth_date_pct,
    nationality_pct,
    position_pct,
    photo_pct,
    team_pct,

    CASE
        WHEN birth_date_pct < 20
             AND nationality_pct < 20
             AND team_pct < 20
        THEN 'SOURCE_GAP'

        WHEN birth_date_pct < 20
             AND nationality_pct < 20
        THEN 'PARTIAL_SOURCE_GAP'

        WHEN photo_pct < 40
             AND birth_date_pct >= 70
        THEN 'PHOTO_GAP'

        WHEN birth_date_pct < 70
             OR nationality_pct < 70
             OR position_pct < 70
        THEN 'PROFILE_GAP'

        ELSE 'READY'
    END AS gap_type,

    CASE
        WHEN birth_date_pct < 20
             AND nationality_pct < 20
             AND team_pct < 20
        THEN 1000

        WHEN birth_date_pct < 20
             AND nationality_pct < 20
        THEN 900

        WHEN photo_pct < 40
             AND birth_date_pct >= 70
        THEN 800

        WHEN birth_date_pct < 70
             OR nationality_pct < 70
             OR position_pct < 70
        THEN 700

        ELSE 500
    END AS priority_score

FROM ops.v_player_profile_quality_dashboard_v1;