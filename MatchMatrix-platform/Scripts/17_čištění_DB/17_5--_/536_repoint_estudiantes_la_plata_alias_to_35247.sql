BEGIN;

-- 536_repoint_estudiantes_la_plata_alias_to_35247.sql
-- Cíl:
-- Přepojit alias "Estudiantes La Plata"
-- ze špatného team_id=73436
-- na správný team_id=35247 (Estudiantes de La Plata).

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
WHERE public.unaccent(lower(a.alias)) = 'estudiantes la plata'
ORDER BY a.team_id, a.id;

-- 2) Smazat případný konflikt na cílovém týmu
DELETE FROM public.team_aliases
WHERE team_id = 35247
  AND public.unaccent(lower(alias)) = 'estudiantes la plata';

-- 3) Přepojit alias na správný canonical tým
UPDATE public.team_aliases
SET team_id = 35247,
    source  = 'audit_536_alias_repoint'
WHERE team_id = 73436
  AND public.unaccent(lower(alias)) = 'estudiantes la plata';

-- 4) Doplň alias, pokud by po update neexistoval
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 35247, 'Estudiantes La Plata', 'audit_536_alias_repoint'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 35247
      AND public.unaccent(lower(a.alias)) = 'estudiantes la plata'
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
WHERE public.unaccent(lower(a.alias)) = 'estudiantes la plata'
ORDER BY a.team_id, a.id;

COMMIT;