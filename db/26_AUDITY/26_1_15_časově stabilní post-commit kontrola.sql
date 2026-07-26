ROLLBACK;

BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY;

SET LOCAL statement_timeout = '120s';
SET LOCAL lock_timeout = '5s';
SET LOCAL TIME ZONE 'UTC';

-------------------------------------------------------------------------------
-- 1. DATOVÉ TYPY A ČASOVÉ PÁSMO
-------------------------------------------------------------------------------

SELECT
    current_setting('TimeZone') AS audit_timezone,

    (
        SELECT data_type
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'matches'
          AND column_name = 'kickoff'
    ) AS matches_kickoff_type,

    (
        SELECT data_type
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'mm_match_ratings'
          AND column_name = 'kickoff'
    ) AS ratings_kickoff_type;

-------------------------------------------------------------------------------
-- 2. UTC-STABILNÍ KONTROLA VŠECH CÍLOVÝCH DIMENZÍ
-------------------------------------------------------------------------------

WITH transfer_plan AS
(
    SELECT DISTINCT
        (metadata ->> 'previous_match_id')::bigint
            AS previous_match_id,

        (metadata ->> 'target_match_id')::bigint
            AS target_match_id

    FROM public.match_provider_map

    WHERE metadata ->> 'belgium_identity_transfer'
          = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1'
),
audit AS
(
    SELECT
        plan.previous_match_id,
        plan.target_match_id,

        ratings.match_id AS rating_match_id,

        ratings.league_id AS rating_league_id,
        target_match.league_id AS target_league_id,

        ratings.kickoff AS rating_kickoff,
        target_match.kickoff AS target_kickoff,

        ratings.home_team_id AS rating_home_team_id,
        target_match.home_team_id AS target_home_team_id,

        ratings.away_team_id AS rating_away_team_id,
        target_match.away_team_id AS target_away_team_id

    FROM transfer_plan plan

    LEFT JOIN public.mm_match_ratings ratings
      ON ratings.match_id = plan.target_match_id

    LEFT JOIN public.matches target_match
      ON target_match.id = plan.target_match_id
)
SELECT
    COUNT(*) AS transfer_pairs,

    COUNT(*) FILTER (
        WHERE rating_match_id IS NOT NULL
    ) AS target_rating_rows,

    COUNT(*) FILTER (
        WHERE rating_league_id = target_league_id
    ) AS league_aligned,

    COUNT(*) FILTER (
        WHERE rating_home_team_id = target_home_team_id
    ) AS home_team_aligned,

    COUNT(*) FILTER (
        WHERE rating_away_team_id = target_away_team_id
    ) AS away_team_aligned,

    COUNT(*) FILTER (
        WHERE rating_kickoff = target_kickoff
    ) AS kickoff_aligned_in_utc_session,

    COUNT(*) FILTER (
        WHERE rating_kickoff =
              target_kickoff::timestamp
              AT TIME ZONE 'UTC'
    ) AS kickoff_aligned_explicit_utc,

    COUNT(*) FILTER (
        WHERE rating_league_id = target_league_id
          AND rating_kickoff =
              target_kickoff::timestamp
              AT TIME ZONE 'UTC'
          AND rating_home_team_id = target_home_team_id
          AND rating_away_team_id = target_away_team_id
    ) AS fully_aligned_explicit_utc

FROM audit;

-------------------------------------------------------------------------------
-- 3. ROZDÍL ČASŮ V MINUTÁCH
-------------------------------------------------------------------------------

WITH transfer_plan AS
(
    SELECT DISTINCT
        (metadata ->> 'target_match_id')::bigint
            AS target_match_id

    FROM public.match_provider_map

    WHERE metadata ->> 'belgium_identity_transfer'
          = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1'
)
SELECT
    EXTRACT(
        EPOCH FROM
        (
            ratings.kickoff
            -
            (
                target_match.kickoff::timestamp
                AT TIME ZONE 'UTC'
            )
        )
    ) / 60.0 AS utc_difference_minutes,

    COUNT(*) AS row_count

FROM transfer_plan plan

JOIN public.mm_match_ratings ratings
  ON ratings.match_id = plan.target_match_id

JOIN public.matches target_match
  ON target_match.id = plan.target_match_id

GROUP BY 1
ORDER BY 1;

-------------------------------------------------------------------------------
-- 4. KONEČNÝ STAV
-------------------------------------------------------------------------------

WITH transfer_plan AS
(
    SELECT DISTINCT
        (metadata ->> 'target_match_id')::bigint
            AS target_match_id

    FROM public.match_provider_map

    WHERE metadata ->> 'belgium_identity_transfer'
          = 'BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1'
),
checks AS
(
    SELECT
        COUNT(*) AS target_rows,

        COUNT(*) FILTER (
            WHERE ratings.league_id = target_match.league_id
              AND ratings.kickoff =
                  target_match.kickoff::timestamp
                  AT TIME ZONE 'UTC'
              AND ratings.home_team_id = target_match.home_team_id
              AND ratings.away_team_id = target_match.away_team_id
        ) AS fully_aligned_rows

    FROM transfer_plan plan

    JOIN public.mm_match_ratings ratings
      ON ratings.match_id = plan.target_match_id

    JOIN public.matches target_match
      ON target_match.id = plan.target_match_id
)
SELECT
    CASE
        WHEN target_rows = 927
         AND fully_aligned_rows = 927
        THEN
            'APPLY_OK – 927 DOWNSTREAM VAZEB TRVALE PŘEVEDENO; PŮVODNÍ VAROVÁNÍ ZPŮSOBILO ČASOVÉ PÁSMO'

        ELSE
            'REVIEW_REQUIRED – UTC-STABILNÍ KONTROLA NEPOTVRDILA VŠECH 927 ŘÁDKŮ'
    END AS final_status,

    target_rows,
    fully_aligned_rows

FROM checks;

ROLLBACK;