/*
MATCHMATRIX SQL 18_1_F
FIX PLAYER WITHOUT PROVIDER MAP V1

CO TO JE:
- Opravný skript pro hráče bez provider mapy.
- Aktuálně řeší G. Gibson / api_football / 57185.

K ČEMU TO JE:
- Doplní chybějící záznam do:
  public.player_provider_map
  public.player_external_identity

KDE TO UVIDÍME:
- OPS Panel V18 → People Layer → Provider Governance.

JAK SE TO VYUŽIJE:
- Po opravě má PLAYER_WITHOUT_PROVIDER_MAP spadnout na 0.
- People Layer bude mít kompletnější provider identitu.
*/

BEGIN;

INSERT INTO public.player_provider_map (
    provider,
    provider_player_id,
    player_id,
    provider_team_id,
    provider_team_name,
    provider_player_name,
    is_active,
    created_at,
    updated_at
)
SELECT
    p.ext_source AS provider,
    p.ext_player_id AS provider_player_id,
    p.id AS player_id,
    NULL::text AS provider_team_id,
    NULL::text AS provider_team_name,
    p.name AS provider_player_name,
    true AS is_active,
    now() AS created_at,
    now() AS updated_at
FROM public.players p
WHERE p.id = 5397
  AND p.ext_source IS NOT NULL
  AND p.ext_player_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM public.player_provider_map ppm
      WHERE ppm.provider = p.ext_source
        AND ppm.provider_player_id = p.ext_player_id
  );

INSERT INTO public.player_external_identity (
    player_id,
    provider,
    external_player_id,
    external_team_id,
    external_league_id,
    season,
    confidence_score,
    match_method,
    is_primary,
    is_active,
    created_at,
    updated_at
)
SELECT
    p.id AS player_id,
    p.ext_source AS provider,
    p.ext_player_id AS external_player_id,
    NULL::text AS external_team_id,
    NULL::text AS external_league_id,
    NULL::text AS season,
    100.00 AS confidence_score,
    'AUTO_FROM_PUBLIC_PLAYERS' AS match_method,
    true AS is_primary,
    true AS is_active,
    now() AS created_at,
    now() AS updated_at
FROM public.players p
WHERE p.id = 5397
  AND p.ext_source IS NOT NULL
  AND p.ext_player_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM public.player_external_identity pei
      WHERE pei.provider = p.ext_source
        AND pei.external_player_id = p.ext_player_id
  );

COMMIT;