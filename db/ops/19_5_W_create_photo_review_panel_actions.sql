/*
===============================================================================
MATCHMATRIX SQL 19_5_W
CREATE PHOTO REVIEW PANEL ACTIONS
===============================================================================

CO TO JE:
- Připraví podklad pro panelové schvalování PHOTO kandidátů.

K ČEMU TO JE:
- Panel bude umět zobrazit kandidáty a nabídnout akce:
  SCHVÁLIT / ZAMÍTNOUT.

KDE TO UVIDÍME:
- OPS Panel / Photo Review
- ops.v_photo_candidate_review_v1

JAK SE TO VYUŽIJE:
- Po schválení se kandidát označí APPROVED.
- Potom se spustí merge do public.players.photo_url.
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_photo_review_panel_actions_v1 AS
SELECT
    candidate_id,
    player_id,
    player_name_public,
    player_name_candidate,
    sport_code,
    provider,
    wikidata_id,
    commons_file,
    photo_url,
    confidence_score,
    review_status,
    recommendation,
    current_public_photo_url,

    CASE
        WHEN review_status = 'PENDING' THEN true
        ELSE false
    END AS can_approve,

    CASE
        WHEN review_status = 'PENDING' THEN true
        ELSE false
    END AS can_reject,

    'APPROVE_PHOTO_CANDIDATE' AS approve_action,
    'REJECT_PHOTO_CANDIDATE' AS reject_action,

    created_at
FROM ops.v_photo_candidate_review_v1;

SELECT *
FROM ops.v_photo_review_panel_actions_v1
ORDER BY created_at DESC;