# -*- coding: utf-8 -*-
"""
MATCHMATRIX 104_S - BUILD FB PLAYER MATCH STATS QUEUE V1

Co skript dělá:
- hledá hotové FB zápasy v public.matches
- kontroluje, zda už mají záznamy v public.player_match_statistics
- chybějící zápasy vloží do ops.fixture_player_stats_queue

Kam výsledek vede:
- ops.fixture_player_stats_queue

K čemu to bude sloužit:
- automatické stahování API-Football /fixtures/players
- naplnění public.player_match_statistics

Jak se využije na webu/aplikaci:
- detail hráče v zápase
- player form engine
- fantasy scoring
- AI prediction layer
- player momentum
"""

import os
import sys
import argparse
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv


BASE_DIR = r"C:\MatchMatrix-platform"
ENV_PATH = os.path.join(BASE_DIR, ".env")

PROVIDER = "api_football"
SPORT_CODE = "FB"
SPORT_ID = 1
ENTITY = "fixture_player_stats"
RUN_GROUP = "FB_PLAYER_MATCH_STATS_DAILY"


def get_conn():
    load_dotenv(ENV_PATH)

    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "postgres"),
        password=os.getenv("PGPASSWORD", ""),
    )


def ensure_queue_table(conn):
    sql = """
    CREATE SCHEMA IF NOT EXISTS ops;

    CREATE TABLE IF NOT EXISTS ops.fixture_player_stats_queue (
        id BIGSERIAL PRIMARY KEY,
        provider TEXT NOT NULL,
        sport_code TEXT NOT NULL,
        sport_id INTEGER NOT NULL,
        entity TEXT NOT NULL,
        match_id BIGINT NOT NULL,
        provider_fixture_id TEXT NOT NULL,
        league_id BIGINT NULL,
        season TEXT NULL,
        kickoff TIMESTAMP NULL,
        run_group TEXT NOT NULL,
        priority INTEGER NOT NULL DEFAULT 50,
        status TEXT NOT NULL DEFAULT 'pending',
        attempts INTEGER NOT NULL DEFAULT 0,
        last_attempt TIMESTAMPTZ NULL,
        next_run TIMESTAMPTZ NULL DEFAULT now(),
        result_message TEXT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
        UNIQUE(provider, provider_fixture_id)
    );

    CREATE INDEX IF NOT EXISTS idx_fixture_player_stats_queue_status
        ON ops.fixture_player_stats_queue(status, priority, next_run);

    CREATE INDEX IF NOT EXISTS idx_fixture_player_stats_queue_match
        ON ops.fixture_player_stats_queue(match_id);

    CREATE INDEX IF NOT EXISTS idx_fixture_player_stats_queue_provider_fixture
        ON ops.fixture_player_stats_queue(provider, provider_fixture_id);
    """

    with conn.cursor() as cur:
        cur.execute(sql)

    conn.commit()


def build_queue(conn, limit):
    sql = """
    WITH candidates AS (
        SELECT
            m.id AS match_id,
            m.ext_match_id AS provider_fixture_id,
            m.league_id,
            m.season,
            m.kickoff
        FROM public.matches m
        WHERE m.sport_id = %(sport_id)s
          AND m.ext_source = %(provider)s
          AND m.status = 'FINISHED'
          AND m.ext_match_id IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM public.player_match_statistics pms
              WHERE pms.match_id = m.id
          )
          AND NOT EXISTS (
              SELECT 1
              FROM ops.fixture_player_stats_queue q
              WHERE q.provider = %(provider)s
                AND q.provider_fixture_id = m.ext_match_id
                AND q.status IN ('pending', 'running', 'done')
          )
        ORDER BY m.kickoff DESC NULLS LAST
        LIMIT %(limit)s
    )
    INSERT INTO ops.fixture_player_stats_queue (
        provider,
        sport_code,
        sport_id,
        entity,
        match_id,
        provider_fixture_id,
        league_id,
        season,
        kickoff,
        run_group,
        priority,
        status,
        next_run
    )
    SELECT
        %(provider)s,
        %(sport_code)s,
        %(sport_id)s,
        %(entity)s,
        match_id,
        provider_fixture_id,
        league_id,
        season,
        kickoff,
        %(run_group)s,
        50,
        'pending',
        now()
    FROM candidates
    ON CONFLICT (provider, provider_fixture_id)
    DO NOTHING
    RETURNING
        id,
        match_id,
        provider_fixture_id,
        league_id,
        season,
        kickoff;
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            sql,
            {
                "provider": PROVIDER,
                "sport_code": SPORT_CODE,
                "sport_id": SPORT_ID,
                "entity": ENTITY,
                "run_group": RUN_GROUP,
                "limit": limit,
            },
        )
        rows = cur.fetchall()

    conn.commit()
    return rows


def print_summary(rows):
    print("=" * 80)
    print("MATCHMATRIX FB PLAYER MATCH STATS QUEUE BUILDER V1")
    print("=" * 80)
    print(f"PROVIDER : {PROVIDER}")
    print(f"SPORT    : {SPORT_CODE}")
    print(f"ENTITY   : {ENTITY}")
    print(f"RUN GROUP: {RUN_GROUP}")
    print("-" * 80)
    print(f"INSERTED QUEUE ROWS: {len(rows)}")

    for row in rows[:30]:
        print(
            f"QUEUE ID {row['id']} | "
            f"MATCH {row['match_id']} | "
            f"FIXTURE {row['provider_fixture_id']} | "
            f"LEAGUE {row['league_id']} | "
            f"SEASON {row['season']} | "
            f"KICKOFF {row['kickoff']}"
        )

    if len(rows) > 30:
        print(f"... dalších {len(rows) - 30} řádků nezobrazeno")

    print("=" * 80)
    print("DONE")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=200)
    args = parser.parse_args()

    conn = get_conn()

    try:
        ensure_queue_table(conn)
        rows = build_queue(conn, args.limit)
        print_summary(rows)
    finally:
        conn.close()


if __name__ == "__main__":
    main()