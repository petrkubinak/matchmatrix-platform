#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Provádí read-only integritní audit prvního kanonického importu dokumentace
MatchMatrix v PostgreSQL schématu `documentation`.

K ČEMU:
- ověří připravenost a konzistenci importního manifestu,
- porovná každý zdrojový Markdown soubor s manifestem a databází,
- ověří SHA-256, verzi, stav, titul, typ, edici a aktuální verzi,
- porovná celý Markdown obsah uložený v databázi se zdrojovým souborem,
- znovu rozparsuje sekce stejnými pravidly jako importer a porovná je 1:1,
- ověří relace mezi dokumenty proti odkazům nalezeným v Markdown obsahu,
- ověří historii stavů, importní běhy, orphan záznamy a unikátnost,
- vytvoří JSON a CSV report,
- databázi nikdy nemění.

KDE:
tools/documentation/25_1_A_7_VERIFY_DOCUMENTATION_IMPORT_V1.py

JAK:
Standardní audit:
    py -3.14 .\\tools\\documentation\\25_1_A_7_VERIFY_DOCUMENTATION_IMPORT_V1.py

Volitelné připojení:
    --dsn "host=localhost port=5432 dbname=matchmatrix user=postgres"

Volitelný manifest:
    --manifest reports/documentation/document_import_manifest_latest.json

Připojení lze dodat také pomocí DATABASE_URL, MATCHMATRIX_DATABASE_URL,
PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD nebo odpovídajících hodnot
v projektovém `.env`.
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
import unicodedata
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence


SCHEMA = "documentation"
MANIFEST_RELATIVE_PATH = Path(
    "reports/documentation/document_import_manifest_latest.json"
)
REPORT_PREFIX = "document_import_verification"
EXPECTED_MANIFEST_STATUS = "DOCUMENT_IMPORT_MANIFEST_READY"
SUCCESS_IMPORT_STATUSES = {"DONE", "DONE_WITH_WARNINGS"}
DOCUMENT_ID_PATTERN = re.compile(
    r"(?<![A-Z0-9])MM-(?:DOC|STD|REF)-\d{3,4}(?![A-Z0-9])",
    re.IGNORECASE,
)
HEADING_PATTERN = re.compile(r"^(#{1,6})\s+(.+?)\s*$")


REQUIRED_TABLE_COLUMNS: dict[str, set[str]] = {
    "documents": {
        "document_pk",
        "document_id",
        "title",
        "document_type",
        "edition",
        "current_version_label",
        "current_status",
        "source_of_truth",
        "is_active",
        "created_at",
        "updated_at",
    },
    "document_versions": {
        "version_pk",
        "document_pk",
        "import_run_pk",
        "version_label",
        "version_status",
        "content_markdown",
        "content_hash_sha256",
        "source_filename",
        "source_file_path",
        "source_git_commit",
        "source_modified_at",
        "change_summary",
        "is_current",
        "imported_at",
        "imported_by",
        "metadata",
    },
    "document_sections": {
        "version_pk",
        "section_order",
        "heading_level",
        "title",
        "section_key",
        "content_markdown",
        "created_at",
    },
    "document_relations": {
        "source_document_pk",
        "target_document_pk",
        "relation_type",
        "created_at",
    },
    "document_status_history": {
        "document_pk",
        "version_pk",
        "previous_status",
        "new_status",
        "change_reason",
        "changed_at",
    },
    "import_runs": {
        "import_run_pk",
        "started_at",
        "finished_at",
        "import_status",
        "source_root",
        "details",
    },
}

REQUIRED_VIEWS = {
    "v_document_integrity_v1",
    "v_document_registry_v1",
}


@dataclass
class Driver:
    name: str
    module: Any
    dict_row_factory: Any

    def connect(self, dsn: str | None, kwargs: dict[str, Any]) -> Any:
        if self.name == "psycopg3":
            if dsn:
                return self.module.connect(dsn, row_factory=self.dict_row_factory)
            return self.module.connect(row_factory=self.dict_row_factory, **kwargs)

        if dsn:
            return self.module.connect(dsn, cursor_factory=self.dict_row_factory)
        return self.module.connect(cursor_factory=self.dict_row_factory, **kwargs)


@dataclass
class Finding:
    severity: str
    code: str
    message: str
    document_id: str | None = None
    details: dict[str, Any] = field(default_factory=dict)

    def as_dict(self) -> dict[str, Any]:
        return {
            "severity": self.severity,
            "code": self.code,
            "message": self.message,
            "document_id": self.document_id,
            "details": self.details,
        }


@dataclass
class AuditState:
    checks_total: int = 0
    checks_passed: int = 0
    warnings: list[Finding] = field(default_factory=list)
    blockers: list[Finding] = field(default_factory=list)

    def require(
        self,
        condition: bool,
        code: str,
        message: str,
        *,
        document_id: str | None = None,
        details: Mapping[str, Any] | None = None,
    ) -> bool:
        self.checks_total += 1
        if condition:
            self.checks_passed += 1
            return True

        self.blockers.append(
            Finding(
                severity="BLOCKER",
                code=code,
                message=message,
                document_id=document_id,
                details=dict(details or {}),
            )
        )
        return False

    def warn(
        self,
        condition: bool,
        code: str,
        message: str,
        *,
        document_id: str | None = None,
        details: Mapping[str, Any] | None = None,
    ) -> bool:
        self.checks_total += 1
        if condition:
            self.checks_passed += 1
            return True

        self.warnings.append(
            Finding(
                severity="WARNING",
                code=code,
                message=message,
                document_id=document_id,
                details=dict(details or {}),
            )
        )
        return False


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Read-only integritní audit importované dokumentace MatchMatrix."
    )
    parser.add_argument(
        "--dsn",
        help="PostgreSQL DSN. Má přednost před proměnnými prostředí a .env.",
    )
    parser.add_argument(
        "--manifest",
        help="Relativní nebo absolutní cesta k JSON manifestu.",
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


def decode_markdown(data: bytes) -> str:
    return data.decode("utf-8-sig")


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
            value = first_nonempty(os.getenv(key), env_file.get(key))
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
        "host": env_value("PGHOST", "DB_HOST", "POSTGRES_HOST")
        or "localhost",
        "port": int(
            env_value("PGPORT", "DB_PORT", "POSTGRES_PORT") or "5432"
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
            'Chybí PostgreSQL driver. Nainstaluj: py -3.14 -m pip install "psycopg[binary]"'
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


def query_one(
    connection: Any,
    sql: str,
    params: Sequence[Any] = (),
) -> dict[str, Any] | None:
    rows = query_all(connection, sql, params)
    return rows[0] if rows else None


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


def resolve_manifest_path(root: Path, value: str | None) -> Path:
    if not value:
        return root / MANIFEST_RELATIVE_PATH

    path = Path(value)
    if not path.is_absolute():
        path = root / path
    return path.resolve()


def load_manifest(
    path: Path,
    root: Path,
    audit: AuditState,
) -> tuple[dict[str, Any], bytes]:
    audit.require(
        path.is_file(),
        "MANIFEST_MISSING",
        f"Manifest nebyl nalezen: {path}",
    )
    if not path.is_file():
        return {}, b""

    data = path.read_bytes()
    try:
        payload = json.loads(data.decode("utf-8-sig"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        audit.require(
            False,
            "MANIFEST_INVALID_JSON",
            f"Manifest nelze načíst jako UTF-8 JSON: {exc}",
        )
        return {}, data

    audit.require(
        payload.get("final_status") == EXPECTED_MANIFEST_STATUS,
        "MANIFEST_NOT_READY",
        (
            "Manifest nemá stav "
            f"{EXPECTED_MANIFEST_STATUS}: {payload.get('final_status')}"
        ),
    )

    documents = payload.get("documents")
    audit.require(
        isinstance(documents, list) and bool(documents),
        "MANIFEST_DOCUMENTS_MISSING",
        "Manifest neobsahuje neprázdný seznam documents.",
    )
    if not isinstance(documents, list):
        payload["documents"] = []
        documents = []

    document_ids = [
        str(item.get("document_id") or "")
        for item in documents
        if isinstance(item, dict)
    ]
    audit.require(
        len(document_ids) == len(set(document_ids)),
        "MANIFEST_DUPLICATE_DOCUMENT_IDS",
        "Manifest obsahuje duplicitní document_id.",
    )
    audit.require(
        all(
            isinstance(item, dict)
            and item.get("import_eligible") is True
            and not item.get("blockers")
            for item in documents
        ),
        "MANIFEST_HAS_INELIGIBLE_DOCUMENT",
        "Ne všechny dokumenty manifestu jsou import_eligible bez blokátorů.",
    )

    configured = payload.get("summary", {}).get("configured_candidates")
    eligible = payload.get("summary", {}).get("eligible_candidates")
    audit.require(
        configured == len(documents) == eligible,
        "MANIFEST_SUMMARY_COUNT_MISMATCH",
        "Počty kandidátů v souhrnu manifestu neodpovídají seznamu documents.",
        details={
            "configured_candidates": configured,
            "eligible_candidates": eligible,
            "documents": len(documents),
        },
    )
    return payload, data


def document_family(document_id: str) -> str:
    parts = document_id.split("-")
    return parts[1] if len(parts) >= 3 else "UNKNOWN"


def default_edition(
    document_id: str,
    manifest_edition: str | None,
) -> str:
    if manifest_edition:
        return manifest_edition
    family = document_family(document_id)
    return {
        "DOC": "TECH",
        "STD": "STANDARD",
        "REF": "REFERENCE",
    }.get(family, family)


def clean_heading(value: str) -> str:
    value = re.sub(r"[`*_]+", "", value)
    value = re.sub(r"\s+#+\s*$", "", value)
    return value.strip()


def slugify(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value)
    ascii_value = "".join(
        ch for ch in normalized if not unicodedata.combining(ch)
    )
    ascii_value = ascii_value.lower()
    ascii_value = re.sub(r"[^a-z0-9]+", "-", ascii_value).strip("-")
    return ascii_value[:240] or "section"


def parse_sections(text: str) -> list[dict[str, Any]]:
    lines = text.splitlines()
    headings: list[tuple[int, int, str]] = []

    for index, line in enumerate(lines):
        match = HEADING_PATTERN.match(line)
        if match:
            headings.append(
                (
                    index,
                    len(match.group(1)),
                    clean_heading(match.group(2)),
                )
            )

    if not headings:
        return [
            {
                "ordinal": 1,
                "level": 1,
                "title": "Document",
                "anchor": "document",
                "content": text,
                "parent_ordinal": None,
            }
        ]

    sections: list[dict[str, Any]] = []
    stack: list[tuple[int, int]] = []
    slug_counts: dict[str, int] = {}

    for position, (line_index, level, title) in enumerate(headings):
        end_index = (
            headings[position + 1][0]
            if position + 1 < len(headings)
            else len(lines)
        )
        content = "\n".join(lines[line_index:end_index]).rstrip() + "\n"

        while stack and stack[-1][0] >= level:
            stack.pop()

        parent_ordinal = stack[-1][1] if stack else None
        ordinal = position + 1
        stack.append((level, ordinal))

        base_slug = slugify(title)
        slug_counts[base_slug] = slug_counts.get(base_slug, 0) + 1
        anchor = (
            base_slug
            if slug_counts[base_slug] == 1
            else f"{base_slug}-{slug_counts[base_slug]}"
        )

        sections.append(
            {
                "ordinal": ordinal,
                "level": level,
                "title": title,
                "anchor": anchor,
                "content": content,
                "parent_ordinal": parent_ordinal,
            }
        )

    return sections


def extract_relations(
    text: str,
    own_document_id: str,
    known_ids: set[str],
) -> set[str]:
    found = {
        match.group(0).upper()
        for match in DOCUMENT_ID_PATTERN.finditer(text)
    }
    found.discard(own_document_id.upper())
    return found & known_ids


def table_and_view_inventory(
    connection: Any,
) -> tuple[dict[str, str], dict[str, set[str]]]:
    objects = query_all(
        connection,
        """
        SELECT
            c.relname AS object_name,
            c.relkind AS object_kind
        FROM pg_class AS c
        JOIN pg_namespace AS n
          ON n.oid = c.relnamespace
        WHERE n.nspname = %s
          AND c.relkind IN ('r', 'p', 'v', 'm')
        """,
        (SCHEMA,),
    )
    object_kinds = {
        str(row["object_name"]): str(row["object_kind"])
        for row in objects
    }

    rows = query_all(
        connection,
        """
        SELECT table_name, column_name
        FROM information_schema.columns
        WHERE table_schema = %s
        ORDER BY table_name, ordinal_position
        """,
        (SCHEMA,),
    )
    columns: dict[str, set[str]] = defaultdict(set)
    for row in rows:
        columns[str(row["table_name"])].add(str(row["column_name"]))

    return object_kinds, dict(columns)


def validate_schema(
    connection: Any,
    audit: AuditState,
) -> dict[str, Any]:
    object_kinds, columns = table_and_view_inventory(connection)

    for table_name, required_columns in REQUIRED_TABLE_COLUMNS.items():
        audit.require(
            object_kinds.get(table_name) in {"r", "p"},
            "REQUIRED_TABLE_MISSING",
            f"Chybí tabulka {SCHEMA}.{table_name}.",
            details={"table": table_name},
        )
        missing = sorted(required_columns - columns.get(table_name, set()))
        audit.require(
            not missing,
            "REQUIRED_COLUMNS_MISSING",
            f"Tabulka {SCHEMA}.{table_name} nemá všechny požadované sloupce.",
            details={
                "table": table_name,
                "missing_columns": missing,
            },
        )

    for view_name in REQUIRED_VIEWS:
        audit.require(
            object_kinds.get(view_name) in {"v", "m"},
            "REQUIRED_VIEW_MISSING",
            f"Chybí view {SCHEMA}.{view_name}.",
            details={"view": view_name},
        )

    return {
        "objects": object_kinds,
        "columns": {
            table: sorted(values)
            for table, values in columns.items()
        },
    }


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
            content_markdown,
            content_hash_sha256,
            source_filename,
            source_file_path,
            source_git_commit,
            source_modified_at,
            change_summary,
            is_current,
            imported_at,
            imported_by,
            metadata
        FROM documentation.document_versions
        ORDER BY document_pk, version_pk
        """,
    )

    sections = query_all(
        connection,
        """
        SELECT
            version_pk,
            section_order,
            heading_level,
            title,
            section_key,
            content_markdown,
            created_at
        FROM documentation.document_sections
        ORDER BY version_pk, section_order
        """,
    )

    relations = query_all(
        connection,
        """
        SELECT
            source.document_id AS source_document_id,
            target.document_id AS target_document_id,
            r.relation_type,
            r.created_at
        FROM documentation.document_relations AS r
        LEFT JOIN documentation.documents AS source
          ON source.document_pk = r.source_document_pk
        LEFT JOIN documentation.documents AS target
          ON target.document_pk = r.target_document_pk
        ORDER BY
            source.document_id,
            target.document_id,
            r.created_at
        """,
    )

    history = query_all(
        connection,
        """
        SELECT
            h.document_pk,
            d.document_id,
            h.version_pk,
            h.previous_status,
            h.new_status,
            h.change_reason,
            h.changed_at
        FROM documentation.document_status_history AS h
        LEFT JOIN documentation.documents AS d
          ON d.document_pk = h.document_pk
        ORDER BY h.document_pk, h.changed_at
        """,
    )

    import_runs = query_all(
        connection,
        """
        SELECT
            import_run_pk,
            started_at,
            finished_at,
            import_status,
            source_root,
            details
        FROM documentation.import_runs
        ORDER BY import_run_pk
        """,
    )

    orphan_counts = query_one(
        connection,
        """
        SELECT
            (
                SELECT COUNT(*)
                FROM documentation.document_versions AS v
                LEFT JOIN documentation.documents AS d
                  ON d.document_pk = v.document_pk
                WHERE d.document_pk IS NULL
            ) AS orphan_versions,
            (
                SELECT COUNT(*)
                FROM documentation.document_sections AS s
                LEFT JOIN documentation.document_versions AS v
                  ON v.version_pk = s.version_pk
                WHERE v.version_pk IS NULL
            ) AS orphan_sections,
            (
                SELECT COUNT(*)
                FROM documentation.document_relations AS r
                LEFT JOIN documentation.documents AS source
                  ON source.document_pk = r.source_document_pk
                LEFT JOIN documentation.documents AS target
                  ON target.document_pk = r.target_document_pk
                WHERE source.document_pk IS NULL
                   OR target.document_pk IS NULL
            ) AS orphan_relations,
            (
                SELECT COUNT(*)
                FROM documentation.document_status_history AS h
                LEFT JOIN documentation.documents AS d
                  ON d.document_pk = h.document_pk
                LEFT JOIN documentation.document_versions AS v
                  ON v.version_pk = h.version_pk
                WHERE d.document_pk IS NULL
                   OR v.version_pk IS NULL
            ) AS orphan_status_history
        """,
    ) or {}

    return {
        "documents": documents,
        "versions": versions,
        "sections": sections,
        "relations": relations,
        "history": history,
        "import_runs": import_runs,
        "orphan_counts": orphan_counts,
    }


def compare_sections(
    expected: list[dict[str, Any]],
    actual: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    mismatches: list[dict[str, Any]] = []

    if len(expected) != len(actual):
        mismatches.append(
            {
                "kind": "COUNT",
                "expected": len(expected),
                "actual": len(actual),
            }
        )

    for index, (expected_row, actual_row) in enumerate(
        zip(expected, actual),
        start=1,
    ):
        comparisons = {
            "section_order": (
                expected_row["ordinal"],
                actual_row.get("section_order"),
            ),
            "heading_level": (
                expected_row["level"],
                actual_row.get("heading_level"),
            ),
            "title": (
                expected_row["title"],
                actual_row.get("title"),
            ),
            "section_key": (
                expected_row["anchor"],
                actual_row.get("section_key"),
            ),
            "content_markdown": (
                expected_row["content"],
                actual_row.get("content_markdown"),
            ),
        }

        row_mismatches = {
            field: {
                "expected": expected_value,
                "actual": actual_value,
            }
            for field, (expected_value, actual_value) in comparisons.items()
            if expected_value != actual_value
        }
        if row_mismatches:
            mismatches.append(
                {
                    "kind": "ROW",
                    "position": index,
                    "fields": row_mismatches,
                }
            )

        if len(mismatches) >= 20:
            break

    return mismatches


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
    payload: dict[str, Any],
    document_rows: list[dict[str, Any]],
) -> tuple[Path, Path]:
    reports_dir = root / "reports" / "documentation"
    reports_dir.mkdir(parents=True, exist_ok=True)

    timestamp = utc_now().astimezone().strftime("%Y%m%d_%H%M%S")
    json_path = reports_dir / f"{REPORT_PREFIX}_{timestamp}.json"
    csv_path = reports_dir / f"{REPORT_PREFIX}_{timestamp}.csv"
    latest_json = reports_dir / f"{REPORT_PREFIX}_latest.json"
    latest_csv = reports_dir / f"{REPORT_PREFIX}_latest.csv"

    encoded = json.dumps(
        serializable(payload),
        ensure_ascii=False,
        indent=2,
    )
    json_path.write_text(encoded, encoding="utf-8")
    latest_json.write_text(encoded, encoding="utf-8")

    fieldnames = [
        "document_id",
        "audit_status",
        "version",
        "document_status",
        "source_path",
        "manifest_sha256",
        "database_sha256",
        "sections_expected",
        "sections_actual",
        "relations_expected",
        "relations_actual_outgoing",
        "blockers",
        "warnings",
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
            for row in document_rows:
                csv_row = dict(row)
                csv_row["blockers"] = ";".join(
                    row.get("blockers", [])
                )
                csv_row["warnings"] = ";".join(
                    row.get("warnings", [])
                )
                writer.writerow(csv_row)

    return json_path, csv_path


def main() -> int:
    args = parse_args()
    root = project_root()
    manifest_path = resolve_manifest_path(root, args.manifest)
    audit = AuditState()
    generated_at = utc_now()
    git = git_info(root)

    report: dict[str, Any] = {
        "generated_at": generated_at.isoformat(),
        "project_root": str(root),
        "manifest_path": str(manifest_path),
        "git": git,
        "database": {},
        "manifest": {},
        "schema": {},
        "counts": {},
        "documents": [],
        "relations": {},
        "import_runs": {},
        "findings": {},
    }
    document_report_rows: list[dict[str, Any]] = []

    print("MATCHMATRIX DOCUMENTATION IMPORT INTEGRITY AUDIT")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"MANIFEST           : {manifest_path}")
    print(f"GIT COMMIT         : {git.get('commit')}")
    print(f"GIT DIRTY          : {git.get('dirty')}")
    print()

    manifest, manifest_bytes = load_manifest(
        manifest_path,
        root,
        audit,
    )
    report["manifest"] = {
        "sha256": sha256_bytes(manifest_bytes)
        if manifest_bytes
        else None,
        "final_status": manifest.get("final_status"),
        "summary": manifest.get("summary"),
        "document_count": len(manifest.get("documents", [])),
    }

    driver: Driver | None = None
    connection: Any = None

    try:
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

        report["schema"] = validate_schema(connection, audit)
        if audit.blockers:
            raise RuntimeError(
                "Schéma documentation neodpovídá požadavkům auditu."
            )

        snapshot = fetch_database_snapshot(connection)

        documents = snapshot["documents"]
        versions = snapshot["versions"]
        sections = snapshot["sections"]
        relations = snapshot["relations"]
        history = snapshot["history"]
        import_runs = snapshot["import_runs"]
        orphan_counts = snapshot["orphan_counts"]

        report["counts"] = {
            "documents": len(documents),
            "document_versions": len(versions),
            "current_versions": sum(
                1 for row in versions if row.get("is_current") is True
            ),
            "document_sections": len(sections),
            "document_relations": len(relations),
            "document_status_history": len(history),
            "import_runs": len(import_runs),
        }

        manifest_documents = manifest.get("documents", [])
        manifest_by_id = {
            str(item["document_id"]): item
            for item in manifest_documents
        }
        known_ids = set(manifest_by_id)

        documents_by_id: dict[str, list[dict[str, Any]]] = defaultdict(list)
        documents_by_pk: dict[Any, dict[str, Any]] = {}
        for row in documents:
            documents_by_id[str(row.get("document_id"))].append(row)
            documents_by_pk[row.get("document_pk")] = row

        versions_by_document_pk: dict[Any, list[dict[str, Any]]] = defaultdict(list)
        versions_by_pk: dict[Any, dict[str, Any]] = {}
        for row in versions:
            versions_by_document_pk[row.get("document_pk")].append(row)
            versions_by_pk[row.get("version_pk")] = row

        sections_by_version_pk: dict[Any, list[dict[str, Any]]] = defaultdict(list)
        for row in sections:
            sections_by_version_pk[row.get("version_pk")].append(row)

        history_by_document_pk: dict[Any, list[dict[str, Any]]] = defaultdict(list)
        for row in history:
            history_by_document_pk[row.get("document_pk")].append(row)

        runs_by_pk = {
            row.get("import_run_pk"): row
            for row in import_runs
        }

        database_ids = {
            str(row.get("document_id"))
            for row in documents
        }
        audit.require(
            database_ids == known_ids,
            "DATABASE_DOCUMENT_SET_MISMATCH",
            "Množina document_id v databázi neodpovídá manifestu.",
            details={
                "missing_in_database": sorted(known_ids - database_ids),
                "extra_in_database": sorted(database_ids - known_ids),
            },
        )

        duplicate_document_ids = {
            document_id: len(rows)
            for document_id, rows in documents_by_id.items()
            if len(rows) > 1
        }
        audit.require(
            not duplicate_document_ids,
            "DATABASE_DUPLICATE_DOCUMENT_IDS",
            "Databáze obsahuje duplicitní document_id.",
            details={"duplicates": duplicate_document_ids},
        )

        multiple_current_versions: dict[str, int] = {}
        missing_current_versions: list[str] = []
        duplicate_version_labels: dict[str, list[str]] = {}
        duplicate_hashes: dict[str, list[str]] = {}

        for document_id, rows in documents_by_id.items():
            if len(rows) != 1:
                continue
            document_pk = rows[0]["document_pk"]
            doc_versions = versions_by_document_pk.get(document_pk, [])
            current_count = sum(
                1 for row in doc_versions if row.get("is_current") is True
            )
            if current_count == 0:
                missing_current_versions.append(document_id)
            elif current_count > 1:
                multiple_current_versions[document_id] = current_count

            labels: dict[str, int] = defaultdict(int)
            hashes: dict[str, int] = defaultdict(int)
            for version_row in doc_versions:
                labels[str(version_row.get("version_label"))] += 1
                hashes[str(version_row.get("content_hash_sha256"))] += 1

            duplicate_labels_for_document = sorted(
                value for value, count in labels.items() if count > 1
            )
            duplicate_hashes_for_document = sorted(
                value for value, count in hashes.items() if count > 1
            )
            if duplicate_labels_for_document:
                duplicate_version_labels[document_id] = (
                    duplicate_labels_for_document
                )
            if duplicate_hashes_for_document:
                duplicate_hashes[document_id] = (
                    duplicate_hashes_for_document
                )

        audit.require(
            not missing_current_versions,
            "CURRENT_VERSION_MISSING",
            "Některé dokumenty nemají aktuální verzi.",
            details={"document_ids": missing_current_versions},
        )
        audit.require(
            not multiple_current_versions,
            "MULTIPLE_CURRENT_VERSIONS",
            "Některé dokumenty mají více aktuálních verzí.",
            details={"documents": multiple_current_versions},
        )
        audit.require(
            not duplicate_version_labels,
            "DUPLICATE_VERSION_LABELS",
            "Dokument obsahuje stejný version_label vícekrát.",
            details={"documents": duplicate_version_labels},
        )
        audit.require(
            not duplicate_hashes,
            "DUPLICATE_VERSION_HASHES",
            "Dokument obsahuje stejný SHA-256 ve více verzích.",
            details={"documents": duplicate_hashes},
        )

        for key, value in orphan_counts.items():
            audit.require(
                int(value or 0) == 0,
                f"{str(key).upper()}_FOUND",
                f"Byly nalezeny orphan záznamy: {key}={value}.",
                details={key: value},
            )

        expected_relations: set[tuple[str, str, str]] = set()
        source_texts: dict[str, str] = {}
        expected_section_total = 0

        print("AUDIT DOKUMENTŮ")
        print("-" * 79)

        for document_id in sorted(known_ids):
            manifest_row = manifest_by_id[document_id]
            blocker_before = len(audit.blockers)
            warning_before = len(audit.warnings)

            source_path = root / str(manifest_row.get("source_path"))
            source_exists = audit.require(
                source_path.is_file(),
                "SOURCE_FILE_MISSING",
                f"Zdrojový Markdown soubor nebyl nalezen: {source_path}",
                document_id=document_id,
            )

            source_data = b""
            source_text = ""
            actual_file_hash = None
            expected_sections: list[dict[str, Any]] = []

            if source_exists:
                source_data = source_path.read_bytes()
                actual_file_hash = sha256_bytes(source_data)
                audit.require(
                    actual_file_hash == str(manifest_row.get("sha256") or ""),
                    "SOURCE_SHA256_MISMATCH",
                    "SHA-256 zdrojového souboru neodpovídá manifestu.",
                    document_id=document_id,
                    details={
                        "manifest_sha256": manifest_row.get("sha256"),
                        "actual_sha256": actual_file_hash,
                    },
                )
                try:
                    source_text = decode_markdown(source_data)
                except UnicodeDecodeError as exc:
                    audit.require(
                        False,
                        "SOURCE_INVALID_UTF8",
                        f"Zdrojový soubor není platné UTF-8: {exc}",
                        document_id=document_id,
                    )
                    source_text = ""

                if source_text:
                    source_texts[document_id] = source_text
                    expected_sections = parse_sections(source_text)
                    expected_section_total += len(expected_sections)
                    for target_id in extract_relations(
                        source_text,
                        document_id,
                        known_ids,
                    ):
                        expected_relations.add(
                            (document_id, target_id, "REFERENCES")
                        )

            db_document_rows = documents_by_id.get(document_id, [])
            audit.require(
                len(db_document_rows) == 1,
                "DATABASE_DOCUMENT_ROW_COUNT_INVALID",
                "Dokument musí mít právě jeden řádek v documentation.documents.",
                document_id=document_id,
                details={"row_count": len(db_document_rows)},
            )

            db_document = db_document_rows[0] if len(db_document_rows) == 1 else None
            db_version = None
            actual_sections: list[dict[str, Any]] = []
            history_rows: list[dict[str, Any]] = []

            if db_document:
                expected_document_values = {
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

                metadata_mismatches = {
                    column: {
                        "expected": expected,
                        "actual": db_document.get(column),
                    }
                    for column, expected in expected_document_values.items()
                    if normalize_scalar(db_document.get(column))
                    != normalize_scalar(expected)
                }
                audit.require(
                    not metadata_mismatches,
                    "DOCUMENT_METADATA_MISMATCH",
                    "Metadata dokumentu v databázi neodpovídají manifestu.",
                    document_id=document_id,
                    details={"mismatches": metadata_mismatches},
                )

                document_pk = db_document["document_pk"]
                current_versions = [
                    row
                    for row in versions_by_document_pk.get(document_pk, [])
                    if row.get("is_current") is True
                ]
                audit.require(
                    len(current_versions) == 1,
                    "CURRENT_VERSION_ROW_COUNT_INVALID",
                    "Dokument musí mít právě jednu aktuální verzi.",
                    document_id=document_id,
                    details={"row_count": len(current_versions)},
                )

                if len(current_versions) == 1:
                    db_version = current_versions[0]
                    expected_version_values = {
                        "version_label": manifest_row.get("version"),
                        "version_status": manifest_row.get("status"),
                        "content_hash_sha256": manifest_row.get("sha256"),
                        "source_filename": source_path.name,
                        "source_file_path": normalize_path(
                            manifest_row.get("source_path")
                        ),
                    }

                    version_mismatches: dict[str, Any] = {}
                    for column, expected in expected_version_values.items():
                        actual = db_version.get(column)
                        if column == "source_file_path":
                            actual = normalize_path(actual)
                            expected = normalize_path(expected)
                        if normalize_scalar(actual) != normalize_scalar(expected):
                            version_mismatches[column] = {
                                "expected": expected,
                                "actual": actual,
                            }

                    audit.require(
                        not version_mismatches,
                        "VERSION_METADATA_MISMATCH",
                        "Metadata aktuální verze neodpovídají manifestu.",
                        document_id=document_id,
                        details={"mismatches": version_mismatches},
                    )

                    audit.require(
                        bool(str(db_version.get("source_git_commit") or "").strip()),
                        "VERSION_SOURCE_GIT_COMMIT_MISSING",
                        "Aktuální verze nemá source_git_commit.",
                        document_id=document_id,
                    )
                    audit.require(
                        db_version.get("source_modified_at") is not None,
                        "VERSION_SOURCE_MODIFIED_AT_MISSING",
                        "Aktuální verze nemá source_modified_at.",
                        document_id=document_id,
                    )
                    audit.require(
                        str(db_version.get("imported_by") or "").strip()
                        == "25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py",
                        "VERSION_IMPORTED_BY_MISMATCH",
                        "Aktuální verze nemá očekávanou hodnotu imported_by.",
                        document_id=document_id,
                        details={
                            "actual": db_version.get("imported_by"),
                        },
                    )

                    metadata = db_version.get("metadata")
                    if isinstance(metadata, str):
                        try:
                            metadata = json.loads(metadata)
                        except json.JSONDecodeError:
                            metadata = None

                    audit.require(
                        isinstance(metadata, dict)
                        and metadata.get("document_id") == document_id
                        and metadata.get("source_of_truth") == "HYBRID",
                        "VERSION_METADATA_JSON_INVALID",
                        "JSON metadata aktuální verze nejsou úplná.",
                        document_id=document_id,
                        details={"metadata": metadata},
                    )

                    db_content = str(
                        db_version.get("content_markdown") or ""
                    )
                    audit.require(
                        db_content == source_text,
                        "DATABASE_CONTENT_MISMATCH",
                        "Markdown obsah aktuální verze se liší od zdrojového souboru.",
                        document_id=document_id,
                        details={
                            "source_normalized_sha256": sha256_bytes(
                                source_text.encode("utf-8")
                            )
                            if source_text
                            else None,
                            "database_normalized_sha256": sha256_bytes(
                                db_content.encode("utf-8")
                            ),
                        },
                    )

                    run = runs_by_pk.get(db_version.get("import_run_pk"))
                    audit.require(
                        run is not None,
                        "VERSION_IMPORT_RUN_MISSING",
                        "Aktuální verze odkazuje na neexistující importní běh.",
                        document_id=document_id,
                        details={
                            "import_run_pk": db_version.get("import_run_pk"),
                        },
                    )
                    if run:
                        audit.require(
                            str(run.get("import_status"))
                            in SUCCESS_IMPORT_STATUSES,
                            "VERSION_IMPORT_RUN_NOT_SUCCESSFUL",
                            "Importní běh aktuální verze není úspěšný.",
                            document_id=document_id,
                            details={
                                "import_run_pk": run.get("import_run_pk"),
                                "import_status": run.get("import_status"),
                            },
                        )
                        audit.require(
                            run.get("finished_at") is not None,
                            "VERSION_IMPORT_RUN_NOT_FINISHED",
                            "Importní běh aktuální verze nemá finished_at.",
                            document_id=document_id,
                        )

                    actual_sections = sections_by_version_pk.get(
                        db_version["version_pk"],
                        [],
                    )
                    section_mismatches = compare_sections(
                        expected_sections,
                        actual_sections,
                    )
                    audit.require(
                        not section_mismatches,
                        "DOCUMENT_SECTIONS_MISMATCH",
                        "Sekce dokumentu v databázi neodpovídají Markdown souboru.",
                        document_id=document_id,
                        details={
                            "expected_count": len(expected_sections),
                            "actual_count": len(actual_sections),
                            "mismatches": section_mismatches,
                        },
                    )

                history_rows = history_by_document_pk.get(document_pk, [])
                audit.require(
                    bool(history_rows),
                    "STATUS_HISTORY_MISSING",
                    "Dokument nemá záznam v historii stavů.",
                    document_id=document_id,
                )
                if history_rows:
                    latest_history = history_rows[-1]
                    audit.require(
                        latest_history.get("new_status")
                        == manifest_row.get("status"),
                        "LATEST_STATUS_HISTORY_MISMATCH",
                        "Poslední historie stavu neodpovídá aktuálnímu stavu.",
                        document_id=document_id,
                        details={
                            "expected": manifest_row.get("status"),
                            "actual": latest_history.get("new_status"),
                        },
                    )
                    if db_version:
                        audit.require(
                            latest_history.get("version_pk")
                            == db_version.get("version_pk"),
                            "LATEST_STATUS_HISTORY_VERSION_MISMATCH",
                            "Poslední historie stavu neodkazuje na aktuální verzi.",
                            document_id=document_id,
                        )

            outgoing_expected = sum(
                1
                for source, _, relation_type in expected_relations
                if source == document_id
                and relation_type == "REFERENCES"
            )
            outgoing_actual = sum(
                1
                for relation in relations
                if relation.get("source_document_id") == document_id
                and relation.get("relation_type") == "REFERENCES"
            )

            document_blockers = [
                finding.code
                for finding in audit.blockers[blocker_before:]
                if finding.document_id == document_id
            ]
            document_warnings = [
                finding.code
                for finding in audit.warnings[warning_before:]
                if finding.document_id == document_id
            ]
            document_status = (
                "BLOCKED"
                if document_blockers
                else "WARNING"
                if document_warnings
                else "OK"
            )

            document_row = {
                "document_id": document_id,
                "audit_status": document_status,
                "version": manifest_row.get("version"),
                "document_status": manifest_row.get("status"),
                "source_path": manifest_row.get("source_path"),
                "manifest_sha256": manifest_row.get("sha256"),
                "database_sha256": (
                    db_version.get("content_hash_sha256")
                    if db_version
                    else None
                ),
                "sections_expected": len(expected_sections),
                "sections_actual": len(actual_sections),
                "relations_expected": outgoing_expected,
                "relations_actual_outgoing": outgoing_actual,
                "blockers": document_blockers,
                "warnings": document_warnings,
            }
            document_report_rows.append(document_row)
            report["documents"].append(document_row)

            print(
                f"{document_id:<15} | {document_status:<7} | "
                f"v{str(manifest_row.get('version')):<7} | "
                f"sections={len(actual_sections):>3}/{len(expected_sections):<3} | "
                f"relations={outgoing_actual:>2}/{outgoing_expected:<2}"
            )

        audit.require(
            len(sections) == expected_section_total,
            "TOTAL_SECTION_COUNT_MISMATCH",
            "Celkový počet sekcí neodpovídá zdrojovým dokumentům.",
            details={
                "expected": expected_section_total,
                "actual": len(sections),
            },
        )

        actual_relation_rows = [
            (
                str(row.get("source_document_id") or ""),
                str(row.get("target_document_id") or ""),
                str(row.get("relation_type") or ""),
            )
            for row in relations
        ]
        actual_relations = set(actual_relation_rows)
        duplicate_relation_count = (
            len(actual_relation_rows) - len(actual_relations)
        )
        missing_relations = sorted(expected_relations - actual_relations)
        extra_relations = sorted(actual_relations - expected_relations)

        audit.require(
            duplicate_relation_count == 0,
            "DUPLICATE_DOCUMENT_RELATIONS",
            "Tabulka document_relations obsahuje duplicitní vazby.",
            details={"duplicate_row_count": duplicate_relation_count},
        )
        audit.require(
            not missing_relations,
            "DOCUMENT_RELATIONS_MISSING",
            "V databázi chybí očekávané vazby mezi dokumenty.",
            details={"missing": missing_relations[:100]},
        )
        audit.require(
            not extra_relations,
            "DOCUMENT_RELATIONS_EXTRA",
            "Databáze obsahuje vazby, které nejsou ve zdrojových dokumentech.",
            details={"extra": extra_relations[:100]},
        )

        successful_runs = [
            row
            for row in import_runs
            if str(row.get("import_status")) in SUCCESS_IMPORT_STATUSES
        ]
        audit.require(
            bool(successful_runs),
            "SUCCESSFUL_IMPORT_RUN_MISSING",
            "Nebyl nalezen žádný úspěšný importní běh.",
        )

        current_version_run_ids = {
            row.get("import_run_pk")
            for row in versions
            if row.get("is_current") is True
        }
        current_version_runs = [
            runs_by_pk.get(run_id)
            for run_id in current_version_run_ids
        ]
        audit.require(
            all(run is not None for run in current_version_runs),
            "CURRENT_VERSION_RUN_REFERENCE_INVALID",
            "Některá aktuální verze odkazuje na neexistující importní běh.",
            details={
                "run_ids": sorted(
                    run_id
                    for run_id in current_version_run_ids
                    if run_id is not None
                )
            },
        )
        audit.require(
            all(
                run is not None
                and str(run.get("import_status"))
                in SUCCESS_IMPORT_STATUSES
                for run in current_version_runs
            ),
            "CURRENT_VERSION_RUN_NOT_SUCCESSFUL",
            "Některá aktuální verze pochází z neúspěšného importního běhu.",
        )

        latest_successful_run = (
            max(
                successful_runs,
                key=lambda row: int(row.get("import_run_pk") or 0),
            )
            if successful_runs
            else None
        )

        if (
            latest_successful_run
            and len(current_version_run_ids) == 1
            and latest_successful_run.get("import_run_pk")
            in current_version_run_ids
        ):
            details = latest_successful_run.get("details")
            if isinstance(details, str):
                try:
                    details = json.loads(details)
                except json.JSONDecodeError:
                    details = None

            expected_counters = {
                "documents_inserted": len(manifest_documents),
                "versions_inserted": len(manifest_documents),
                "sections_inserted": expected_section_total,
                "relations_inserted": len(expected_relations),
                "status_history_inserted": len(manifest_documents),
            }
            counter_mismatches = {
                key: {
                    "expected": expected,
                    "actual": details.get(key)
                    if isinstance(details, dict)
                    else None,
                }
                for key, expected in expected_counters.items()
                if not isinstance(details, dict)
                or details.get(key) != expected
            }
            audit.require(
                not counter_mismatches,
                "IMPORT_RUN_COUNTERS_MISMATCH",
                "Souhrn posledního importního běhu neodpovídá databázi.",
                details={"mismatches": counter_mismatches},
            )

        report["relations"] = {
            "expected": len(expected_relations),
            "actual": len(actual_relation_rows),
            "unique_actual": len(actual_relations),
            "missing": missing_relations,
            "extra": extra_relations,
            "duplicate_row_count": duplicate_relation_count,
        }
        report["import_runs"] = {
            "successful_run_count": len(successful_runs),
            "current_version_run_ids": sorted(
                run_id
                for run_id in current_version_run_ids
                if run_id is not None
            ),
            "latest_successful_run": serializable(
                latest_successful_run
            ),
        }

        print()
        print("DATABÁZOVÉ POČTY")
        print("-" * 79)
        for key, value in report["counts"].items():
            print(f"{key:<30}: {value}")

        print()
        print("INTEGRITA VAZEB")
        print("-" * 79)
        print(f"expected_relations             : {len(expected_relations)}")
        print(f"actual_relations               : {len(actual_relation_rows)}")
        print(f"missing_relations              : {len(missing_relations)}")
        print(f"extra_relations                : {len(extra_relations)}")
        print(f"duplicate_relation_rows        : {duplicate_relation_count}")

    except Exception as exc:
        if not any(
            finding.code == "UNHANDLED_AUDIT_ERROR"
            for finding in audit.blockers
        ):
            audit.blockers.append(
                Finding(
                    severity="BLOCKER",
                    code="UNHANDLED_AUDIT_ERROR",
                    message=f"{type(exc).__name__}: {exc}",
                    details={
                        "traceback": traceback.format_exc(),
                    },
                )
            )
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

    final_status = (
        "DOCUMENTATION_IMPORT_VERIFIED"
        if not audit.blockers
        else "DOCUMENTATION_IMPORT_VERIFICATION_FAILED"
    )

    report["findings"] = {
        "checks_total": audit.checks_total,
        "checks_passed": audit.checks_passed,
        "warnings": [
            finding.as_dict()
            for finding in audit.warnings
        ],
        "blockers": [
            finding.as_dict()
            for finding in audit.blockers
        ],
    }
    report["final_status"] = final_status

    json_path, csv_path = write_reports(
        root,
        report,
        document_report_rows,
    )

    if audit.blockers:
        print()
        print("BLOKÁTORY")
        print("-" * 79)
        for finding in audit.blockers:
            prefix = (
                f"{finding.document_id} | "
                if finding.document_id
                else ""
            )
            print(f"{prefix}{finding.code}: {finding.message}")

    if audit.warnings:
        print()
        print("VAROVÁNÍ")
        print("-" * 79)
        for finding in audit.warnings:
            prefix = (
                f"{finding.document_id} | "
                if finding.document_id
                else ""
            )
            print(f"{prefix}{finding.code}: {finding.message}")

    print()
    print("SOUHRN")
    print("-" * 79)
    print(f"checks_total                  : {audit.checks_total}")
    print(f"checks_passed                 : {audit.checks_passed}")
    print(f"warnings                      : {len(audit.warnings)}")
    print(f"blockers                      : {len(audit.blockers)}")
    print(f"JSON REPORT                   : {json_path}")
    print(f"CSV REPORT                    : {csv_path}")
    print(f"FINAL STATUS                  : {final_status}")

    return 0 if not audit.blockers else 1


if __name__ == "__main__":
    raise SystemExit(main())
