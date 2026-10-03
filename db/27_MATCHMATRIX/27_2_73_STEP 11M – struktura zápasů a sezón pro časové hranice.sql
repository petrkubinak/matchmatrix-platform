-- CO: STEP 11M – struktura zápasů a sezón pro časové hranice
-- K ČEMU: Najít sloupce pro datum zápasu, ligu a sezónu před návrhem pravidel obnovy.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz.

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'matches',
      'match_provider_map',
      'seasons',
      'leagues'
  )
ORDER BY table_name, ordinal_position;