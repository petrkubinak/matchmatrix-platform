-- 325_select_ticket_history_prediction_enriched.sql
-- Historická predikce aktuálního tiketu podle obohacené historie
-- Parametry:
--   :p_run_id
--   :p_ticket_index

WITH current_ticket AS (
    SELECT
        thb.run_id,
        thb.ticket_index,
        thb.ticket_size,
        thb.odd_band,
        thb.cnt_home,
        thb.cnt_draw,
        thb.cnt_away,
        thb.outcome_signature,
        thb.sport_count,
        thb.sport_signature,
        thb.league_count,
        thb.league_signature,
        thb.probability,
        thb.total_odd
    FROM public.ticket_history_base thb
    WHERE thb.run_id = :p_run_id
      AND thb.ticket_index = :p_ticket_index
),
matched_history AS (
    SELECT
        v.*
    FROM public.v_ticket_history_summary_enriched v
    JOIN current_ticket ct
      ON v.ticket_size = ct.ticket_size
     AND COALESCE(v.odd_band, '') = COALESCE(ct.odd_band, '')
     AND COALESCE(v.cnt_home, 0) = COALESCE(ct.cnt_home, 0)
     AND COALESCE(v.cnt_draw, 0) = COALESCE(ct.cnt_draw, 0)
     AND COALESCE(v.cnt_away, 0) = COALESCE(ct.cnt_away, 0)
     AND COALESCE(v.sport_count, 0) = COALESCE(ct.sport_count, 0)
     AND COALESCE(v.league_count, 0) = COALESCE(ct.league_count, 0)
),
best_match AS (
    SELECT *
    FROM matched_history
    ORDER BY sample_size DESC
    LIMIT 1
)
SELECT
    ct.run_id,
    ct.ticket_index,
    ct.ticket_size,
    ct.odd_band,
    ct.cnt_home,
    ct.cnt_draw,
    ct.cnt_away,
    ct.outcome_signature,
    ct.sport_count,
    ct.sport_signature,
    ct.league_count,
    ct.league_signature,
    ct.probability AS current_probability,
    ct.total_odd AS current_total_odd,

    bm.sample_size,
    bm.avg_probability,
    bm.avg_total_odd,
    bm.hit_rate,
    bm.avg_profit,
    bm.avg_roi,

    CASE
        WHEN bm.sample_size IS NULL THEN 'Bez historické shody'
        WHEN bm.sample_size < 5 THEN 'Málo historických dat'
        WHEN bm.hit_rate >= 0.60 THEN 'Historicky silná kombinace'
        WHEN bm.hit_rate >= 0.45 THEN 'Historicky průměrná kombinace'
        ELSE 'Historicky slabší kombinace'
    END AS history_prediction
FROM current_ticket ct
LEFT JOIN best_match bm ON TRUE;