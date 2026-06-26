/*
===============================================================================
MATCHMATRIX SQL 19_5_W
CREATE PHOTO REVIEW PANEL VIEW V1
===============================================================================

CO TO JE:
- Panelové view pro schvalování fotek hráčů.

K ČEMU TO JE:
- OPS Panel uvidí PENDING kandidáty z photo workeru.
- U každého kandidáta bude jasné, jestli jde SCHVÁLIT nebo ZAMÍTNOUT.

KDE TO UVIDÍME:
- OPS Panel / MEDIA / PHOTO REVIEW
- budoucí Photo Governance záložka

JAK SE TO VYUŽIJE:
- Panel načte view.
- Vybere kandidáta.
- Akce SCHVÁLIT změní review_status na APPROVED.
- Akce ZAMÍTNOUT změní review_status na REJECTED.
- Merge funkce zapíše APPROVED kandidáty do public.players.photo_url.
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_photo_review_panel_v1 AS
SELECT
    c.candidate_id,
    c.player_id,
    p.name AS public_player_name,
    c.player_name AS candidate_player_name,
    c.sport_code,
    c.provider,
    c.source_system,
    c.wikidata_id,
    c.commons_file,
    c.photo_url,
    c.confidence_score,
    c.review_status,

    CASE
        WHEN c.review_status = 'PENDING' THEN true
        ELSE false
    END AS can_approve,

    CASE
        WHEN c.review_status = 'PENDING' THEN true
        ELSE false
    END AS can_reject,

    CASE
        WHEN p.photo_url IS NULL OR length(trim(p.photo_url)) = 0 THEN 'PUBLIC_PHOTO_EMPTY'
        ELSE 'PUBLIC_PHOTO_ALREADY_EXISTS'
    END AS public_photo_state,

    p.photo_url AS current_public_photo_url,

    CASE
        WHEN c.confidence_score >= 90 THEN 'HIGH'
        WHEN c.confidence_score >= 75 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS confidence_level,

    c.approved_by,
    c.approved_at,
    c.created_at,
    c.updated_at

FROM staging.stg_player_photo_candidates c
LEFT JOIN public.players p
       ON p.id = c.player_id
ORDER BY
    CASE c.review_status
        WHEN 'PENDING' THEN 1
        WHEN 'APPROVED' THEN 2
        WHEN 'REJECTED' THEN 3
        ELSE 9
    END,
    c.created_at DESC;

SELECT *
FROM ops.v_photo_review_panel_v1;