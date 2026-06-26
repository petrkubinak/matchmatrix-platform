/*
MATCHMATRIX SQL 19_5_Z
PROVIDER PROFILE ENRICHMENT PLAN V1

CO TO JE:
- Plán doplnění provider profilů hráčů.

K ČEMU TO JE:
- Ukáže, který provider/sport má největší chybějící profilovou mezeru.

KDE TO UVIDÍME:
- ops.v_provider_profile_enrichment_plan_v1

JAK SE TO VYUŽIJE:
- Podle tohoto pořadí budeme připravovat workery pro doplnění profilů.
*/

CREATE OR REPLACE VIEW ops.v_provider_profile_enrichment_plan_v1 AS
SELECT
    sport_code,
    ext_source AS provider,
    COUNT(*) AS missing_profiles,

    SUM(CASE WHEN team_id IS NULL THEN 1 ELSE 0 END) AS missing_team,
    SUM(CASE WHEN position IS NULL OR trim(position) = '' THEN 1 ELSE 0 END) AS missing_position,
    SUM(CASE WHEN public_photo_url IS NULL OR trim(public_photo_url) = '' THEN 1 ELSE 0 END) AS missing_photo,

    CASE
        WHEN ext_source = 'sportsdataio' THEN 'SPORTSDATAIO_PROFILE_ENRICHMENT'
        WHEN ext_source = 'api_football' THEN 'API_FOOTBALL_PROFILE_ENRICHMENT'
        WHEN ext_source = 'api_sport' THEN 'API_SPORT_PROFILE_ENRICHMENT'
        WHEN ext_source = 'api_cricket' THEN 'API_CRICKET_PROFILE_ENRICHMENT'
        WHEN ext_source = 'api_tennis' THEN 'API_TENNIS_PROFILE_ENRICHMENT'
        WHEN ext_source = 'api_american_football' THEN 'API_AMERICAN_FOOTBALL_PROFILE_ENRICHMENT'
        ELSE 'UNKNOWN_PROFILE_ENRICHMENT'
    END AS recommended_worker_group,

    CASE
        WHEN sport_code IS NULL THEN 1000
        WHEN ext_source = 'api_football' THEN 950
        WHEN ext_source = 'sportsdataio' AND sport_code = 'BSB' THEN 900
        WHEN ext_source = 'sportsdataio' AND sport_code = 'MMA' THEN 850
        WHEN ext_source = 'sportsdataio' AND sport_code = 'HK' THEN 800
        WHEN ext_source = 'sportsdataio' AND sport_code = 'BK' THEN 750
        ELSE 500
    END AS priority_score,

    CASE
        WHEN sport_code IS NULL THEN 'OPRAVIT SPORT_ID / SPORT_CODE'
        WHEN ext_source = 'api_football' THEN 'PRIORITA FB: doplnit profily před Photo Layer 2.0'
        WHEN ext_source = 'sportsdataio' THEN 'PROVĚŘIT SPORTSDATAIO profilový endpoint / lokální data'
        ELSE 'PROVĚŘIT PROVIDER PROFILOVÝ ENDPOINT'
    END AS next_action

FROM ops.v_player_detail_coverage_audit_v1
WHERE missing_provider_profile = 1
GROUP BY sport_code, ext_source
ORDER BY priority_score DESC, missing_profiles DESC;