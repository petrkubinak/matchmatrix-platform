/*
MATCHMATRIX SQL 19_5_Y
PLAYER ENRICHMENT PRIORITY QUEUE V1

CO TO JE:
- Fronta hráčů, které musíme doplnit před dalším Photo Layer harvestem.

K ČEMU TO JE:
- Určí priority podle rizika špatné identity a chybějících dat.

KDE TO UVIDÍME:
- ops.v_player_enrichment_priority_queue_v1

JAK SE TO VYUŽIJE:
- Nejdřív doplníme rizikové a neúplné hráče.
- Photo worker pak nebude slepě hledat fotky pro zkrácená jména.
*/

CREATE OR REPLACE VIEW ops.v_player_enrichment_priority_queue_v1 AS
SELECT
    player_id,
    sport_code,
    sport_name,
    name,
    birth_date,
    nationality,
    position,
    team_id,
    team_name,
    ext_source,
    ext_player_id,
    missing_fields_count,
    missing_provider_profile,
    missing_team,
    missing_position,
    missing_public_photo,
    missing_height_cm,
    missing_weight_kg,
    recommended_action,

    CASE
        WHEN sport_code IS NULL THEN 1000
        WHEN missing_provider_profile = 1 THEN 900
        WHEN name ~ '^[A-Z]\.\s' THEN 850
        WHEN missing_team = 1 THEN 800
        WHEN missing_position = 1 THEN 700
        WHEN missing_public_photo = 1 THEN 600
        ELSE 100
    END AS enrichment_priority,

    CASE
        WHEN sport_code IS NULL THEN 'OPRAVIT SPORT_CODE / SPORT_ID'
        WHEN missing_provider_profile = 1 THEN 'DOPLNIT PROVIDER PROFIL'
        WHEN name ~ '^[A-Z]\.\s' THEN 'OVĚŘIT CELÉ JMÉNO'
        WHEN missing_team = 1 THEN 'DOPLNIT TÝM'
        WHEN missing_position = 1 THEN 'DOPLNIT POZICI'
        WHEN missing_public_photo = 1 THEN 'PŘIPRAVIT PHOTO ENRICHMENT'
        ELSE 'NÍZKÁ PRIORITA'
    END AS next_enrichment_step

FROM ops.v_player_detail_coverage_audit_v1
WHERE missing_fields_count > 0
ORDER BY
    enrichment_priority DESC,
    missing_fields_count DESC,
    sport_code,
    name;