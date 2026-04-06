BEGIN;

-- 542_repoint_platense_alias_to_35258.sql
-- Cíl:
-- Přepojit alias "Platense"
-- ze špatného team_id=28033
-- na správný team_id=35258 (CA Platense).

-- 1) Kontrola před změnou
SELECT
    a.id,
    a.team_id,
    t.name AS team_name,
    a.alias,
    a.source
FROM public.team_aliases a
JOIN public.teams t
  ON t.id = a.team_id
WHERE public.unaccent(lower(a.alias)) = 'platense'
ORDER BY a.team_id, a.id;

-- 2) Smazat případný konflikt na cílovém týmu
DELETE FROM public.team_aliases
WHERE team_id = 35258
  AND public.unaccent(lower(alias)) = 'platense';

-- 3) Přepojit alias na správný canonical tým
UPDATE public.team_aliases
SET team_id = 35258,
    source  = 'audit_542_alias_repoint'
WHERE team_id = 28033
  AND public.unaccent(lower(alias)) = 'platense';

-- 4) Doplň alias, pokud by po update neexistoval
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 35258, 'Platense', 'audit_542_alias_repoint'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 35258
      AND public.unaccent(lower(a.alias)) = 'platense'
);

-- 5) Kontrola po změně
SELECT
    a.id,
    a.team_id,
    t.name AS team_name,
    a.alias,
    a.source
FROM public.team_aliases a
JOIN public.teams t
  ON t.id = a.team_id
WHERE public.unaccent(lower(a.alias)) = 'platense'
ORDER BY a.team_id, a.id;

COMMIT;