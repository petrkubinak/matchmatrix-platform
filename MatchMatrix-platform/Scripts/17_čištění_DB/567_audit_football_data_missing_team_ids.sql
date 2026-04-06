-- ============================================================
-- 567_audit_football_data_missing_team_ids.sql
-- MatchMatrix / Football-Data
--
-- Účel:
-- audit zápasů z football-data raw payloadů, kde chybí mapování
-- home/away týmu do public.teams, a proto se fixture nevloží do public.matches
--
-- Použití:
-- - otevři v DBeaveru
-- - případně uprav v CTE params konkrétní run_id
--
-- Pozn:
-- football-data raw payload může být uložen jako:
--   payload -> 'payload' -> 'matches'
-- nebo přímo:
--   payload -> 'matches'
-- skript podporuje obě varianty
-- ============================================================

WITH params AS (
    -- nastav konkrétní football_data run_id
    SELECT 192::bigint AS football_data_run_id
),

raw_base AS (
    SELECT
        arp.id AS raw_id,
        arp.run_id,
        arp.endpoint,
        arp.payload,
        CASE
            WHEN jsonb_typeof(arp.payload -> 'payload' -> 'matches') = 'array'
                THEN arp.payload -> 'payload' -> 'matches'
            WHEN jsonb_typeof(arp.payload -> 'matches') = 'array'
                THEN arp.payload -> 'matches'
            ELSE '[]'::jsonb
        END AS matches_json
    FROM public.api_raw_payloads arp
    JOIN params p
      ON p.football_data_run_id = arp.run_id
    WHERE arp.source = 'football_data'
),

raw_matches AS (
    SELECT
        rb.raw_id,
        rb.run_id,
        rb.endpoint,

        -- competition
        COALESCE(
            m -> 'competition' ->> 'id',
            rb.payload -> 'payload' -> 'competition' ->> 'id',
            rb.payload -> 'competition' ->> 'id'
        ) AS provider_league_id,

        COALESCE(
            m -> 'competition' ->> 'name',
            rb.payload -> 'payload' -> 'competition' ->> 'name',
            rb.payload -> 'competition' ->> 'name'
        ) AS competition_name,

        -- match
        COALESCE(
            m ->> 'id',
            m ->> 'match_id'
        ) AS provider_match_id,

        COALESCE(
            m ->> 'utcDate',
            m ->> 'date',
            m ->> 'kickoff'
        ) AS provider_kickoff_raw,

        -- home
        COALESCE(
            m -> 'homeTeam' ->> 'id',
            m -> 'home' ->> 'id'
        ) AS provider_home_team_id,

        COALESCE(
            m -> 'homeTeam' ->> 'name',
            m -> 'home' ->> 'name'
        ) AS provider_home_team_name,

        -- away
        COALESCE(
            m -> 'awayTeam' ->> 'id',
            m -> 'away' ->> 'id'
        ) AS provider_away_team_id,

        COALESCE(
            m -> 'awayTeam' ->> 'name',
            m -> 'away' ->> 'name'
        ) AS provider_away_team_name

    FROM raw_base rb
    CROSS JOIN LATERAL jsonb_array_elements(rb.matches_json) m
),

joined AS (
    SELECT
        rm.*,

        l.id AS canonical_league_id,
        l.name AS canonical_league_name,
        l.theodds_key,

        th.id AS home_team_id_by_ext,
        th.name AS home_team_name_by_ext,

        ta.id AS away_team_id_by_ext,
        ta.name AS away_team_name_by_ext

    FROM raw_matches rm
    LEFT JOIN public.leagues l
           ON l.ext_source = 'football_data'
          AND l.ext_league_id = rm.provider_league_id

    LEFT JOIN public.teams th
           ON th.ext_source = 'football_data'
          AND th.ext_team_id = rm.provider_home_team_id

    LEFT JOIN public.teams ta
           ON ta.ext_source = 'football_data'
          AND ta.ext_team_id = rm.provider_away_team_id
),

name_candidates AS (
    SELECT
        j.*,

        thn.id AS home_team_id_by_name,
        thn.name AS home_team_name_by_name,

        tan.id AS away_team_id_by_name,
        tan.name AS away_team_name_by_name

    FROM joined j

    LEFT JOIN LATERAL (
        SELECT t.id, t.name
        FROM public.teams t
        WHERE lower(btrim(t.name)) = lower(btrim(j.provider_home_team_name))
        ORDER BY
            CASE
                WHEN t.ext_source = 'football_data' THEN 0
                WHEN t.ext_source = 'football_data_uk' THEN 1
                WHEN t.ext_source = 'api_football' THEN 2
                WHEN t.ext_source = 'api_sport' THEN 3
                ELSE 9
            END,
            t.id
        LIMIT 1
    ) thn ON TRUE

    LEFT JOIN LATERAL (
        SELECT t.id, t.name
        FROM public.teams t
        WHERE lower(btrim(t.name)) = lower(btrim(j.provider_away_team_name))
        ORDER BY
            CASE
                WHEN t.ext_source = 'football_data' THEN 0
                WHEN t.ext_source = 'football_data_uk' THEN 1
                WHEN t.ext_source = 'api_football' THEN 2
                WHEN t.ext_source = 'api_sport' THEN 3
                ELSE 9
            END,
            t.id
        LIMIT 1
    ) tan ON TRUE
),

audit AS (
    SELECT
        nc.*,

        COALESCE(nc.home_team_id_by_ext, nc.home_team_id_by_name) AS resolved_home_team_id,
        COALESCE(nc.away_team_id_by_ext, nc.away_team_id_by_name) AS resolved_away_team_id,

        CASE
            WHEN COALESCE(nc.home_team_id_by_ext, nc.home_team_id_by_name) IS NULL
             AND COALESCE(nc.away_team_id_by_ext, nc.away_team_id_by_name) IS NULL
                THEN 'BOTH_TEAMS_UNMAPPED'
            WHEN COALESCE(nc.home_team_id_by_ext, nc.home_team_id_by_name) IS NULL
                THEN 'HOME_TEAM_UNMAPPED'
            WHEN COALESCE(nc.away_team_id_by_ext, nc.away_team_id_by_name) IS NULL
                THEN 'AWAY_TEAM_UNMAPPED'
            ELSE 'BOTH_TEAMS_RESOLVED'
        END AS mapping_status
    FROM name_candidates nc
)

SELECT
    run_id,
    endpoint,
    competition_name,
    provider_league_id,
    canonical_league_id,
    canonical_league_name,
    theodds_key,

    provider_match_id,
    provider_kickoff_raw,

    provider_home_team_id,
    provider_home_team_name,
    home_team_id_by_ext,
    home_team_name_by_ext,
    home_team_id_by_name,
    home_team_name_by_name,

    provider_away_team_id,
    provider_away_team_name,
    away_team_id_by_ext,
    away_team_name_by_ext,
    away_team_id_by_name,
    away_team_name_by_name,

    resolved_home_team_id,
    resolved_away_team_id,
    mapping_status

FROM audit
WHERE mapping_status <> 'BOTH_TEAMS_RESOLVED'
ORDER BY
    competition_name,
    provider_match_id NULLS LAST,
    provider_home_team_name,
    provider_away_team_name;