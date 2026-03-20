from __future__ import annotations

import argparse
from datetime import datetime
from typing import List, Optional

import psycopg2


DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

# Povolené entity pro planner V1
ALLOWED_ENTITIES = {
    "leagues",
    "teams",
    "fixtures",
    "odds",
    "players",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build MatchMatrix ingest planner jobs from ops.ingest_targets"
    )

    parser.add_argument(
        "--entities",
        required=True,
        help="Čárkou oddělený seznam entit, např. teams,fixtures,players"
    )

    parser.add_argument(
        "--provider",
        default=None,
        help="Filtr provideru, např. api_football"
    )

    parser.add_argument(
        "--sport",
        default=None,
        help="Filtr sportu, např. football"
    )

    parser.add_argument(
        "--run-group",
        default=None,
        help="Filtr run_group, např. FOOTBALL_MAINTENANCE nebo FREE_TEST_PRIMARY"
    )

    parser.add_argument(
        "--priority",
        type=int,
        default=5,
        help="Priorita planner jobů. Menší číslo = vyšší priorita."
    )

    parser.add_argument(
        "--next-run-now",
        action="store_true",
        help="Když je zadáno, next_run se nastaví na NOW(). Jinak zůstane NULL."
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Pouze vypíše, co by vytvořil, ale nic nezapíše do DB."
    )

    return parser.parse_args()


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def normalize_entities(raw_entities: str) -> List[str]:
    entities = [x.strip().lower() for x in raw_entities.split(",") if x.strip()]
    if not entities:
        raise ValueError("Nebyla zadána žádná entita.")

    invalid = [x for x in entities if x not in ALLOWED_ENTITIES]
    if invalid:
        raise ValueError(
            f"Neplatné entity: {', '.join(invalid)}. "
            f"Povolené jsou: {', '.join(sorted(ALLOWED_ENTITIES))}"
        )

    # odstranění duplicit při zachování pořadí
    unique_entities = []
    seen = set()
    for entity in entities:
        if entity not in seen:
            unique_entities.append(entity)
            seen.add(entity)

    return unique_entities


def print_header(args: argparse.Namespace, entities: List[str]) -> None:
    print("=" * 80)
    print("MATCHMATRIX: BUILD INGEST PLANNER JOBS V1")
    print("=" * 80)
    print("START TIME :", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print("PROVIDER   :", args.provider)
    print("SPORT      :", args.sport)
    print("RUN GROUP  :", args.run_group)
    print("ENTITIES   :", ", ".join(entities))
    print("PRIORITY   :", args.priority)
    print("NEXT RUN   :", "NOW()" if args.next_run_now else "NULL")
    print("DRY RUN    :", args.dry_run)
    print("=" * 80)


def load_targets(
    conn,
    provider: Optional[str],
    sport: Optional[str],
    run_group: Optional[str],
):
    sql = """
        SELECT
            id,
            provider,
            sport_code,
            provider_league_id,
            NULLIF(BTRIM(season), '') AS season,
            NULLIF(BTRIM(run_group), '') AS run_group,
            enabled,
            tier,
            notes
        FROM ops.ingest_targets
        WHERE enabled = TRUE
          AND provider_league_id IS NOT NULL
          AND COALESCE(BTRIM(provider_league_id), '') <> ''
          AND (%s IS NULL OR provider = %s)
          AND (%s IS NULL OR sport_code = %s)
          AND (%s IS NULL OR run_group = %s)
        ORDER BY provider, sport_code, run_group, provider_league_id, season
    """

    with conn.cursor() as cur:
        cur.execute(sql, (provider, provider, sport, sport, run_group, run_group))
        rows = cur.fetchall()

    return rows


def planner_job_exists(
    conn,
    provider: str,
    sport_code: str,
    entity: str,
    provider_league_id: str,
    season: Optional[str],
    run_group: Optional[str],
) -> bool:
    sql = """
        SELECT 1
        FROM ops.ingest_planner
        WHERE provider = %s
          AND sport_code = %s
          AND entity = %s
          AND provider_league_id = %s
          AND (
                (season IS NULL AND %s IS NULL)
                OR season = %s
              )
          AND (
                (run_group IS NULL AND %s IS NULL)
                OR run_group = %s
              )
        LIMIT 1
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                provider,
                sport_code,
                entity,
                provider_league_id,
                season,
                season,
                run_group,
                run_group,
            ),
        )
        row = cur.fetchone()

    return row is not None


def insert_planner_job(
    conn,
    provider: str,
    sport_code: str,
    entity: str,
    provider_league_id: str,
    season: Optional[str],
    run_group: Optional[str],
    priority: int,
    next_run_now: bool,
) -> None:
    sql = """
        INSERT INTO ops.ingest_planner
        (
            provider,
            sport_code,
            entity,
            provider_league_id,
            season,
            run_group,
            priority,
            status,
            attempts,
            last_attempt,
            next_run,
            created_at,
            updated_at
        )
        VALUES
        (
            %s, %s, %s, %s, %s, %s,
            %s,
            'pending',
            0,
            NULL,
            CASE WHEN %s THEN NOW() ELSE NULL END,
            NOW(),
            NOW()
        )
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                provider,
                sport_code,
                entity,
                provider_league_id,
                season,
                run_group,
                priority,
                next_run_now,
            ),
        )


def main() -> int:
    args = parse_args()
    entities = normalize_entities(args.entities)
    print_header(args, entities)

    conn = get_connection()
    try:
        targets = load_targets(
            conn=conn,
            provider=args.provider,
            sport=args.sport,
            run_group=args.run_group,
        )

        print(f"Enabled targets found: {len(targets)}")
        if not targets:
            print("Nebyl nalezen žádný odpovídající aktivní target v ops.ingest_targets.")
            return 1

        inserted = 0
        skipped_existing = 0
        planned_total = 0

        for row in targets:
            (
                target_id,
                provider,
                sport_code,
                provider_league_id,
                season,
                run_group,
                enabled,
                tier,
                notes,
            ) = row

            for entity in entities:
                planned_total += 1

                exists = planner_job_exists(
                    conn=conn,
                    provider=provider,
                    sport_code=sport_code,
                    entity=entity,
                    provider_league_id=provider_league_id,
                    season=season,
                    run_group=run_group,
                )

                if exists:
                    skipped_existing += 1
                    print(
                        f"SKIP existing | provider={provider} sport={sport_code} "
                        f"entity={entity} league={provider_league_id} season={season} run_group={run_group}"
                    )
                    continue

                print(
                    f"ADD planner job | provider={provider} sport={sport_code} "
                    f"entity={entity} league={provider_league_id} season={season} run_group={run_group}"
                )

                if not args.dry_run:
                    insert_planner_job(
                        conn=conn,
                        provider=provider,
                        sport_code=sport_code,
                        entity=entity,
                        provider_league_id=provider_league_id,
                        season=season,
                        run_group=run_group,
                        priority=args.priority,
                        next_run_now=args.next_run_now,
                    )
                    inserted += 1

        if not args.dry_run:
            conn.commit()

        print("-" * 80)
        print("SUMMARY")
        print("-" * 80)
        print("Planner combinations total :", planned_total)
        print("Inserted                  :", inserted)
        print("Skipped existing          :", skipped_existing)
        print("Dry run                   :", args.dry_run)
        print("-" * 80)
        print("Hotovo.")
        print("-" * 80)

        return 0

    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())