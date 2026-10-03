/*
CO:
STEP 9O – CANONICAL SEASON 24881/2024 RESOLUTION

K ČEMU:
Ověřit konkrétní canonical sezonu pro:
HB / canonical league 24881 / API-Sports league 131 / provider season 2024.

CÍL:
Rozhodnout, zda budoucí exact coverage child registr
může používat season_id jako stabilní FK.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. PŘESNÝ KONTRAKT PUBLIC.SEASONS
   ========================================================= */

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'seasons'
ORDER BY ordinal_position;


/* =========================================================
   2. VŠECHNY SEZONY PRO CANONICAL LEAGUE 24881
   ========================================================= */

SELECT *
FROM public.seasons
WHERE league_id = 24881
ORDER BY id;


/* =========================================================
   3. PŘÍMÉ HLEDÁNÍ PROVIDER SEASON = 2024

   Ověříme season_code i season_label.
   ========================================================= */

SELECT *
FROM public.seasons
WHERE league_id = 24881
  AND (
       season_code = '2024'
       OR season_label = '2024'
       OR season_code ILIKE '%2024%'
       OR season_label ILIKE '%2024%'
  )
ORDER BY id;


/* =========================================================
   4. MATCH DATA PRO TUTO CANONICAL LIGU
   ========================================================= */

SELECT
    league_id,
    season,
    COUNT(*) AS matches,
    MIN(kickoff) AS first_kickoff,
    MAX(kickoff) AS last_kickoff,
    COUNT(*) FILTER (
        WHERE status = 'FINISHED'
    ) AS finished
FROM public.matches
WHERE league_id = 24881
GROUP BY
    league_id,
    season
ORDER BY
    first_kickoff;


/* =========================================================
   5. PROVIDER MAP
   ========================================================= */

SELECT *
FROM public.league_provider_map
WHERE league_id = 24881
  AND provider = 'api_handball';


/* =========================================================
   6. OVĚŘENÍ, ZDA JE SEASON_ID UŽ REÁLNĚ POUŽÍVÁNO
      PRO TUTO LIGU
   ========================================================= */

SELECT
    cr.season_id,
    COUNT(*) AS competition_round_rows
FROM public.competition_rounds cr
JOIN public.seasons s
  ON s.id = cr.season_id
WHERE s.league_id = 24881
GROUP BY cr.season_id
ORDER BY cr.season_id;