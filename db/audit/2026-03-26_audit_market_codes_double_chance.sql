-- Audit marketů a outcome kódů pro Ticket Studio
-- Spouštět v DBeaveru

-- 1) Přehled všech marketů
SELECT
    m.id,
    m.code,
    m.name
FROM public.markets m
ORDER BY m.id;

-- 2) Přehled všech outcomes
SELECT
    mo.id,
    mo.market_id,
    m.code AS market_code,
    m.name AS market_name,
    mo.code AS outcome_code,
    mo.label AS outcome_label
FROM public.market_outcomes mo
JOIN public.markets m
  ON m.id = mo.market_id
ORDER BY m.id, mo.id;

-- 3) Najdi všechny outcomes, které vypadají jako double chance
SELECT
    mo.id,
    mo.market_id,
    m.code AS market_code,
    m.name AS market_name,
    mo.code AS outcome_code,
    mo.label AS outcome_label
FROM public.market_outcomes mo
JOIN public.markets m
  ON m.id = mo.market_id
WHERE
    mo.code IN ('1X', '12', 'X2')
    OR mo.label ILIKE '%1X%'
    OR mo.label ILIKE '%12%'
    OR mo.label ILIKE '%X2%'
    OR m.code ILIKE '%double%'
    OR m.name ILIKE '%double%'
ORDER BY m.id, mo.id;

-- 4) Kolik odds řádků existuje podle marketu
SELECT
    m.id,
    m.code,
    m.name,
    COUNT(*) AS odds_rows
FROM public.odds o
JOIN public.market_outcomes mo
  ON mo.id = o.market_outcome_id
JOIN public.markets m
  ON m.id = mo.market_id
GROUP BY
    m.id, m.code, m.name
ORDER BY odds_rows DESC, m.id;