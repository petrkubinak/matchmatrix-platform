/*
MATCHMATRIX SQL 19_2_F_FIX
Photo License Review Action Plan V2

CO TO JE:
- Opravuje příliš obecné bucketování license review.
- Rozděluje photo/logo/stadium providery na přesnější typ kontroly.

K ČEMU TO JE:
- Aby všechno nepadalo pouze do Wikimedia Commons.
- Aby bylo jasné, co ověřovat jako licenci obrázku, co jako entitu, co jako oficiální web a co jako placený plán.

KDE TO UVIDÍME:
- OPS Panel V18
- Provider Command Center
- Photo Provider Research
- PC2 Harvest Readiness

JAK SE TO VYUŽIJE:
- Pro přesnější rozhodnutí, které zdroje jsou použitelné pro PC2.
- Pro budoucí photo/logo harvest workery.
*/

CREATE OR REPLACE VIEW ops.v_photo_license_review_action_plan_v2 AS
SELECT
    research_rank,
    sport_code,
    sport_name,
    entity_type,
    priority_score,
    recommended_provider,
    access_type,
    research_provider_url,

    CASE
        WHEN access_type = 'PAID'
            THEN 'PAID_PROVIDER_PLAN_CHECK'

        WHEN recommended_provider ILIKE '%Official%'
            THEN 'OFFICIAL_SITE_TERMS_CHECK'

        WHEN recommended_provider ILIKE '%Wikidata%'
            THEN 'WIKIDATA_ENTITY_CHECK'

        WHEN recommended_provider ILIKE '%Wikipedia%'
          OR recommended_provider ILIKE '%Wikimedia%'
            THEN 'WIKIMEDIA_COMMONS_IMAGE_LICENSE_CHECK'

        WHEN recommended_provider ILIKE '%League%'
            THEN 'LEAGUE_SITE_TERMS_CHECK'

        ELSE 'MANUAL_RESEARCH_REQUIRED'
    END AS review_bucket,

    CASE
        WHEN access_type = 'FREE'
            THEN 1
        WHEN access_type = 'LIMITED_FREE'
            THEN 2
        WHEN access_type = 'PAID'
            THEN 3
        ELSE 9
    END AS review_priority,

    CASE
        WHEN access_type = 'PAID'
            THEN 'Ověřit placený plán, endpointy a práva na použití obrázků.'

        WHEN recommended_provider ILIKE '%Official%'
            THEN 'Ověřit podmínky oficiálního webu a zákaz/stav automatického stahování.'

        WHEN recommended_provider ILIKE '%Wikidata%'
            THEN 'Ověřit entity ve Wikidata a vazbu na obrázky / Commons media.'

        WHEN recommended_provider ILIKE '%Wikipedia%'
          OR recommended_provider ILIKE '%Wikimedia%'
            THEN 'Ověřit licenci konkrétních obrázků na Wikimedia Commons.'

        WHEN recommended_provider ILIKE '%League%'
            THEN 'Ověřit podmínky ligového webu a dostupnost media assetů.'

        ELSE 'Provést ruční research zdroje a licence.'
    END AS review_action_cs,

    research_status,
    worker_needed,
    license_note,
    next_action,
    updated_at

FROM ops.provider_missing_matrix
WHERE entity_type IN (
    'PLAYER_PHOTOS',
    'COACH_PHOTOS',
    'TEAM_LOGOS',
    'STADIUM_PHOTOS'
)
ORDER BY
    review_priority,
    review_bucket,
    research_rank,
    priority_score DESC;


CREATE OR REPLACE VIEW ops.v_photo_license_review_summary_v2 AS
SELECT
    review_bucket,
    access_type,
    COUNT(*) AS rows_count,
    MIN(review_priority) AS best_priority,
    MIN(research_rank) AS best_rank,
    MAX(priority_score) AS max_priority
FROM ops.v_photo_license_review_action_plan_v2
GROUP BY
    review_bucket,
    access_type
ORDER BY
    best_priority,
    best_rank,
    rows_count DESC;


CREATE OR REPLACE VIEW ops.v_photo_license_review_top_v2 AS
SELECT
    research_rank,
    sport_code,
    sport_name,
    entity_type,
    priority_score,
    access_type,
    review_bucket,
    review_action_cs,
    recommended_provider,
    research_provider_url,
    research_status,
    worker_needed,
    next_action
FROM ops.v_photo_license_review_action_plan_v2
ORDER BY
    review_priority,
    research_rank,
    priority_score DESC,
    sport_code,
    entity_type;


SELECT
    review_bucket,
    access_type,
    COUNT(*) AS rows_count
FROM ops.v_photo_license_review_action_plan_v2
GROUP BY
    review_bucket,
    access_type
ORDER BY
    review_bucket,
    access_type;