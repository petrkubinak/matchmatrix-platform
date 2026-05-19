-- =========================================================
-- MATCHMATRIX
-- COUNTRY FLAG SEED V1
-- =========================================================
--
-- Co to dělá:
-- ---------------------------------------------------------
-- Doplňuje základní URL vlajek států.
--
-- Web/App:
-- ---------------------------------------------------------
-- - match list
-- - league pages
-- - team pages
-- - player profiles
-- - AI feed
--
-- Asset path:
-- ---------------------------------------------------------
-- /assets/flags/{iso2}.png
--
-- Příklad:
-- ---------------------------------------------------------
-- CZ -> /assets/flags/cz.png
-- US -> /assets/flags/us.png
--
-- =========================================================

UPDATE public.countries
SET flag_url =
    '/assets/flags/' || LOWER(iso2) || '.png'
WHERE iso2 IS NOT NULL;