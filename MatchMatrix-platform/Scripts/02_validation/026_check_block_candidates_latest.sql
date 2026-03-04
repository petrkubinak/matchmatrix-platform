-- 026_check_block_candidates_latest.sql

-- 1) Kolik kandidátů celkem
SELECT COUNT(*) AS cnt
FROM public.ml_block_candidates_latest_v1;

-- 2) Rozdělení podle ligy
SELECT league_id, COUNT(*) AS cnt
FROM public.ml_block_candidates_latest_v1
GROUP BY league_id
ORDER BY cnt DESC;

-- 3) Top 20 kandidátů podle block_score (hlavní metrika)
SELECT *
FROM public.ml_block_candidates_latest_v1
ORDER BY block_score DESC
LIMIT 20;
