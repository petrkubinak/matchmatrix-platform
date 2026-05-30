/*
MATCHMATRIX SQL 109_U Create Block Reason Catalog V1

CO TO JE:
- Katalog známých důvodů blokací.

K ČEMU TO JE:
- Aby systém věděl proč byl job zastaven.
- Aby znal doporučené opravy.
- Aby se mohl časem učit z výsledků oprav.

KDE TO UVIDÍME:
- AI OPS
- BLOKOVANÉ POLOŽKY
- OPRAVY
- KNOWLEDGE BASE

JAK SE TO VYUŽIJE:
- Každá blokace dostane typ problému.
- Každý typ problému dostane doporučené řešení.
- Později se bude evidovat úspěšnost oprav.
*/


CREATE TABLE IF NOT EXISTS ops.block_reason_catalog (

    id bigserial PRIMARY KEY,

    reason_code text NOT NULL UNIQUE,

    reason_name text NOT NULL,

    description text,

    recommended_fix text,

    requires_manual_review boolean NOT NULL DEFAULT true,

    can_auto_retry boolean NOT NULL DEFAULT false,

    can_auto_switch_provider boolean NOT NULL DEFAULT false,

    can_auto_disable boolean NOT NULL DEFAULT false,

    active_flag boolean NOT NULL DEFAULT true,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);



INSERT INTO ops.block_reason_catalog (
    reason_code,
    reason_name,
    description,
    recommended_fix,
    requires_manual_review,
    can_auto_retry,
    can_auto_switch_provider,
    can_auto_disable
)
VALUES

(
'PROVIDER_NO_DATA',
'Provider nevrací data',
'Provider vrací prázdnou odpověď pro ligu nebo sezónu.',
'Ověřit league_id, sezónu a dostupnost dat.',
true,
false,
true,
false
),

(
'ENDPOINT_NOT_AVAILABLE',
'Endpoint není dostupný',
'Provider endpoint neexistuje nebo není podporován.',
'Najít alternativní endpoint nebo providera.',
true,
false,
true,
false
),

(
'ENDPOINT_EMPTY',
'Endpoint vrací prázdnou odpověď',
'Endpoint existuje, ale vrací 0 záznamů.',
'Provést smoke test a ověřit parametry.',
true,
true,
false,
false
),

(
'INVALID_LEAGUE_MAPPING',
'Neplatné mapování ligy',
'League ID není správně navázáno.',
'Opravit provider_league_id.',
true,
false,
false,
false
),

(
'INVALID_SEASON',
'Neplatná sezóna',
'Provider danou sezónu nepodporuje.',
'Upravit rozsah sezón.',
true,
false,
false,
false
),

(
'RATE_LIMIT',
'Rate limit',
'Provider odmítl požadavek kvůli limitu.',
'Odložit retry.',
false,
true,
false,
false
),

(
'TIMEOUT',
'Timeout',
'Požadavek překročil časový limit.',
'Opatrný retry.',
false,
true,
false,
false
),

(
'PARSER_ERROR',
'Parser chyba',
'Parser nedokázal zpracovat payload.',
'Upravit parser.',
true,
false,
false,
false
),

(
'MERGE_ERROR',
'Merge chyba',
'Chyba při zápisu do public vrstvy.',
'Opravit merge logiku.',
true,
false,
false,
false
),

(
'TEAM_MAPPING_ERROR',
'Mapování týmu',
'Nenalezen tým v provider mapě.',
'Doplnit team_provider_map.',
true,
false,
false,
false
),

(
'PLAYER_MAPPING_ERROR',
'Mapování hráče',
'Nenalezen hráč v provider mapě.',
'Doplnit player_provider_map.',
true,
false,
false,
false
),

(
'UNKNOWN',
'Neznámý problém',
'Důvod zatím není znám.',
'Ruční analýza.',
true,
false,
false,
false
)

ON CONFLICT (reason_code)
DO NOTHING;



CREATE OR REPLACE VIEW ops.v_block_reason_catalog_v1 AS
SELECT
    reason_code,
    reason_name,
    description,
    recommended_fix,
    requires_manual_review,
    can_auto_retry,
    can_auto_switch_provider,
    can_auto_disable,
    active_flag
FROM ops.block_reason_catalog
ORDER BY reason_code;