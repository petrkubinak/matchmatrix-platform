BEGIN;

-- 534_repoint_lanus_alias_to_35245.sql
-- Cíl:
-- Přepojit alias "Lanus"
-- ze špatného team_id=73439
-- na správný team_id=35245 (CA Lanús).

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
WHERE public.unaccent(lower(a.alias)) = 'lanus'
ORDER BY a.team_id, a.id;

-- 2) Smazat případný konflikt na cílovém týmu
DELETE FROM public.team_aliases
WHERE team_id = 35245
  AND public.unaccent(lower(alias)) = 'lanus';

-- 3) Přepojit alias na správný canonical tým
UPDATE public.team_aliases
SET team_id = 35245,
    source  = 'audit_534_alias_repoint'
WHERE team_id = 73439
  AND public.unaccent(lower(alias)) = 'lanus';

-- 4) Doplň alias, pokud by po update neexistoval
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 35245, 'Lanus', 'audit_534_alias_repoint'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 35245
      AND public.unaccent(lower(a.alias)) = 'lanus'
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
WHERE public.unaccent(lower(a.alias)) = 'lanus'
ORDER BY a.team_id, a.id;

COMMIT;