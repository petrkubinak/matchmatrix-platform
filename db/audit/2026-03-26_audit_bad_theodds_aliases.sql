-- Oprava chybných theodds aliasů
-- Spouštět v DBeaveru

BEGIN;

-- 1) Smazat prokazatelně špatné aliasy
DELETE FROM public.team_aliases
WHERE source = 'theodds'
  AND alias IN (
      'Braga',
      'Boca Juniors',
      'Coquimbo Unido'
  );

-- 2) Vložit správný alias pro Bragu
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'Braga', 'theodds'
FROM public.teams t
WHERE t.name = 'Sporting Clube de Braga'
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_aliases ta
      WHERE ta.source = 'theodds'
        AND lower(ta.alias) = lower('Braga')
  );

COMMIT;