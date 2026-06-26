/*
MATCHMATRIX 19_6_A – PLAYER PROFILE QUALITY AUDIT

CO TO JE:
Audit kvality hráčských profilů v public.players.

K ČEMU TO JE:
Zjistí, kolik hráčů má vyplněné klíčové údaje:
jméno, datum narození, národnost, pozici, výšku, váhu, foto, tým.

KDE TO UVIDÍME:
OPS / PEOPLE / PLAYER PROFILE QUALITY

JAK SE TO VYUŽIJE:
Výstup bude základ pro 19_6_B dashboard a 19_6_C enrichment queue.
*/

CREATE OR REPLACE VIEW ops.v_player_profile_quality_audit_v1 AS
SELECT
    s.code AS sport_code,
    s.name AS sport_name,

    COUNT(*) AS total_players,

    COUNT(*) FILTER (WHERE p.name IS NOT NULL AND btrim(p.name) <> '') AS has_name,
    COUNT(*) FILTER (WHERE p.first_name IS NOT NULL AND btrim(p.first_name) <> '') AS has_first_name,
    COUNT(*) FILTER (WHERE p.last_name IS NOT NULL AND btrim(p.last_name) <> '') AS has_last_name,
    COUNT(*) FILTER (WHERE p.birth_date IS NOT NULL) AS has_birth_date,
    COUNT(*) FILTER (WHERE p.nationality IS NOT NULL AND btrim(p.nationality) <> '') AS has_nationality,
    COUNT(*) FILTER (WHERE p.position IS NOT NULL AND btrim(p.position) <> '') AS has_position,
    COUNT(*) FILTER (WHERE p.height_cm IS NOT NULL) AS has_height,
    COUNT(*) FILTER (WHERE p.weight_kg IS NOT NULL) AS has_weight,
    COUNT(*) FILTER (WHERE p.photo_url IS NOT NULL AND btrim(p.photo_url) <> '') AS has_photo,
    COUNT(*) FILTER (WHERE p.team_id IS NOT NULL) AS has_team,

    ROUND(100.0 * COUNT(*) FILTER (WHERE p.birth_date IS NOT NULL) / NULLIF(COUNT(*), 0), 2) AS birth_date_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE p.nationality IS NOT NULL AND btrim(p.nationality) <> '') / NULLIF(COUNT(*), 0), 2) AS nationality_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE p.position IS NOT NULL AND btrim(p.position) <> '') / NULLIF(COUNT(*), 0), 2) AS position_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE p.photo_url IS NOT NULL AND btrim(p.photo_url) <> '') / NULLIF(COUNT(*), 0), 2) AS photo_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE p.team_id IS NOT NULL) / NULLIF(COUNT(*), 0), 2) AS team_pct,

    ROUND(
        (
            (
                COUNT(*) FILTER (WHERE p.name IS NOT NULL AND btrim(p.name) <> '') +
                COUNT(*) FILTER (WHERE p.birth_date IS NOT NULL) +
                COUNT(*) FILTER (WHERE p.nationality IS NOT NULL AND btrim(p.nationality) <> '') +
                COUNT(*) FILTER (WHERE p.position IS NOT NULL AND btrim(p.position) <> '') +
                COUNT(*) FILTER (WHERE p.height_cm IS NOT NULL) +
                COUNT(*) FILTER (WHERE p.weight_kg IS NOT NULL) +
                COUNT(*) FILTER (WHERE p.photo_url IS NOT NULL AND btrim(p.photo_url) <> '') +
                COUNT(*) FILTER (WHERE p.team_id IS NOT NULL)
            )::numeric
            / NULLIF(COUNT(*) * 8, 0)
        ) * 100,
        2
    ) AS profile_quality_pct,

    CASE
        WHEN ROUND(
            (
                (
                    COUNT(*) FILTER (WHERE p.name IS NOT NULL AND btrim(p.name) <> '') +
                    COUNT(*) FILTER (WHERE p.birth_date IS NOT NULL) +
                    COUNT(*) FILTER (WHERE p.nationality IS NOT NULL AND btrim(p.nationality) <> '') +
                    COUNT(*) FILTER (WHERE p.position IS NOT NULL AND btrim(p.position) <> '') +
                    COUNT(*) FILTER (WHERE p.height_cm IS NOT NULL) +
                    COUNT(*) FILTER (WHERE p.weight_kg IS NOT NULL) +
                    COUNT(*) FILTER (WHERE p.photo_url IS NOT NULL AND btrim(p.photo_url) <> '') +
                    COUNT(*) FILTER (WHERE p.team_id IS NOT NULL)
                )::numeric
                / NULLIF(COUNT(*) * 8, 0)
            ) * 100,
            2
        ) >= 80 THEN 'READY'
        WHEN ROUND(
            (
                (
                    COUNT(*) FILTER (WHERE p.name IS NOT NULL AND btrim(p.name) <> '') +
                    COUNT(*) FILTER (WHERE p.birth_date IS NOT NULL) +
                    COUNT(*) FILTER (WHERE p.nationality IS NOT NULL AND btrim(p.nationality) <> '') +
                    COUNT(*) FILTER (WHERE p.position IS NOT NULL AND btrim(p.position) <> '') +
                    COUNT(*) FILTER (WHERE p.height_cm IS NOT NULL) +
                    COUNT(*) FILTER (WHERE p.weight_kg IS NOT NULL) +
                    COUNT(*) FILTER (WHERE p.photo_url IS NOT NULL AND btrim(p.photo_url) <> '') +
                    COUNT(*) FILTER (WHERE p.team_id IS NOT NULL)
                )::numeric
                / NULLIF(COUNT(*) * 8, 0)
            ) * 100,
            2
        ) >= 50 THEN 'PARTIAL'
        ELSE 'DATA_GAP'
    END AS quality_status

FROM public.players p
LEFT JOIN public.sports s
    ON s.id = p.sport_id
GROUP BY
    s.code,
    s.name;