-- 025_check_value_ev_latest.sql

-- 1) Kolik řádků je ve value view (mělo by být > 0)
SELECT COUNT(*) AS rows_cnt
FROM public.ml_value_ev_latest_v1;

-- 2) Top 20 nejvyšších EV (jen kontrola, že to má hodnoty)
SELECT *
FROM public.ml_value_ev_latest_v1
ORDER BY ev_home DESC NULLS LAST
LIMIT 20;
