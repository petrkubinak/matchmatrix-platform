#!/usr/bin/env python3
# -*- coding: utf-8 -*-

r"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

DOCUMENT ID:
25_1_A_33

NÁZEV:
EXPORT ÚPLNÉHO READ-ONLY AUDITU DATABÁZOVÉ STRUKTURY MATCHMATRIX

VERZE:
1.0

DATUM:
2026-07-14

CO:
Provede úplný read-only audit struktury produkční PostgreSQL databáze
MatchMatrix a vytvoří strojové i čitelné podklady pro MM-DB-001 a MM-DB-002.

K ČEMU:
- ověří připojení a vynutí READ ONLY + REPEATABLE READ,
- exportuje schémata, databázové objekty, sloupce, constraints, indexy,
  rutiny, triggery, závislosti, oprávnění, typy a governance registr,
- vyhodnotí tabulky bez PK, velké objekty, neaktuální statistiky,
  dead tuples, legacy/deprecated objekty a názvy použité ve více schématech,
- vytvoří JSON, Markdown a samostatné CSV soubory,
- vytvoří také odpovídající soubory *_latest.*,
- databázi ani zdrojové soubory projektu nemění.

KDE:
Aktivní skript:
tools/documentation/25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py

Výstupy:
reports/documentation/database_audit/

JAK:
Výchozí spuštění na PC2:
    py -3.14 .\tools\documentation\25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py

Explicitní DSN:
    py -3.14 .\tools\documentation\25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py `
      --dsn "host=localhost port=5432 dbname=matchmatrix user=matchmatrix"

Výběr schémat:
    py -3.14 .\tools\documentation\25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py `
      --schemas staging,public,ops,documentation,work

Bez definic views a rutin:
    py -3.14 .\tools\documentation\25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py `
      --no-definitions

Pouze ověření připojení:
    py -3.14 .\tools\documentation\25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py `
      --validate-connection-only

VSTUPY:
- PostgreSQL databáze MatchMatrix,
- parametry, DSN nebo proměnné PGHOST, PGPORT, PGDATABASE, PGUSER,
  PGPASSWORD / MATCHMATRIX_DB_PASSWORD,
- seznam auditovaných schémat.

VÝSTUPY:
- database_structure_audit_YYYYMMDD_HHMMSS.json
- database_structure_audit_YYYYMMDD_HHMMSS.md
- database_structure_schemas_YYYYMMDD_HHMMSS.csv
- database_structure_objects_YYYYMMDD_HHMMSS.csv
- database_structure_columns_YYYYMMDD_HHMMSS.csv
- database_structure_constraints_YYYYMMDD_HHMMSS.csv
- database_structure_indexes_YYYYMMDD_HHMMSS.csv
- database_structure_routines_YYYYMMDD_HHMMSS.csv
- database_structure_triggers_YYYYMMDD_HHMMSS.csv
- database_structure_dependencies_YYYYMMDD_HHMMSS.csv
- database_structure_privileges_YYYYMMDD_HHMMSS.csv
- database_structure_types_YYYYMMDD_HHMMSS.csv
- database_structure_governance_YYYYMMDD_HHMMSS.csv
- database_structure_warnings_YYYYMMDD_HHMMSS.csv
- odpovídající *_latest.* soubory

REŽIM:
READ_ONLY

BEZPEČNOST:
- jedna transakce READ ONLY + REPEATABLE READ,
- ověřuje SHOW transaction_read_only = on,
- nepoužívá žádné zápisové SQL,
- nepoužívá přesné COUNT(*) nad všemi tabulkami,
- počty řádků jsou odhady z PostgreSQL statistik,
- používá statement_timeout a lock_timeout,
- heslo se nikdy nevypisuje,
- transakce se vždy rollbackne,
- výstupy zapisuje jen do reports/documentation/database_audit/.

ROLLBACK:
Databázový rollback není potřeba, protože transakce je READ ONLY.
Na konci se vždy provede rollback, aby nezůstala otevřená transakce.

FINAL STATUS:
- DATABASE_STRUCTURE_AUDIT_EXPORTED
- DATABASE_STRUCTURE_CONNECTION_VERIFIED
- DATABASE_STRUCTURE_AUDIT_BLOCKED
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import re
import shutil
import subprocess
import traceback
from collections import Counter, defaultdict
from datetime import date, datetime, timezone
from decimal import Decimal
from pathlib import Path
from typing import Any, Mapping, Sequence


DOCUMENT_ID = "25_1_A_33"
ENGINE_VERSION = "A33_DATABASE_STRUCTURE_AUDIT_V1_0"
CONTRACT_VERSION = "1.0"

FINAL_EXPORTED = "DATABASE_STRUCTURE_AUDIT_EXPORTED"
FINAL_CONNECTION_VERIFIED = "DATABASE_STRUCTURE_CONNECTION_VERIFIED"
FINAL_BLOCKED = "DATABASE_STRUCTURE_AUDIT_BLOCKED"

DEFAULT_SCHEMAS = ("staging", "public", "ops", "documentation", "work")
DEFAULT_OUTPUT = Path("reports/documentation/database_audit")

LARGE_OBJECT_BYTES = 100 * 1024 * 1024
STALE_ANALYZE_MIN_ROWS = 1000
DEAD_TUPLE_MIN_TOTAL = 1000
DEAD_TUPLE_RATIO = 0.20


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Exportuje úplný read-only audit databázové struktury MatchMatrix."
    )
    parser.add_argument("--dsn", help="Volitelný PostgreSQL DSN.")
    parser.add_argument("--host", default=os.environ.get("PGHOST", "localhost"))
    parser.add_argument("--port", type=int, default=int(os.environ.get("PGPORT", "5432")))
    parser.add_argument("--dbname", default=os.environ.get("PGDATABASE", "matchmatrix"))
    parser.add_argument("--user", default=os.environ.get("PGUSER", "matchmatrix"))
    parser.add_argument(
        "--password",
        default=(
            os.environ.get("MATCHMATRIX_DB_PASSWORD")
            or os.environ.get("PGPASSWORD")
            or "matchmatrix_pass"
        ),
        help=argparse.SUPPRESS,
    )
    parser.add_argument(
        "--schemas",
        default=",".join(DEFAULT_SCHEMAS),
        help="Čárkou oddělený seznam schémat.",
    )
    parser.add_argument("--output-dir")
    parser.add_argument("--statement-timeout-ms", type=int, default=120000)
    parser.add_argument("--lock-timeout-ms", type=int, default=5000)
    parser.add_argument("--no-definitions", action="store_true")
    parser.add_argument("--validate-connection-only", action="store_true")
    return parser.parse_args()


def parse_schemas(value: str) -> list[str]:
    result: list[str] = []
    for raw in value.split(","):
        name = raw.strip()
        if not name:
            continue
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_$]*", name):
            raise ValueError(f"Neplatný název schématu: {name!r}")
        if name not in result:
            result.append(name)
    if not result:
        raise ValueError("Musí být zadáno alespoň jedno schéma.")
    return result


def resolve_output(root: Path, value: str | None) -> Path:
    path = Path(value) if value else DEFAULT_OUTPUT
    return (path if path.is_absolute() else root / path).resolve()


def run_git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=root,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    return result.stdout.strip() if result.returncode == 0 else ""


def git_state(root: Path) -> dict[str, Any]:
    status = run_git(root, "status", "--porcelain")
    return {
        "branch": run_git(root, "branch", "--show-current"),
        "commit": run_git(root, "rev-parse", "HEAD"),
        "origin_main": run_git(root, "rev-parse", "origin/main"),
        "dirty": bool(status),
        "dirty_lines": status.splitlines(),
    }


def sanitize_dsn(value: str | None) -> str | None:
    if not value:
        return None
    value = re.sub(
        r"(?i)(password\s*=\s*)(?:'[^']*'|\"[^\"]*\"|\S+)",
        r"\1***",
        value,
    )
    return re.sub(
        r"(?i)(postgres(?:ql)?://[^:/@\s]+:)[^@/\s]+(@)",
        r"\1***\2",
        value,
    )


def connection_description(args: argparse.Namespace) -> dict[str, Any]:
    if args.dsn:
        return {"mode": "DSN", "dsn_sanitized": sanitize_dsn(args.dsn)}
    return {
        "mode": "PARAMETERS",
        "host": args.host,
        "port": args.port,
        "dbname": args.dbname,
        "user": args.user,
        "password": "***",
    }


def connect_database(args: argparse.Namespace):
    try:
        import psycopg2
    except ImportError as exc:
        raise RuntimeError(
            "Chybí psycopg2. Použij Python prostředí panelu nebo nainstaluj "
            "psycopg2-binary."
        ) from exc

    if args.dsn:
        connection = psycopg2.connect(args.dsn)
    else:
        connection = psycopg2.connect(
            host=args.host,
            port=args.port,
            dbname=args.dbname,
            user=args.user,
            password=args.password,
        )
    connection.set_session(
        isolation_level="REPEATABLE READ",
        readonly=True,
        autocommit=False,
    )
    return connection


def query_dicts(cursor, sql: str, params: Sequence[Any] = ()) -> list[dict[str, Any]]:
    cursor.execute(sql, params)
    columns = [item.name for item in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def scalar(cursor, sql: str, params: Sequence[Any] = ()) -> Any:
    cursor.execute(sql, params)
    row = cursor.fetchone()
    return row[0] if row else None


def schema_filter(column: str, schemas: Sequence[str]) -> str:
    return f"{column} IN ({', '.join(['%s'] * len(schemas))})"


def json_default(value: Any) -> Any:
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, Path):
        return str(value)
    if isinstance(value, bytes):
        return value.hex()
    return str(value)


def normalize_csv(value: Any) -> Any:
    if value is None:
        return ""
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    if isinstance(value, (dict, list, tuple, set)):
        return json.dumps(value, ensure_ascii=False, default=json_default)
    return value


def write_json(path: Path, payload: Mapping[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, default=json_default),
        encoding="utf-8",
    )


def write_csv(path: Path, rows: Sequence[Mapping[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fields: list[str] = []
    seen: set[str] = set()
    for row in rows:
        for key in row:
            if key not in seen:
                seen.add(key)
                fields.append(key)
    if not fields:
        fields = ["status"]

    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for row in rows:
            writer.writerow({field: normalize_csv(row.get(field)) for field in fields})


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def format_bytes(value: int | None) -> str:
    size = int(value or 0)
    amount = float(size)
    for unit in ("B", "kB", "MB", "GB", "TB"):
        if amount < 1024 or unit == "TB":
            return f"{int(amount)} B" if unit == "B" else f"{amount:.2f} {unit}"
        amount /= 1024
    return str(size)


def governance_key(row: Mapping[str, Any]) -> tuple[str | None, str | None]:
    schema_keys = ("schema_name", "object_schema", "table_schema", "schema")
    object_keys = ("object_name", "table_name", "relation_name", "name")
    schema_name = next((str(row[k]) for k in schema_keys if row.get(k)), None)
    object_name = next((str(row[k]) for k in object_keys if row.get(k)), None)
    return schema_name, object_name


def governance_status(row: Mapping[str, Any]) -> str | None:
    for key in (
        "governance_status",
        "status",
        "object_status",
        "lifecycle_status",
        "classification",
    ):
        if row.get(key) not in (None, ""):
            return str(row[key])
    return None


def attach_governance(
    objects: list[dict[str, Any]],
    governance_rows: Sequence[Mapping[str, Any]],
) -> dict[str, Any]:
    by_key: dict[tuple[str, str], list[Mapping[str, Any]]] = defaultdict(list)
    usable = 0
    for row in governance_rows:
        schema_name, object_name = governance_key(row)
        if schema_name and object_name:
            by_key[(schema_name, object_name)].append(row)
            usable += 1

    matched = ambiguous = 0
    for item in objects:
        matches = by_key.get((str(item["schema_name"]), str(item["object_name"])), [])
        if len(matches) == 1:
            matched += 1
            item["governance_status"] = governance_status(matches[0])
            item["governance_record"] = dict(matches[0])
        elif len(matches) > 1:
            ambiguous += 1
            item["governance_status"] = "AMBIGUOUS_MULTIPLE_RECORDS"
            item["governance_record"] = [dict(row) for row in matches]
        else:
            item["governance_status"] = None
            item["governance_record"] = None

    return {
        "registry_rows": len(governance_rows),
        "usable_registry_rows": usable,
        "matched_objects": matched,
        "ambiguous_objects": ambiguous,
        "unmatched_objects": len(objects) - matched - ambiguous,
    }


def build_warnings(
    objects: Sequence[Mapping[str, Any]],
    governance_summary: Mapping[str, Any],
) -> list[dict[str, Any]]:
    warnings: list[dict[str, Any]] = []
    name_schemas: dict[str, set[str]] = defaultdict(set)

    for item in objects:
        schema_name = str(item["schema_name"])
        object_name = str(item["object_name"])
        name_schemas[object_name].add(schema_name)

        object_type = str(item["object_type"])
        estimated = int(item.get("estimated_rows") or 0)
        live = int(item.get("statistics_live_rows") or 0)
        dead = int(item.get("statistics_dead_rows") or 0)
        total_bytes = int(item.get("total_bytes") or 0)
        table_bytes = int(item.get("table_bytes") or 0)
        index_bytes = int(item.get("index_bytes") or 0)
        comment = str(item.get("object_comment") or "")
        gov = str(item.get("governance_status") or "")
        searchable = f"{schema_name} {object_name} {comment} {gov}".lower()

        def add(severity: str, code: str, message: str, evidence: Mapping[str, Any]):
            warnings.append(
                {
                    "severity": severity,
                    "code": code,
                    "schema_name": schema_name,
                    "object_name": object_name,
                    "message": message,
                    "evidence": dict(evidence),
                }
            )

        if (
            object_type in {"TABLE", "PARTITIONED_TABLE"}
            and not bool(item.get("has_primary_key"))
        ):
            add(
                "HIGH" if max(estimated, live) >= 1000 else "MEDIUM",
                "TABLE_WITHOUT_PRIMARY_KEY",
                "Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt.",
                {"estimated_rows": estimated, "statistics_live_rows": live},
            )

        if total_bytes >= LARGE_OBJECT_BYTES:
            add(
                "INFO",
                "LARGE_DATABASE_OBJECT",
                "Objekt přesahuje 100 MB a musí být zahrnut do kapacitního a zálohovacího plánu.",
                {"total_bytes": total_bytes, "total_size": format_bytes(total_bytes)},
            )

        if (
            object_type in {"TABLE", "PARTITIONED_TABLE"}
            and max(estimated, live) >= STALE_ANALYZE_MIN_ROWS
            and not item.get("last_analyze")
            and not item.get("last_autoanalyze")
        ):
            add(
                "MEDIUM",
                "ANALYZE_NOT_RECORDED",
                "U větší tabulky není evidován ANALYZE ani AUTOANALYZE.",
                {"estimated_rows": estimated, "statistics_live_rows": live},
            )

        total_stat = live + dead
        if total_stat >= DEAD_TUPLE_MIN_TOTAL and dead / total_stat >= DEAD_TUPLE_RATIO:
            add(
                "MEDIUM",
                "HIGH_DEAD_TUPLE_RATIO",
                "Podíl dead tuples podle statistik přesahuje 20 %.",
                {
                    "statistics_live_rows": live,
                    "statistics_dead_rows": dead,
                    "dead_ratio_percent": round(dead * 100.0 / total_stat, 2),
                },
            )

        if table_bytes > 0 and index_bytes > table_bytes * 2:
            add(
                "INFO",
                "INDEXES_LARGER_THAN_TABLE",
                "Indexy jsou více než dvojnásobně větší než data tabulky.",
                {"table_size": format_bytes(table_bytes), "index_size": format_bytes(index_bytes)},
            )

        if any(
            token in searchable
            for token in (
                "deprecated",
                "legacy",
                "drop_candidate",
                "drop candidate",
                "transitional",
                "historical_only",
            )
        ):
            add(
                "HIGH",
                "LEGACY_OR_DEPRECATED_OBJECT",
                "Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated.",
                {"comment": comment, "governance_status": gov},
            )

    for object_name, schemas in sorted(name_schemas.items()):
        if len(schemas) > 1:
            warnings.append(
                {
                    "severity": "INFO",
                    "code": "SAME_OBJECT_NAME_IN_MULTIPLE_SCHEMAS",
                    "schema_name": ",".join(sorted(schemas)),
                    "object_name": object_name,
                    "message": "Stejný název existuje ve více schématech; používat kvalifikované názvy.",
                    "evidence": {"schemas": sorted(schemas)},
                }
            )

    if int(governance_summary.get("registry_rows") or 0) == 0:
        warnings.append(
            {
                "severity": "HIGH",
                "code": "GOVERNANCE_REGISTRY_EMPTY_OR_UNAVAILABLE",
                "schema_name": "ops",
                "object_name": "database_object_governance",
                "message": "Governance registr není dostupný nebo je prázdný.",
                "evidence": dict(governance_summary),
            }
        )
    elif int(governance_summary.get("unmatched_objects") or 0) > 0:
        warnings.append(
            {
                "severity": "MEDIUM",
                "code": "OBJECTS_WITHOUT_GOVERNANCE_MATCH",
                "schema_name": "",
                "object_name": "",
                "message": "Část databázových objektů nemá jednoznačnou shodu v governance registru.",
                "evidence": dict(governance_summary),
            }
        )

    order = {"CRITICAL": 0, "HIGH": 1, "MEDIUM": 2, "LOW": 3, "INFO": 4}
    warnings.sort(
        key=lambda item: (
            order.get(str(item["severity"]), 9),
            str(item.get("schema_name") or ""),
            str(item.get("object_name") or ""),
            str(item["code"]),
        )
    )
    return warnings


def md_table(headers: Sequence[str], rows: Sequence[Sequence[Any]]) -> list[str]:
    lines = [
        "| " + " | ".join(headers) + " |",
        "|" + "|".join("---" for _ in headers) + "|",
    ]
    for row in rows:
        lines.append(
            "| "
            + " | ".join(
                str(value if value is not None else "")
                .replace("|", "\\|")
                .replace("\n", " ")
                for value in row
            )
            + " |"
        )
    return lines


def build_markdown(payload: Mapping[str, Any]) -> str:
    summary = payload["summary"]
    database = payload["database"]
    git = payload["git"]
    data = payload["datasets"]
    warnings = data["warnings"]
    severity = Counter(str(row.get("severity") or "UNKNOWN") for row in warnings)

    lines: list[str] = [
        "# MATCHMATRIX – READ-ONLY AUDIT DATABÁZOVÉ STRUKTURY",
        "",
        "## Informace o auditu",
        "",
        "| Položka | Hodnota |",
        "|---|---|",
        f"| Document ID nástroje | `{DOCUMENT_ID}` |",
        f"| Engine | `{ENGINE_VERSION}` |",
        f"| Vygenerováno | {payload['generated_at']} |",
        f"| Databáze | `{database.get('current_database', '')}` |",
        f"| Uživatel | `{database.get('current_user', '')}` |",
        f"| PostgreSQL | {database.get('server_version', '')} |",
        f"| Read-only | `{database.get('transaction_read_only', '')}` |",
        f"| Izolace | `{database.get('transaction_isolation', '')}` |",
        f"| Git commit | `{git.get('commit', '')}` |",
        f"| Git dirty | `{git.get('dirty', False)}` |",
        f"| Schémata | {', '.join(payload['schemas'])} |",
        f"| Final status | `{payload['final_status']}` |",
        "",
        "## Souhrn",
        "",
        "| Metrika | Hodnota |",
        "|---|---:|",
        f"| Schémata | {summary['schemas']} |",
        f"| Objekty | {summary['objects']} |",
        f"| Tabulky | {summary['tables']} |",
        f"| Views | {summary['views']} |",
        f"| Materialized views | {summary['materialized_views']} |",
        f"| Sekvence | {summary['sequences']} |",
        f"| Sloupce | {summary['columns']} |",
        f"| Constraints | {summary['constraints']} |",
        f"| Indexy | {summary['indexes']} |",
        f"| Rutiny | {summary['routines']} |",
        f"| Triggery | {summary['triggers']} |",
        f"| Závislosti | {summary['dependencies']} |",
        f"| Oprávnění | {summary['privileges']} |",
        f"| Typy | {summary['types']} |",
        f"| Celková velikost | {summary['total_object_size']} |",
        f"| Varování | {summary['warnings']} |",
        f"| HIGH | {severity.get('HIGH', 0)} |",
        f"| MEDIUM | {severity.get('MEDIUM', 0)} |",
        f"| INFO | {severity.get('INFO', 0)} |",
        "",
        "## Schémata",
        "",
    ]

    lines.extend(
        md_table(
            ("Schéma", "Vlastník", "Tabulky", "Views", "Sekvence", "Funkce", "Velikost", "Komentář"),
            [
                (
                    row.get("schema_name"),
                    row.get("schema_owner"),
                    row.get("tables"),
                    row.get("views"),
                    row.get("sequences"),
                    row.get("functions"),
                    row.get("total_relation_size"),
                    row.get("schema_comment") or "",
                )
                for row in data["schemas"]
            ],
        )
    )

    largest = sorted(
        data["objects"],
        key=lambda row: int(row.get("total_bytes") or 0),
        reverse=True,
    )[:30]
    lines.extend(["", "## Největší objekty", ""])
    lines.extend(
        md_table(
            ("Objekt", "Typ", "Odhad řádků", "Celkem", "Data", "Indexy", "PK", "Governance"),
            [
                (
                    f"{row.get('schema_name')}.{row.get('object_name')}",
                    row.get("object_type"),
                    row.get("estimated_rows"),
                    row.get("total_size"),
                    row.get("table_size"),
                    row.get("index_size"),
                    row.get("has_primary_key"),
                    row.get("governance_status") or "",
                )
                for row in largest
            ],
        )
    )

    no_pk = [
        row
        for row in data["objects"]
        if row.get("object_type") in {"TABLE", "PARTITIONED_TABLE"}
        and not bool(row.get("has_primary_key"))
    ]
    lines.extend(["", "## Tabulky bez primárního klíče", ""])
    if no_pk:
        lines.extend(
            md_table(
                ("Tabulka", "Odhad řádků", "Velikost", "Indexy", "Komentář"),
                [
                    (
                        f"{row.get('schema_name')}.{row.get('object_name')}",
                        row.get("estimated_rows"),
                        row.get("total_size"),
                        row.get("index_count"),
                        row.get("object_comment") or "",
                    )
                    for row in no_pk
                ],
            )
        )
    else:
        lines.append("_Nenalezeny žádné tabulky bez primárního klíče._")

    lines.extend(["", "## Governance pokrytí", ""])
    gov = payload["governance_summary"]
    lines.extend(
        [
            "| Metrika | Hodnota |",
            "|---|---:|",
            f"| Řádky registru | {gov.get('registry_rows', 0)} |",
            f"| Použitelné řádky | {gov.get('usable_registry_rows', 0)} |",
            f"| Spárované objekty | {gov.get('matched_objects', 0)} |",
            f"| Nejednoznačné | {gov.get('ambiguous_objects', 0)} |",
            f"| Nespárované | {gov.get('unmatched_objects', 0)} |",
        ]
    )

    lines.extend(["", "## Varování a kontrolní nálezy", ""])
    if warnings:
        lines.extend(
            md_table(
                ("Závažnost", "Kód", "Objekt", "Popis"),
                [
                    (
                        row.get("severity"),
                        row.get("code"),
                        (
                            f"{row.get('schema_name')}.{row.get('object_name')}"
                            if row.get("schema_name") or row.get("object_name")
                            else ""
                        ),
                        row.get("message"),
                    )
                    for row in warnings
                ],
            )
        )
    else:
        lines.append("_Audit nevytvořil žádná varování._")

    lines.extend(
        [
            "",
            "## Interpretace",
            "",
            "- Počty řádků jsou odhady z PostgreSQL statistik.",
            "- Absence PK je nález k posouzení, ne automatický pokyn k opravě.",
            "- Legacy/deprecated objekt se nesmí odstranit bez auditu závislostí.",
            "- Report je podklad pro MM-DB-001 a MM-DB-002, nikoli migrační plán.",
            "",
            "## Bezpečnostní závěr",
            "",
            "- Databáze nebyla změněna.",
            "- Audit proběhl v READ ONLY / REPEATABLE READ.",
            "- Transakce byla rollbacknuta.",
            "- Výstupy jsou pouze v reports/documentation/database_audit/.",
            "",
            "## Další krok",
            "",
            "Z JSON a CSV výstupů vytvořit první ověřenou verzi "
            "`MM-DB-001_ARCHITEKTURA_DATABAZE_MATCHMATRIX.md`.",
            "",
            f"**FINAL STATUS:** `{payload['final_status']}`",
            "",
        ]
    )
    return "\n".join(lines)


def collect_audit(
    connection,
    schemas: Sequence[str],
    include_definitions: bool,
    statement_timeout_ms: int,
    lock_timeout_ms: int,
) -> dict[str, Any]:
    params = list(schemas)

    with connection.cursor() as cursor:
        scalar(cursor, "SELECT set_config('statement_timeout', %s, true)", (f"{statement_timeout_ms}ms",))
        scalar(cursor, "SELECT set_config('lock_timeout', %s, true)", (f"{lock_timeout_ms}ms",))
        scalar(cursor, "SELECT set_config('idle_in_transaction_session_timeout', %s, true)", ("180000ms",))

        read_only = str(scalar(cursor, "SHOW transaction_read_only")).lower()
        isolation = str(scalar(cursor, "SHOW transaction_isolation"))
        if read_only not in {"on", "true"}:
            raise RuntimeError("Transakce není READ ONLY.")

        database = query_dicts(
            cursor,
            """
            SELECT
                current_database() AS current_database,
                current_user AS current_user,
                version() AS server_version,
                inet_server_addr()::text AS server_address,
                inet_server_port() AS server_port,
                pg_postmaster_start_time() AS postmaster_started_at,
                current_setting('transaction_read_only') AS transaction_read_only,
                current_setting('transaction_isolation') AS transaction_isolation
            """,
        )[0]

        sf = schema_filter("n.nspname", schemas)
        schemas_sql = f"""
            WITH relation_counts AS (
                SELECT
                    c.relnamespace AS schema_oid,
                    COUNT(*) FILTER (WHERE c.relkind IN ('r', 'p')) AS tables,
                    COUNT(*) FILTER (WHERE c.relkind = 'v') AS views,
                    COUNT(*) FILTER (WHERE c.relkind = 'm') AS materialized_views,
                    COUNT(*) FILTER (WHERE c.relkind = 'S') AS sequences,
                    COUNT(*) FILTER (WHERE c.relkind = 'f') AS foreign_tables,
                    COALESCE(SUM(CASE WHEN c.relkind IN ('r','p','m','S')
                        THEN pg_total_relation_size(c.oid) ELSE 0 END), 0)
                        AS total_relation_bytes
                FROM pg_class c
                GROUP BY c.relnamespace
            ),
            routine_counts AS (
                SELECT
                    p.pronamespace AS schema_oid,
                    COUNT(*) FILTER (WHERE p.prokind = 'f') AS functions,
                    COUNT(*) FILTER (WHERE p.prokind = 'p') AS procedures,
                    COUNT(*) FILTER (WHERE p.prokind = 'a') AS aggregate_functions,
                    COUNT(*) FILTER (WHERE p.prokind = 'w') AS window_functions
                FROM pg_proc p
                GROUP BY p.pronamespace
            )
            SELECT
                n.nspname AS schema_name,
                pg_get_userbyid(n.nspowner) AS schema_owner,
                COALESCE(r.tables, 0) AS tables,
                COALESCE(r.views, 0) AS views,
                COALESCE(r.materialized_views, 0) AS materialized_views,
                COALESCE(r.sequences, 0) AS sequences,
                COALESCE(r.foreign_tables, 0) AS foreign_tables,
                COALESCE(fn.functions, 0) AS functions,
                COALESCE(fn.procedures, 0) AS procedures,
                COALESCE(fn.aggregate_functions, 0) AS aggregate_functions,
                COALESCE(fn.window_functions, 0) AS window_functions,
                pg_size_pretty(COALESCE(r.total_relation_bytes, 0))
                    AS total_relation_size,
                COALESCE(r.total_relation_bytes, 0) AS total_relation_bytes,
                obj_description(n.oid, 'pg_namespace') AS schema_comment
            FROM pg_namespace n
            LEFT JOIN relation_counts r ON r.schema_oid = n.oid
            LEFT JOIN routine_counts fn ON fn.schema_oid = n.oid
            WHERE {sf}
            ORDER BY COALESCE(r.total_relation_bytes, 0) DESC, n.nspname
        """
        schema_rows = query_dicts(cursor, schemas_sql, params)

        objects_sql = f"""
            SELECT
                n.nspname AS schema_name,
                c.relname AS object_name,
                CASE c.relkind
                    WHEN 'r' THEN 'TABLE'
                    WHEN 'p' THEN 'PARTITIONED_TABLE'
                    WHEN 'v' THEN 'VIEW'
                    WHEN 'm' THEN 'MATERIALIZED_VIEW'
                    WHEN 'S' THEN 'SEQUENCE'
                    WHEN 'f' THEN 'FOREIGN_TABLE'
                    ELSE c.relkind::text
                END AS object_type,
                pg_get_userbyid(c.relowner) AS object_owner,
                c.relpersistence AS persistence,
                c.reltuples::bigint AS estimated_rows,
                COALESCE(st.n_live_tup, 0)::bigint AS statistics_live_rows,
                COALESCE(st.n_dead_tup, 0)::bigint AS statistics_dead_rows,
                CASE WHEN c.relkind IN ('r','p','m','S')
                    THEN pg_total_relation_size(c.oid) ELSE 0 END AS total_bytes,
                CASE WHEN c.relkind IN ('r','p','m')
                    THEN pg_relation_size(c.oid) ELSE 0 END AS table_bytes,
                CASE WHEN c.relkind IN ('r','p','m')
                    THEN pg_indexes_size(c.oid) ELSE 0 END AS index_bytes,
                pg_size_pretty(CASE WHEN c.relkind IN ('r','p','m','S')
                    THEN pg_total_relation_size(c.oid) ELSE 0 END) AS total_size,
                pg_size_pretty(CASE WHEN c.relkind IN ('r','p','m')
                    THEN pg_relation_size(c.oid) ELSE 0 END) AS table_size,
                pg_size_pretty(CASE WHEN c.relkind IN ('r','p','m')
                    THEN pg_indexes_size(c.oid) ELSE 0 END) AS index_size,
                EXISTS (
                    SELECT 1 FROM pg_constraint con
                    WHERE con.conrelid = c.oid AND con.contype = 'p'
                ) AS has_primary_key,
                (SELECT COUNT(*) FROM pg_constraint con
                    WHERE con.conrelid = c.oid AND con.contype = 'f')
                    AS foreign_key_count,
                (SELECT COUNT(*) FROM pg_constraint con
                    WHERE con.conrelid = c.oid AND con.contype = 'u')
                    AS unique_constraint_count,
                (SELECT COUNT(*) FROM pg_constraint con
                    WHERE con.conrelid = c.oid AND con.contype = 'c')
                    AS check_constraint_count,
                (SELECT COUNT(*) FROM pg_index i WHERE i.indrelid = c.oid)
                    AS index_count,
                (SELECT COUNT(*) FROM pg_inherits i WHERE i.inhparent = c.oid)
                    AS direct_partition_count,
                st.last_analyze,
                st.last_autoanalyze,
                st.last_vacuum,
                st.last_autovacuum,
                obj_description(c.oid, 'pg_class') AS object_comment,
                CASE WHEN %s::boolean AND c.relkind IN ('v','m')
                    THEN pg_get_viewdef(c.oid, true) ELSE NULL END
                    AS object_definition
            FROM pg_class c
            JOIN pg_namespace n ON n.oid = c.relnamespace
            LEFT JOIN pg_stat_all_tables st ON st.relid = c.oid
            WHERE {sf}
              AND c.relkind IN ('r','p','v','m','S','f')
            ORDER BY total_bytes DESC, n.nspname, c.relname
        """
        object_rows = query_dicts(cursor, objects_sql, [include_definitions, *params])

        cf = schema_filter("cols.table_schema", schemas)
        column_rows = query_dicts(
            cursor,
            f"""
            SELECT
                cols.table_schema AS schema_name,
                cols.table_name AS object_name,
                cols.ordinal_position,
                cols.column_name,
                cols.data_type,
                cols.udt_schema,
                cols.udt_name,
                cols.is_nullable,
                cols.column_default,
                cols.is_identity,
                cols.identity_generation,
                cols.is_generated,
                cols.generation_expression,
                cols.character_maximum_length,
                cols.numeric_precision,
                cols.numeric_scale,
                cols.datetime_precision,
                col_description(cls.oid, att.attnum) AS column_comment
            FROM information_schema.columns cols
            JOIN pg_namespace ns ON ns.nspname = cols.table_schema
            JOIN pg_class cls
              ON cls.relnamespace = ns.oid AND cls.relname = cols.table_name
            JOIN pg_attribute att
              ON att.attrelid = cls.oid AND att.attname = cols.column_name
             AND att.attnum > 0 AND NOT att.attisdropped
            WHERE {cf}
            ORDER BY cols.table_schema, cols.table_name, cols.ordinal_position
            """,
            params,
        )

        constraint_rows = query_dicts(
            cursor,
            f"""
            SELECT
                n.nspname AS schema_name,
                c.relname AS object_name,
                con.conname AS constraint_name,
                CASE con.contype
                    WHEN 'p' THEN 'PRIMARY_KEY'
                    WHEN 'f' THEN 'FOREIGN_KEY'
                    WHEN 'u' THEN 'UNIQUE'
                    WHEN 'c' THEN 'CHECK'
                    WHEN 'x' THEN 'EXCLUSION'
                    ELSE con.contype::text
                END AS constraint_type,
                pg_get_constraintdef(con.oid, true) AS constraint_definition,
                rn.nspname AS referenced_schema,
                rc.relname AS referenced_object,
                con.condeferrable AS is_deferrable,
                con.condeferred AS initially_deferred,
                con.convalidated AS is_validated
            FROM pg_constraint con
            JOIN pg_class c ON c.oid = con.conrelid
            JOIN pg_namespace n ON n.oid = c.relnamespace
            LEFT JOIN pg_class rc ON rc.oid = con.confrelid
            LEFT JOIN pg_namespace rn ON rn.oid = rc.relnamespace
            WHERE {sf}
            ORDER BY n.nspname, c.relname, constraint_type, con.conname
            """,
            params,
        )

        index_rows = query_dicts(
            cursor,
            f"""
            SELECT
                n.nspname AS schema_name,
                tbl.relname AS object_name,
                idx.relname AS index_name,
                am.amname AS access_method,
                i.indisprimary AS is_primary,
                i.indisunique AS is_unique,
                i.indisvalid AS is_valid,
                i.indisready AS is_ready,
                pg_relation_size(idx.oid) AS index_bytes,
                pg_size_pretty(pg_relation_size(idx.oid)) AS index_size,
                pg_get_indexdef(idx.oid) AS index_definition,
                obj_description(idx.oid, 'pg_class') AS index_comment
            FROM pg_index i
            JOIN pg_class tbl ON tbl.oid = i.indrelid
            JOIN pg_namespace n ON n.oid = tbl.relnamespace
            JOIN pg_class idx ON idx.oid = i.indexrelid
            JOIN pg_am am ON am.oid = idx.relam
            WHERE {sf}
            ORDER BY n.nspname, tbl.relname, i.indisprimary DESC, idx.relname
            """,
            params,
        )

        routine_rows = query_dicts(
            cursor,
            f"""
            SELECT
                n.nspname AS schema_name,
                p.proname AS routine_name,
                p.oid::regprocedure::text AS routine_signature,
                CASE p.prokind
                    WHEN 'f' THEN 'FUNCTION'
                    WHEN 'p' THEN 'PROCEDURE'
                    WHEN 'a' THEN 'AGGREGATE'
                    WHEN 'w' THEN 'WINDOW_FUNCTION'
                    ELSE p.prokind::text
                END AS routine_type,
                pg_get_userbyid(p.proowner) AS routine_owner,
                l.lanname AS language,
                pg_get_function_identity_arguments(p.oid) AS identity_arguments,
                pg_get_function_result(p.oid) AS result_type,
                CASE p.provolatile
                    WHEN 'i' THEN 'IMMUTABLE'
                    WHEN 's' THEN 'STABLE'
                    WHEN 'v' THEN 'VOLATILE'
                END AS volatility,
                p.prosecdef AS security_definer,
                obj_description(p.oid, 'pg_proc') AS routine_comment,
                CASE WHEN %s::boolean THEN pg_get_functiondef(p.oid)
                    ELSE NULL END AS routine_definition
            FROM pg_proc p
            JOIN pg_namespace n ON n.oid = p.pronamespace
            JOIN pg_language l ON l.oid = p.prolang
            WHERE {sf}
            ORDER BY n.nspname, p.proname, routine_signature
            """,
            [include_definitions, *params],
        )

        trigger_rows = query_dicts(
            cursor,
            f"""
            SELECT
                n.nspname AS schema_name,
                c.relname AS object_name,
                t.tgname AS trigger_name,
                t.tgenabled AS enabled_mode,
                pg_get_triggerdef(t.oid, true) AS trigger_definition,
                pn.nspname AS function_schema,
                p.proname AS function_name
            FROM pg_trigger t
            JOIN pg_class c ON c.oid = t.tgrelid
            JOIN pg_namespace n ON n.oid = c.relnamespace
            JOIN pg_proc p ON p.oid = t.tgfoid
            JOIN pg_namespace pn ON pn.oid = p.pronamespace
            WHERE {sf} AND NOT t.tgisinternal
            ORDER BY n.nspname, c.relname, t.tgname
            """,
            params,
        )

        left = schema_filter("sn.nspname", schemas)
        right = schema_filter("rn.nspname", schemas)
        dependency_rows = query_dicts(
            cursor,
            f"""
            SELECT DISTINCT
                sn.nspname AS source_schema,
                sc.relname AS source_object,
                rn.nspname AS referenced_schema,
                rc.relname AS referenced_object,
                d.deptype AS dependency_type
            FROM pg_depend d
            JOIN pg_class sc ON sc.oid = d.objid
            JOIN pg_namespace sn ON sn.oid = sc.relnamespace
            JOIN pg_class rc ON rc.oid = d.refobjid
            JOIN pg_namespace rn ON rn.oid = rc.relnamespace
            WHERE d.classid = 'pg_class'::regclass
              AND d.refclassid = 'pg_class'::regclass
              AND {left}
              AND {right}
              AND d.objid <> d.refobjid
            ORDER BY sn.nspname, sc.relname, rn.nspname, rc.relname
            """,
            [*params, *params],
        )

        pf = schema_filter("table_schema", schemas)
        privilege_rows = query_dicts(
            cursor,
            f"""
            SELECT
                grantor,
                grantee,
                table_schema AS schema_name,
                table_name AS object_name,
                privilege_type,
                is_grantable,
                with_hierarchy
            FROM information_schema.role_table_grants
            WHERE {pf}
            ORDER BY table_schema, table_name, grantee, privilege_type
            """,
            params,
        )

        type_rows = query_dicts(
            cursor,
            f"""
            SELECT
                n.nspname AS schema_name,
                t.typname AS type_name,
                CASE t.typtype
                    WHEN 'e' THEN 'ENUM'
                    WHEN 'd' THEN 'DOMAIN'
                    WHEN 'c' THEN 'COMPOSITE'
                    WHEN 'r' THEN 'RANGE'
                    WHEN 'm' THEN 'MULTIRANGE'
                    ELSE t.typtype::text
                END AS type_kind,
                pg_get_userbyid(t.typowner) AS type_owner,
                format_type(t.typbasetype, t.typtypmod) AS domain_base_type,
                t.typnotnull AS domain_not_null,
                (SELECT string_agg(e.enumlabel, ', ' ORDER BY e.enumsortorder)
                 FROM pg_enum e WHERE e.enumtypid = t.oid) AS enum_values,
                obj_description(t.oid, 'pg_type') AS type_comment
            FROM pg_type t
            JOIN pg_namespace n ON n.oid = t.typnamespace
            WHERE {sf}
              AND t.typtype IN ('e','d','c','r','m')
              AND (
                    t.typtype <> 'c'
                    OR EXISTS (
                        SELECT 1 FROM pg_class c
                        WHERE c.oid = t.typrelid AND c.relkind = 'c'
                    )
              )
            ORDER BY n.nspname, t.typname
            """,
            params,
        )

        governance_rows: list[dict[str, Any]] = []
        if bool(scalar(cursor, "SELECT to_regclass('ops.database_object_governance') IS NOT NULL")):
            raw = query_dicts(
                cursor,
                "SELECT to_jsonb(g) AS governance_record "
                "FROM ops.database_object_governance g ORDER BY 1::text",
            )
            governance_rows = [
                row["governance_record"]
                for row in raw
                if isinstance(row.get("governance_record"), dict)
            ]

    governance_summary = attach_governance(object_rows, governance_rows)
    warnings = build_warnings(object_rows, governance_summary)

    return {
        "database": database,
        "transaction_read_only": read_only,
        "transaction_isolation": isolation,
        "datasets": {
            "schemas": schema_rows,
            "objects": object_rows,
            "columns": column_rows,
            "constraints": constraint_rows,
            "indexes": index_rows,
            "routines": routine_rows,
            "triggers": trigger_rows,
            "dependencies": dependency_rows,
            "privileges": privilege_rows,
            "types": type_rows,
            "governance": governance_rows,
            "warnings": warnings,
        },
        "governance_summary": governance_summary,
    }


def write_outputs(output_dir: Path, payload: dict[str, Any]) -> dict[str, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().astimezone().strftime("%Y%m%d_%H%M%S")

    paths: dict[str, Path] = {
        "json": output_dir / f"database_structure_audit_{stamp}.json",
        "markdown": output_dir / f"database_structure_audit_{stamp}.md",
    }
    prefixes = {
        "schemas": "database_structure_schemas",
        "objects": "database_structure_objects",
        "columns": "database_structure_columns",
        "constraints": "database_structure_constraints",
        "indexes": "database_structure_indexes",
        "routines": "database_structure_routines",
        "triggers": "database_structure_triggers",
        "dependencies": "database_structure_dependencies",
        "privileges": "database_structure_privileges",
        "types": "database_structure_types",
        "governance": "database_structure_governance",
        "warnings": "database_structure_warnings",
    }
    for key, prefix in prefixes.items():
        paths[key] = output_dir / f"{prefix}_{stamp}.csv"

    payload["output_files"] = {key: str(path) for key, path in paths.items()}
    write_json(paths["json"], payload)
    paths["markdown"].write_text(build_markdown(payload), encoding="utf-8")
    for key in prefixes:
        write_csv(paths[key], payload["datasets"][key])

    latest: dict[str, Path] = {
        "json": output_dir / "database_structure_audit_latest.json",
        "markdown": output_dir / "database_structure_audit_latest.md",
    }
    for key, prefix in prefixes.items():
        latest[key] = output_dir / f"{prefix}_latest.csv"
    for key, path in paths.items():
        shutil.copyfile(path, latest[key])

    payload["output_hashes_sha256"] = {key: sha256_file(path) for key, path in paths.items()}
    write_json(paths["json"], payload)
    shutil.copyfile(paths["json"], latest["json"])
    return paths


def main() -> int:
    args = parse_args()
    root = project_root()
    output_dir = resolve_output(root, args.output_dir)
    started = utc_now()
    connection = None

    print("MATCHMATRIX DATABASE STRUCTURE AUDIT")
    print("=" * 79)
    print(f"DOCUMENT ID        : {DOCUMENT_ID}")
    print(f"PROJECT_ROOT       : {root}")
    print(f"ENGINE             : {ENGINE_VERSION}")
    print("MODE               : READ_ONLY")
    print(f"OUTPUT DIR         : {output_dir}")
    print("DATABASE WRITES    : DISABLED")
    print()

    report: dict[str, Any] = {
        "contract_version": CONTRACT_VERSION,
        "document_id": DOCUMENT_ID,
        "engine_version": ENGINE_VERSION,
        "started_at": started.isoformat(),
        "project_root": str(root),
        "mode": "READ_ONLY",
        "database_modified": False,
        "project_sources_modified": False,
        "final_status": "STARTING",
    }

    try:
        schemas = parse_schemas(args.schemas)
        if args.statement_timeout_ms <= 0 or args.lock_timeout_ms <= 0:
            raise ValueError("Timeouty musí být větší než 0.")

        report["schemas"] = schemas
        report["connection"] = connection_description(args)
        report["git"] = git_state(root)

        print("PŘIPOJENÍ")
        print("-" * 79)
        if args.dsn:
            print(f"DSN                : {sanitize_dsn(args.dsn)}")
        else:
            print(f"HOST               : {args.host}")
            print(f"PORT               : {args.port}")
            print(f"DATABASE           : {args.dbname}")
            print(f"USER               : {args.user}")
            print("PASSWORD           : ***")
        print(f"SCHEMAS            : {', '.join(schemas)}")
        print()

        connection = connect_database(args)
        with connection.cursor() as cursor:
            read_only = str(scalar(cursor, "SHOW transaction_read_only")).lower()
            if read_only not in {"on", "true"}:
                raise RuntimeError("Připojení není READ ONLY.")
            current_database = scalar(cursor, "SELECT current_database()")
            current_user = scalar(cursor, "SELECT current_user")
            server_version = scalar(cursor, "SHOW server_version")

        print("OVĚŘENÍ")
        print("-" * 79)
        print(f"DATABASE           : {current_database}")
        print(f"USER               : {current_user}")
        print(f"POSTGRESQL         : {server_version}")
        print("TRANSACTION        : READ ONLY")
        print("ISOLATION          : REPEATABLE READ")
        print()

        if args.validate_connection_only:
            connection.rollback()
            print(f"FINAL STATUS       : {FINAL_CONNECTION_VERIFIED}")
            return 0

        audit = collect_audit(
            connection,
            schemas,
            include_definitions=not args.no_definitions,
            statement_timeout_ms=args.statement_timeout_ms,
            lock_timeout_ms=args.lock_timeout_ms,
        )
        connection.rollback()

        data = audit["datasets"]
        object_counts = Counter(str(row.get("object_type") or "") for row in data["objects"])
        total_bytes = sum(int(row.get("total_bytes") or 0) for row in data["objects"])

        summary = {
            "schemas": len(data["schemas"]),
            "objects": len(data["objects"]),
            "tables": object_counts.get("TABLE", 0) + object_counts.get("PARTITIONED_TABLE", 0),
            "views": object_counts.get("VIEW", 0),
            "materialized_views": object_counts.get("MATERIALIZED_VIEW", 0),
            "sequences": object_counts.get("SEQUENCE", 0),
            "foreign_tables": object_counts.get("FOREIGN_TABLE", 0),
            "columns": len(data["columns"]),
            "constraints": len(data["constraints"]),
            "indexes": len(data["indexes"]),
            "routines": len(data["routines"]),
            "triggers": len(data["triggers"]),
            "dependencies": len(data["dependencies"]),
            "privileges": len(data["privileges"]),
            "types": len(data["types"]),
            "governance_rows": len(data["governance"]),
            "warnings": len(data["warnings"]),
            "total_object_bytes": total_bytes,
            "total_object_size": format_bytes(total_bytes),
        }

        report.update(
            {
                "generated_at": utc_now().isoformat(),
                "database": audit["database"],
                "transaction": {
                    "read_only": audit["transaction_read_only"],
                    "isolation": audit["transaction_isolation"],
                    "rolled_back_after_audit": True,
                },
                "include_definitions": not args.no_definitions,
                "summary": summary,
                "governance_summary": audit["governance_summary"],
                "datasets": data,
                "finished_at": utc_now().isoformat(),
                "final_status": FINAL_EXPORTED,
            }
        )

        paths = write_outputs(output_dir, report)
        severity = Counter(str(row.get("severity") or "") for row in data["warnings"])

        print("VÝSLEDEK AUDITU")
        print("-" * 79)
        print(f"SCHEMAS            : {summary['schemas']}")
        print(f"OBJECTS            : {summary['objects']}")
        print(f"TABLES             : {summary['tables']}")
        print(f"VIEWS              : {summary['views']}")
        print(f"COLUMNS            : {summary['columns']}")
        print(f"CONSTRAINTS        : {summary['constraints']}")
        print(f"INDEXES            : {summary['indexes']}")
        print(f"ROUTINES           : {summary['routines']}")
        print(f"TRIGGERS           : {summary['triggers']}")
        print(f"DEPENDENCIES       : {summary['dependencies']}")
        print(f"TOTAL SIZE         : {summary['total_object_size']}")
        print(f"WARNINGS           : {summary['warnings']}")
        print(f"HIGH               : {severity.get('HIGH', 0)}")
        print(f"MEDIUM             : {severity.get('MEDIUM', 0)}")
        print(f"INFO               : {severity.get('INFO', 0)}")
        print()

        print("VÝSTUPY")
        print("-" * 79)
        for key, path in paths.items():
            print(f"{key.upper():18}: {path}")
        print("DATABASE MODIFIED  : False")
        print("TRANSACTION ROLLBACK: True")
        print(f"FINAL STATUS       : {FINAL_EXPORTED}")
        return 0

    except Exception as exc:
        if connection is not None:
            try:
                connection.rollback()
            except Exception:
                pass

        report["error"] = {
            "type": type(exc).__name__,
            "message": str(exc),
            "traceback": traceback.format_exc(),
        }
        report["finished_at"] = utc_now().isoformat()
        report["final_status"] = FINAL_BLOCKED

        try:
            output_dir.mkdir(parents=True, exist_ok=True)
            failure = output_dir / "database_structure_audit_failure_latest.json"
            write_json(failure, report)
        except Exception:
            failure = None

        print("DATABASE STRUCTURE AUDIT ERROR")
        print("-" * 79)
        print(f"{type(exc).__name__}: {exc}")
        if failure:
            print(f"FAILURE REPORT     : {failure}")
        print("DATABASE MODIFIED  : False")
        print(f"FINAL STATUS       : {FINAL_BLOCKED}")
        return 1

    finally:
        if connection is not None:
            try:
                connection.close()
            except Exception:
                pass


if __name__ == "__main__":
    raise SystemExit(main())
