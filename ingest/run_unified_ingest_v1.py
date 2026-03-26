from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime
from typing import Any, Dict, Optional

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PROVIDERS_DIR = os.path.join(CURRENT_DIR, "providers")

if PROVIDERS_DIR not in sys.path:
    sys.path.insert(0, PROVIDERS_DIR)

from provider_registry import get_provider_class  # noqa: E402


# ==========================================================
# MATCHMATRIX
# UNIFIED INGEST V1
#
# Kam uložit:
# C:\MatchMatrix-platform\ingest\run_unified_ingest_v1.py
#
# Co dělá:
# - vezme provider / sport / entity / season / league_id
# - předá je do provider.dispatch(...)
# - provider teprve rozhodne, jaký konkrétní script spustit
#
# DŮLEŽITÉ:
# - tento runner league_id a season opravdu předává dál
# - pokud se v child scriptu neobjeví -LeagueId / -Season,
#   problém je v provider implementaci, ne zde
# ==========================================================


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


def normalize_optional(value: Optional[str]) -> Optional[str]:
    """
    Prázdný string -> None.
    Hodí se pro argparse hodnoty z panelu / scheduleru.
    """
    if value is None:
        return None

    value = str(value).strip()
    if value == "":
        return None

    return value


def generate_run_id() -> int:
    """
    Run ID ve formátu YYYYMMDDHHMMSSmmm
    kde mmm = milisekundy.
    Je stále číselné, čitelné, unikátnější pro paralelní běh
    a stále se vejde do PowerShell Int64.
    """
    now = datetime.now()
    return int(now.strftime("%Y%m%d%H%M%S") + f"{now.microsecond // 1000:03d}")


def print_header(
    provider: str,
    sport: str,
    entity: str,
    season: Optional[str],
    league_id: Optional[str],
    run_group: Optional[str],
    days_ahead: Optional[int],
    force: bool,
    run_id: int,
) -> None:
    print("=" * 70)
    print("MATCHMATRIX UNIFIED INGEST V1")
    print("=" * 70)
    print(f"START TIME : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"RUN ID     : {run_id}")
    print(f"PROVIDER   : {provider}")
    print(f"SPORT      : {sport}")
    print(f"ENTITY     : {entity}")
    print(f"SEASON     : {season}")
    print(f"LEAGUE ID  : {league_id}")
    print(f"RUN GROUP  : {run_group}")
    print(f"DAYS AHEAD : {days_ahead}")
    print(f"FORCE      : {force}")
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

    provider_name = normalize_optional(args.provider)
    sport_name = normalize_optional(args.sport)
    entity_name = normalize_optional(args.entity)
    season_value = normalize_optional(args.season)
    league_id_value = normalize_optional(args.league_id)
    run_group_value = normalize_optional(args.run_group)

    if not provider_name:
        print("FATAL ERROR: provider is empty")
        return 2

    if not sport_name:
        print("FATAL ERROR: sport is empty")
        return 2

    if not entity_name:
        print("FATAL ERROR: entity is empty")
        return 2

    print_header(
        provider=provider_name,
        sport=sport_name,
        entity=entity_name,
        season=season_value,
        league_id=league_id_value,
        run_group=run_group_value,
        days_ahead=args.days_ahead,
        force=args.force,
        run_id=run_id,
    )

    try:
        provider_cls = get_provider_class(provider_name, sport_name)
        provider = provider_cls(provider_name, sport_name)

        print("DISPATCH PARAMS")
        print(
            f"entity={entity_name} | run_id={run_id} | season={season_value} | "
            f"league_id={league_id_value} | run_group={run_group_value} | "
            f"days_ahead={args.days_ahead} | force={args.force}"
        )
        print("-" * 70)

        result = provider.dispatch(
            entity=entity_name,
            run_id=run_id,
            season=season_value,
            league_id=league_id_value,
            run_group=run_group_value,
            days_ahead=args.days_ahead,
            force=args.force,
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