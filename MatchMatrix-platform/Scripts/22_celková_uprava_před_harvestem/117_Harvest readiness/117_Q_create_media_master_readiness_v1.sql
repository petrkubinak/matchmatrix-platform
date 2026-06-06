/*
MATCHMATRIX SQL 117_Q
MEDIA MASTER READINESS V1

CO TO JE:
- Master audit připravenosti MEDIA vrstvy.
- Vyhodnocuje články, videa, kvalitu, feed eligibility, mapování na ligy/týmy/hráče/zápasy a trending.

K ČEMU TO JE:
- Ukáže, jestli je MEDIA vrstva použitelná pro web.
- Ukáže, kde chybí linking, videa, kvalita nebo zdroje.

KDE TO UVIDÍME:
- OPS Panel -> MEDIA
- OPS Panel -> HARVEST
- Budoucí web -> homepage feed, detail týmu, detail hráče, detail zápasu.

JAK SE TO VYUŽIJE:
- Pro řízení media ingestu.
- Pro přípravu webového obsahu.
- Pro rozhodnutí, který sport má dost obsahu pro veřejný web.
*/

CREATE OR REPLACE VIEW ops.v_media_master_readiness_v1 AS
WITH article_base AS (
    SELECT
        COALESCE(s.code, 'UNKNOWN') AS sport_code,
        COALESCE(s.name, 'Unknown') AS sport_name,
        a.id AS article_id,
        a.is_video,
        a.video_url,
        a.thumbnail_url,
        a.published_at,
        a.is_feed_eligible,
        a.quality_score,
        a.article_quality_score,
        a.hot_score
    FROM public.articles a
    LEFT JOIN public.article_league_map alm
        ON alm.article_id = a.id
    LEFT JOIN public.leagues l
        ON l.id = alm.league_id
    LEFT JOIN public.sports s
        ON s.id = l.sport_id
),
article_by_sport AS (
    SELECT
        sport_code,
        sport_name,
        COUNT(DISTINCT article_id) AS articles_count,
        COUNT(DISTINCT article_id) FILTER (
            WHERE COALESCE(is_video,false) = true
               OR video_url IS NOT NULL
        ) AS videos_count,
        COUNT(DISTINCT article_id) FILTER (
            WHERE thumbnail_url IS NOT NULL
              AND trim(thumbnail_url) <> ''
        ) AS articles_with_thumbnail,
        COUNT(DISTINCT article_id) FILTER (
            WHERE published_at IS NOT NULL
        ) AS articles_with_published_at,
        COUNT(DISTINCT article_id) FILTER (
            WHERE COALESCE(is_feed_eligible,false) = true
        ) AS feed_eligible_articles,
        COUNT(DISTINCT article_id) FILTER (
            WHERE COALESCE(article_quality_score, quality_score, 0) >= 70
        ) AS quality_70_plus_articles,
        ROUND(AVG(COALESCE(article_quality_score, quality_score, 0)), 2) AS avg_quality_score,
        ROUND(AVG(COALESCE(hot_score, 0)), 2) AS avg_hot_score
    FROM article_base
    GROUP BY sport_code, sport_name
),
league_links AS (
    SELECT
        s.code AS sport_code,
        COUNT(DISTINCT alm.article_id) AS league_linked_articles
    FROM public.article_league_map alm
    JOIN public.leagues l
        ON l.id = alm.league_id
    JOIN public.sports s
        ON s.id = l.sport_id
    GROUP BY s.code
),
team_links AS (
    SELECT
        s.code AS sport_code,
        COUNT(DISTINCT atm.article_id) AS team_linked_articles
    FROM public.article_team_map atm
    JOIN public.teams t
        ON t.id = atm.team_id
    JOIN public.sports s
        ON s.id = t.sport_id
    GROUP BY s.code
),
player_links AS (
    SELECT
        s.code AS sport_code,
        COUNT(DISTINCT apm.article_id) AS player_linked_articles
    FROM public.article_player_map apm
    JOIN public.players p
        ON p.id = apm.player_id
    JOIN public.sports s
        ON s.id = p.sport_id
    GROUP BY s.code
),
match_links AS (
    SELECT
        s.code AS sport_code,
        COUNT(DISTINCT amm.article_id) AS match_linked_articles
    FROM public.article_match_map amm
    JOIN public.matches m
        ON m.id = amm.match_id
    JOIN public.sports s
        ON s.id = m.sport_id
    GROUP BY s.code
),
trending_leagues AS (
    SELECT
        s.code AS sport_code,
        COUNT(*) AS trending_leagues_count
    FROM public.media_trending_leagues mtl
    JOIN public.leagues l
        ON l.id = mtl.league_id
    JOIN public.sports s
        ON s.id = l.sport_id
    GROUP BY s.code
),
trending_teams AS (
    SELECT
        s.code AS sport_code,
        COUNT(*) AS trending_teams_count
    FROM public.media_trending_teams mtt
    JOIN public.teams t
        ON t.id = mtt.team_id
    JOIN public.sports s
        ON s.id = t.sport_id
    GROUP BY s.code
),
trending_players AS (
    SELECT
        s.code AS sport_code,
        COUNT(*) AS trending_players_count
    FROM public.media_trending_players mtp
    JOIN public.players p
        ON p.id = mtp.player_id
    JOIN public.sports s
        ON s.id = p.sport_id
    GROUP BY s.code
),
sports AS (
    SELECT
        code AS sport_code,
        name AS sport_name
    FROM public.sports
    WHERE is_active = true
),
base AS (
    SELECT
        sp.sport_code,
        sp.sport_name,

        COALESCE(a.articles_count, 0) AS articles_count,
        COALESCE(a.videos_count, 0) AS videos_count,
        COALESCE(a.articles_with_thumbnail, 0) AS articles_with_thumbnail,
        COALESCE(a.articles_with_published_at, 0) AS articles_with_published_at,
        COALESCE(a.feed_eligible_articles, 0) AS feed_eligible_articles,
        COALESCE(a.quality_70_plus_articles, 0) AS quality_70_plus_articles,
        COALESCE(a.avg_quality_score, 0) AS avg_quality_score,
        COALESCE(a.avg_hot_score, 0) AS avg_hot_score,

        COALESCE(ll.league_linked_articles, 0) AS league_linked_articles,
        COALESCE(tl.team_linked_articles, 0) AS team_linked_articles,
        COALESCE(pl.player_linked_articles, 0) AS player_linked_articles,
        COALESCE(ml.match_linked_articles, 0) AS match_linked_articles,

        COALESCE(trg_l.trending_leagues_count, 0) AS trending_leagues_count,
        COALESCE(trg_t.trending_teams_count, 0) AS trending_teams_count,
        COALESCE(trg_p.trending_players_count, 0) AS trending_players_count

    FROM sports sp
    LEFT JOIN article_by_sport a ON a.sport_code = sp.sport_code
    LEFT JOIN league_links ll ON ll.sport_code = sp.sport_code
    LEFT JOIN team_links tl ON tl.sport_code = sp.sport_code
    LEFT JOIN player_links pl ON pl.sport_code = sp.sport_code
    LEFT JOIN match_links ml ON ml.sport_code = sp.sport_code
    LEFT JOIN trending_leagues trg_l ON trg_l.sport_code = sp.sport_code
    LEFT JOIN trending_teams trg_t ON trg_t.sport_code = sp.sport_code
    LEFT JOIN trending_players trg_p ON trg_p.sport_code = sp.sport_code
)
SELECT
    sport_code,
    sport_name,

    articles_count,
    videos_count,
    articles_with_thumbnail,
    articles_with_published_at,
    feed_eligible_articles,
    quality_70_plus_articles,

    league_linked_articles,
    team_linked_articles,
    player_linked_articles,
    match_linked_articles,

    trending_leagues_count,
    trending_teams_count,
    trending_players_count,

    avg_quality_score,
    avg_hot_score,

    ROUND(
        CASE WHEN articles_count > 0
        THEN (feed_eligible_articles::numeric / articles_count::numeric) * 100
        ELSE 0 END,
        2
    ) AS feed_eligible_pct,

    ROUND(
        CASE WHEN articles_count > 0
        THEN (quality_70_plus_articles::numeric / articles_count::numeric) * 100
        ELSE 0 END,
        2
    ) AS quality_70_plus_pct,

    ROUND(
        CASE WHEN articles_count > 0
        THEN (league_linked_articles::numeric / articles_count::numeric) * 100
        ELSE 0 END,
        2
    ) AS league_link_pct,

    ROUND(
        CASE WHEN articles_count > 0
        THEN (team_linked_articles::numeric / articles_count::numeric) * 100
        ELSE 0 END,
        2
    ) AS team_link_pct,

    ROUND(
        CASE WHEN articles_count > 0
        THEN (player_linked_articles::numeric / articles_count::numeric) * 100
        ELSE 0 END,
        2
    ) AS player_link_pct,

    ROUND(
        CASE WHEN articles_count > 0
        THEN (match_linked_articles::numeric / articles_count::numeric) * 100
        ELSE 0 END,
        2
    ) AS match_link_pct,

    LEAST(
        100,
        (
            CASE WHEN articles_count > 0 THEN 20 ELSE 0 END
            +
            CASE WHEN feed_eligible_articles > 0 THEN 15 ELSE 0 END
            +
            CASE WHEN quality_70_plus_articles > 0 THEN 15 ELSE 0 END
            +
            CASE WHEN league_linked_articles > 0 THEN 10 ELSE 0 END
            +
            CASE WHEN team_linked_articles > 0 THEN 10 ELSE 0 END
            +
            CASE WHEN player_linked_articles > 0 THEN 10 ELSE 0 END
            +
            CASE WHEN match_linked_articles > 0 THEN 10 ELSE 0 END
            +
            CASE WHEN videos_count > 0 THEN 5 ELSE 0 END
            +
            CASE WHEN (
                trending_leagues_count
                + trending_teams_count
                + trending_players_count
            ) > 0 THEN 5 ELSE 0 END
        )
    ) AS media_master_score,

    CASE
        WHEN articles_count = 0 THEN 'MEDIA_GAP'
        WHEN feed_eligible_articles = 0 THEN 'FEED_GAP'
        WHEN quality_70_plus_articles = 0 THEN 'QUALITY_GAP'
        WHEN league_linked_articles = 0
          AND team_linked_articles = 0
          AND player_linked_articles = 0
          AND match_linked_articles = 0 THEN 'LINKING_GAP'
        WHEN match_linked_articles = 0 THEN 'MATCH_LINK_GAP'
        WHEN videos_count = 0 THEN 'VIDEO_GAP'
        WHEN LEAST(
            100,
            (
                CASE WHEN articles_count > 0 THEN 20 ELSE 0 END
                +
                CASE WHEN feed_eligible_articles > 0 THEN 15 ELSE 0 END
                +
                CASE WHEN quality_70_plus_articles > 0 THEN 15 ELSE 0 END
                +
                CASE WHEN league_linked_articles > 0 THEN 10 ELSE 0 END
                +
                CASE WHEN team_linked_articles > 0 THEN 10 ELSE 0 END
                +
                CASE WHEN player_linked_articles > 0 THEN 10 ELSE 0 END
                +
                CASE WHEN match_linked_articles > 0 THEN 10 ELSE 0 END
                +
                CASE WHEN videos_count > 0 THEN 5 ELSE 0 END
                +
                CASE WHEN (
                    trending_leagues_count
                    + trending_teams_count
                    + trending_players_count
                ) > 0 THEN 5 ELSE 0 END
            )
        ) >= 80 THEN 'READY'
        WHEN LEAST(
            100,
            (
                CASE WHEN articles_count > 0 THEN 20 ELSE 0 END
                +
                CASE WHEN feed_eligible_articles > 0 THEN 15 ELSE 0 END
                +
                CASE WHEN quality_70_plus_articles > 0 THEN 15 ELSE 0 END
                +
                CASE WHEN league_linked_articles > 0 THEN 10 ELSE 0 END
                +
                CASE WHEN team_linked_articles > 0 THEN 10 ELSE 0 END
                +
                CASE WHEN player_linked_articles > 0 THEN 10 ELSE 0 END
                +
                CASE WHEN match_linked_articles > 0 THEN 10 ELSE 0 END
                +
                CASE WHEN videos_count > 0 THEN 5 ELSE 0 END
                +
                CASE WHEN (
                    trending_leagues_count
                    + trending_teams_count
                    + trending_players_count
                ) > 0 THEN 5 ELSE 0 END
            )
        ) >= 50 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END AS media_master_status,

    CASE
        WHEN articles_count = 0 THEN 'Najít nebo napojit media zdroj pro tento sport.'
        WHEN feed_eligible_articles = 0 THEN 'Zlepšit parsing a feed eligibility článků.'
        WHEN quality_70_plus_articles = 0 THEN 'Zlepšit kvalitu článků, summary, raw_text a AI scoring.'
        WHEN league_linked_articles = 0
          AND team_linked_articles = 0
          AND player_linked_articles = 0
          AND match_linked_articles = 0 THEN 'Doplnit entity matcher pro ligy, týmy, hráče a zápasy.'
        WHEN match_linked_articles = 0 THEN 'Doplnit article_match_map / match linking.'
        WHEN videos_count = 0 THEN 'Najít nebo napojit video/highlights zdroj.'
        ELSE 'MEDIA vrstva je použitelná, pokračovat rozšiřováním zdrojů a kvality.'
    END AS recommendation_cz,

    now() AS generated_at

FROM base
ORDER BY
    media_master_score DESC,
    sport_code;