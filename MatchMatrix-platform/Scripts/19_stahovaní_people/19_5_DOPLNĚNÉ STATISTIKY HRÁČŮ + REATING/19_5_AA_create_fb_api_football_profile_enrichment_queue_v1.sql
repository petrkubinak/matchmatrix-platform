/*
MATCHMATRIX SQL 19_5_AA
FB API-FOOTBALL PROFILE ENRICHMENT QUEUE V1

CO TO JE:
- Prioritní fronta fotbalových hráčů z api_football, kterým chybí provider profil.

K ČEMU TO JE:
- Připraví přesný seznam hráčů pro další enrichment worker.

KDE TO UVIDÍME:
- ops.v_fb_api_football_profile_enrichment_queue_v1

JAK SE TO VYUŽIJE:
- Podle této fronty budeme doplňovat profily do staging.stg_provider_player_profiles.
- Až potom bezpečně pustíme Photo Layer 2.0.
*/

CREATE OR REPLACE VIEW ops.v_fb_api_football_profile_enrichment_queue_v1 AS
SELECT
    player_id,
    name,
    birth_date,
    nationality,
    ext_source AS provider,
    ext_player_id AS api_football_player_id,
    team_id,
    team_name,
    missing_team,
    missing_position,
    missing_public_photo,
    missing_fields_count,

    CASE
        WHEN name ~ '^[A-Z]\.\s' THEN 1000
        WHEN missing_team = 1 AND missing_position = 1 AND missing_public_photo = 1 THEN 900
        WHEN missing_team = 1 THEN 800
        WHEN missing_position = 1 THEN 700
        WHEN missing_public_photo = 1 THEN 600
        ELSE 100
    END AS priority_score,

    CASE
        WHEN name ~ '^[A-Z]\.\s' THEN 'RIZIKO ZKRÁCENÉHO JMÉNA - DOPLNIT CELÝ PROFIL'
        WHEN missing_team = 1 AND missing_position = 1 AND missing_public_photo = 1 THEN 'DOPLNIT PROFIL + TÝM + POZICI + FOTO'
        WHEN missing_team = 1 THEN 'DOPLNIT TÝMOVÝ KONTEXT'
        WHEN missing_position = 1 THEN 'DOPLNIT POZICI'
        WHEN missing_public_photo = 1 THEN 'DOPLNIT FOTO'
        ELSE 'DOPLNIT PROFIL'
    END AS enrichment_reason,

    'pending'::text AS queue_status,
    now() AS created_at

FROM ops.v_player_detail_coverage_audit_v1
WHERE sport_code = 'FB'
  AND ext_source = 'api_football'
  AND missing_provider_profile = 1
ORDER BY
    priority_score DESC,
    missing_fields_count DESC,
    name;