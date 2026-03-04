-- 092_post_merge_report.sql
-- Params:
--   :merge_started_at (timestamp)

SELECT
  (SELECT count(*) FROM public.leagues) AS leagues_total,
  (SELECT count(*) FROM public.teams)   AS teams_total,
  (SELECT count(*) FROM public.matches) AS matches_total;

-- “Touched since merge start”
SELECT
  (SELECT count(*) FROM public.teams   WHERE updated_at >= :merge_started_at) AS teams_updated,
  (SELECT count(*) FROM public.matches WHERE updated_at >= :merge_started_at) AS matches_updated;