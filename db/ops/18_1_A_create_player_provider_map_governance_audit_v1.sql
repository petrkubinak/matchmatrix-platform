/*
MATCHMATRIX SQL 18_G_A
PLAYER PROVIDER MAP GOVERNANCE AUDIT V1

CO TO JE:
- Audit integrity mezi:
  public.players
  public.player_provider_map
  public.player_external_identity

K ČEMU TO JE:
- Najde orphan mapy, duplicitní provider identity a hráče bez provider vazby.

KDE TO UVIDÍME:
- OPS Panel V18 → People Layer → Provider Governance.

JAK SE TO VYUŽIJE:
- Před připojením dalších People providerů.
- Ochrana proti rozbití hráčské identity.
*/

CREATE OR REPLACE VIEW ops.v_player_provider_map_governance_audit_v1 AS

WITH ppm AS (
    SELECT
        'PLAYER_PROVIDER_MAP'::text AS source_table,
        m.id AS source_id,
        m.player_id,
        m.provider,
        m.provider_player_id AS external_player_id,
        m.provider_team_id AS external_team_id,
        m.provider_player_name AS external_player_name,
        m.is_active,
        m.created_at,
        m.updated_at
    FROM public.player_provider_map m
),

pei AS (
    SELECT
        'PLAYER_EXTERNAL_IDENTITY'::text AS source_table,
        e.id AS source_id,
        e.player_id,
        e.provider,
        e.external_player_id,
        e.external_team_id,
        NULL::text AS external_player_name,
        e.is_active,
        e.created_at,
        e.updated_at
    FROM public.player_external_identity e
),

combined AS (
    SELECT * FROM ppm
    UNION ALL
    SELECT * FROM pei
),

provider_identity_dupes AS (
    SELECT
        provider,
        external_player_id,
        COUNT(DISTINCT player_id) AS player_count,
        COUNT(*) AS rows_count
    FROM combined
    WHERE provider IS NOT NULL
      AND external_player_id IS NOT NULL
      AND trim(provider) <> ''
      AND trim(external_player_id) <> ''
    GROUP BY provider, external_player_id
    HAVING COUNT(DISTINCT player_id) > 1
),

players_without_map AS (
    SELECT
        p.id AS player_id
    FROM public.players p
    LEFT JOIN combined c
      ON c.player_id = p.id
    WHERE c.player_id IS NULL
)

SELECT
    c.source_table,
    c.source_id,
    c.player_id,
    c.provider,
    c.external_player_id,
    c.external_team_id,
    c.external_player_name,
    c.is_active,
    c.created_at,
    c.updated_at,

    CASE
        WHEN p.id IS NULL
            THEN 'ORPHAN_PROVIDER_IDENTITY'

        WHEN d.player_count IS NOT NULL
            THEN 'PROVIDER_IDENTITY_COLLISION'

        ELSE 'OK'
    END AS governance_issue,

    CASE
        WHEN p.id IS NULL THEN 'CRITICAL'
        WHEN d.player_count IS NOT NULL THEN 'CRITICAL'
        ELSE 'LOW'
    END AS risk_level,

    CASE
        WHEN p.id IS NULL
            THEN 'Provider mapa ukazuje na player_id, který neexistuje v public.players.'

        WHEN d.player_count IS NOT NULL
            THEN 'Stejný provider + external_player_id ukazuje na více různých player_id. Nutná oprava identity.'

        ELSE 'Vazba je v pořádku.'
    END AS recommended_action

FROM combined c
LEFT JOIN public.players p
  ON p.id = c.player_id
LEFT JOIN provider_identity_dupes d
  ON d.provider = c.provider
 AND d.external_player_id = c.external_player_id

UNION ALL

SELECT
    'PUBLIC_PLAYERS'::text AS source_table,
    p.id AS source_id,
    p.id AS player_id,
    p.ext_source AS provider,
    p.ext_player_id AS external_player_id,
    NULL::text AS external_team_id,
    p.name AS external_player_name,
    p.is_active,
    p.created_at,
    p.updated_at,

    'PLAYER_WITHOUT_PROVIDER_MAP' AS governance_issue,
    'MEDIUM' AS risk_level,
    'Hráč existuje v public.players, ale nemá záznam v player_provider_map ani player_external_identity.' AS recommended_action

FROM public.players p
JOIN players_without_map pwm
  ON pwm.player_id = p.id;