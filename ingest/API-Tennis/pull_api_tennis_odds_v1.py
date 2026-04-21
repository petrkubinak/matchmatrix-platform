# -*- coding: utf-8 -*-
"""
pull_api_tennis_odds_v1.py

Účel:
- načte TN zápasy z public.matches
- pro každý TN match zavolá RapidAPI Tennis endpoint na winning odds
- uloží RAW payload do public.api_raw_payloads

Použitý endpoint:
- /api/tennis/event/{event_id}/provider/{provider_id}/winning-odds
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
from pathlib import Path
from typing import Any, Optional

import psycopg2
import psycopg2.extras
import requests
from dotenv import load_dotenv


SCRIPT_DIR = Path(__file__).resolve().parent
ENV_PATH = SCRIPT_DIR / ".env"

if ENV_PATH.exists():
    load_dotenv(dotenv_path=ENV_PATH, override=True)
else:
    load_dotenv(override=True)


SOURCE = "api_tennis"
DEFAULT_PROVIDER_ID = 1
DEFAULT_TIMEOUT_SEC = 30

RAPIDAPI_KEY = os.getenv("RAPIDAPI_KEY", "")

RAPIDAPI_TENNIS_ODDS_HOST = os.getenv("RAPIDAPI_TENNIS_ODDS_HOST", "tennisapi1.p.rapidapi.com")
RAPIDAPI_TENNIS_ODDS_BASE = os.getenv("RAPIDAPI_TENNIS_ODDS_BASE", "https://tennisapi1.p.rapidapi.com")
RAPIDAPI_TENNIS_ODDS_PATH_TEMPLATE = os.getenv(
    "RAPIDAPI_TENNIS_ODDS_PATH_TEMPLATE",
    "/api/tennis/event/{event_id}/provider/{provider_id}/winning-odds",
)


def get_conn():
    host = os.getenv("PGHOST", "localhost").strip()
    port = os.getenv("PGPORT", "5432").strip()
    dbname = os.getenv("PGDATABASE", "matchmatrix").strip()
    user = os.getenv("PGUSER", "matchmatrix").strip()
    password = os.getenv("PGPASSWORD", "matchmatrix_pass").strip()

    return psycopg2.connect(
        host=host,
        port=port,
        dbname=dbname,
        user=user,
        password=password,
    )


def create_job_run(cur, limit: int, dry_run: bool, provider_id: int) -> int:
    cur.execute(
        """
        insert into ops.job_runs (
            job_code,
            status,
            params,
            message,
            details
        )
        values (
            %s,
            'running',
            %s::jsonb,
            %s,
            '{}'::jsonb
        )
        returning id
        """,
        (
            "TN_ODDS_RAW_PULL_V1",
            json.dumps(
                {
                    "limit": limit,
                    "dry_run": dry_run,
                    "source": SOURCE,
                    "provider_id": provider_id,
                    "odds_host": RAPIDAPI_TENNIS_ODDS_HOST,
                    "odds_base": RAPIDAPI_TENNIS_ODDS_BASE,
                    "odds_path_template": RAPIDAPI_TENNIS_ODDS_PATH_TEMPLATE,
                },
                ensure_ascii=False,
            ),
            "TN odds raw pull started",
        ),
    )
    return int(cur.fetchone()["id"])


def finish_job_run(
    cur,
    run_id: int,
    status: str,
    message: str,
    rows_affected: int,
) -> None:
    cur.execute(
        """
        update ops.job_runs
        set
            finished_at = now(),
            status = %s,
            message = %s,
            rows_affected = %s
        where id = %s
        """,
        (status, message, rows_affected, run_id),
    )


def create_api_import_run(cur) -> int:
    """
    RAW payloads používají FK na public.api_import_runs.
    """
    cur.execute(
        """
        insert into public.api_import_runs (
            source,
            started_at,
            status,
            details
        )
        values (
            %s,
            now(),
            'running',
            %s::jsonb
        )
        returning id
        """,
        (
            SOURCE,
            json.dumps(
                {
                    "entity": "odds",
                    "mode": "raw_pull",
                    "provider": "rapidapi_tennisapi",
                },
                ensure_ascii=False,
            ),
        ),
    )
    return int(cur.fetchone()["id"])


def finish_api_import_run(cur, import_run_id: int, status: str, details: dict[str, Any]) -> None:
    cur.execute(
        """
        update public.api_import_runs
        set
            finished_at = now(),
            status = %s,
            details = coalesce(details, '{}'::jsonb) || %s::jsonb
        where id = %s
        """,
        (
            status,
            json.dumps(details, ensure_ascii=False),
            import_run_id,
        ),
    )


def load_tennis_matches(cur, limit: int) -> list[dict[str, Any]]:
    cur.execute(
        """
        select
            id as match_id,
            ext_match_id,
            kickoff,
            status
        from public.matches
        where ext_source = 'api_tennis'
          and ext_match_id is not null
        order by kickoff desc, id desc
        limit %s
        """,
        (limit,),
    )
    return list(cur.fetchall())


def save_raw_payload(cur, import_run_id: int, endpoint: str, payload: Any) -> None:
    cur.execute(
        """
        insert into public.api_raw_payloads
            (run_id, source, endpoint, fetched_at, payload)
        values
            (%s, %s, %s, now(), %s::jsonb)
        """,
        (
            import_run_id,
            SOURCE,
            endpoint,
            json.dumps(payload, ensure_ascii=False),
        ),
    )


def build_headers() -> dict[str, str]:
    return {
        "Content-Type": "application/json",
        "x-rapidapi-host": RAPIDAPI_TENNIS_ODDS_HOST,
        "x-rapidapi-key": RAPIDAPI_KEY,
    }


def build_endpoint(ext_match_id: str, provider_id: int) -> str:
    return RAPIDAPI_TENNIS_ODDS_PATH_TEMPLATE.format(
        event_id=ext_match_id,
        provider_id=provider_id,
    )


def fetch_winning_odds(
    ext_match_id: str,
    provider_id: int,
    timeout_sec: int = DEFAULT_TIMEOUT_SEC,
) -> dict[str, Any]:
    endpoint = build_endpoint(ext_match_id=ext_match_id, provider_id=provider_id)
    url = f"{RAPIDAPI_TENNIS_ODDS_BASE}{endpoint}"

    response = requests.get(
        url,
        headers=build_headers(),
        timeout=timeout_sec,
    )
    response.raise_for_status()

    try:
        payload = response.json()
    except Exception as exc:
        raise ValueError(f"Response není validní JSON: {exc}") from exc

    return {
        "endpoint": endpoint,
        "payload": payload,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Pull TN winning odds RAW -> public.api_raw_payloads")
    parser.add_argument("--limit", type=int, default=3, help="Kolik TN matchů načíst")
    parser.add_argument("--provider-id", type=int, default=DEFAULT_PROVIDER_ID, help="Provider ID")
    parser.add_argument("--sleep-ms", type=int, default=300, help="Prodleva mezi requesty")
    parser.add_argument("--timeout-sec", type=int, default=30, help="HTTP timeout")
    parser.add_argument("--dry-run", action="store_true", help="Jen test requestů, bez insertu do DB")
    args = parser.parse_args()

    if not RAPIDAPI_KEY:
        print("FATAL ERROR: chybí RAPIDAPI_KEY v environmentu")
        print(f"Očekávaný .env soubor: {ENV_PATH}")
        return 1

    conn: Optional[psycopg2.extensions.connection] = None
    job_run_id: Optional[int] = None
    import_run_id: Optional[int] = None

    try:
        conn = get_conn()
        conn.autocommit = False

        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            print("=" * 70)
            print("MATCHMATRIX TN ODDS RAW PULL V1")
            print("=" * 70)
            print(f"ENV PATH            : {ENV_PATH}")
            print(f"ODDS HOST           : {RAPIDAPI_TENNIS_ODDS_HOST}")
            print(f"ODDS BASE           : {RAPIDAPI_TENNIS_ODDS_BASE}")
            print(f"ODDS PATH TEMPLATE  : {RAPIDAPI_TENNIS_ODDS_PATH_TEMPLATE}")
            print(f"PGHOST              : {os.getenv('PGHOST', '')}")
            print(f"PGPORT              : {os.getenv('PGPORT', '')}")
            print(f"PGDATABASE          : {os.getenv('PGDATABASE', '')}")
            print(f"PGUSER              : {os.getenv('PGUSER', '')}")
            print(f"PROVIDER ID         : {args.provider_id}")
            print(f"LIMIT               : {args.limit}")
            print(f"SLEEP MS            : {args.sleep_ms}")
            print(f"TIMEOUT SEC         : {args.timeout_sec}")
            print(f"DRY RUN             : {args.dry_run}")
            print("=" * 70)

            job_run_id = create_job_run(
                cur=cur,
                limit=args.limit,
                dry_run=args.dry_run,
                provider_id=args.provider_id,
            )

            import_run_id = create_api_import_run(cur)
            matches = load_tennis_matches(cur, args.limit)

            print(f"JOB RUN ID          : {job_run_id}")
            print(f"API IMPORT RUN ID   : {import_run_id}")
            print(f"MATCHES LOADED      : {len(matches)}")
            print("-" * 70)

            saved = 0
            failed = 0

            for row in matches:
                ext_match_id = str(row["ext_match_id"])
                match_id = row["match_id"]

                try:
                    result = fetch_winning_odds(
                        ext_match_id=ext_match_id,
                        provider_id=args.provider_id,
                        timeout_sec=args.timeout_sec,
                    )

                    endpoint = result["endpoint"]
                    payload = result["payload"]

                    print(f"[OK] match_id={match_id} ext_match_id={ext_match_id} endpoint={endpoint}")

                    if not args.dry_run:
                        save_raw_payload(
                            cur=cur,
                            import_run_id=import_run_id,
                            endpoint=endpoint,
                            payload=payload,
                        )
                        saved += 1

                except Exception as exc:
                    failed += 1
                    print(f"[ERROR] match_id={match_id} ext_match_id={ext_match_id} error={exc}")

                time.sleep(args.sleep_ms / 1000.0)

            if args.dry_run:
                conn.rollback()
                print("-" * 70)
                print("DRY RUN -> rollback")
            else:
                finish_api_import_run(
                    cur=cur,
                    import_run_id=import_run_id,
                    status="success",
                    details={
                        "saved": saved,
                        "failed": failed,
                        "entity": "odds",
                    },
                )
                finish_job_run(
                    cur=cur,
                    run_id=job_run_id,
                    status="success",
                    message=f"TN odds raw pull finished | saved={saved} failed={failed}",
                    rows_affected=saved,
                )
                conn.commit()
                print("-" * 70)
                print("COMMIT OK")

            print("-" * 70)
            print(f"SAVED               : {saved}")
            print(f"FAILED              : {failed}")
            print("-" * 70)

        return 0

    except Exception as exc:
        if conn:
            conn.rollback()

        try:
            if conn and job_run_id is not None:
                with conn.cursor() as cur:
                    finish_job_run(
                        cur=cur,
                        run_id=job_run_id,
                        status="error",
                        message=str(exc),
                        rows_affected=0,
                    )
                    conn.commit()
        except Exception:
            pass

        print(f"FATAL ERROR: {exc}")
        return 1

    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    sys.exit(main())