/*
MATCHMATRIX SQL 19_5_W Create Photo Review Player Context V1

CO TO JE:
- View pro kontrolu kandidáta fotky proti reálným datům hráče z public.players.

K ČEMU TO JE:
- Abychom před schválením fotky viděli věk, datum narození, národnost, pozici,
  provider ID, aktuální public photo_url a stav kandidáta.

KDE TO UVIDÍME:
- OPS Panel V19.11+ / MEDIA / PHOTO REVIEW.

JAK SE TO VYUŽIJE:
- Schvalování fotky nebude naslepo.
- Pokud Wikidata kandidát nesedí na věk/jméno/sport, fotka se zamítne.
*/

CREATE OR REPLACE VIEW ops.v_photo_review_player_context_v1 AS
SELECT
    c.candidate_id,
    c.review_status,
    c.confidence_score,

    c.player_id,
    p.name AS public_player_name,
    p.first_name,
    p.last_name,
    p.short_name,
    p.birth_date,
    CASE
        WHEN p.birth_date IS NOT NULL
        THEN EXTRACT(YEAR FROM age(current_date, p.birth_date))::int
        ELSE NULL
    END AS age_years,
    p.nationality,
    p.position,
    p.shirt_number,
    p.height_cm,
    p.weight_kg,
    p.team_id,
    p.ext_source,
    p.ext_player_id,
    p.photo_url AS current_public_photo_url,

    c.provider AS photo_provider,
    c.source_system,
    c.wikidata_id,
    c.wikipedia_url,
    c.commons_file,
    c.photo_url AS candidate_photo_url,
    c.license_name,
    c.license_url,
    c.approved_by,
    c.approved_at,
    c.created_at,
    c.updated_at,

    CASE
        WHEN p.photo_url IS NOT NULL AND p.photo_url <> ''
            THEN 'PUBLIC_PHOTO_ALREADY_EXISTS'
        WHEN c.review_status = 'REJECTED'
            THEN 'REJECTED'
        WHEN c.review_status = 'APPROVED'
            THEN 'APPROVED_READY_FOR_MERGE'
        ELSE 'NEEDS_REVIEW'
    END AS review_decision_hint

FROM staging.stg_player_photo_candidates c
LEFT JOIN public.players p
    ON p.id = c.player_id;