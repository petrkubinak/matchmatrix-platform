/*
MATCHMATRIX SQL 18_1_G
FIX G GIBSON WRONG EXTERNAL IDENTITY V1

CO TO JE:
- Opravný skript pro chybnou external identity u hráče G. Gibson.

K ČEMU TO JE:
- Odstraní chybně vytvořený záznam:
  player_id = 5397
  provider = api_football
  external_player_id = 57185

- Tento external_player_id už správně patří hráči:
  player_id = 4757

KDE TO UVIDÍME:
- OPS Panel V18 → People Layer → Provider Governance.

JAK SE TO VYUŽIJE:
- Po opravě se CRITICAL kolize vrátí z 10 zpět na 8.
- Hráč 5397 zůstane bez bezpečné provider mapy a bude řešen ručně.
*/

BEGIN;

DELETE FROM public.player_external_identity
WHERE player_id = 5397
  AND provider = 'api_football'
  AND external_player_id = '57185';

DELETE FROM public.player_provider_map
WHERE player_id = 5397
  AND provider = 'api_football'
  AND provider_player_id = '57185';

COMMIT;