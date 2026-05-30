# -*- coding: utf-8 -*-
"""
MATCHMATRIX 104_H - BUILD FIXTURE PLAYER STATS QUEUE V1

Co skript dělá:
- hledá FINISHED football zápasy v public.matches
- kontroluje, zda už existují data v public.player_match_statistics
- pokud chybí, vloží zápas do ops.fixture_player_stats_queue

Kam výsledek vede:
- ops.fixture_player_stats_queue

K čemu to slouží:
- připravuje automatické stahování API-Football /fixtures/players

Jak se využije na webu:
- player match detail
- player form engine
- fantasy scoring
- AI prediction layer
- player momentum
"""

import os
import sys
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv


BASE_DIR = r"C:\MatchMatrix-platform"
ENV_PATH = os.path.join(BASE_DIR, ".env")

PROVIDER = "api_football"
SPORT_CODE = "FB"
ENTITY = "fixture_player_stats"
RUN_GROUP = "FB_PLAYER_MATCH_STATS_DAILY"
DEFAULT_LIMIT = 500


def get_conn():
    load_dotenv(ENV_PATH)

    db_dsn = os.getenv("DB_DSN")
    if db_dsn:
        return psycopg2.connect(db_dsn)

    return psycopg2.connect(
        host=os.getenv("PGHOST", os.getenv("DB_HOST", "localhost")),
        port=os.getenv("PGPORT", os.getenv("DB_PORT", "5432")),
        dbname=os.getenv("PGDATABASE", os.getenv("DB_NAME", "matchmatrix")),
        user=os.getenv("PGUSER", os.getenv("DB_USER", "postgres")),
        password=os.getenv("PGPASSWORD", os.getenv("DB_PASSWORD", "")),
    )


def ensure_queue_table(conn):
    sql = """
    CREATE TABLE IF NOT EXISTS ops.fixture_player_stats_queue (
        id BIGSERIAL PRIMARY KEY,
        provider TEXT NOT NULL,
        sport_code TEXT NOT NULL,
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
    """
    with conn.cursor() as cur:
        cur.execute(sql)
    conn.commit()


def build_queue(conn, limit: int):
    sql = """
    WITH candidates AS (
        SELECT
            m.id AS match_id,
            m.ext_match_id AS provider_fixture_id,
            m.league_id,
            m.season,
            m.kickoff
        FROM public.matches m
        WHERE m.ext_source = %(provider)s
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
        ORDER BY m.kickoff DESC
        LIMIT %(limit)s
    )
    INSERT INTO ops.fixture_player_stats_queue (
        provider,
        sport_code,
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
    RETURNING id, match_id, provider_fixture_id, league_id, season, kickoff;
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            sql,
            {
                "provider": PROVIDER,
                "sport_code": SPORT_CODE,
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
    print("MATCHMATRIX FIXTURE PLAYER STATS QUEUE BUILDER V1")
    print("=" * 80)
    print(f"PROVIDER : {PROVIDER}")
    print(f"SPORT    : {SPORT_CODE}")
    print(f"ENTITY   : {ENTITY}")
    print(f"RUN GROUP: {RUN_GROUP}")
    print("-" * 80)
    print(f"INSERTED QUEUE ROWS: {len(rows)}")

    for row in rows[:30]:
        print(
            f"QUEUE ID {row['id']} | MATCH {row['match_id']} | "
            f"FIXTURE {row['provider_fixture_id']} | "
            f"LEAGUE {row['league_id']} | SEASON {row['season']} | "
            f"KICKOFF {row['kickoff']}"
        )

    if len(rows) > 30:
        print(f"... dalších {len(rows) - 30} řádků nezobrazeno")

    print("=" * 80)
    print("DONE")


def main():
    limit = DEFAULT_LIMIT

    if "--limit" in sys.argv:
        idx = sys.argv.index("--limit")
        if idx + 1 < len(sys.argv):
            limit = int(sys.argv[idx + 1])

    conn = get_conn()
    try:
        ensure_queue_table(conn)
        rows = build_queue(conn, limit)
        print_summary(rows)
    finally:
        conn.close()


if __name__ == "__main__":
    main()