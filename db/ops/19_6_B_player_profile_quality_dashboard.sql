/*
MATCHMATRIX 19_6_B – PLAYER PROFILE QUALITY DASHBOARD

CO TO JE:
Dashboard nad auditem kvality hráčských profilů.

K ČEMU TO JE:
Převádí detailní audit 19_6_A do přehledné prioritní tabulky.

KDE TO UVIDÍME:
OPS Panel -> PEOPLE -> PLAYER PROFILE QUALITY

JAK SE TO VYUŽIJE:
Ukáže, který sport má největší problém a co přesně doplnit.
*/

CREATE OR REPLACE VIEW ops.v_player_profile_quality_dashboard_v1 AS
SELECT
    sport_code,
    sport_name,
    total_players,
    profile_quality_pct,
    quality_status,

    birth_date_pct,
    nationality_pct,
    position_pct,
    photo_pct,
    team_pct,

    CASE
        WHEN birth_date_pct < 50 THEN 'DOPLNIT DATUM NAROZENÍ'
        WHEN photo_pct < 50 THEN 'DOPLNIT FOTO'
        WHEN team_pct < 50 THEN 'DOPLNIT TÝMOVÉ NAPOJENÍ'
        WHEN position_pct < 70 THEN 'DOPLNIT POZICE'
        ELSE 'KONTROLA DETAILŮ PROFILU'
    END AS main_gap,

    CASE
        WHEN profile_quality_pct < 30 THEN 950
        WHEN profile_quality_pct < 40 THEN 900
        WHEN profile_quality_pct < 50 THEN 850
        WHEN profile_quality_pct < 70 THEN 800
        ELSE 600
    END AS priority_score,

    CASE
        WHEN profile_quality_pct < 30 THEN 'HIGH_PRIORITY'
        WHEN profile_quality_pct < 50 THEN 'MEDIUM_PRIORITY'
        WHEN profile_quality_pct < 70 THEN 'LOW_PRIORITY'
        ELSE 'MONITOR'
    END AS priority_level,

    CASE
        WHEN sport_code = 'FB' THEN 'Pokračovat profile enrichment přes api_football + photo layer.'
        WHEN sport_code IN ('HK','BK','BSB','AFB') THEN 'Hledat / rozšířit people provider a připravit photo enrichment.'
        WHEN sport_code IN ('TN','MMA','CK') THEN 'Nejdříve ověřit dostupnost detailních profilů u providerů.'
        ELSE 'Zapsat do Source Discovery a hledat nový zdroj.'
    END AS recommended_action

FROM ops.v_player_profile_quality_audit_v1;