import psycopg2


def get_conn():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="matchmatrix",
        user="matchmatrix",
        password="matchmatrix_pass",
    )


def load_candidates(conn, per_sport_limit=5):
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
            COALESCE(it.season, '') AS season,
            it.tier,
            it.run_group,
            COALESCE(it.max_requests_per_run, 1) AS max_requests_per_run,
            it.notes,

            ROW_NUMBER() OVER
            (
                PARTITION BY sb.sport_code
                ORDER BY
                    it.tier ASC,
                    COALESCE(it.max_requests_per_run, 1) DESC,
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


def enqueue_candidate(conn, row):
    sql = """
    INSERT INTO ops.scheduler_queue
    (
        queue_day,
        sport_code,
        target_id,
        canonical_league_id,
        provider,
        provider_league_id,
        season,
        tier,
        run_group,
        max_requests_per_run,
        status,
        selected_by,
        message
    )
    VALUES
    (
        CURRENT_DATE,
        %s, %s, %s, %s, %s, %s, %s, %s, %s,
        'pending',
        'run_multisport_scheduler_v3',
        %s
    )
    ON CONFLICT (queue_day, target_id) DO NOTHING;
    """
    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                row[0],   # sport_code
                row[7],   # target_id
                row[8],   # canonical_league_id
                row[9],   # provider
                row[10],  # provider_league_id
                row[11],  # season
                row[12],  # tier
                row[13],  # run_group
                row[14],  # max_requests_per_run
                row[15],  # notes
            ),
        )


def main():
    conn = get_conn()
    try:
        rows = load_candidates(conn, per_sport_limit=2)

        if not rows:
            print("Žádní kandidáti pro ingest.")
            return

        print("=== MULTI-SPORT SCHEDULER V3: ENQUEUE ===")

        for row in rows:
            enqueue_candidate(conn, row)

            print(
                f"[ENQUEUED] sport={row[0]} | "
                f"target_id={row[7]} | "
                f"league_id={row[8]} | "
                f"provider={row[9]} | "
                f"provider_league_id={row[10]} | "
                f"tier={row[12]} | "
                f"run_group={row[13]} | "
                f"notes={row[15]}"
            )

        conn.commit()
        print()
        print("Hotovo: kandidáti zapsáni do ops.scheduler_queue.")
    finally:
        conn.close()


if __name__ == "__main__":
    main()