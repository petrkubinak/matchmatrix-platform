#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Sestaví read-only synchronizační plán mezi kanonickými Markdown dokumenty,
posledním importním manifestem a databázovým registrem dokumentace MatchMatrix.

K ČEMU:
- zjistí, které dokumenty jsou plně IN_SYNC,
- odhalí změněný soubor bez obnoveného manifestu,
- rozpozná novou verzi připravenou k importu,
- zablokuje změnu obsahu bez navýšení verze,
- odhalí změnu metadat vyžadující review,
- odhalí dokument v databázi bez manifestu,
- odhalí nezařazený aktivní Markdown soubor,
- vytvoří JSON a CSV akční plán,
- databázi ani zdrojové dokumenty nemění.

KDE:
tools/documentation/25_1_A_8_BUILD_DOCUMENT_SYNC_PLAN_V1.py

JAK:
    py -3.14 .\\tools\\documentation\\25_1_A_8_BUILD_DOCUMENT_SYNC_PLAN_V1.py

Volitelný manifest:
    --manifest reports/documentation/document_import_manifest_latest.json

Volitelné připojení:
    --dsn "host=localhost port=5432 dbname=matchmatrix user=postgres"

Připojení lze dodat také pomocí MATCHMATRIX_DATABASE_URL, DATABASE_URL,
PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD nebo projektového `.env`.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import re
import subprocess
import sys
import traceback
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Mapping, Sequence


SCHEMA = "documentation"
MANIFEST_RELATIVE_PATH = Path(
    "reports/documentation/document_import_manifest_latest.json"
)
REPORT_PREFIX = "document_sync_plan"
EXPECTED_MANIFEST_STATUS = "DOCUMENT_IMPORT_MANIFEST_READY"

STATUS_IN_SYNC = "IN_SYNC"
STATUS_NEW_DOCUMENT_READY = "NEW_DOCUMENT_READY"
STATUS_NEW_VERSION_READY = "NEW_VERSION_READY"
STATUS_VERSION_BUMP_REQUIRED = "VERSION_BUMP_REQUIRED"
STATUS_MANIFEST_REFRESH_REQUIRED = "MANIFEST_REFRESH_REQUIRED"
STATUS_METADATA_CHANGE_REVIEW = "METADATA_CHANGE_REVIEW"
STATUS_SOURCE_MISSING = "SOURCE_MISSING"
STATUS_DATABASE_INTEGRITY_ERROR = "DATABASE_INTEGRITY_ERROR"
STATUS_DATABASE_ONLY_REVIEW = "DATABASE_ONLY_REVIEW"
STATUS_UNREGISTERED_SOURCE_REVIEW = "UNREGISTERED_SOURCE_REVIEW"

ACTIONABLE_STATUSES = {
    STATUS_NEW_DOCUMENT_READY,
    STATUS_NEW_VERSION_READY,
    STATUS_MANIFEST_REFRESH_REQUIRED,
    STATUS_METADATA_CHANGE_REVIEW,
    STATUS_DATABASE_ONLY_REVIEW,
    STATUS_UNREGISTERED_SOURCE_REVIEW,
}

BLOCKING_STATUSES = {
    STATUS_VERSION_BUMP_REQUIRED,
    STATUS_SOURCE_MISSING,
    STATUS_DATABASE_INTEGRITY_ERROR,
}

VERSION_PATTERN = re.compile(r"^\d+(?:\.\d+)*$")
MARKDOWN_SUFFIX = ".md"


@dataclass
class Driver:
    name: str
    module: Any
    dict_row_factory: Any

    def connect(self, dsn: str | None, kwargs: dict[str, Any]) -> Any:
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


@dataclass
class Finding:
    severity: str
    code: str
    message: str
    document_id: str | None = None
    source_path: str | None = None
    details: dict[str, Any] = field(default_factory=dict)

    def as_dict(self) -> dict[str, Any]:
        return {
            "severity": self.severity,
            "code": self.code,
            "message": self.message,
            "document_id": self.document_id,
            "source_path": self.source_path,
            "details": self.details,
        }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Read-only synchronizační plán dokumentace MatchMatrix."
        )
    )
    parser.add_argument(
        "--manifest",
        help="Relativní nebo absolutní cesta k JSON manifestu.",
    )
    parser.add_argument(
        "--dsn",
        help="PostgreSQL DSN s předností před prostředím a .env.",
    )
    return parser.parse_args()


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def normalize_path(value: Any) -> str:
    return str(value or "").replace("\\", "/").strip()


def normalize_scalar(value: Any) -> Any:
    if isinstance(value, str):
        return value.strip()
    return value


def document_family(document_id: str) -> str:
    parts = document_id.split("-")
    return parts[1] if len(parts) >= 3 else "UNKNOWN"


def default_edition(
    document_id: str,
    manifest_edition: str | None,
) -> str:
    if manifest_edition:
        return str(manifest_edition).strip()
    family = document_family(document_id)
    return {
        "DOC": "TECH",
        "STD": "STANDARD",
        "REF": "REFERENCE",
    }.get(family, family)


def parse_version_tuple(value: Any) -> tuple[int, ...] | None:
    text = str(value or "").strip()
    if not VERSION_PATTERN.fullmatch(text):
        return None
    return tuple(int(part) for part in text.split("."))


def compare_versions(left: Any, right: Any) -> int | None:
    left_tuple = parse_version_tuple(left)
    right_tuple = parse_version_tuple(right)
    if left_tuple is None or right_tuple is None:
        return None

    size = max(len(left_tuple), len(right_tuple))
    left_normalized = left_tuple + (0,) * (size - len(left_tuple))
    right_normalized = right_tuple + (0,) * (size - len(right_tuple))

    if left_normalized > right_normalized:
        return 1
    if left_normalized < right_normalized:
        return -1
    return 0


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


def query_all(
    connection: Any,
    sql: str,
    params: Sequence[Any] = (),
) -> list[dict[str, Any]]:
    with connection.cursor() as cursor:
        cursor.execute(sql, tuple(params))
        if cursor.description is None:
            return []
        return [dict(row) for row in cursor.fetchall()]


def git_info(root: Path) -> dict[str, Any]:
    def run(*args: str) -> str:
        result = subprocess.run(
            ["git", *args],
            cwd=root,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            check=False,
        )
        return result.stdout.strip()

    commit = run("rev-parse", "HEAD")
    status = run("status", "--porcelain")
    return {
        "commit": commit or None,
        "dirty": bool(status),
        "status_lines": status.splitlines() if status else [],
    }


def resolve_manifest_path(
    root: Path,
    value: str | None,
) -> Path:
    if not value:
        return root / MANIFEST_RELATIVE_PATH

    path = Path(value)
    if not path.is_absolute():
        path = root / path
    return path.resolve()


def load_manifest(path: Path) -> tuple[dict[str, Any], bytes]:
    if not path.is_file():
        raise FileNotFoundError(f"Manifest nebyl nalezen: {path}")

    data = path.read_bytes()
    payload = json.loads(data.decode("utf-8-sig"))

    if payload.get("final_status") != EXPECTED_MANIFEST_STATUS:
        raise RuntimeError(
            "Manifest není připraven pro synchronizaci. "
            f"Stav: {payload.get('final_status')}"
        )

    documents = payload.get("documents")
    if not isinstance(documents, list) or not documents:
        raise RuntimeError(
            "Manifest neobsahuje neprázdný seznam documents."
        )

    return payload, data


def fetch_database_snapshot(connection: Any) -> dict[str, Any]:
    documents = query_all(
        connection,
        """
        SELECT
            document_pk,
            document_id,
            title,
            document_type,
            edition,
            current_version_label,
            current_status,
            source_of_truth,
            is_active,
            created_at,
            updated_at
        FROM documentation.documents
        ORDER BY document_id, document_pk
        """,
    )

    versions = query_all(
        connection,
        """
        SELECT
            version_pk,
            document_pk,
            import_run_pk,
            version_label,
            version_status,
            content_hash_sha256,
            source_filename,
            source_file_path,
            source_git_commit,
            is_current,
            imported_at
        FROM documentation.document_versions
        ORDER BY document_pk, version_pk
        """,
    )

    return {
        "documents": documents,
        "versions": versions,
    }


def expected_document_metadata(
    document_id: str,
    manifest_row: Mapping[str, Any],
) -> dict[str, Any]:
    return {
        "title": manifest_row.get("title"),
        "document_type": document_family(document_id),
        "edition": default_edition(
            document_id,
            manifest_row.get("edition"),
        ),
        "current_version_label": manifest_row.get("version"),
        "current_status": manifest_row.get("status"),
        "source_of_truth": "HYBRID",
        "is_active": manifest_row.get("status")
        in {"ACTIVE", "APPROVED", "REVIEW"},
    }


def metadata_mismatches(
    db_document: Mapping[str, Any],
    expected: Mapping[str, Any],
) -> dict[str, dict[str, Any]]:
    return {
        column: {
            "database": db_document.get(column),
            "manifest": expected_value,
        }
        for column, expected_value in expected.items()
        if normalize_scalar(db_document.get(column))
        != normalize_scalar(expected_value)
    }


def classified_manifest_paths(
    manifest: Mapping[str, Any],
) -> set[str]:
    paths: set[str] = set()

    for item in manifest.get("documents", []):
        path = normalize_path(item.get("source_path"))
        if path:
            paths.add(path)

    for item in manifest.get("superseded_sources", []):
        path = normalize_path(
            item.get("relative_path")
            or item.get("source_path")
        )
        if path:
            paths.add(path)

    for item in manifest.get("excluded_sources", []):
        path = normalize_path(
            item.get("relative_path")
            or item.get("source_path")
        )
        if path:
            paths.add(path)

    return paths


def scan_active_markdown_files(root: Path) -> set[str]:
    docs_root = root / "docs"
    if not docs_root.is_dir():
        return set()

    paths: set[str] = set()
    for path in docs_root.rglob("*"):
        if not path.is_file():
            continue
        if path.suffix.lower() != MARKDOWN_SUFFIX:
            continue

        relative = path.relative_to(root)
        parts_upper = {part.upper() for part in relative.parts}
        if "99_ARCHIVE" in parts_upper:
            continue

        paths.add(relative.as_posix())

    return paths


def choose_document_status(
    *,
    source_exists: bool,
    source_hash: str | None,
    manifest_hash: str | None,
    db_document_count: int,
    current_version_count: int,
    db_hash: str | None,
    manifest_version: str | None,
    db_version: str | None,
    metadata_diff: Mapping[str, Any],
) -> tuple[str, str]:
    if not source_exists:
        return (
            STATUS_SOURCE_MISSING,
            "Obnovit nebo opravit zdrojový Markdown soubor.",
        )

    if db_document_count == 0:
        if source_hash != manifest_hash:
            return (
                STATUS_MANIFEST_REFRESH_REQUIRED,
                "Znovu sestavit importní manifest před prvním importem dokumentu.",
            )
        return (
            STATUS_NEW_DOCUMENT_READY,
            "Po review spustit kanonický importer s --apply.",
        )

    if db_document_count != 1 or current_version_count != 1:
        return (
            STATUS_DATABASE_INTEGRITY_ERROR,
            "Opravit duplicitu dokumentu nebo počet aktuálních verzí.",
        )

    if source_hash != manifest_hash:
        return (
            STATUS_MANIFEST_REFRESH_REQUIRED,
            "Znovu spustit 25_1_A_5_BUILD_DOCUMENT_IMPORT_MANIFEST_V1.py.",
        )

    if db_hash == manifest_hash:
        if metadata_diff:
            return (
                STATUS_METADATA_CHANGE_REVIEW,
                "Provést review změny metadat před synchronizací.",
            )
        return (
            STATUS_IN_SYNC,
            "Bez akce.",
        )

    version_comparison = compare_versions(
        manifest_version,
        db_version,
    )
    if version_comparison is None:
        return (
            STATUS_VERSION_BUMP_REQUIRED,
            "Použít číselnou verzi a navýšit ji proti databázi.",
        )

    if version_comparison > 0:
        return (
            STATUS_NEW_VERSION_READY,
            "Po review spustit kanonický importer s --apply.",
        )

    return (
        STATUS_VERSION_BUMP_REQUIRED,
        "Navýšit verzi dokumentu a znovu sestavit manifest.",
    )


def serializable(value: Any) -> Any:
    if isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, Path):
        return str(value)
    if isinstance(value, dict):
        return {
            str(key): serializable(item)
            for key, item in value.items()
        }
    if isinstance(value, (list, tuple, set)):
        return [serializable(item) for item in value]
    return value


def write_reports(
    root: Path,
    payload: Mapping[str, Any],
    rows: list[dict[str, Any]],
) -> tuple[Path, Path]:
    reports_dir = root / "reports" / "documentation"
    reports_dir.mkdir(parents=True, exist_ok=True)

    timestamp = utc_now().astimezone().strftime("%Y%m%d_%H%M%S")
    json_path = reports_dir / f"{REPORT_PREFIX}_{timestamp}.json"
    csv_path = reports_dir / f"{REPORT_PREFIX}_{timestamp}.csv"
    latest_json = reports_dir / f"{REPORT_PREFIX}_latest.json"
    latest_csv = reports_dir / f"{REPORT_PREFIX}_latest.csv"

    encoded = json.dumps(
        serializable(dict(payload)),
        ensure_ascii=False,
        indent=2,
    )
    json_path.write_text(encoded, encoding="utf-8")
    latest_json.write_text(encoded, encoding="utf-8")

    fieldnames = [
        "document_id",
        "sync_status",
        "action",
        "source_path",
        "source_exists",
        "source_sha256",
        "manifest_sha256",
        "database_sha256",
        "manifest_version",
        "database_version",
        "manifest_status",
        "database_status",
        "metadata_mismatches",
    ]

    for path in (csv_path, latest_csv):
        with path.open(
            "w",
            encoding="utf-8-sig",
            newline="",
        ) as handle:
            writer = csv.DictWriter(
                handle,
                fieldnames=fieldnames,
                extrasaction="ignore",
            )
            writer.writeheader()
            for row in rows:
                csv_row = dict(row)
                csv_row["metadata_mismatches"] = json.dumps(
                    row.get("metadata_mismatches", {}),
                    ensure_ascii=False,
                    separators=(",", ":"),
                )
                writer.writerow(csv_row)

    return json_path, csv_path


def main() -> int:
    args = parse_args()
    root = project_root()
    manifest_path = resolve_manifest_path(
        root,
        args.manifest,
    )
    generated_at = utc_now()
    git = git_info(root)

    findings: list[Finding] = []
    rows: list[dict[str, Any]] = []
    report: dict[str, Any] = {
        "generated_at": generated_at.isoformat(),
        "project_root": str(root),
        "manifest_path": str(manifest_path),
        "git": git,
        "database": {},
        "summary": {},
        "documents": rows,
        "unregistered_sources": [],
        "database_only_documents": [],
        "findings": [],
    }

    print("MATCHMATRIX DOCUMENT SYNCHRONIZATION PLAN")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"MANIFEST           : {manifest_path}")
    print(f"GIT COMMIT         : {git.get('commit')}")
    print(f"GIT DIRTY          : {git.get('dirty')}")
    print()

    connection: Any = None

    try:
        manifest, manifest_bytes = load_manifest(manifest_path)
        report["manifest_sha256"] = sha256_bytes(manifest_bytes)
        report["manifest_generated_at"] = manifest.get("generated_at")

        driver = load_driver()
        dsn, kwargs, public_db = connection_settings(
            root,
            args.dsn,
        )
        report["database"] = {
            "driver": driver.name,
            "target": public_db,
        }

        print(f"DB DRIVER          : {driver.name}")
        print(
            "DB TARGET          : "
            f"{public_db['user']}@{public_db['host']}:"
            f"{public_db['port']}/{public_db['dbname']}"
        )
        print()

        connection = driver.connect(dsn, kwargs)
        with connection.cursor() as cursor:
            cursor.execute("SET TRANSACTION READ ONLY")

        snapshot = fetch_database_snapshot(connection)
        documents = snapshot["documents"]
        versions = snapshot["versions"]

        documents_by_id: dict[str, list[dict[str, Any]]] = defaultdict(list)
        for db_document in documents:
            documents_by_id[
                str(db_document.get("document_id"))
            ].append(db_document)

        versions_by_document_pk: dict[Any, list[dict[str, Any]]] = defaultdict(list)
        for db_version in versions:
            versions_by_document_pk[
                db_version.get("document_pk")
            ].append(db_version)

        manifest_documents = manifest.get("documents", [])
        manifest_ids = {
            str(item.get("document_id"))
            for item in manifest_documents
        }
        database_ids = set(documents_by_id)

        print("SYNCHRONIZAČNÍ STAV DOKUMENTŮ")
        print("-" * 79)

        for manifest_row in sorted(
            manifest_documents,
            key=lambda item: str(item.get("document_id")),
        ):
            document_id = str(manifest_row.get("document_id"))
            source_relative = normalize_path(
                manifest_row.get("source_path")
            )
            source_path = root / source_relative
            source_exists = source_path.is_file()
            source_hash = (
                sha256_bytes(source_path.read_bytes())
                if source_exists
                else None
            )
            manifest_hash = str(
                manifest_row.get("sha256") or ""
            ) or None

            db_document_rows = documents_by_id.get(
                document_id,
                [],
            )
            db_document = (
                db_document_rows[0]
                if len(db_document_rows) == 1
                else None
            )
            current_versions: list[dict[str, Any]] = []
            if db_document:
                current_versions = [
                    item
                    for item in versions_by_document_pk.get(
                        db_document.get("document_pk"),
                        [],
                    )
                    if item.get("is_current") is True
                ]

            db_version = (
                current_versions[0]
                if len(current_versions) == 1
                else None
            )
            db_hash = (
                str(
                    db_version.get(
                        "content_hash_sha256"
                    )
                    or ""
                )
                or None
                if db_version
                else None
            )
            db_version_label = (
                str(db_version.get("version_label") or "")
                or None
                if db_version
                else None
            )

            expected_metadata = expected_document_metadata(
                document_id,
                manifest_row,
            )
            metadata_diff = (
                metadata_mismatches(
                    db_document,
                    expected_metadata,
                )
                if db_document
                else {}
            )

            sync_status, action = choose_document_status(
                source_exists=source_exists,
                source_hash=source_hash,
                manifest_hash=manifest_hash,
                db_document_count=len(db_document_rows),
                current_version_count=len(current_versions),
                db_hash=db_hash,
                manifest_version=manifest_row.get("version"),
                db_version=db_version_label,
                metadata_diff=metadata_diff,
            )

            row = {
                "document_id": document_id,
                "sync_status": sync_status,
                "action": action,
                "source_path": source_relative,
                "source_exists": source_exists,
                "source_sha256": source_hash,
                "manifest_sha256": manifest_hash,
                "database_sha256": db_hash,
                "manifest_version": manifest_row.get("version"),
                "database_version": db_version_label,
                "manifest_status": manifest_row.get("status"),
                "database_status": (
                    db_document.get("current_status")
                    if db_document
                    else None
                ),
                "database_document_rows": len(db_document_rows),
                "database_current_versions": len(current_versions),
                "metadata_mismatches": metadata_diff,
            }
            rows.append(row)

            if sync_status in BLOCKING_STATUSES:
                findings.append(
                    Finding(
                        severity="BLOCKER",
                        code=sync_status,
                        message=action,
                        document_id=document_id,
                        source_path=source_relative,
                        details=row,
                    )
                )
            elif sync_status != STATUS_IN_SYNC:
                findings.append(
                    Finding(
                        severity="ACTION",
                        code=sync_status,
                        message=action,
                        document_id=document_id,
                        source_path=source_relative,
                        details=row,
                    )
                )

            print(
                f"{document_id:<15} | "
                f"{sync_status:<27} | "
                f"file={str(manifest_row.get('version') or '-'):>5} | "
                f"db={str(db_version_label or '-'):>5}"
            )

        database_only_ids = sorted(database_ids - manifest_ids)
        report["database_only_documents"] = database_only_ids
        for document_id in database_only_ids:
            finding = Finding(
                severity="ACTION",
                code=STATUS_DATABASE_ONLY_REVIEW,
                message=(
                    "Dokument je v databázi, ale není v kanonickém manifestu."
                ),
                document_id=document_id,
            )
            findings.append(finding)

        classified_paths = classified_manifest_paths(manifest)
        active_markdown_paths = scan_active_markdown_files(root)
        unregistered_paths = sorted(
            active_markdown_paths - classified_paths
        )
        report["unregistered_sources"] = unregistered_paths
        for source_path in unregistered_paths:
            findings.append(
                Finding(
                    severity="ACTION",
                    code=STATUS_UNREGISTERED_SOURCE_REVIEW,
                    message=(
                        "Aktivní Markdown soubor není klasifikovaný "
                        "v importním manifestu."
                    ),
                    source_path=source_path,
                )
            )

        status_counts = Counter(
            row["sync_status"]
            for row in rows
        )
        blocker_count = sum(
            1 for finding in findings
            if finding.severity == "BLOCKER"
        )
        action_count = sum(
            1 for finding in findings
            if finding.severity == "ACTION"
        )

        if blocker_count:
            final_status = "DOCUMENT_SYNC_PLAN_BLOCKED"
        elif action_count:
            final_status = "DOCUMENT_SYNC_PLAN_ACTION_REQUIRED"
        else:
            final_status = "DOCUMENT_SYNC_PLAN_IN_SYNC"

        report["summary"] = {
            "manifest_documents": len(manifest_documents),
            "database_documents": len(documents),
            "database_versions": len(versions),
            "status_counts": dict(
                sorted(status_counts.items())
            ),
            "unregistered_sources": len(unregistered_paths),
            "database_only_documents": len(database_only_ids),
            "actions": action_count,
            "blockers": blocker_count,
        }
        report["findings"] = [
            finding.as_dict()
            for finding in findings
        ]
        report["final_status"] = final_status

    except Exception as exc:
        findings.append(
            Finding(
                severity="BLOCKER",
                code="UNHANDLED_SYNC_PLAN_ERROR",
                message=f"{type(exc).__name__}: {exc}",
                details={
                    "traceback": traceback.format_exc(),
                },
            )
        )
        report["findings"] = [
            finding.as_dict()
            for finding in findings
        ]
        report["summary"] = {
            "actions": 0,
            "blockers": 1,
        }
        report["final_status"] = "DOCUMENT_SYNC_PLAN_BLOCKED"

    finally:
        if connection is not None:
            try:
                connection.rollback()
            except Exception:
                pass
            try:
                connection.close()
            except Exception:
                pass

    json_path, csv_path = write_reports(
        root,
        report,
        rows,
    )

    summary = report.get("summary", {})
    status_counts = summary.get("status_counts", {})

    print()
    print("SOUHRN STAVŮ")
    print("-" * 79)
    if status_counts:
        for status, count in status_counts.items():
            print(f"{status:<35}: {count}")
    print(
        f"{'UNREGISTERED_SOURCE_REVIEW':<35}: "
        f"{summary.get('unregistered_sources', 0)}"
    )
    print(
        f"{'DATABASE_ONLY_REVIEW':<35}: "
        f"{summary.get('database_only_documents', 0)}"
    )
    print(f"{'ACTIONS':<35}: {summary.get('actions', 0)}")
    print(f"{'BLOCKERS':<35}: {summary.get('blockers', 0)}")

    if findings:
        print()
        print("AKČNÍ FRONTA")
        print("-" * 79)
        for finding in findings:
            subject = (
                finding.document_id
                or finding.source_path
                or "GLOBAL"
            )
            print(
                f"{finding.severity:<7} | "
                f"{finding.code:<30} | "
                f"{subject}"
            )

    print()
    print(f"JSON REPORT                   : {json_path}")
    print(f"CSV REPORT                    : {csv_path}")
    print(
        "FINAL STATUS                  : "
        f"{report.get('final_status')}"
    )

    return (
        1
        if report.get("final_status")
        == "DOCUMENT_SYNC_PLAN_BLOCKED"
        else 0
    )


if __name__ == "__main__":
    raise SystemExit(main())
