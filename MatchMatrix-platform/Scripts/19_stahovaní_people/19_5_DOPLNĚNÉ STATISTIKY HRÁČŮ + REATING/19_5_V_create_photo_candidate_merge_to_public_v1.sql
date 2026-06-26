/*
===============================================================================
MATCHMATRIX SQL 19_5_V
CREATE PHOTO CANDIDATE MERGE TO PUBLIC V1
===============================================================================

CO TO JE:
- Bezpečný merge schválených kandidátních fotografií do public.players.photo_url.

K ČEMU TO JE:
- PHOTO worker jen navrhuje kandidáty.
- Do public.players se zapisuje pouze ručně schválený kandidát.

KDE TO UVIDÍME:
- public.players.photo_url
- detail hráče
- player cards
- webové soupisky

JAK SE TO VYUŽIJE:
- Kandidát ve staging.stg_player_photo_candidates musí mít review_status='APPROVED'.
- Merge zapíše photo_url pouze tam, kde public.players.photo_url je prázdné.
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_photo_candidate_approved_for_merge_v1
AS
SELECT
    c.candidate_id,
    c.player_id,
    p.name AS player_name,
    c.sport_code,
    c.provider,
    c.wikidata_id,
    c.commons_file,
    c.photo_url,
    c.confidence_score,
    c.review_status,
    p.photo_url AS current_public_photo_url,
    c.approved_by,
    c.approved_at,
    c.created_at
FROM staging.stg_player_photo_candidates c
JOIN public.players p
    ON p.id = c.player_id
WHERE c.review_status = 'APPROVED'
  AND c.photo_url IS NOT NULL
  AND length(trim(c.photo_url)) > 0
  AND (p.photo_url IS NULL OR length(trim(p.photo_url)) = 0);


CREATE OR REPLACE FUNCTION ops.fn_merge_approved_player_photos_v1()
RETURNS TABLE (
    merged_count integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count integer;
BEGIN
    UPDATE public.players p
    SET
        photo_url = c.photo_url,
        updated_at = now()
    FROM staging.stg_player_photo_candidates c
    WHERE p.id = c.player_id
      AND c.review_status = 'APPROVED'
      AND c.photo_url IS NOT NULL
      AND length(trim(c.photo_url)) > 0
      AND (p.photo_url IS NULL OR length(trim(p.photo_url)) = 0);

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN QUERY SELECT v_count;
END;
$$;


SELECT *
FROM ops.v_photo_candidate_approved_for_merge_v1;