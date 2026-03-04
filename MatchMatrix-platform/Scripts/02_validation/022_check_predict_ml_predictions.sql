-- 022_check_predict_ml_predictions.sql
-- Kontrola, že se predikce uložily správně (ml_predictions)

-- 1) Kolik predikcí podle modelu (rychlý přehled)
SELECT model_code, COUNT(*) AS cnt
FROM public.ml_predictions
GROUP BY model_code
ORDER BY cnt DESC;

-- 2) Poslední běh (kolik záznamů v nejnovějším runu pro model)
-- Pozn.: pokud nemáš run_ts, použij created_at.
WITH last_run AS (
  SELECT model_code, run_ts
  FROM public.ml_predictions
  ORDER BY run_ts DESC
  LIMIT 1
)
SELECT p.model_code, p.run_ts, COUNT(*) AS cnt
FROM public.ml_predictions p
JOIN last_run r ON r.model_code = p.model_code AND r.run_ts = p.run_ts
GROUP BY p.model_code, p.run_ts;

-- 3) Sanity: pravděpodobnosti v rozmezí 0..1 (musí vrátit 0 řádků)
SELECT *
FROM public.ml_predictions
WHERE p_home < 0 OR p_home > 1
   OR p_draw < 0 OR p_draw > 1
   OR p_away < 0 OR p_away > 1
LIMIT 50;

-- 4) Sanity: součet pravděpodobností ~ 1 (tolerance 0.001)
-- (musí vrátit 0 řádků; malé odchylky jsou jen zaokrouhlení)
SELECT match_id, model_code, run_ts, p_home, p_draw, p_away,
       (p_home + p_draw + p_away) AS p_sum
FROM public.ml_predictions
WHERE ABS((p_home + p_draw + p_away) - 1.0) > 0.001
ORDER BY ABS((p_home + p_draw + p_away) - 1.0) DESC
LIMIT 50;

-- 5) Ukázka 20 nejbližších budoucích zápasů s predikcí (kontrola „zdravého rozumu“)
SELECT m.kickoff, l.name AS league, th.name AS home, ta.name AS away,
       p.model_code, p.p_home, p.p_draw, p.p_away
FROM public.ml_predictions p
JOIN public.matches m ON m.id = p.match_id
JOIN public.leagues l ON l.id = m.league_id
JOIN public.teams th ON th.id = m.home_team_id
JOIN public.teams ta ON ta.id = m.away_team_id
WHERE m.kickoff >= now()
ORDER BY m.kickoff
LIMIT 20;
