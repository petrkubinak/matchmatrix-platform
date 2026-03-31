-- MatchMatrix
-- SAFE DELETE team větví bez usage

DELETE FROM public.teams
WHERE id IN (
    498,   -- Arsenal dup
    499,   -- Bournemouth dup
    5815,  -- Bournemouth dup
    6666,  -- Sporting CP dup
    6667   -- Braga dup
);