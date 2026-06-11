/*
MATCHMATRIX SQL 18_A
PLAYER DUPLICATE AUDIT V1

CO TO JE:
- První audit možných duplicit hráčů v public.players.

K ČEMU TO JE:
- Najde rizika podle:
  1) ext_source + ext_player_id
  2) name + birth_date + sport_id
  3) name + team_id + sport_id

KDE TO UVIDÍME:
- OPS Panel V18 → PEOPLE / PLAYER IDENTITY GOVERNANCE.

JAK SE TO VYUŽIJE:
- Zjistíme, kolik hráčských duplicit je skutečných.
- Připravíme následný canonical audit, hold list a insert guard.
*/

CREATE OR REPLACE VIEW ops.v_player_duplicate_audit_v1 AS
WITH base AS (
    SELECT
        p.id AS player_id,
        p.team_id,
        p.name,
        lower(trim(p.name)) AS normalized_name,
        p.first_name,
        p.last_name,
        p.short_name,
        p.birth_date,
        p.nationality,
        p.position,
        p.shirt_number,
        p.ext_source,
        p.ext_player_id,
        p.photo_url,
        p.sport_id,
        p.created_at,
        p.updated_at
    FROM public.players p
    WHERE p.name IS NOT NULL
      AND trim(p.name) <> ''
),

provider_dupes AS (
    SELECT
        ext_source,
        ext_player_id,
        COUNT(*) AS duplicate_count
    FROM base
    WHERE ext_source IS NOT NULL
      AND ext_player_id IS NOT NULL
      AND trim(ext_source) <> ''
      AND trim(ext_player_id) <> ''
    GROUP BY ext_source, ext_player_id
    HAVING COUNT(*) > 1
),

name_birth_dupes AS (
    SELECT
        normalized_name,
        birth_date,
        sport_id,
        COUNT(*) AS duplicate_count
    FROM base
    WHERE normalized_name IS NOT NULL
      AND normalized_name <> ''
      AND birth_date IS NOT NULL
      AND sport_id IS NOT NULL
    GROUP BY normalized_name, birth_date, sport_id
    HAVING COUNT(*) > 1
),

name_team_dupes AS (
    SELECT
        normalized_name,
        team_id,
        sport_id,
        COUNT(*) AS duplicate_count
    FROM base
    WHERE normalized_name IS NOT NULL
      AND normalized_name <> ''
      AND team_id IS NOT NULL
      AND sport_id IS NOT NULL
    GROUP BY normalized_name, team_id, sport_id
    HAVING COUNT(*) > 1
)

SELECT
    b.player_id,
    b.team_id,
    b.name,
    b.normalized_name,
    b.first_name,
    b.last_name,
    b.short_name,
    b.birth_date,
    b.nationality,
    b.position,
    b.shirt_number,
    b.ext_source,
    b.ext_player_id,
    b.photo_url,
    b.sport_id,
    b.created_at,
    b.updated_at,

    CASE
        WHEN pd.duplicate_count IS NOT NULL THEN 'PROVIDER_PLAYER_ID_DUPLICATE'
        WHEN nbd.duplicate_count IS NOT NULL THEN 'NAME_BIRTH_SPORT_DUPLICATE'
        WHEN ntd.duplicate_count IS NOT NULL THEN 'NAME_TEAM_SPORT_DUPLICATE'
        ELSE 'OK'
    END AS risk_type,

    CASE
        WHEN pd.duplicate_count IS NOT NULL THEN pd.duplicate_count
        WHEN nbd.duplicate_count IS NOT NULL THEN nbd.duplicate_count
        WHEN ntd.duplicate_count IS NOT NULL THEN ntd.duplicate_count
        ELSE 1
    END AS duplicate_count,

    CASE
        WHEN pd.duplicate_count IS NOT NULL THEN 'CRITICAL'
        WHEN nbd.duplicate_count IS NOT NULL THEN 'HIGH'
        WHEN ntd.duplicate_count IS NOT NULL THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_level,

    CASE
        WHEN pd.duplicate_count IS NOT NULL
            THEN 'Stejný provider + ext_player_id existuje vícekrát. Kandidát na bezpečný merge.'
        WHEN nbd.duplicate_count IS NOT NULL
            THEN 'Stejné jméno + datum narození + sport. Pravděpodobná duplicita, nutný canonical audit.'
        WHEN ntd.duplicate_count IS NOT NULL
            THEN 'Stejné jméno + tým + sport. Může jít o duplicitu bez birth_date.'
        ELSE 'Bez zjištěného rizika.'
    END AS recommended_action

FROM base b
LEFT JOIN provider_dupes pd
    ON pd.ext_source = b.ext_source
   AND pd.ext_player_id = b.ext_player_id
LEFT JOIN name_birth_dupes nbd
    ON nbd.normalized_name = b.normalized_name
   AND nbd.birth_date = b.birth_date
   AND nbd.sport_id = b.sport_id
LEFT JOIN name_team_dupes ntd
    ON ntd.normalized_name = b.normalized_name
   AND ntd.team_id = b.team_id
   AND ntd.sport_id = b.sport_id
WHERE pd.duplicate_count IS NOT NULL
   OR nbd.duplicate_count IS NOT NULL
   OR ntd.duplicate_count IS NOT NULL
ORDER BY
    CASE
        WHEN pd.duplicate_count IS NOT NULL THEN 1
        WHEN nbd.duplicate_count IS NOT NULL THEN 2
        WHEN ntd.duplicate_count IS NOT NULL THEN 3
        ELSE 4
    END,
    duplicate_count DESC,
    normalized_name,
    player_id;