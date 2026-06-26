/*
MATCHMATRIX SQL 19_5_X
PLAYER DETAIL COVERAGE AUDIT V1

CO TO JE:
- Audit úplnosti hráčských profilů.

K ČEMU TO JE:
- Zjistí, kterým hráčům chybí důležité údaje před dalším Photo Layer harvestem.

KDE TO UVIDÍME:
- ops.v_player_detail_coverage_audit_v1
- ops.v_player_detail_coverage_summary_v1

JAK SE TO VYUŽIJE:
- Připraví enrichment frontu pro hráče s neúplným profilem.
- Zabrání špatnému párování fotek u zkrácených jmen typu N. Ferguson.
*/

CREATE OR REPLACE VIEW ops.v_player_detail_coverage_audit_v1 AS
WITH latest_profile AS (
    SELECT DISTINCT ON (provider, external_player_id)
        provider,
        sport_code,
        external_player_id,
        player_name,
        first_name,
        last_name,
        display_name,
        short_name,
        birth_date,
        birth_place,
        birth_country,
        nationality,
        height_cm,
        weight_kg,
        preferred_foot,
        shirt_number,
        position_code,
        position_name,
        photo_url,
        external_team_id,
        team_name,
        external_league_id,
        league_name,
        season,
        updated_at,
        created_at
    FROM staging.stg_provider_player_profiles
    ORDER BY provider, external_player_id, updated_at DESC NULLS LAST, created_at DESC NULLS LAST, id DESC
)
SELECT
    p.id AS player_id,
    p.sport_id,
    s.code AS sport_code,
    s.name AS sport_name,
    p.name,
    p.first_name,
    p.last_name,
    p.birth_date,
    p.nationality,
    p.position,
    p.team_id,
    t.name AS team_name,
    p.ext_source,
    p.ext_player_id,
    p.photo_url AS public_photo_url,

    lp.display_name AS profile_display_name,
    lp.birth_place,
    lp.birth_country,
    lp.height_cm,
    lp.weight_kg,
    lp.preferred_foot,
    lp.shirt_number,
    lp.position_name AS profile_position_name,
    lp.photo_url AS profile_photo_url,
    lp.external_team_id,
    lp.team_name AS profile_team_name,
    lp.external_league_id,
    lp.league_name AS profile_league_name,
    lp.season AS profile_season,

    CASE WHEN p.name IS NULL OR trim(p.name) = '' THEN 1 ELSE 0 END AS missing_name,
    CASE WHEN p.first_name IS NULL OR trim(p.first_name) = '' THEN 1 ELSE 0 END AS missing_first_name,
    CASE WHEN p.last_name IS NULL OR trim(p.last_name) = '' THEN 1 ELSE 0 END AS missing_last_name,
    CASE WHEN p.birth_date IS NULL THEN 1 ELSE 0 END AS missing_birth_date,
    CASE WHEN p.nationality IS NULL OR trim(p.nationality) = '' THEN 1 ELSE 0 END AS missing_nationality,
    CASE WHEN p.position IS NULL OR trim(p.position) = '' THEN 1 ELSE 0 END AS missing_position,
    CASE WHEN p.team_id IS NULL THEN 1 ELSE 0 END AS missing_team,
    CASE WHEN p.photo_url IS NULL OR trim(p.photo_url) = '' THEN 1 ELSE 0 END AS missing_public_photo,
    CASE WHEN lp.height_cm IS NULL THEN 1 ELSE 0 END AS missing_height_cm,
    CASE WHEN lp.weight_kg IS NULL THEN 1 ELSE 0 END AS missing_weight_kg,
    CASE WHEN lp.external_player_id IS NULL THEN 1 ELSE 0 END AS missing_provider_profile,

    (
        CASE WHEN p.name IS NULL OR trim(p.name) = '' THEN 1 ELSE 0 END +
        CASE WHEN p.first_name IS NULL OR trim(p.first_name) = '' THEN 1 ELSE 0 END +
        CASE WHEN p.last_name IS NULL OR trim(p.last_name) = '' THEN 1 ELSE 0 END +
        CASE WHEN p.birth_date IS NULL THEN 1 ELSE 0 END +
        CASE WHEN p.nationality IS NULL OR trim(p.nationality) = '' THEN 1 ELSE 0 END +
        CASE WHEN p.position IS NULL OR trim(p.position) = '' THEN 1 ELSE 0 END +
        CASE WHEN p.team_id IS NULL THEN 1 ELSE 0 END +
        CASE WHEN p.photo_url IS NULL OR trim(p.photo_url) = '' THEN 1 ELSE 0 END +
        CASE WHEN lp.height_cm IS NULL THEN 1 ELSE 0 END +
        CASE WHEN lp.weight_kg IS NULL THEN 1 ELSE 0 END +
        CASE WHEN lp.external_player_id IS NULL THEN 1 ELSE 0 END
    ) AS missing_fields_count,

    CASE
        WHEN lp.external_player_id IS NULL THEN 'NEJDŘÍV DOPLNIT PROVIDER PROFIL'
        WHEN p.name ~ '^[A-Z]\.\s' THEN 'RIZIKO ZKRÁCENÉHO JMÉNA - NEPOUŠTĚT PHOTO AUTO MERGE'
        WHEN p.team_id IS NULL THEN 'DOPLNIT TÝMOVÝ KONTEXT'
        WHEN p.position IS NULL OR trim(p.position) = '' THEN 'DOPLNIT POZICI'
        WHEN p.photo_url IS NULL OR trim(p.photo_url) = '' THEN 'VHODNÉ PRO PHOTO ENRICHMENT'
        ELSE 'PROFIL OK'
    END AS recommended_action
FROM public.players p
LEFT JOIN public.sports s
    ON s.id = p.sport_id
LEFT JOIN public.teams t
    ON t.id = p.team_id
LEFT JOIN latest_profile lp
    ON lp.provider = p.ext_source
   AND lp.external_player_id = p.ext_player_id;


CREATE OR REPLACE VIEW ops.v_player_detail_coverage_summary_v1 AS
SELECT
    sport_code,
    sport_name,
    COUNT(*) AS total_players,
    SUM(CASE WHEN missing_fields_count = 0 THEN 1 ELSE 0 END) AS complete_players,
    SUM(CASE WHEN missing_fields_count > 0 THEN 1 ELSE 0 END) AS incomplete_players,
    ROUND(
        100.0 * SUM(CASE WHEN missing_fields_count = 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0),
        2
    ) AS complete_pct,
    SUM(missing_provider_profile) AS missing_provider_profile,
    SUM(missing_team) AS missing_team,
    SUM(missing_position) AS missing_position,
    SUM(missing_public_photo) AS missing_public_photo,
    SUM(missing_height_cm) AS missing_height_cm,
    SUM(missing_weight_kg) AS missing_weight_kg
FROM ops.v_player_detail_coverage_audit_v1
GROUP BY sport_code, sport_name
ORDER BY incomplete_players DESC, sport_code;