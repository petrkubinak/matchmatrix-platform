BEGIN;

-- 529_repoint_universidad_catolica_aliases_conflict_safe.sql
-- Cíl:
-- Bezpečně přepojit aliasy Universidad Catolica z team_id=10979 na team_id=603
-- i v případě, že na cílovém týmu už některý alias existuje.

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
WHERE lower(a.alias) IN ('universidad catolica', 'universidad catolica chi')
ORDER BY lower(a.alias), a.team_id, a.id;

-- 2) Smazat případné duplicitní aliasy na cílovém týmu 603
--    aby následný UPDATE nespadl na unique constraint
DELETE FROM public.team_aliases a
WHERE a.team_id = 603
  AND lower(a.alias) IN ('universidad catolica', 'universidad catolica chi');

-- 3) Přepojit aliasy ze starého týmu 10979 na správný tým 603
UPDATE public.team_aliases
SET team_id = 603,
    source = CASE
               WHEN lower(alias) = 'universidad catolica chi' THEN 'audit_529_alias_repoint'
               ELSE source
             END
WHERE team_id = 10979
  AND lower(alias) IN ('universidad catolica', 'universidad catolica chi');

-- 4) Kontrola po změně
SELECT
    a.id,
    a.team_id,
    t.name AS team_name,
    a.alias,
    a.source
FROM public.team_aliases a
JOIN public.teams t
  ON t.id = a.team_id
WHERE lower(a.alias) IN ('universidad catolica', 'universidad catolica chi')
ORDER BY lower(a.alias), a.team_id, a.id;

COMMIT;