BEGIN;

-- 543_repoint_penarol_montevideo_alias_to_35261.sql
-- Cíl:
-- Přepojit alias "Peñarol Montevideo"
-- ze špatného team_id=73440
-- na správný team_id=35261 (CA Peñarol).

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
WHERE public.unaccent(lower(a.alias)) = 'penarol montevideo'
ORDER BY a.team_id, a.id;

-- 2) Smazat případný konflikt na cílovém týmu
DELETE FROM public.team_aliases
WHERE team_id = 35261
  AND public.unaccent(lower(alias)) = 'penarol montevideo';

-- 3) Přepojit alias na správný canonical tým
UPDATE public.team_aliases
SET team_id = 35261,
    source  = 'audit_543_alias_repoint'
WHERE team_id = 73440
  AND public.unaccent(lower(alias)) = 'penarol montevideo';

-- 4) Doplň alias, pokud by po update neexistoval
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 35261, 'Peñarol Montevideo', 'audit_543_alias_repoint'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 35261
      AND public.unaccent(lower(a.alias)) = 'penarol montevideo'
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
WHERE public.unaccent(lower(a.alias)) = 'penarol montevideo'
ORDER BY a.team_id, a.id;

COMMIT;