import os
import psycopg2
from psycopg2.extras import RealDictCursor


def get_dsn() -> str:
    return "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"
    if not dsn:
        raise RuntimeError("Chybí DB_DSN.")
    return dsn


def load_sports_with_budget(conn):
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT
                sport_code,
                sport_name,
                priority,
                requests_used,
                requests_limit,
                requests_remaining,
                max_parallel_jobs
            FROM ops.v_api_budget_today
            WHERE requests_remaining > 0
            ORDER BY priority, sport_code
            """
        )
        return cur.fetchall()


def load_targets_for_sport(conn, sport_code: str, limit: int = 20):
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT
                id,
                sport_code,
                canonical_league_id,
                provider,
                provider_league_id,
                season,
                enabled,
                tier,
                fixtures_days_back,
                fixtures_days_forward,
                odds_days_forward,
                max_requests_per_run,
                run_group,
                notes
            FROM ops.ingest_targets
            WHERE enabled = true
              AND sport_code = %s
            ORDER BY
                tier ASC,
                canonical_league_id ASC,
                provider_league_id ASC
            LIMIT %s
            """,
            (sport_code, limit),
        )
        return cur.fetchall()


def main():
    dsn = get_dsn()

    with psycopg2.connect(dsn) as conn:
        sports = load_sports_with_budget(conn)

        if not sports:
            print("Žádný sport dnes nemá volný API budget.")
            return

        print("=== MULTI-SPORT SCHEDULER: DRY RUN ===")
        print()

        for sport in sports:
            print(
                f"[SPORT] {sport['sport_code']} | "
                f"used={sport['requests_used']} / {sport['requests_limit']} | "
                f"remaining={sport['requests_remaining']} | "
                f"parallel={sport['max_parallel_jobs']}"
            )

            targets = load_targets_for_sport(conn, sport["sport_code"], limit=10)

            if not targets:
                print("  - žádné aktivní ingest_targets")
                print()
                continue

            for t in targets:
                print(
                    f"  - target_id={t['id']} | "
                    f"league_id={t['canonical_league_id']} | "
                    f"provider_league_id={t['provider_league_id']} | "
                    f"season={t['season']} | "
                    f"tier={t['tier']} | "
                    f"run_group={t['run_group']}"
                )

            print()


if __name__ == "__main__":
    main()