# ============================================================
# build_media_trending_v1.py
# MATCHMATRIX MEDIA TRENDING ENGINE V1
# ============================================================

from __future__ import annotations

import psycopg


DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)


# ============================================================
# DECAY FORMULA
# ============================================================

DECAY_FORMULA = """
GREATEST(
    0.25,
    1.0 - (
        EXTRACT(EPOCH FROM (now() - a.created_at))
        / 86400.0
        / 7.0
    )
)
"""


# ============================================================
# TRENDING PLAYERS
# ============================================================

TRENDING_PLAYERS_SQL = f"""
INSERT INTO public.media_trending_players
(
    player_id,
    article_count,
    total_score,
    trending_score,
    updated_at
)
SELECT
    apm.player_id,

    COUNT(*) AS article_count,

    COALESCE(
        SUM(a.quality_score),
        0
    ) AS total_score,

    COALESCE(
        SUM(
            (
                10 + COALESCE(a.quality_score, 0)
            )
            *
            ({DECAY_FORMULA})
        ),
        0
    ) AS trending_score,

    now()

FROM public.article_player_map apm

JOIN public.articles a
    ON a.id = apm.article_id

GROUP BY apm.player_id

ON CONFLICT (player_id)
DO UPDATE SET
    article_count = EXCLUDED.article_count,
    total_score = EXCLUDED.total_score,
    trending_score = EXCLUDED.trending_score,
    updated_at = now();
"""


# ============================================================
# TRENDING TEAMS
# ============================================================

TRENDING_TEAMS_SQL = f"""
INSERT INTO public.media_trending_teams
(
    team_id,
    article_count,
    total_score,
    trending_score,
    updated_at
)
SELECT
    atm.team_id,

    COUNT(*) AS article_count,

    COALESCE(
        SUM(a.quality_score),
        0
    ) AS total_score,

    COALESCE(
        SUM(
            (
                10 + COALESCE(a.quality_score, 0)
            )
            *
            ({DECAY_FORMULA})
        ),
        0
    ) AS trending_score,

    now()

FROM public.article_team_map atm

JOIN public.articles a
    ON a.id = atm.article_id

GROUP BY atm.team_id

ON CONFLICT (team_id)
DO UPDATE SET
    article_count = EXCLUDED.article_count,
    total_score = EXCLUDED.total_score,
    trending_score = EXCLUDED.trending_score,
    updated_at = now();
"""


# ============================================================
# TRENDING LEAGUES
# ============================================================

TRENDING_LEAGUES_SQL = f"""
INSERT INTO public.media_trending_leagues
(
    league_id,
    article_count,
    total_score,
    trending_score,
    updated_at
)
SELECT
    alm.league_id,

    COUNT(*) AS article_count,

    COALESCE(
        SUM(a.quality_score),
        0
    ) AS total_score,

    COALESCE(
        SUM(
            (
                10 + COALESCE(a.quality_score, 0)
            )
            *
            ({DECAY_FORMULA})
        ),
        0
    ) AS trending_score,

    now()

FROM public.article_league_map alm

JOIN public.articles a
    ON a.id = alm.article_id

GROUP BY alm.league_id

ON CONFLICT (league_id)
DO UPDATE SET
    article_count = EXCLUDED.article_count,
    total_score = EXCLUDED.total_score,
    trending_score = EXCLUDED.trending_score,
    updated_at = now();
"""


# ============================================================
# MAIN
# ============================================================

def main():

    conn = psycopg.connect(DB_DSN)
    conn.autocommit = True

    print("=" * 80)
    print("MATCHMATRIX MEDIA TRENDING ENGINE V1")
    print("=" * 80)

    conn.execute(TRENDING_PLAYERS_SQL)
    print("TRENDING PLAYERS UPDATED")

    conn.execute(TRENDING_TEAMS_SQL)
    print("TRENDING TEAMS UPDATED")

    conn.execute(TRENDING_LEAGUES_SQL)
    print("TRENDING LEAGUES UPDATED")

    print("\n" + "=" * 80)
    print("DONE")
    print("=" * 80)

    conn.close()


if __name__ == "__main__":
    main()