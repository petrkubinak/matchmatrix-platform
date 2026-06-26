/*
MATCHMATRIX SQL 18_F

PLAYER INSERT GUARD SUMMARY V1

CO TO JE:
- Souhrnný dashboard ochrany proti vytváření nových duplicitních hráčů.
- Navazuje na 18_E Player Insert Guard.

K ČEMU TO JE:
- Ukazuje kolik hráčů je chráněno podle:
    1) provider + ext_player_id
    2) name + birth_date + sport
    3) HOLD identity review seznam

- Slouží jako rychlá kontrola před spuštěním:
    - People ingest workerů
    - Player merge workerů
    - Nových provider onboardingů

KDE TO UVIDÍME:
- OPS Panel V18
- People Layer
- Player Identity Governance
- Governance Dashboard

JAK SE TO VYUŽIJE:
- Panel zobrazí aktuální stav ochrany hráčských identit.
- Pokud HOLD identit existuje:
      guard_status = ACTIVE

- Pokud HOLD identit není:
      guard_status = READY

- Slouží jako ochrana proti:
      duplicitním hráčům
      chybným merge operacím
      chybnému provider mappingu

- Je to finální kontrolní vrstva před INSERTEM nových hráčů.
*/

CREATE OR REPLACE VIEW ops.v_player_insert_guard_summary_v1 AS

SELECT

    now() AS checked_at,

    COUNT(*) FILTER (
        WHERE guard_type = 'EXISTING_PROVIDER_PLAYER_ID'
    ) AS provider_player_guard_rows,

    COUNT(*) FILTER (
        WHERE guard_type = 'EXISTING_NAME_BIRTH_SPORT'
    ) AS name_birth_guard_rows,

    COUNT(*) FILTER (
        WHERE guard_type = 'HOLD_PLAYER_IDENTITY'
    ) AS hold_identity_guard_rows,

    CASE
        WHEN COUNT(*) FILTER (
            WHERE guard_type = 'HOLD_PLAYER_IDENTITY'
        ) > 0
        THEN 'ACTIVE'

        ELSE 'READY'
    END AS guard_status

FROM ops.v_player_insert_guard_v1;