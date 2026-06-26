/*
MATCHMATRIX 19_7_A – PEOPLE SOURCE GAP ANALYSIS

CO TO JE:
Analýza chybějících dat hráčských profilů podle sportů.

K ČEMU TO JE:
Rozlišit:
- SOURCE GAP
- PROFILE GAP
- PHOTO GAP

KDE TO UVIDÍME:
OPS → PEOPLE → SOURCE GAP ANALYSIS

JAK SE TO VYUŽIJE:
Určení priorit pro nové providery,
PC2 harvest,
Photo Layer 2.0
a Player Profile Enrichment.
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

        WHEN
            birth_date_pct < 20
            AND nationality_pct < 20
            AND position_pct < 20
        THEN 'SOURCE_GAP'

        WHEN
            photo_pct < 40
            AND birth_date_pct >= 70
        THEN 'PHOTO_GAP'

        WHEN
            birth_date_pct < 70
            OR nationality_pct < 70
            OR position_pct < 70
        THEN 'PROFILE_GAP'

        ELSE 'READY'
    END AS gap_type,

    CASE

        WHEN
            birth_date_pct < 20
            AND nationality_pct < 20
            AND position_pct < 20
        THEN 1000

        WHEN
            photo_pct < 40
            AND birth_date_pct >= 70
        THEN 800

        WHEN
            birth_date_pct < 70
            OR nationality_pct < 70
            OR position_pct < 70
        THEN 700

        ELSE 500

    END AS priority_score

FROM ops.v_player_profile_quality_dashboard_v1;