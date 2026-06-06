# -*- coding: utf-8 -*-
"""
MATCHMATRIX 104_Z - BUILD PLAYER FORM V1

Co skript dělá:
- počítá formu hráčů z public.player_match_statistics
- bere posledních 5 a 10 zápasů hráče
- ukládá agregace do public.player_form

Kam výsledek vede:
- public.player_form

K čemu to slouží:
- player form engine
- player momentum
- fantasy scoring
- AI prediction layer

Web/app využití:
- karta hráče
- forma posledních zápasů
- hot/cold streak
- fantasy value
"""

import os
import argparse
import psycopg2
from dotenv import load_dotenv


BASE_DIR = r"C:\MatchMatrix-platform"
ENV_PATH = os.path.join(BASE_DIR, ".env")


def get_conn():
    load_dotenv(ENV_PATH)
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "postgres"),
        password=os.getenv("PGPASSWORD", ""),
    )


def build_player_form(conn, sport_id):
    sql = """
    WITH ranked AS (
        SELECT
            pms.player_id,
            m.sport_id,
            pms.match_id,
            m.kickoff AS match_at,
            pms.minutes_played,
            pms.rating,
            pms.goals,
            pms.assists,
            pms.shots_total,
            pms.key_passes,
            pms.yellow_cards,
            pms.red_cards,
            ROW_NUMBER() OVER (
                PARTITION BY pms.player_id
                ORDER BY m.kickoff DESC, pms.match_id DESC
            ) AS rn
        FROM public.player_match_statistics pms
        JOIN public.matches m
            ON m.id = pms.match_id
        WHERE m.sport_id = %(sport_id)s
    ),
    agg AS (
        SELECT
            player_id,
            sport_id,

            COUNT(*) FILTER (WHERE rn <= 5) AS matches_last_5,
            COUNT(*) FILTER (WHERE rn <= 10) AS matches_last_10,

            ROUND(AVG(rating) FILTER (WHERE rn <= 5), 2) AS avg_rating_last_5,
            ROUND(AVG(rating) FILTER (WHERE rn <= 10), 2) AS avg_rating_last_10,

            COALESCE(SUM(goals) FILTER (WHERE rn <= 5), 0) AS goals_last_5,
            COALESCE(SUM(goals) FILTER (WHERE rn <= 10), 0) AS goals_last_10,

            COALESCE(SUM(assists) FILTER (WHERE rn <= 5), 0) AS assists_last_5,
            COALESCE(SUM(assists) FILTER (WHERE rn <= 10), 0) AS assists_last_10,

            COALESCE(SUM(shots_total) FILTER (WHERE rn <= 5), 0) AS shots_last_5,
            COALESCE(SUM(shots_total) FILTER (WHERE rn <= 10), 0) AS shots_last_10,

            COALESCE(SUM(key_passes) FILTER (WHERE rn <= 5), 0) AS key_passes_last_5,
            COALESCE(SUM(key_passes) FILTER (WHERE rn <= 10), 0) AS key_passes_last_10,

            COALESCE(SUM(minutes_played) FILTER (WHERE rn <= 5), 0) AS minutes_last_5,
            COALESCE(SUM(minutes_played) FILTER (WHERE rn <= 10), 0) AS minutes_last_10,

            COALESCE(SUM(yellow_cards) FILTER (WHERE rn <= 5), 0) AS yellow_cards_last_5,
            COALESCE(SUM(red_cards) FILTER (WHERE rn <= 5), 0) AS red_cards_last_5,

            MAX(match_id) FILTER (WHERE rn = 1) AS last_match_id,
            MAX(match_at) FILTER (WHERE rn = 1) AS last_match_at
        FROM ranked
        WHERE rn <= 10
        GROUP BY player_id, sport_id
    ),
    scored AS (
        SELECT
            *,
            ROUND(
                (
                    COALESCE(avg_rating_last_5, 0) * 10
                    + goals_last_5 * 8
                    + assists_last_5 * 6
                    + shots_last_5 * 1.2
                    + key_passes_last_5 * 1.5
                    + LEAST(minutes_last_5 / 90.0, 5) * 2
                    - yellow_cards_last_5 * 1
                    - red_cards_last_5 * 4
                ),
                2
            ) AS form_score,

            ROUND(
                (
                    COALESCE(avg_rating_last_5, 0) * 10
                    - COALESCE(avg_rating_last_10, 0) * 8
                    + goals_last_5 * 5
                    + assists_last_5 * 4
                ),
                2
            ) AS momentum_score
        FROM agg
    )
    INSERT INTO public.player_form (
        player_id,
        sport_id,
        matches_last_5,
        matches_last_10,
        avg_rating_last_5,
        avg_rating_last_10,
        goals_last_5,
        goals_last_10,
        assists_last_5,
        assists_last_10,
        shots_last_5,
        shots_last_10,
        key_passes_last_5,
        key_passes_last_10,
        minutes_last_5,
        minutes_last_10,
        yellow_cards_last_5,
        red_cards_last_5,
        form_score,
        momentum_score,
        last_match_id,
        last_match_at,
        created_at,
        updated_at
    )
    SELECT
        player_id,
        sport_id,
        matches_last_5,
        matches_last_10,
        avg_rating_last_5,
        avg_rating_last_10,
        goals_last_5,
        goals_last_10,
        assists_last_5,
        assists_last_10,
        shots_last_5,
        shots_last_10,
        key_passes_last_5,
        key_passes_last_10,
        minutes_last_5,
        minutes_last_10,
        yellow_cards_last_5,
        red_cards_last_5,
        form_score,
        momentum_score,
        last_match_id,
        last_match_at,
        now(),
        now()
    FROM scored
    ON CONFLICT (player_id)
    DO UPDATE SET
        sport_id = EXCLUDED.sport_id,
        matches_last_5 = EXCLUDED.matches_last_5,
        matches_last_10 = EXCLUDED.matches_last_10,
        avg_rating_last_5 = EXCLUDED.avg_rating_last_5,
        avg_rating_last_10 = EXCLUDED.avg_rating_last_10,
        goals_last_5 = EXCLUDED.goals_last_5,
        goals_last_10 = EXCLUDED.goals_last_10,
        assists_last_5 = EXCLUDED.assists_last_5,
        assists_last_10 = EXCLUDED.assists_last_10,
        shots_last_5 = EXCLUDED.shots_last_5,
        shots_last_10 = EXCLUDED.shots_last_10,
        key_passes_last_5 = EXCLUDED.key_passes_last_5,
        key_passes_last_10 = EXCLUDED.key_passes_last_10,
        minutes_last_5 = EXCLUDED.minutes_last_5,
        minutes_last_10 = EXCLUDED.minutes_last_10,
        yellow_cards_last_5 = EXCLUDED.yellow_cards_last_5,
        red_cards_last_5 = EXCLUDED.red_cards_last_5,
        form_score = EXCLUDED.form_score,
        momentum_score = EXCLUDED.momentum_score,
        last_match_id = EXCLUDED.last_match_id,
        last_match_at = EXCLUDED.last_match_at,
        updated_at = now();
    """

    with conn.cursor() as cur:
        cur.execute(sql, {"sport_id": sport_id})

    conn.commit()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--sport-id", type=int, default=1)
    args = parser.parse_args()

    print("=" * 80)
    print("MATCHMATRIX PLAYER FORM BUILDER V1")
    print("=" * 80)
    print(f"SPORT ID: {args.sport_id}")

    conn = get_conn()

    try:
        build_player_form(conn, args.sport_id)
        print("DONE")
    finally:
        conn.close()


if __name__ == "__main__":
    main()