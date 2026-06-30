#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Načte poslední stavový snapshot dokumentační vrstvy MatchMatrix vytvořený
nástrojem A10 a uloží jej do documentation.status_snapshots.

K ČEMU:
- načte documentation_status_snapshot_latest.json,
- ověří strukturu a povinné hodnoty snapshotu,
- vypočítá SHA-256 celého zdrojového JSON souboru,
- provede idempotentní INSERT do documentation.status_snapshots,
- při opakovaném spuštění stejný snapshot znovu nevloží,
- ověří poslední uložený snapshot,
- ověří ops.v_documentation_status_kpi_v1,
- podporuje bezpečný DRY RUN a explicitní režim --apply.

KDE:
tools/documentation/25_1_A_13_IMPORT_DOCUMENTATION_STATUS_SNAPSHOT_V1.py

JAK:
Dry run:
    py -3.14 .\\tools\\documentation\\25_1_A_13_IMPORT_DOCUMENTATION_STATUS_SNAPSHOT_V1.py

Skutečný zápis:
    py -3.14 .\\tools\\documentation\\25_1_A_13_IMPORT_DOCUMENTATION_STATUS_SNAPSHOT_V1.py --apply

Volitelný snapshot:
    --snapshot reports/documentation/documentation_status_snapshot_latest.json

Volitelné připojení:
    --dsn "host=localhost port=5432 dbname=matchmatrix user=postgres"

Připojení lze dodat také pomocí MATCHMATRIX_DATABASE_URL, DATABASE_URL,
PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD nebo projektového `.env`.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
import traceback
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, Mapping, Sequence


DEFAULT_SNAPSHOT = Path(
    "reports/documentation/documentation_status_snapshot_latest.json"
)

EXPECTED_SNAPSHOT_STATUSES = {
    "DOCUMENTATION_STATUS_READY",
    "DOCUMENTATION_STATUS_WARNING",
    "DOCUMENTATION_STATUS_BLOCKED",
}

EXPECTED_HEALTH_VALUES = {
    "READY",
    "WARNING",
    "BLOCKED",
}

EXPECTED_REPORT_STATUSES = {
    "manifest": "DOCUMENT_IMPORT_MANIFEST_READY",
    "verification": "DOCUMENTATION_IMPORT_VERIFIED",
    "sync_plan": "DOCUMENT_SYNC_PLAN_IN_SYNC",
    "control_cycle": "DOCUMENTATION_CONTROL_CYCLE_READY",
}

FINAL_DRY_RUN = "DOCUMENTATION_STATUS_SNAPSHOT_DRY_RUN_READY"
FINAL_INSERTED = "DOCUMENTATION_STATUS_SNAPSHOT_IMPORTED"
FINAL_UNCHANGED = "DOCUMENTATION_STATUS_SNAPSHOT_UNCHANGED"
FINAL_BLOCKED = "DOCUMENTATION_STATUS_SNAPSHOT_IMPORT_BLOCKED"


@dataclass
class Driver:
    name: str
    module: Any
    dict_row_factory: Any

    def connect(
        self,
        dsn: str | None,
        kwargs: dict[str, Any],
    ) -> Any:
        if self.name == "psycopg3":
            if dsn:
                return self.module.connect(
                    dsn,
                    row_factory=self.dict_row_factory,
                )
            return self.module.connect(
                row_factory=self.dict_row_factory,
                **kwargs,
            )

        if dsn:
            return self.module.connect(
                dsn,
                cursor_factory=self.dict_row_factory,
            )
        return self.module.connect(
            cursor_factory=self.dict_row_factory,
            **kwargs,
        )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Import stavového snapshotu dokumentace MatchMatrix do databáze."
        )
    )
    parser.add_argument(
        "--snapshot",
        help="Relativní nebo absolutní cesta ke snapshot JSON.",
    )
    parser.add_argument(
        "--dsn",
        help="PostgreSQL DSN s předností před prostředím a .env.",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Provede skutečný INSERT. Bez tohoto přepínače běží DRY RUN.",
    )
    return parser.parse_args()


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def load_dotenv(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    if not path.is_file():
        return values

    for raw_line in path.read_text(
        encoding="utf-8-sig",
        errors="replace",
    ).splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue

        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()

        if (
            len(value) >= 2
            and value[0] == value[-1]
            and value[0] in {"'", '"'}
        ):
            value = value[1:-1]

        values[key] = value

    return values


def first_nonempty(*values: str | None) -> str | None:
    for value in values:
        if value is not None and str(value).strip():
            return str(value).strip()
    return None


def connection_settings(
    root: Path,
    explicit_dsn: str | None,
) -> tuple[str | None, dict[str, Any], dict[str, Any]]:
    env_file = load_dotenv(root / ".env")

    def env_value(*keys: str) -> str | None:
        for key in keys:
            value = first_nonempty(
                os.getenv(key),
                env_file.get(key),
            )
            if value:
                return value
        return None

    dsn = first_nonempty(
        explicit_dsn,
        env_value(
            "MATCHMATRIX_DATABASE_URL",
            "DATABASE_URL",
            "POSTGRES_URL",
        ),
    )

    kwargs: dict[str, Any] = {
        "host": env_value(
            "PGHOST",
            "DB_HOST",
            "POSTGRES_HOST",
        )
        or "localhost",
        "port": int(
            env_value(
                "PGPORT",
                "DB_PORT",
                "POSTGRES_PORT",
            )
            or "5432"
        ),
        "dbname": env_value(
            "PGDATABASE",
            "DB_NAME",
            "POSTGRES_DB",
        )
        or "matchmatrix",
        "user": env_value(
            "PGUSER",
            "DB_USER",
            "POSTGRES_USER",
        )
        or "postgres",
    }

    password = env_value(
        "PGPASSWORD",
        "DB_PASSWORD",
        "POSTGRES_PASSWORD",
    )
    if password:
        kwargs["password"] = password

    public = {
        "dsn_supplied": bool(dsn),
        "host": kwargs["host"],
        "port": kwargs["port"],
        "dbname": kwargs["dbname"],
        "user": kwargs["user"],
    }
    return dsn, kwargs, public


def load_driver() -> Driver:
    try:
        import psycopg
        from psycopg.rows import dict_row

        return Driver(
            name="psycopg3",
            module=psycopg,
            dict_row_factory=dict_row,
        )
    except ImportError:
        pass

    try:
        import psycopg2
        from psycopg2.extras import RealDictCursor

        return Driver(
            name="psycopg2",
            module=psycopg2,
            dict_row_factory=RealDictCursor,
        )
    except ImportError as exc:
        raise RuntimeError(
            'Chybí PostgreSQL driver. Nainstaluj: '
            'py -3.14 -m pip install "psycopg[binary]"'
        ) from exc


def resolve_snapshot_path(
    root: Path,
    value: str | None,
) -> Path:
    if not value:
        return root / DEFAULT_SNAPSHOT

    path = Path(value)
    if not path.is_absolute():
        path = root / path
    return path.resolve()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def load_snapshot(
    path: Path,
) -> tuple[dict[str, Any], bytes, str]:
    if not path.is_file():
        raise FileNotFoundError(
            f"Snapshot nebyl nalezen: {path}"
        )

    raw = path.read_bytes()
    payload = json.loads(raw.decode("utf-8-sig"))
    digest = sha256_bytes(raw)

    if not isinstance(payload, dict):
        raise RuntimeError(
            "Snapshot JSON musí být objekt."
        )

    return payload, raw, digest


def nested(
    payload: Mapping[str, Any] | None,
    *keys: str,
    default: Any = None,
) -> Any:
    current: Any = payload
    for key in keys:
        if not isinstance(current, Mapping):
            return default
        current = current.get(key)
    return default if current is None else current


def as_int(value: Any, field_name: str) -> int:
    try:
        result = int(value)
    except (TypeError, ValueError) as exc:
        raise RuntimeError(
            f"Pole {field_name} není celé číslo: {value!r}"
        ) from exc

    if result < 0:
        raise RuntimeError(
            f"Pole {field_name} nesmí být záporné: {result}"
        )
    return result


def as_datetime(value: Any, field_name: str) -> datetime:
    text = str(value or "").strip()
    if not text:
        raise RuntimeError(
            f"Chybí povinné datum {field_name}."
        )

    if text.endswith("Z"):
        text = text[:-1] + "+00:00"

    try:
        return datetime.fromisoformat(text)
    except ValueError as exc:
        raise RuntimeError(
            f"Neplatné ISO datum v poli {field_name}: {value!r}"
        ) from exc


def report_status(
    payload: Mapping[str, Any],
    key: str,
) -> str:
    reports = payload.get("reports")
    if not isinstance(reports, Mapping):
        raise RuntimeError(
            "Snapshot neobsahuje objekt reports."
        )

    report = reports.get(key)
    if not isinstance(report, Mapping):
        raise RuntimeError(
            f"Snapshot neobsahuje reports.{key}."
        )

    status = str(report.get("final_status") or "").strip()
    if not status:
        raise RuntimeError(
            f"Snapshot neobsahuje reports.{key}.final_status."
        )

    return status


def validate_snapshot(
    payload: Mapping[str, Any],
) -> dict[str, Any]:
    generated_at = as_datetime(
        payload.get("generated_at"),
        "generated_at",
    )

    health = str(payload.get("health") or "").strip()
    final_status = str(
        payload.get("final_status") or ""
    ).strip()

    if health not in EXPECTED_HEALTH_VALUES:
        raise RuntimeError(
            f"Neplatný health stav: {health!r}"
        )

    if final_status not in EXPECTED_SNAPSHOT_STATUSES:
        raise RuntimeError(
            f"Neplatný final_status: {final_status!r}"
        )

    git = payload.get("git")
    if not isinstance(git, Mapping):
        raise RuntimeError(
            "Snapshot neobsahuje objekt git."
        )

    kpis = payload.get("kpis")
    if not isinstance(kpis, Mapping):
        raise RuntimeError(
            "Snapshot neobsahuje objekt kpis."
        )

    blockers = payload.get("blockers", [])
    warnings = payload.get("warnings", [])

    if not isinstance(blockers, list):
        raise RuntimeError(
            "Pole blockers musí být JSON pole."
        )

    if not isinstance(warnings, list):
        raise RuntimeError(
            "Pole warnings musí být JSON pole."
        )

    values = {
        "snapshot_at": generated_at,
        "health": health,
        "final_status": final_status,

        "manifest_status": report_status(
            payload,
            "manifest",
        ),
        "verification_status": report_status(
            payload,
            "verification",
        ),
        "sync_status": report_status(
            payload,
            "sync_plan",
        ),
        "control_cycle_status": report_status(
            payload,
            "control_cycle",
        ),

        "source_git_commit": (
            str(git.get("commit")).strip()
            if git.get("commit")
            else None
        ),
        "source_git_branch": (
            str(git.get("branch")).strip()
            if git.get("branch")
            else None
        ),
        "source_git_dirty": bool(
            git.get("dirty", False)
        ),

        "documents_count": as_int(
            kpis.get("documents", 0),
            "kpis.documents",
        ),
        "current_versions_count": as_int(
            kpis.get("current_versions", 0),
            "kpis.current_versions",
        ),
        "sections_count": as_int(
            kpis.get("sections", 0),
            "kpis.sections",
        ),
        "relations_count": as_int(
            kpis.get("relations", 0),
            "kpis.relations",
        ),
        "status_history_count": as_int(
            kpis.get("status_history", 0),
            "kpis.status_history",
        ),
        "import_runs_count": as_int(
            kpis.get("import_runs", 0),
            "kpis.import_runs",
        ),

        "checks_total": as_int(
            kpis.get("checks_total", 0),
            "kpis.checks_total",
        ),
        "checks_passed": as_int(
            kpis.get("checks_passed", 0),
            "kpis.checks_passed",
        ),

        "verification_warnings": as_int(
            kpis.get("verification_warnings", 0),
            "kpis.verification_warnings",
        ),
        "verification_blockers": as_int(
            kpis.get("verification_blockers", 0),
            "kpis.verification_blockers",
        ),

        "in_sync_count": as_int(
            kpis.get("in_sync", 0),
            "kpis.in_sync",
        ),
        "sync_actions": as_int(
            kpis.get("sync_actions", 0),
            "kpis.sync_actions",
        ),
        "sync_blockers": as_int(
            kpis.get("sync_blockers", 0),
            "kpis.sync_blockers",
        ),

        "unregistered_sources": as_int(
            kpis.get("unregistered_sources", 0),
            "kpis.unregistered_sources",
        ),
        "database_only_documents": as_int(
            kpis.get("database_only_documents", 0),
            "kpis.database_only_documents",
        ),

        "manifest_candidates": as_int(
            kpis.get("manifest_candidates", 0),
            "kpis.manifest_candidates",
        ),
        "manifest_ready": as_int(
            kpis.get("manifest_ready", 0),
            "kpis.manifest_ready",
        ),
        "manifest_blockers": as_int(
            kpis.get("manifest_blockers", 0),
            "kpis.manifest_blockers",
        ),
        "manifest_warnings": as_int(
            kpis.get("manifest_warnings", 0),
            "kpis.manifest_warnings",
        ),

        "control_stages": as_int(
            kpis.get("control_stages", 0),
            "kpis.control_stages",
        ),
        "control_stages_successful": as_int(
            kpis.get("control_stages_successful", 0),
            "kpis.control_stages_successful",
        ),

        "blockers": blockers,
        "warnings": warnings,
        "source_reports": payload.get("reports", {}),
        "source_payload": dict(payload),
    }

    if (
        values["current_versions_count"]
        > values["documents_count"]
    ):
        raise RuntimeError(
            "current_versions_count je vyšší než documents_count."
        )

    if values["in_sync_count"] > values["documents_count"]:
        raise RuntimeError(
            "in_sync_count je vyšší než documents_count."
        )

    if values["checks_passed"] > values["checks_total"]:
        raise RuntimeError(
            "checks_passed je vyšší než checks_total."
        )

    if (
        values["manifest_ready"]
        > values["manifest_candidates"]
    ):
        raise RuntimeError(
            "manifest_ready je vyšší než manifest_candidates."
        )

    if (
        values["control_stages_successful"]
        > values["control_stages"]
    ):
        raise RuntimeError(
            "control_stages_successful je vyšší než control_stages."
        )

    return values


def query_one(
    connection: Any,
    sql: str,
    params: Sequence[Any] = (),
) -> dict[str, Any] | None:
    with connection.cursor() as cursor:
        cursor.execute(sql, tuple(params))
        row = cursor.fetchone()
        return dict(row) if row is not None else None


def table_exists(connection: Any) -> bool:
    row = query_one(
        connection,
        """
        SELECT to_regclass(
            'documentation.status_snapshots'
        ) IS NOT NULL AS exists
        """,
    )
    return bool(row and row.get("exists"))


def required_views_exist(
    connection: Any,
) -> dict[str, bool]:
    result: dict[str, bool] = {}

    for name in (
        "documentation.v_latest_status_snapshot_v1",
        "ops.v_documentation_status_kpi_v1",
        "ops.v_documentation_status_history_v1",
    ):
        row = query_one(
            connection,
            "SELECT to_regclass(%s) IS NOT NULL AS exists",
            (name,),
        )
        result[name] = bool(
            row and row.get("exists")
        )

    return result


def existing_snapshot(
    connection: Any,
    snapshot_hash: str,
) -> dict[str, Any] | None:
    return query_one(
        connection,
        """
        SELECT
            status_snapshot_pk,
            snapshot_at,
            health,
            final_status,
            snapshot_hash_sha256,
            created_at
        FROM documentation.status_snapshots
        WHERE snapshot_hash_sha256 = %s
        """,
        (snapshot_hash,),
    )


def insert_snapshot(
    connection: Any,
    values: Mapping[str, Any],
    snapshot_path: Path,
    snapshot_hash: str,
) -> dict[str, Any] | None:
    sql = """
        INSERT INTO documentation.status_snapshots
        (
            snapshot_at,
            health,
            final_status,

            manifest_status,
            verification_status,
            sync_status,
            control_cycle_status,

            source_git_commit,
            source_git_branch,
            source_git_dirty,

            documents_count,
            current_versions_count,
            sections_count,
            relations_count,
            status_history_count,
            import_runs_count,

            checks_total,
            checks_passed,

            verification_warnings,
            verification_blockers,

            in_sync_count,
            sync_actions,
            sync_blockers,

            unregistered_sources,
            database_only_documents,

            manifest_candidates,
            manifest_ready,
            manifest_blockers,
            manifest_warnings,

            control_stages,
            control_stages_successful,

            blockers,
            warnings,
            source_reports,
            source_payload,

            source_file_path,
            snapshot_hash_sha256
        )
        VALUES
        (
            %s, %s, %s,
            %s, %s, %s, %s,
            %s, %s, %s,
            %s, %s, %s, %s, %s, %s,
            %s, %s,
            %s, %s,
            %s, %s, %s,
            %s, %s,
            %s, %s, %s, %s,
            %s, %s,
            %s::jsonb, %s::jsonb, %s::jsonb, %s::jsonb,
            %s, %s
        )
        ON CONFLICT (snapshot_hash_sha256)
        DO NOTHING
        RETURNING
            status_snapshot_pk,
            snapshot_at,
            health,
            final_status,
            snapshot_hash_sha256,
            created_at
    """

    params = (
        values["snapshot_at"],
        values["health"],
        values["final_status"],

        values["manifest_status"],
        values["verification_status"],
        values["sync_status"],
        values["control_cycle_status"],

        values["source_git_commit"],
        values["source_git_branch"],
        values["source_git_dirty"],

        values["documents_count"],
        values["current_versions_count"],
        values["sections_count"],
        values["relations_count"],
        values["status_history_count"],
        values["import_runs_count"],

        values["checks_total"],
        values["checks_passed"],

        values["verification_warnings"],
        values["verification_blockers"],

        values["in_sync_count"],
        values["sync_actions"],
        values["sync_blockers"],

        values["unregistered_sources"],
        values["database_only_documents"],

        values["manifest_candidates"],
        values["manifest_ready"],
        values["manifest_blockers"],
        values["manifest_warnings"],

        values["control_stages"],
        values["control_stages_successful"],

        json.dumps(
            values["blockers"],
            ensure_ascii=False,
        ),
        json.dumps(
            values["warnings"],
            ensure_ascii=False,
        ),
        json.dumps(
            values["source_reports"],
            ensure_ascii=False,
        ),
        json.dumps(
            values["source_payload"],
            ensure_ascii=False,
        ),

        snapshot_path.as_posix(),
        snapshot_hash,
    )

    return query_one(connection, sql, params)


def verify_latest(
    connection: Any,
) -> dict[str, Any] | None:
    return query_one(
        connection,
        """
        SELECT *
        FROM documentation.v_latest_status_snapshot_v1
        """,
    )


def verify_kpi(
    connection: Any,
) -> dict[str, Any] | None:
    return query_one(
        connection,
        """
        SELECT *
        FROM ops.v_documentation_status_kpi_v1
        """,
    )


def snapshot_count(connection: Any) -> int:
    row = query_one(
        connection,
        """
        SELECT COUNT(*) AS snapshot_count
        FROM documentation.status_snapshots
        """,
    )
    return int(row["snapshot_count"]) if row else 0


def print_snapshot_summary(
    values: Mapping[str, Any],
    snapshot_hash: str,
) -> None:
    print("SNAPSHOT")
    print("-" * 79)
    print(f"snapshot_at                  : {values['snapshot_at'].isoformat()}")
    print(f"health                       : {values['health']}")
    print(f"final_status                 : {values['final_status']}")
    print(f"git_commit                   : {values['source_git_commit']}")
    print(f"git_branch                   : {values['source_git_branch']}")
    print(f"git_dirty                    : {values['source_git_dirty']}")
    print(f"documents                    : {values['documents_count']}")
    print(f"current_versions             : {values['current_versions_count']}")
    print(f"sections                     : {values['sections_count']}")
    print(f"relations                    : {values['relations_count']}")
    print(f"checks                       : {values['checks_passed']}/{values['checks_total']}")
    print(f"in_sync                      : {values['in_sync_count']}")
    print(f"sync_actions                 : {values['sync_actions']}")
    print(f"sync_blockers                : {values['sync_blockers']}")
    print(f"snapshot_hash_sha256         : {snapshot_hash}")


def main() -> int:
    args = parse_args()
    root = project_root()
    snapshot_path = resolve_snapshot_path(
        root,
        args.snapshot,
    )

    mode = "APPLY" if args.apply else "DRY_RUN"

    print("MATCHMATRIX DOCUMENTATION STATUS SNAPSHOT IMPORT")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"SNAPSHOT           : {snapshot_path}")
    print(f"MODE               : {mode}")
    print()

    connection: Any = None

    try:
        payload, _raw, snapshot_hash = load_snapshot(
            snapshot_path
        )
        values = validate_snapshot(payload)
        print_snapshot_summary(values, snapshot_hash)
        print()

        driver = load_driver()
        dsn, kwargs, public_db = connection_settings(
            root,
            args.dsn,
        )

        print(f"DB DRIVER          : {driver.name}")
        print(
            "DB TARGET          : "
            f"{public_db['user']}@{public_db['host']}:"
            f"{public_db['port']}/{public_db['dbname']}"
        )
        print()

        connection = driver.connect(dsn, kwargs)

        if not table_exists(connection):
            raise RuntimeError(
                "Chybí tabulka documentation.status_snapshots. "
                "Nejprve spusť A12."
            )

        views = required_views_exist(connection)
        missing_views = [
            name
            for name, exists in views.items()
            if not exists
        ]
        if missing_views:
            raise RuntimeError(
                "Chybí požadované view: "
                + ", ".join(missing_views)
            )

        duplicate = existing_snapshot(
            connection,
            snapshot_hash,
        )

        print("DATABASE PRECHECK")
        print("-" * 79)
        print("status_snapshots table       : EXISTS")
        for name, exists in views.items():
            print(
                f"{name:<30}: "
                f"{'EXISTS' if exists else 'MISSING'}"
            )
        print(
            "snapshot already stored      : "
            f"{bool(duplicate)}"
        )
        print()

        if not args.apply:
            connection.rollback()

            print("SOUHRN")
            print("-" * 79)
            print("rows_inserted                : 0")
            print(
                "would_insert                 : "
                f"{0 if duplicate else 1}"
            )
            print(f"stored_snapshots             : {snapshot_count(connection)}")
            print(f"FINAL STATUS                 : {FINAL_DRY_RUN}")
            return 0

        inserted = insert_snapshot(
            connection,
            values,
            snapshot_path,
            snapshot_hash,
        )
        connection.commit()

        latest = verify_latest(connection)
        kpi = verify_kpi(connection)
        count = snapshot_count(connection)

        if inserted is None:
            final_status = FINAL_UNCHANGED
            rows_inserted = 0
            stored = duplicate or existing_snapshot(
                connection,
                snapshot_hash,
            )
        else:
            final_status = FINAL_INSERTED
            rows_inserted = 1
            stored = inserted

        if not stored:
            raise RuntimeError(
                "Snapshot nebyl po APPLY dohledán v databázi."
            )

        if not latest:
            raise RuntimeError(
                "View documentation.v_latest_status_snapshot_v1 "
                "nevrátilo žádný řádek."
            )

        if not kpi:
            raise RuntimeError(
                "View ops.v_documentation_status_kpi_v1 "
                "nevrátilo žádný řádek."
            )

        if (
            latest.get("snapshot_hash_sha256")
            != snapshot_hash
        ):
            raise RuntimeError(
                "Poslední snapshot v databázi neodpovídá "
                "importovanému JSON souboru."
            )

        print("DATABASE RESULT")
        print("-" * 79)
        print(f"rows_inserted                : {rows_inserted}")
        print(f"stored_snapshots             : {count}")
        print(
            "stored_snapshot_pk           : "
            f"{stored.get('status_snapshot_pk')}"
        )
        print(
            "latest_snapshot_at           : "
            f"{latest.get('snapshot_at')}"
        )
        print(
            "latest_health                : "
            f"{latest.get('health')}"
        )
        print(
            "latest_final_status          : "
            f"{latest.get('final_status')}"
        )
        print(
            "ops_documentation_health     : "
            f"{kpi.get('documentation_health')}"
        )
        print(
            "ops_kpi_status               : "
            f"{kpi.get('kpi_status')}"
        )
        print()

        print("SOUHRN")
        print("-" * 79)
        print(f"FINAL STATUS                 : {final_status}")
        return 0

    except Exception as exc:
        if connection is not None:
            try:
                connection.rollback()
            except Exception:
                pass

        print()
        print("IMPORT ERROR")
        print("-" * 79)
        print(f"{type(exc).__name__}: {exc}")
        print(traceback.format_exc())
        print(f"FINAL STATUS                 : {FINAL_BLOCKED}")
        return 1

    finally:
        if connection is not None:
            try:
                connection.close()
            except Exception:
                pass


if __name__ == "__main__":
    raise SystemExit(main())
