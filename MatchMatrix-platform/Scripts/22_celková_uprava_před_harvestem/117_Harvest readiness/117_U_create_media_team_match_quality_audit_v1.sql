/*
MATCHMATRIX SQL 117_U
MEDIA TEAM MATCH QUALITY AUDIT V1

CO TO JE:
- Audit kvality kandidátů pro párování článků na týmy.

K ČEMU TO JE:
- Odhalí duplicitní názvy týmů.
- Odhalí krátké/rizikové názvy.
- Oddělí bezpečné kandidáty od těch, které nesmíme automaticky vložit.

KDE TO UVIDÍME:
- OPS Panel -> MEDIA
- DBeaver audit před article_team_map insertem.

JAK SE TO VYUŽIJE:
- Další skript 117_V vloží do public.article_team_map jen SAFE kandidáty.
*/

CREATE OR REPLACE VIEW ops.v_media_team_match_quality_audit_v1 AS
WITH duplicate_names AS (
    SELECT
        lower(name) AS team_name_norm,
        COUNT(*) AS duplicate_count
    FROM public.teams
    GROUP BY lower(name)
    HAVING COUNT(*) > 1
),
candidates AS (
    SELECT
        c.article_id,
        c.title,
        c.team_id,
        c.team_name,
        c.match_score,
        COALESCE(d.duplicate_count, 1) AS duplicate_count
    FROM ops.v_media_team_keyword_candidates_v1 c
    LEFT JOIN duplicate_names d
        ON d.team_name_norm = lower(c.team_name)
)
SELECT
    article_id,
    title,
    team_id,
    team_name,
    match_score,
    duplicate_count,

    CASE
        WHEN duplicate_count > 1 THEN 'DUPLICATE_TEAM_NAME'
        WHEN length(team_name) < 8 THEN 'SHORT_TEAM_NAME'
        WHEN lower(team_name) IN (
            'sporting',
            'england',
            'york',
            'thun',
            'brea',
            'inter',
            'aves',
            'lens',
            'bonn',
            'oman',
            'russia',
            'derby'
        ) THEN 'BLACKLISTED_NAME'
        ELSE 'SAFE'
    END AS quality_status,

    CASE
        WHEN duplicate_count > 1 THEN 'Nevkládat automaticky. Duplicitní název týmu.'
        WHEN length(team_name) < 8 THEN 'Nevkládat automaticky. Krátký název má vysoké riziko falešné shody.'
        WHEN lower(team_name) IN (
            'sporting',
            'england',
            'york',
            'thun',
            'brea',
            'inter',
            'aves',
            'lens',
            'bonn',
            'oman',
            'russia',
            'derby'
        ) THEN 'Nevkládat automaticky. Název je na blacklistu.'
        ELSE 'Bezpečný kandidát pro article_team_map.'
    END AS recommendation_cz,

    now() AS generated_at

FROM candidates
ORDER BY
    CASE
        WHEN duplicate_count > 1 THEN 1
        WHEN length(team_name) < 8 THEN 2
        ELSE 3
    END,
    article_id;