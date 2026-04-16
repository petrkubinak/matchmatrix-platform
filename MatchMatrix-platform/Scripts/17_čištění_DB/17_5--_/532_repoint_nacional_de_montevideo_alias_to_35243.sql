BEGIN;

-- 532_repoint_nacional_de_montevideo_alias_to_35243.sql
-- Cíl:
-- Přepojit alias "Nacional de Montevideo"
-- ze špatného team_id=582 (CD Nacional)
-- na správný team_id=35243 (Club Nacional de Football).

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
WHERE lower(a.alias) = lower('Nacional de Montevideo')
ORDER BY a.team_id, a.id;

-- 2) Smazat případný konflikt na cílovém týmu
DELETE FROM public.team_aliases
WHERE team_id = 35243
  AND lower(alias) = lower('Nacional de Montevideo');

-- 3) Přepojit alias na správný canonical tým
UPDATE public.team_aliases
SET team_id = 35243,
    source  = 'audit_532_alias_repoint'
WHERE team_id = 582
  AND lower(alias) = lower('Nacional de Montevideo');

-- 4) Pokud by alias po update neexistoval, doplnit ho
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 35243, 'Nacional de Montevideo', 'audit_532_alias_repoint'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 35243
      AND lower(a.alias) = lower('Nacional de Montevideo')
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
WHERE lower(a.alias) = lower('Nacional de Montevideo')
ORDER BY a.team_id, a.id;

COMMIT;