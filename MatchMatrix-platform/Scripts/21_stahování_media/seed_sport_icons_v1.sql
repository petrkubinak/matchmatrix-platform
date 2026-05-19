-- =========================================================
-- MATCHMATRIX
-- SPORT ICON SEED V1
-- =========================================================
--
-- Co to dělá:
-- ---------------------------------------------------------
-- Doplňuje základní ikony sportů pro frontend.
--
-- Web/App:
-- ---------------------------------------------------------
-- - menu sportů
-- - match cards
-- - homepage
-- - mobile app
--
-- Později:
-- ---------------------------------------------------------
-- lze nahradit CDN / SVG / animated icons
--
-- =========================================================

UPDATE public.sports
SET icon_url = '/assets/sports/football.png'
WHERE LOWER(code) IN ('fb', 'football');

UPDATE public.sports
SET icon_url = '/assets/sports/hockey.png'
WHERE LOWER(code) IN ('hk', 'hockey');

UPDATE public.sports
SET icon_url = '/assets/sports/basketball.png'
WHERE LOWER(code) IN ('bk', 'basketball');

UPDATE public.sports
SET icon_url = '/assets/sports/tennis.png'
WHERE LOWER(code) IN ('tn', 'tennis');

UPDATE public.sports
SET icon_url = '/assets/sports/baseball.png'
WHERE LOWER(code) IN ('bsb', 'baseball');

UPDATE public.sports
SET icon_url = '/assets/sports/handball.png'
WHERE LOWER(code) IN ('hb', 'handball');

UPDATE public.sports
SET icon_url = '/assets/sports/volleyball.png'
WHERE LOWER(code) IN ('vb', 'volleyball');

UPDATE public.sports
SET icon_url = '/assets/sports/rugby.png'
WHERE LOWER(code) IN ('rgb', 'rugby');

UPDATE public.sports
SET icon_url = '/assets/sports/cricket.png'
WHERE LOWER(code) IN ('ck', 'cricket');

UPDATE public.sports
SET icon_url = '/assets/sports/american_football.png'
WHERE LOWER(code) IN ('afb', 'american_football');

UPDATE public.sports
SET icon_url = '/assets/sports/darts.png'
WHERE LOWER(code) IN ('drt', 'darts');

UPDATE public.sports
SET icon_url = '/assets/sports/mma.png'
WHERE LOWER(code) IN ('mma');

UPDATE public.sports
SET icon_url = '/assets/sports/esports.png'
WHERE LOWER(code) IN ('esp', 'esports');