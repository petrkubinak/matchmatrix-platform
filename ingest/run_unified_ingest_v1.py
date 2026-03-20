from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime
from typing import Any, Dict

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PROVIDERS_DIR = os.path.join(CURRENT_DIR, "providers")

if PROVIDERS_DIR not in sys.path:
    sys.path.insert(0, PROVIDERS_DIR)

from provider_registry import get_provider_class  # noqa: E402


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="MatchMatrix Unified Ingest V1")

    parser.add_argument("--provider", required=True, help="Např. api_football, api_hockey")
    parser.add_argument("--sport", required=True, help="Např. football, hockey")
    parser.add_argument("--entity", required=True, help="leagues, teams, fixtures, odds, players")

    parser.add_argument("--season", required=False, help="Sezona, např. 2025")
    parser.add_argument("--league-id", required=False, help="Volitelný externí league id")
    parser.add_argument("--run-group", required=False, help="Např. EU_top,EU_exact_v1")
    parser.add_argument("--days-ahead", required=False, type=int, help="Počet dní dopředu")
    parser.add_argument("--force", action="store_true", help="Force reload / refresh")

    return parser.parse_args()


def generate_run_id() -> int:
    """
    Run ID ve formátu YYYYMMDDHHMMSSmmm
    kde mmm = milisekundy.
    Je stále číselné, čitelné, unikátnější pro paralelní běh
    a stále se vejde do PowerShell Int64.
    """
    now = datetime.now()
    return int(now.strftime("%Y%m%d%H%M%S") + f"{now.microsecond // 1000:03d}")


def print_header(args: argparse.Namespace, run_id: int) -> None:
    print("=" * 70)
    print("MATCHMATRIX UNIFIED INGEST V1")
    print("=" * 70)
    print(f"START TIME : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"RUN ID     : {run_id}")
    print(f"PROVIDER   : {args.provider}")
    print(f"SPORT      : {args.sport}")
    print(f"ENTITY     : {args.entity}")
    print(f"SEASON     : {args.season}")
    print(f"LEAGUE ID  : {args.league_id}")
    print(f"RUN GROUP  : {args.run_group}")
    print(f"DAYS AHEAD : {args.days_ahead}")
    print(f"FORCE      : {args.force}")
    print("=" * 70)


def print_summary(result: Dict[str, Any]) -> None:
    print("-" * 70)
    print("SUMMARY")
    print("-" * 70)
    print(f"STATUS       : {result.get('status')}")
    print(f"MESSAGE      : {result.get('message')}")
    print(f"RETURNCODE   : {result.get('returncode')}")
    print(f"STDOUT LINES : {result.get('stdout_lines')}")
    print("-" * 70)


def main() -> int:
    args = parse_args()
    run_id = generate_run_id()

    print_header(args, run_id)

    try:
        provider_cls = get_provider_class(args.provider, args.sport)
        provider = provider_cls(args.provider, args.sport)

        result = provider.dispatch(
            entity=args.entity,
            run_id=run_id,
            season=args.season,
            league_id=args.league_id,
            run_group=args.run_group,
            days_ahead=args.days_ahead,
            force=args.force
        )

        print_summary(result)

        if result.get("status") == "ok":
            print("Unified ingest finished OK.")
            return 0

        if result.get("status") == "warning":
            print("Unified ingest finished with WARNING.")
            return 1

        print("Unified ingest finished with ERROR.")
        return 2

    except NotImplementedError as exc:
        print(f"NOT IMPLEMENTED: {exc}")
        return 2

    except Exception as exc:
        print(f"FATAL ERROR: {exc}")
        return 2


if __name__ == "__main__":
    sys.exit(main())