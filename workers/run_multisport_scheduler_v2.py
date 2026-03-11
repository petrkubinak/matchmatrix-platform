import psycopg2


def get_conn():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="matchmatrix",
        user="matchmatrix",
        password="matchmatrix_pass",
    )


def load_candidates(conn, per_sport_limit=10):
    sql = """
    WITH sports_budget AS
    (
        SELECT
            v.sport_code,
            v.sport_name,
            v.priority,
            v.requests_used,
            v.requests_limit,
            v.requests_remaining,
            v.max_parallel_jobs
        FROM ops.v_api_budget_today v
        WHERE v.enabled = true
          AND v.requests_remaining > 0
    ),
    ranked_targets AS
    (
        SELECT
            sb.sport_code,
            sb.sport_name,
            sb.priority AS sport_priority,
            sb.requests_used,
            sb.requests_limit,
            sb.requests_remaining,
            sb.max_parallel_jobs,

            it.id AS target_id,
            it.canonical_league_id,
            it.provider,
            it.provider_league_id,
            it.season,
            it.tier,
            it.run_group,
            it.max_requests_per_run,
            it.notes,

            ROW_NUMBER() OVER
            (
                PARTITION BY sb.sport_code
                ORDER BY
                    it.tier ASC,
                    it.max_requests_per_run DESC,
                    it.provider_league_id ASC
            ) AS rn
        FROM sports_budget sb
        JOIN ops.ingest_targets it
            ON it.sport_code = sb.sport_code
        WHERE it.enabled = true
    )
    SELECT
        sport_code,
        sport_name,
        sport_priority,
        requests_used,
        requests_limit,
        requests_remaining,
        max_parallel_jobs,
        target_id,
        canonical_league_id,
        provider,
        provider_league_id,
        season,
        tier,
        run_group,
        max_requests_per_run,
        notes
    FROM ranked_targets
    WHERE rn <= %s
    ORDER BY
        sport_priority ASC,
        sport_code ASC,
        tier ASC,
        max_requests_per_run DESC,
        provider_league_id ASC;
    """
    with conn.cursor() as cur:
        cur.execute(sql, (per_sport_limit,))
        return cur.fetchall()


def main():
    conn = get_conn()
    try:
        rows = load_candidates(conn, per_sport_limit=10)

        if not rows:
            print("Žádní kandidáti pro ingest.")
            return

        print("=== MULTI-SPORT SCHEDULER V2 ===")
        current_sport = None

        for row in rows:
            (
                sport_code,
                sport_name,
                sport_priority,
                requests_used,
                requests_limit,
                requests_remaining,
                max_parallel_jobs,
                target_id,
                canonical_league_id,
                provider,
                provider_league_id,
                season,
                tier,
                run_group,
                max_requests_per_run,
                notes,
            ) = row

            if sport_code != current_sport:
                current_sport = sport_code
                print()
                print(
                    f"[SPORT] {sport_code} | {sport_name} | "
                    f"priority={sport_priority} | "
                    f"used={requests_used}/{requests_limit} | "
                    f"remaining={requests_remaining} | "
                    f"parallel={max_parallel_jobs}"
                )

            print(
                f"  - target_id={target_id} | "
                f"league_id={canonical_league_id} | "
                f"provider={provider} | "
                f"provider_league_id={provider_league_id} | "
                f"season={season} | "
                f"tier={tier} | "
                f"run_group={run_group} | "
                f"max_req_run={max_requests_per_run} | "
                f"notes={notes}"
            )
    finally:
        conn.close()


if __name__ == "__main__":
    main()