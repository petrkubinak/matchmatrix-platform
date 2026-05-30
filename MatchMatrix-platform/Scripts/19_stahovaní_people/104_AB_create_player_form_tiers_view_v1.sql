/*
MATCHMATRIX 104_AB - CREATE PLAYER FORM TIERS VIEW V1

Co view dělá:
- kategorizuje hráče podle form_score

K čemu slouží:
- homepage
- hot players
- trending
- fantasy
- AI recommendations

Web/app využití:
- HOT 🔥
- GOOD 📈
- AVERAGE ⚪
- COLD ❄
*/

CREATE OR REPLACE VIEW public.v_player_form_tiers_v1 AS
SELECT
    vpf.*,

    CASE
        WHEN vpf.form_score >= 90 THEN 'HOT'
        WHEN vpf.form_score >= 75 THEN 'GOOD'
        WHEN vpf.form_score >= 55 THEN 'AVERAGE'
        ELSE 'COLD'
    END AS form_tier,

    CASE
        WHEN vpf.form_score >= 90 THEN '🔥'
        WHEN vpf.form_score >= 75 THEN '📈'
        WHEN vpf.form_score >= 55 THEN '⚪'
        ELSE '❄'
    END AS form_tier_icon

FROM public.v_player_form_v1 vpf;