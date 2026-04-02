-- 491_cleanup_duplicate_theodds_teams.sql
-- nechá vždy jen nejnižší ID pro nově vložené theodds týmy

WITH ranked AS (
    SELECT
        id,
        name,
        ext_source,
        ROW_NUMBER() OVER (
            PARTITION BY lower(trim(name)), COALESCE(ext_source, '')
            ORDER BY id
        ) AS rn
    FROM public.teams
    WHERE ext_source = 'theodds'
      AND name IN (
          'Deportes Tolima',
          'DR Congo',
          'Estudiantes La Plata',
          'FC Zwolle',
          'Iraq',
          'Lanus',
          'Peñarol Montevideo'
      )
)
DELETE FROM public.teams
WHERE id IN (
    SELECT id
    FROM ranked
    WHERE rn > 1
);

-- kontrola
SELECT id, name, ext_source
FROM public.teams
WHERE ext_source = 'theodds'
  AND name IN (
      'Deportes Tolima',
      'DR Congo',
      'Estudiantes La Plata',
      'FC Zwolle',
      'Iraq',
      'Lanus',
      'Peñarol Montevideo'
  )
ORDER BY name, id;