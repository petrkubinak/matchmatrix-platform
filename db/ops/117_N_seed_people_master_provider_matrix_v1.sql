/*
MATCHMATRIX SQL 117_N
SEED PEOPLE MASTER PROVIDER MATRIX V1

CO TO JE:
- Naplní ops.people_master_provider_matrix z existujícího people auditu.

K ČEMU TO JE:
- PEOPLE MASTER READINESS nebude hlásit PROVIDER_GAP u sportů,
  kde už provider audit reálně existuje.

KDE TO UVIDÍME:
- OPS Panel -> PEOPLE
- OPS Panel -> HARVEST
- ops.v_people_master_readiness_v1

JAK SE TO VYUŽIJE:
- Panel pozná, že sport má people providera,
  i když hráči/trenéři/profily/statistiky ještě nejsou kompletní.
*/

INSERT INTO ops.people_master_provider_matrix (
    sport_code,
    sport_name,
    people_provider,
    players_supported,
    coaches_supported,
    profiles_supported,
    season_stats_supported,
    match_stats_supported,
    rankings_supported,
    photos_supported,
    provider_status,
    priority_order,
    notes,
    created_at,
    updated_at
)
SELECT
    a.sport_code,
    COALESCE(s.name, a.sport_code) AS sport_name,
    a.provider AS people_provider,

    BOOL_OR(a.entity = 'players' AND a.final_verdict IN (
        'PUBLIC_CONFIRMED',
        'STAGING_CONFIRMED',
        'WAIT_SCOPE_FIX',
        'WAIT_PROVIDER_DOC_CHECK',
        'WAIT_PROVIDER'
    )) AS players_supported,

    BOOL_OR(a.entity = 'coaches' AND a.final_verdict IN (
        'PUBLIC_CONFIRMED',
        'STAGING_CONFIRMED',
        'WAIT_SCOPE_FIX',
        'WAIT_PROVIDER_DOC_CHECK',
        'WAIT_PROVIDER'
    )) AS coaches_supported,

    BOOL_OR(a.entity IN ('profiles', 'player_profiles') AND a.final_verdict IN (
        'PUBLIC_CONFIRMED',
        'STAGING_CONFIRMED',
        'WAIT_SCOPE_FIX',
        'WAIT_PROVIDER_DOC_CHECK',
        'WAIT_PROVIDER'
    )) AS profiles_supported,

    BOOL_OR(a.entity IN ('season_stats', 'player_season_stats') AND a.final_verdict IN (
        'PUBLIC_CONFIRMED',
        'STAGING_CONFIRMED',
        'WAIT_SCOPE_FIX',
        'WAIT_PROVIDER_DOC_CHECK',
        'WAIT_PROVIDER'
    )) AS season_stats_supported,

    BOOL_OR(a.entity IN ('match_stats', 'player_stats') AND a.final_verdict IN (
        'PUBLIC_CONFIRMED',
        'STAGING_CONFIRMED',
        'WAIT_SCOPE_FIX',
        'WAIT_PROVIDER_DOC_CHECK',
        'WAIT_PROVIDER'
    )) AS match_stats_supported,

    false AS rankings_supported,
    false AS photos_supported,

    CASE
        WHEN BOOL_OR(a.final_verdict = 'PUBLIC_CONFIRMED') THEN 'PUBLIC_CONFIRMED'
        WHEN BOOL_OR(a.final_verdict = 'STAGING_CONFIRMED') THEN 'STAGING_CONFIRMED'
        WHEN BOOL_OR(a.final_verdict = 'WAIT_SCOPE_FIX') THEN 'WAIT_SCOPE_FIX'
        WHEN BOOL_OR(a.final_verdict = 'WAIT_PROVIDER_DOC_CHECK') THEN 'WAIT_PROVIDER_DOC_CHECK'
        WHEN BOOL_OR(a.final_verdict = 'WAIT_PROVIDER') THEN 'WAIT_PROVIDER'
        WHEN BOOL_OR(a.final_verdict = 'NOT_USABLE_NOW') THEN 'NOT_USABLE_NOW'
        ELSE 'UNKNOWN'
    END AS provider_status,

    MIN(COALESCE(a.priority_rank, 999)) AS priority_order,

    STRING_AGG(
        DISTINCT CONCAT(
            a.entity,
            ': ',
            a.final_verdict,
            ' | ',
            COALESCE(a.next_step, '')
        ),
        E'\n'
    ) AS notes,

    now(),
    now()

FROM ops.provider_people_audit a
LEFT JOIN public.sports s
       ON s.code = a.sport_code
GROUP BY
    a.sport_code,
    COALESCE(s.name, a.sport_code),
    a.provider
ON CONFLICT DO NOTHING;