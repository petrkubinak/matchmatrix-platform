/*
===============================================================================
MATCHMATRIX SQL 19_5_U FIX
CREATE PHOTO CANDIDATE REVIEW VIEW V1
===============================================================================

CO TO JE:
- Oprava review view pro PHOTO kandidáty.

K ČEMU TO JE:
- public.players používá sloupec id, ne player_id.

KDE TO UVIDÍME:
- ops.v_photo_candidate_review_v1

JAK SE TO VYUŽIJE:
- Ruční schvalování fotografií před zápisem do public.players.photo_url.
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_photo_candidate_review_v1
AS
SELECT
    c.candidate_id,
    c.player_id,
    p.name AS player_name_public,
    c.player_name AS player_name_candidate,
    c.sport_code,
    c.provider,

    c.wikidata_id,
    c.commons_file,
    c.photo_url,

    c.confidence_score,
    c.review_status,

    CASE
        WHEN c.confidence_score >= 90 THEN 'AUTO_APPROVE'
        WHEN c.confidence_score >= 75 THEN 'MANUAL_REVIEW'
        ELSE 'LOW_CONFIDENCE'
    END AS recommendation,

    p.photo_url AS current_public_photo_url,

    c.created_at

FROM staging.stg_player_photo_candidates c

LEFT JOIN public.players p
       ON p.id = c.player_id

ORDER BY
    c.confidence_score DESC,
    c.created_at DESC;