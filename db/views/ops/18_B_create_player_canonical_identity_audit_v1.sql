/*
MATCHMATRIX SQL 18_B
PLAYER CANONICAL IDENTITY AUDIT V1

CO TO JE:
- Klasifikace možných hráčských duplicit.

K ČEMU TO JE:
- Rozdělí případy na:
  SAFE_DIFFERENT_BIRTH_DATE
  SUSPECT_MISSING_BIRTH_DATE
  SUSPECT_SAME_BIRTH_DATE
  REAL_PROVIDER_PLAYER_DUPLICATE

KDE TO UVIDÍME:
- OPS Panel V18 → PEOPLE / PLAYER IDENTITY GOVERNANCE.

JAK SE TO VYUŽIJE:
- Připraví bezpečný merge plán a hold list.
*/

CREATE OR REPLACE VIEW ops.v_player_canonical_identity_audit_v1 AS
WITH base AS (
    SELECT
        p.id AS player_id,
        p.team_id,
        p.name,
        lower(trim(p.name)) AS normalized_name,
        p.first_name,
        p.last_name,
        p.birth_date,
        p.nationality,
        p.position,
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

groups AS (
    SELECT
        normalized_name,
        sport_id,
        team_id,
        COUNT(*) AS player_rows,
        COUNT(DISTINCT player_id) AS player_id_count,
        COUNT(DISTINCT ext_source) AS provider_count,
        COUNT(DISTINCT ext_player_id) AS provider_player_id_count,
        COUNT(DISTINCT birth_date) FILTER (WHERE birth_date IS NOT NULL) AS birth_date_count,
        COUNT(*) FILTER (WHERE birth_date IS NULL) AS missing_birth_date_count,
        STRING_AGG(DISTINCT ext_source, ', ' ORDER BY ext_source) AS providers,
        STRING_AGG(DISTINCT ext_player_id::text, ', ' ORDER BY ext_player_id::text) AS provider_player_ids,
        STRING_AGG(DISTINCT birth_date::text, ', ' ORDER BY birth_date::text) AS birth_dates,
        MIN(created_at) AS first_seen_at,
        MAX(updated_at) AS last_updated_at
    FROM base
    GROUP BY normalized_name, sport_id, team_id
    HAVING COUNT(*) > 1
),

classified AS (
    SELECT
        g.*,

        CASE
            WHEN provider_count = 1
             AND provider_player_id_count = 1
             AND player_rows > 1
                THEN 'REAL_PROVIDER_PLAYER_DUPLICATE'

            WHEN birth_date_count > 1
                THEN 'SAFE_DIFFERENT_BIRTH_DATE'

            WHEN birth_date_count = 1
             AND missing_birth_date_count = 0
                THEN 'SUSPECT_SAME_BIRTH_DATE'

            WHEN birth_date_count = 1
             AND missing_birth_date_count > 0
                THEN 'SUSPECT_MISSING_BIRTH_DATE'

            WHEN birth_date_count = 0
                THEN 'SUSPECT_NO_BIRTH_DATE'

            ELSE 'UNKNOWN_REVIEW'
        END AS identity_status,

        CASE
            WHEN provider_count = 1
             AND provider_player_id_count = 1
             AND player_rows > 1
                THEN 'CRITICAL'

            WHEN birth_date_count > 1
                THEN 'LOW'

            WHEN birth_date_count = 1
             AND missing_birth_date_count = 0
                THEN 'HIGH'

            WHEN birth_date_count = 1
             AND missing_birth_date_count > 0
                THEN 'MEDIUM'

            WHEN birth_date_count = 0
                THEN 'MEDIUM'

            ELSE 'MEDIUM'
        END AS risk_level
    FROM groups g
)

SELECT
    normalized_name,
    sport_id,
    team_id,
    player_rows,
    player_id_count,
    provider_count,
    provider_player_id_count,
    birth_date_count,
    missing_birth_date_count,
    providers,
    provider_player_ids,
    birth_dates,
    identity_status,
    risk_level,
    first_seen_at,
    last_updated_at,

    CASE
        WHEN identity_status = 'REAL_PROVIDER_PLAYER_DUPLICATE'
            THEN 'Stejný provider + ext_player_id existuje vícekrát. Bezpečný merge kandidát.'

        WHEN identity_status = 'SAFE_DIFFERENT_BIRTH_DATE'
            THEN 'Stejné jméno a tým, ale různé datum narození. Neslučovat automaticky.'

        WHEN identity_status = 'SUSPECT_SAME_BIRTH_DATE'
            THEN 'Stejné jméno a stejné datum narození. Pravděpodobná duplicita, připravit merge kandidáty.'

        WHEN identity_status = 'SUSPECT_MISSING_BIRTH_DATE'
            THEN 'Jeden hráč má birth_date, druhý ne. Nutná kontrola, ale může jít o stejnou osobu.'

        WHEN identity_status = 'SUSPECT_NO_BIRTH_DATE'
            THEN 'Duplicitní jméno bez birth_date. Ruční kontrola.'

        ELSE 'Ruční kontrola.'
    END AS recommended_action

FROM classified
ORDER BY
    CASE risk_level
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
        ELSE 5
    END,
    normalized_name;