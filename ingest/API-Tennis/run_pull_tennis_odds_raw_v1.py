# -*- coding: utf-8 -*-
"""
pull_api_tennis_odds_v1.py

Účel:
- načte TN zápasy z public.matches
- pro každý TN match zavolá RapidAPI Tennis endpoint na odds
- uloží RAW payload do public.api_raw_payloads

Poznámka:
- toto je PULL vrstva
- parser do public.odds bude samostatný krok
- .env se načítá z:
  C:\MatchMatrix-platform\ingest\API-Tennis\.env
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


# =========================================================
# ENV LOAD
# =========================================================

SCRIPT_DIR = Path(__file__).resolve().parent
ENV_PATH = SCRIPT_DIR / ".env"

if ENV_PATH.exists():
    load_dotenv(dotenv_path=ENV_PATH)
else:
    load_dotenv()  # fallback


# =========================================================
# KONSTANTY
# =========================================================

SOURCE = "api_tennis"

# UPRAV PODLE SKUTEČNÉHO ODDS ENDPOINTU TENNISAPI
# Zatím držíme nejpravděpodobnější pattern:
ENDPOINT_TEMPLATE = "/api/tennis/event/{event_id}/odds"

RAPIDAPI_HOST = os.getenv("RAPIDAPI_HOST", "tennisapi1.p.rapidapi.com")
RAPIDAPI_KEY = os.getenv("RAPIDAPI_KEY", "")

DEFAULT_TIMEOUT_SEC = 30


# =========================================================
# DB
# =========================================================

def get_conn():
    """Vrátí DB connection."""
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "matchmatrix"),
        user=os.getenv("DB_USER", "matchmatrix"),
        password=os.getenv("DB_PASSWORD", "matchmatrix_pass"),
    )


# =========================================================
# JOB RUN
# =========================================================

def create_job_run(cur, limit: int, dry_run: bool) -> int:
    """Založí záznam v ops.job_runs."""
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
                    "endpoint_template": ENDPOINT_TEMPLATE,
                },
                ensure_ascii=False,
            ),
            "TN odds raw pull started",
        ),
    )
    row = cur.fetchone()
    return int(row["id"])


def finish_job_run(
    cur,
    run_id: int,
    status: str,
    message: str,
    rows_affected: int,
) -> None:
    """Dokončí job run."""
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


# =========================================================
# LOAD MATCHES
# =========================================================

def load_tennis_matches(cur, limit: int) -> list[dict[str, Any]]:
    """
    Načte TN zápasy z public.matches.
    """
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


# =========================================================
# RAW SAVE
# =========================================================

def save_raw_payload(cur, run_id: int, endpoint: str, payload: Any) -> None:
    """
    Uloží RAW JSON do public.api_raw_payloads.
    """
    cur.execute(
        """
        insert into public.api_raw_payloads
            (run_id, source, endpoint, fetched_at, payload)
        values
            (%s, %s, %s, now(), %s::jsonb)
        """,
        (
            run_id,
            SOURCE,
            endpoint,
            json.dumps(payload, ensure_ascii=False),
        ),
    )


# =========================================================
# HTTP
# =========================================================

def build_headers() -> dict[str, str]:
    """Sestaví request headers pro RapidAPI."""
    return {
        "X-RapidAPI-Key": RAPIDAPI_KEY,
        "X-RapidAPI-Host": RAPIDAPI_HOST,
    }


def fetch_odds(ext_match_id: str, timeout_sec: int = DEFAULT_TIMEOUT_SEC) -> dict[str, Any]:
    """
    Zavolá TennisAPI odds endpoint a vrátí:
    {
        "endpoint": "...",
        "payload": {...}
    }
    """
    endpoint = ENDPOINT_TEMPLATE.format(event_id=ext_match_id)
    url = f"https://{RAPIDAPI_HOST}{endpoint}"

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


# =========================================================
# MAIN
# =========================================================

def main() -> int:
    parser = argparse.ArgumentParser(description="Pull TN odds RAW -> public.api_raw_payloads")
    parser.add_argument("--limit", type=int, default=5, help="Kolik TN matchů načíst")
    parser.add_argument("--sleep-ms", type=int, default=300, help="Prodleva mezi requesty")
    parser.add_argument("--timeout-sec", type=int, default=30, help="HTTP timeout")
    parser.add_argument("--dry-run", action="store_true", help="Jen test requestů, bez insertu do DB")
    args = parser.parse_args()

    if not RAPIDAPI_KEY:
        print("FATAL ERROR: chybí RAPIDAPI_KEY v environmentu")
        print(f"Očekávaný .env soubor: {ENV_PATH}")
        return 1

    conn: Optional[psycopg2.extensions.connection] = None
    run_id: Optional[int] = None

    try:
        conn = get_conn()
        conn.autocommit = False

        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            print("=" * 70)
            print("MATCHMATRIX TN ODDS RAW PULL V1")
            print("=" * 70)
            print(f"ENV PATH          : {ENV_PATH}")
            print(f"RAPIDAPI HOST     : {RAPIDAPI_HOST}")
            print(f"ENDPOINT TEMPLATE : {ENDPOINT_TEMPLATE}")
            print(f"LIMIT             : {args.limit}")
            print(f"SLEEP MS          : {args.sleep_ms}")
            print(f"TIMEOUT SEC       : {args.timeout_sec}")
            print(f"DRY RUN           : {args.dry_run}")
            print("=" * 70)

            run_id = create_job_run(cur, args.limit, args.dry_run)
            matches = load_tennis_matches(cur, args.limit)

            print(f"JOB RUN ID        : {run_id}")
            print(f"MATCHES LOADED    : {len(matches)}")
            print("-" * 70)

            saved = 0
            failed = 0

            for row in matches:
                ext_match_id = str(row["ext_match_id"])
                match_id = row["match_id"]

                try:
                    result = fetch_odds(
                        ext_match_id=ext_match_id,
                        timeout_sec=args.timeout_sec,
                    )

                    endpoint = result["endpoint"]
                    payload = result["payload"]

                    print(f"[OK] match_id={match_id} ext_match_id={ext_match_id} endpoint={endpoint}")

                    if not args.dry_run:
                        save_raw_payload(
                            cur=cur,
                            run_id=run_id,
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
                finish_job_run(
                    cur=cur,
                    run_id=run_id,
                    status="success",
                    message=f"TN odds raw dry-run finished | tested={len(matches)} failed={failed}",
                    rows_affected=0,
                )
                conn.commit()
            else:
                finish_job_run(
                    cur=cur,
                    run_id=run_id,
                    status="success",
                    message=f"TN odds raw pull finished | saved={saved} failed={failed}",
                    rows_affected=saved,
                )
                conn.commit()
                print("-" * 70)
                print("COMMIT OK")

            print("-" * 70)
            print(f"SAVED             : {saved}")
            print(f"FAILED            : {failed}")
            print("-" * 70)

        return 0

    except Exception as exc:
        if conn:
            conn.rollback()

        try:
            if conn and run_id is not None:
                with conn.cursor() as cur:
                    finish_job_run(
                        cur=cur,
                        run_id=run_id,
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