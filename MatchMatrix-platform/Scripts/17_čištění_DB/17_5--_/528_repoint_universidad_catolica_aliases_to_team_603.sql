BEGIN;

-- 528_repoint_universidad_catolica_aliases_to_team_603.sql
-- Cíl:
-- Přepojit TheOdds / audit aliasy pro Universidad Catolica
-- ze staré větve 10979 na správný canonical tým 603 = CD Universidad Católica.
--
-- Bez merge týmů.
-- Jen bezpečný alias fix pro resolver.

-- 1) Kontrola před změnou
SELECT
    t.id AS team_id,
    t.name AS team_name,
    a.alias,
    a.source
FROM public.team_aliases a
JOIN public.teams t
  ON t.id = a.team_id
WHERE lower(a.alias) IN ('universidad catolica', 'universidad catolica chi')
ORDER BY a.alias, t.id;

-- 2) Přepojení existujících aliasů na správný canonical tým
UPDATE public.team_aliases
SET team_id = 603
WHERE team_id = 10979
  AND lower(alias) IN ('universidad catolica', 'universidad catolica chi');

-- 3) Doplň aliasy na 603, pokud by některý chyběl
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 603, v.alias, v.source
FROM (
    VALUES
        ('universidad catolica', 'theodds'),
        ('universidad catolica chi', 'audit_528_alias_repoint')
) AS v(alias, source)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 603
      AND lower(a.alias) = lower(v.alias)
);

-- 4) Kontrola po změně
SELECT
    t.id AS team_id,
    t.name AS team_name,
    a.alias,
    a.source
FROM public.team_aliases a
JOIN public.teams t
  ON t.id = a.team_id
WHERE lower(a.alias) IN ('universidad catolica', 'universidad catolica chi')
ORDER BY a.alias, t.id;

COMMIT;