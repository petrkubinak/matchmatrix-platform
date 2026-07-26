/*
===============================================================================
MATCHMATRIX – BELGIUM JUPILER PRO LEAGUE
READ ONLY – MM_MATCH_RATINGS SEMANTIC ALIGNMENT AUDIT V1
===============================================================================

CO:
- Porovná 927 řádků public.mm_match_ratings:
    1. s původním historickým zápasem,
    2. s cílovým kanonickým zápasem API-Football.

K ČEMU:
- Rozhodne, zda při migraci stačí změnit pouze match_id,
  nebo zda musí být současně sjednoceny:
    league_id,
    kickoff,
    home_team_id,
    away_team_id.

BEZPEČNOST:
- READ ONLY.
- Bez dočasných tabulek.
- Bez změn produkčních dat.
===============================================================================
*/

ROLLBACK;

BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '180s';
SET LOCAL client_min_messages = 'notice';
SET LOCAL TIME ZONE 'UTC';

-------------------------------------------------------------------------------
-- 1. PROSTŘEDÍ
-------------------------------------------------------------------------------

SELECT
    current_database() AS database_name,
    current_user AS database_user,
    current_setting('transaction_isolation') AS transaction_isolation,
    current_setting('transaction_read_only') AS transaction_read_only,
    current_setting('TimeZone') AS session_timezone,
    clock_timestamp() AS audit_started_at;

-------------------------------------------------------------------------------
-- 2. KONTROLA MIGRAČNÍHO PLÁNU
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
)
SELECT
    COUNT(*) AS transfer_pairs,
    COUNT(DISTINCT previous_match_id) AS distinct_previous_matches,
    COUNT(DISTINCT target_match_id) AS distinct_target_matches,
    COUNT(*) FILTER (
        WHERE previous_match_id = target_match_id
    ) AS invalid_same_match_pairs
FROM transfer_plan;

-------------------------------------------------------------------------------
-- 3. POKRYTÍ OBOU DOTČENÝCH TABULEK
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
)
SELECT
    'public.match_features' AS table_name,

    COUNT(*) FILTER (
        WHERE previous_row.match_id IS NOT NULL
    ) AS previous_rows,

    COUNT(*) FILTER (
        WHERE target_row.match_id IS NOT NULL
    ) AS target_rows

FROM transfer_plan plan

LEFT JOIN public.match_features previous_row
  ON previous_row.match_id = plan.previous_match_id

LEFT JOIN public.match_features target_row
  ON target_row.match_id = plan.target_match_id

UNION ALL

SELECT
    'public.mm_match_ratings',

    COUNT(*) FILTER (
        WHERE previous_row.match_id IS NOT NULL
    ),

    COUNT(*) FILTER (
        WHERE target_row.match_id IS NOT NULL
    )

FROM transfer_plan plan

LEFT JOIN public.mm_match_ratings previous_row
  ON previous_row.match_id = plan.previous_match_id

LEFT JOIN public.mm_match_ratings target_row
  ON target_row.match_id = plan.target_match_id;

-------------------------------------------------------------------------------
-- 4. SÉMANTICKÉ POROVNÁNÍ RATINGŮ
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
rating_audit AS
(
    SELECT
        plan.previous_match_id,
        plan.target_match_id,

        rating.match_id AS rating_match_id,

        rating.league_id AS rating_league_id,
        previous_match.league_id AS previous_league_id,
        target_match.league_id AS target_league_id,

        rating.kickoff AS rating_kickoff,
        previous_match.kickoff AS previous_kickoff,
        target_match.kickoff AS target_kickoff,

        rating.home_team_id AS rating_home_team_id,
        previous_match.home_team_id AS previous_home_team_id,
        target_match.home_team_id AS target_home_team_id,

        rating.away_team_id AS rating_away_team_id,
        previous_match.away_team_id AS previous_away_team_id,
        target_match.away_team_id AS target_away_team_id,

        target_rating.match_id AS existing_target_rating_id

    FROM transfer_plan plan

    LEFT JOIN public.matches previous_match
      ON previous_match.id = plan.previous_match_id

    LEFT JOIN public.matches target_match
      ON target_match.id = plan.target_match_id

    LEFT JOIN public.mm_match_ratings rating
      ON rating.match_id = plan.previous_match_id

    LEFT JOIN public.mm_match_ratings target_rating
      ON target_rating.match_id = plan.target_match_id
)
SELECT
    COUNT(*) AS transfer_pairs,

    COUNT(*) FILTER (
        WHERE rating_match_id IS NOT NULL
    ) AS previous_rating_rows,

    COUNT(*) FILTER (
        WHERE existing_target_rating_id IS NOT NULL
    ) AS existing_target_rating_rows,

    COUNT(*) FILTER (
        WHERE rating_league_id = previous_league_id
    ) AS league_matches_previous,

    COUNT(*) FILTER (
        WHERE rating_kickoff = previous_kickoff
    ) AS kickoff_matches_previous,

    COUNT(*) FILTER (
        WHERE rating_home_team_id = previous_home_team_id
    ) AS home_team_matches_previous,

    COUNT(*) FILTER (
        WHERE rating_away_team_id = previous_away_team_id
    ) AS away_team_matches_previous,

    COUNT(*) FILTER (
        WHERE rating_league_id = target_league_id
    ) AS league_already_matches_target,

    COUNT(*) FILTER (
        WHERE rating_kickoff = target_kickoff
    ) AS kickoff_already_matches_target,

    COUNT(*) FILTER (
        WHERE rating_home_team_id = target_home_team_id
    ) AS home_team_already_matches_target,

    COUNT(*) FILTER (
        WHERE rating_away_team_id = target_away_team_id
    ) AS away_team_already_matches_target,

    COUNT(*) FILTER (
        WHERE rating_league_id = previous_league_id
          AND rating_kickoff = previous_kickoff
          AND rating_home_team_id = previous_home_team_id
          AND rating_away_team_id = previous_away_team_id
    ) AS fully_consistent_with_previous_match,

    COUNT(*) FILTER (
        WHERE rating_league_id = target_league_id
          AND rating_kickoff = target_kickoff
          AND rating_home_team_id = target_home_team_id
          AND rating_away_team_id = target_away_team_id
    ) AS fully_consistent_with_target_match

FROM rating_audit;

-------------------------------------------------------------------------------
-- 5. PŘESNÉ TYPY ROZDÍLŮ PROTI CÍLOVÉMU ZÁPASU
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
rating_audit AS
(
    SELECT
        rating.league_id AS rating_league_id,
        target_match.league_id AS target_league_id,

        rating.kickoff AS rating_kickoff,
        target_match.kickoff AS target_kickoff,

        rating.home_team_id AS rating_home_team_id,
        target_match.home_team_id AS target_home_team_id,

        rating.away_team_id AS rating_away_team_id,
        target_match.away_team_id AS target_away_team_id

    FROM transfer_plan plan

    JOIN public.matches target_match
      ON target_match.id = plan.target_match_id

    JOIN public.mm_match_ratings rating
      ON rating.match_id = plan.previous_match_id
)
SELECT
    CASE
        WHEN rating_league_id = target_league_id
         AND rating_kickoff = target_kickoff
         AND rating_home_team_id = target_home_team_id
         AND rating_away_team_id = target_away_team_id
            THEN 'ALL_TARGET_DIMENSIONS_ALREADY_MATCH'

        WHEN rating_league_id <> target_league_id
         AND rating_kickoff = target_kickoff
         AND rating_home_team_id <> target_home_team_id
         AND rating_away_team_id <> target_away_team_id
            THEN 'LEAGUE_AND_TEAMS_DIFFER_KICKOFF_MATCHES'

        WHEN rating_kickoff <> target_kickoff
            THEN 'KICKOFF_DIFFERS'

        ELSE 'OTHER_DIMENSION_COMBINATION'
    END AS dimension_difference_type,

    COUNT(*) AS row_count

FROM rating_audit

GROUP BY 1
ORDER BY row_count DESC, dimension_difference_type;

-------------------------------------------------------------------------------
-- 6. KONTROLNÍ VZOREK 20 ŘÁDKŮ
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
)
SELECT
    plan.previous_match_id,
    plan.target_match_id,

    rating.league_id AS current_rating_league_id,
    target_match.league_id AS target_league_id,

    rating.kickoff AS current_rating_kickoff,
    target_match.kickoff AS target_kickoff,

    rating.home_team_id AS current_rating_home_team_id,
    target_match.home_team_id AS target_home_team_id,

    rating.away_team_id AS current_rating_away_team_id,
    target_match.away_team_id AS target_away_team_id

FROM transfer_plan plan

JOIN public.mm_match_ratings rating
  ON rating.match_id = plan.previous_match_id

JOIN public.matches target_match
  ON target_match.id = plan.target_match_id

ORDER BY plan.previous_match_id

LIMIT 20;

-------------------------------------------------------------------------------
-- 7. KONEČNÉ ROZHODNUTÍ
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
rating_audit AS
(
    SELECT
        plan.previous_match_id,
        plan.target_match_id,

        rating.match_id AS rating_match_id,
        target_rating.match_id AS target_rating_match_id,

        rating.league_id AS rating_league_id,
        previous_match.league_id AS previous_league_id,
        target_match.league_id AS target_league_id,

        rating.kickoff AS rating_kickoff,
        previous_match.kickoff AS previous_kickoff,
        target_match.kickoff AS target_kickoff,

        rating.home_team_id AS rating_home_team_id,
        previous_match.home_team_id AS previous_home_team_id,
        target_match.home_team_id AS target_home_team_id,

        rating.away_team_id AS rating_away_team_id,
        previous_match.away_team_id AS previous_away_team_id,
        target_match.away_team_id AS target_away_team_id

    FROM transfer_plan plan

    LEFT JOIN public.matches previous_match
      ON previous_match.id = plan.previous_match_id

    LEFT JOIN public.matches target_match
      ON target_match.id = plan.target_match_id

    LEFT JOIN public.mm_match_ratings rating
      ON rating.match_id = plan.previous_match_id

    LEFT JOIN public.mm_match_ratings target_rating
      ON target_rating.match_id = plan.target_match_id
),
summary AS
(
    SELECT
        COUNT(*) AS plan_rows,

        COUNT(*) FILTER (
            WHERE rating_match_id IS NOT NULL
        ) AS previous_rating_rows,

        COUNT(*) FILTER (
            WHERE target_rating_match_id IS NOT NULL
        ) AS existing_target_rating_rows,

        COUNT(*) FILTER (
            WHERE rating_league_id = previous_league_id
              AND rating_kickoff = previous_kickoff
              AND rating_home_team_id = previous_home_team_id
              AND rating_away_team_id = previous_away_team_id
        ) AS consistent_with_previous,

        COUNT(*) FILTER (
            WHERE rating_league_id = target_league_id
              AND rating_kickoff = target_kickoff
              AND rating_home_team_id = target_home_team_id
              AND rating_away_team_id = target_away_team_id
        ) AS already_consistent_with_target

    FROM rating_audit
)
SELECT
    plan_rows,
    previous_rating_rows,
    existing_target_rating_rows,
    consistent_with_previous,
    already_consistent_with_target,

    CASE
        WHEN plan_rows <> 927
            THEN 'SEMANTIC_AUDIT_FAILED – MIGRAČNÍ PLÁN NEMÁ 927 DVOJIC'

        WHEN previous_rating_rows <> 927
            THEN 'SEMANTIC_AUDIT_FAILED – CHYBÍ PŮVODNÍ RATINGOVÉ ŘÁDKY'

        WHEN existing_target_rating_rows <> 0
            THEN 'SEMANTIC_AUDIT_REVIEW_REQUIRED – CÍLOVÉ RATINGY JIŽ EXISTUJÍ'

        WHEN consistent_with_previous <> 927
            THEN 'SEMANTIC_AUDIT_REVIEW_REQUIRED – RATINGY NEODPOVÍDAJÍ PŮVODNÍM ZÁPASŮM'

        WHEN already_consistent_with_target = 927
            THEN 'SEMANTIC_AUDIT_OK – STAČÍ ZMĚNIT MATCH_ID'

        ELSE
            'SEMANTIC_AUDIT_OK – ZMĚNIT MATCH_ID A SROVNAT DIMENZE PODLE CÍLOVÉHO ZÁPASU'
    END AS audit_status

FROM summary;

ROLLBACK;