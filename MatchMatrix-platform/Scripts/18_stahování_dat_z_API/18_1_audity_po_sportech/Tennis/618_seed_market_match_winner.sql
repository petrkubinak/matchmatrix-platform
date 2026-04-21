-- 618_seed_market_match_winner.sql
-- Účel:
-- Přidá univerzální 2-way market pro sporty bez remízy

BEGIN;

-- 1) MARKET
INSERT INTO public.markets (code, name)
SELECT 'match_winner', 'Match Winner (2-way)'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.markets
    WHERE lower(code) = lower('match_winner')
);

-- 2) OUTCOME HOME
INSERT INTO public.market_outcomes (market_id, code, label)
SELECT m.id, 'HOME', 'Home Win'
FROM public.markets m
WHERE lower(m.code) = lower('match_winner')
  AND NOT EXISTS (
      SELECT 1
      FROM public.market_outcomes mo
      WHERE mo.market_id = m.id
        AND upper(mo.code) = 'HOME'
  );

-- 3) OUTCOME AWAY
INSERT INTO public.market_outcomes (market_id, code, label)
SELECT m.id, 'AWAY', 'Away Win'
FROM public.markets m
WHERE lower(m.code) = lower('match_winner')
  AND NOT EXISTS (
      SELECT 1
      FROM public.market_outcomes mo
      WHERE mo.market_id = m.id
        AND upper(mo.code) = 'AWAY'
  );

COMMIT;

-- 4) kontrola
SELECT
    m.code,
    m.name,
    mo.code,
    mo.label
FROM public.markets m
JOIN public.market_outcomes mo
    ON mo.market_id = m.id
WHERE lower(m.code) = 'match_winner';