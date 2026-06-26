/*
===============================================================================
MATCHMATRIX SQL 19_5_X FIX
PHOTO REVIEW DASHBOARD V1
===============================================================================

CO TO JE:
- Oprava photo dashboardu.

K ČEMU TO JE:
- public.sports používá sloupec code, ne sport_code.

KDE TO UVIDÍME:
- ops.v_photo_review_dashboard_v1

JAK SE TO VYUŽIJE:
- OPS Panel / MEDIA / PHOTO REVIEW.
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_photo_review_dashboard_v1
AS
WITH player_stats AS (
    SELECT
        s.code AS sport_code,
        COUNT(*) AS total_players,
        COUNT(*) FILTER (
            WHERE p.photo_url IS NOT NULL
              AND length(trim(p.photo_url)) > 0
        ) AS players_with_photo
    FROM public.players p
    JOIN public.sports s
         ON s.id = p.sport_id
    GROUP BY s.code
),
review_stats AS (
    SELECT
        sport_code,
        COUNT(*) FILTER (WHERE review_status = 'PENDING') AS pending_reviews,
        COUNT(*) FILTER (WHERE review_status = 'APPROVED') AS approved_reviews,
        COUNT(*) FILTER (WHERE review_status = 'REJECTED') AS rejected_reviews
    FROM staging.stg_player_photo_candidates
    GROUP BY sport_code
)
SELECT
    ps.sport_code,
    ps.total_players,
    ps.players_with_photo,
    ROUND(
        ps.players_with_photo::numeric * 100.0 / NULLIF(ps.total_players,0),
        2
    ) AS coverage_pct,
    COALESCE(rs.pending_reviews,0) AS pending_reviews,
    COALESCE(rs.approved_reviews,0) AS approved_reviews,
    COALESCE(rs.rejected_reviews,0) AS rejected_reviews,
    CASE
        WHEN ROUND(ps.players_with_photo::numeric * 100.0 / NULLIF(ps.total_players,0), 2) >= 80
            THEN 'READY'
        WHEN ROUND(ps.players_with_photo::numeric * 100.0 / NULLIF(ps.total_players,0), 2) >= 40
            THEN 'PARTIAL'
        ELSE 'PHOTO_GAP'
    END AS photo_status
FROM player_stats ps
LEFT JOIN review_stats rs
       ON rs.sport_code = ps.sport_code
ORDER BY coverage_pct DESC;

SELECT *
FROM ops.v_photo_review_dashboard_v1;