#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Importuje kanonickou dokumentaci MatchMatrix z manifestu do PostgreSQL schématu
`documentation`.

K ČEMU:
- načte `document_import_manifest_latest.json`,
- ověří stav manifestu, počet kandidátů a SHA-256 zdrojových Markdown souborů,
- introspektuje skutečné tabulky, sloupce, primární a cizí klíče,
- zapíše dokumenty, jejich verze, Markdown obsah a sekce,
- eviduje importní běh a změny stavu,
- chrání proti opakovanému importu stejného SHA-256,
- zablokuje změnu obsahu bez navýšení verze,
- podporuje fyzické názvy sloupců MatchMatrix jako `content_hash_sha256`,
  `source_file_path`, `source_filename` a `import_run_pk`,
- výchozí režim DRY_RUN provede celý import v transakci a následně rollback.

KDE:
tools/documentation/25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py

JAK:
Bezpečný test s rollbackem:
    py -3.14 .\\tools\\documentation\\25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py

Skutečný import:
    py -3.14 .\\tools\\documentation\\25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py --apply

Volitelné připojení:
    --dsn "host=localhost port=5432 dbname=matchmatrix user=postgres"

Připojení lze dodat také pomocí DATABASE_URL, MATCHMATRIX_DATABASE_URL,
PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD nebo odpovídajících hodnot
v projektovém `.env`.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import traceback
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence


SCHEMA = "documentation"
EXPECTED_DOCUMENTS = 21
MANIFEST_RELATIVE_PATH = Path("reports/documentation/document_import_manifest_latest.json")
REPORT_PREFIX = "document_database_import"
DOCUMENT_ID_PATTERN = re.compile(r"(?<![A-Z0-9])MM-(?:DOC|STD|REF)-\d{3,4}(?![A-Z0-9])", re.IGNORECASE)
HEADING_PATTERN = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
TEXT_TYPES = {"text", "varchar", "bpchar", "citext", "name"}
INTEGER_TYPES = {"int2", "int4", "int8", "smallint", "integer", "bigint"}
JSON_TYPES = {"json", "jsonb"}
TIMESTAMP_TYPES = {"timestamp", "timestamptz", "timestamp without time zone", "timestamp with time zone"}


@dataclass(frozen=True)
class ColumnInfo:
    name: str
    data_type: str
    udt_name: str
    nullable: bool
    default: str | None
    identity: bool
    generated: bool

    @property
    def type_key(self) -> str:
        return self.udt_name.lower()

    @property
    def has_server_value(self) -> bool:
        return self.default is not None or self.identity or self.generated


@dataclass(frozen=True)
class ForeignKeyInfo:
    table_name: str
    column_name: str
    referenced_table: str
    referenced_column: str
    constraint_name: str


@dataclass
class TableInfo:
    name: str
    columns: dict[str, ColumnInfo]
    primary_key: tuple[str, ...]
    foreign_keys: tuple[ForeignKeyInfo, ...]


@dataclass
class DbDriver:
    name: str
    module: Any
    json_adapter: Any

    def connect(self, dsn: str | None, kwargs: dict[str, Any]) -> Any:
        if dsn:
            return self.module.connect(dsn)
        return self.module.connect(**kwargs)

    def adapt_json(self, value: Any) -> Any:
        return self.json_adapter(value)


@dataclass
class ImportCounters:
    documents_inserted: int = 0
    documents_updated: int = 0
    documents_unchanged: int = 0
    versions_inserted: int = 0
    versions_skipped_same_hash: int = 0
    sections_inserted: int = 0
    relations_inserted: int = 0
    relations_skipped: int = 0
    status_history_inserted: int = 0

    def as_dict(self) -> dict[str, int]:
        return {
            "documents_inserted": self.documents_inserted,
            "documents_updated": self.documents_updated,
            "documents_unchanged": self.documents_unchanged,
            "versions_inserted": self.versions_inserted,
            "versions_skipped_same_hash": self.versions_skipped_same_hash,
            "sections_inserted": self.sections_inserted,
            "relations_inserted": self.relations_inserted,
            "relations_skipped": self.relations_skipped,
            "status_history_inserted": self.status_history_inserted,
        }


class ImportBlocked(RuntimeError):
    pass


class SchemaMappingError(ImportBlocked):
    pass


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Import kanonické dokumentace MatchMatrix do PostgreSQL."
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Potvrdí transakci. Bez přepínače se celý import po ověření vrátí rollbackem.",
    )
    parser.add_argument(
        "--dsn",
        help="PostgreSQL DSN. Přednost před proměnnými prostředí a .env.",
    )
    parser.add_argument(
        "--manifest",
        help="Relativní nebo absolutní cesta k JSON manifestu.",
    )
    parser.add_argument(
        "--allow-version-rewrite",
        action="store_true",
        help="Povolí stejnou verzi s jiným SHA-256. Standardně je to blokováno.",
    )
    parser.add_argument(
        "--skip-relations",
        action="store_true",
        help="Nevytváří vazby mezi dokumenty. Dokumenty, verze a sekce se importují.",
    )
    return parser.parse_args()


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def quote_identifier(identifier: str) -> str:
    return '"' + identifier.replace('"', '""') + '"'


def qualified(table: str) -> str:
    return f"{quote_identifier(SCHEMA)}.{quote_identifier(table)}"


def load_dotenv(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    if not path.is_file():
        return values

    for raw_line in path.read_text(encoding="utf-8-sig", errors="replace").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
            value = value[1:-1]
        values[key] = value
    return values


def first_nonempty(*values: str | None) -> str | None:
    for value in values:
        if value is not None and str(value).strip():
            return str(value).strip()
    return None


def connection_settings(root: Path, explicit_dsn: str | None) -> tuple[str | None, dict[str, Any], dict[str, Any]]:
    env_file = load_dotenv(root / ".env")

    def env_value(*keys: str) -> str | None:
        for key in keys:
            value = first_nonempty(os.getenv(key), env_file.get(key))
            if value:
                return value
        return None

    dsn = first_nonempty(
        explicit_dsn,
        env_value("MATCHMATRIX_DATABASE_URL", "DATABASE_URL", "POSTGRES_URL"),
    )

    kwargs: dict[str, Any] = {
        "host": env_value("PGHOST", "DB_HOST", "POSTGRES_HOST") or "localhost",
        "port": int(env_value("PGPORT", "DB_PORT", "POSTGRES_PORT") or "5432"),
        "dbname": env_value("PGDATABASE", "DB_NAME", "POSTGRES_DB") or "matchmatrix",
        "user": env_value("PGUSER", "DB_USER", "POSTGRES_USER") or "postgres",
    }
    password = env_value("PGPASSWORD", "DB_PASSWORD", "POSTGRES_PASSWORD")
    if password:
        kwargs["password"] = password

    public = {
        "dsn_supplied": bool(dsn),
        "host": kwargs["host"],
        "port": kwargs["port"],
        "dbname": kwargs["dbname"],
        "user": kwargs["user"],
        "password_supplied": "password" in kwargs or bool(dsn),
    }
    return dsn, kwargs, public


def load_driver() -> DbDriver:
    try:
        import psycopg  # type: ignore
        from psycopg.types.json import Jsonb  # type: ignore

        return DbDriver("psycopg3", psycopg, Jsonb)
    except ImportError:
        pass

    try:
        import psycopg2  # type: ignore
        from psycopg2.extras import Json  # type: ignore

        return DbDriver("psycopg2", psycopg2, Json)
    except ImportError as exc:
        raise ImportBlocked(
            "Chybí PostgreSQL Python driver. Nainstaluj jej příkazem: "
            "py -3.14 -m pip install \"psycopg[binary]\""
        ) from exc


def fetch_rows(cursor: Any) -> list[dict[str, Any]]:
    rows = cursor.fetchall()
    names = [description[0] for description in cursor.description]
    return [dict(zip(names, row)) for row in rows]


def inspect_schema(connection: Any) -> dict[str, TableInfo]:
    expected_tables = (
        "import_runs",
        "documents",
        "document_versions",
        "document_sections",
        "document_relations",
        "document_status_history",
    )

    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT
                table_name,
                column_name,
                data_type,
                udt_name,
                is_nullable,
                column_default,
                is_identity,
                is_generated
            FROM information_schema.columns
            WHERE table_schema = %s
              AND table_name = ANY(%s)
            ORDER BY table_name, ordinal_position
            """,
            (SCHEMA, list(expected_tables)),
        )
        column_rows = fetch_rows(cursor)

        cursor.execute(
            """
            SELECT
                tc.table_name,
                kcu.column_name,
                kcu.ordinal_position
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu
              ON kcu.constraint_schema = tc.constraint_schema
             AND kcu.constraint_name = tc.constraint_name
             AND kcu.table_schema = tc.table_schema
             AND kcu.table_name = tc.table_name
            WHERE tc.table_schema = %s
              AND tc.constraint_type = 'PRIMARY KEY'
              AND tc.table_name = ANY(%s)
            ORDER BY tc.table_name, kcu.ordinal_position
            """,
            (SCHEMA, list(expected_tables)),
        )
        pk_rows = fetch_rows(cursor)

        cursor.execute(
            """
            SELECT
                tc.table_name,
                kcu.column_name,
                ccu.table_name AS referenced_table,
                ccu.column_name AS referenced_column,
                tc.constraint_name
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu
              ON kcu.constraint_schema = tc.constraint_schema
             AND kcu.constraint_name = tc.constraint_name
             AND kcu.table_schema = tc.table_schema
             AND kcu.table_name = tc.table_name
            JOIN information_schema.constraint_column_usage ccu
              ON ccu.constraint_schema = tc.constraint_schema
             AND ccu.constraint_name = tc.constraint_name
            WHERE tc.table_schema = %s
              AND tc.constraint_type = 'FOREIGN KEY'
              AND tc.table_name = ANY(%s)
            ORDER BY tc.table_name, tc.constraint_name, kcu.ordinal_position
            """,
            (SCHEMA, list(expected_tables)),
        )
        fk_rows = fetch_rows(cursor)

    columns_by_table: dict[str, dict[str, ColumnInfo]] = {table: {} for table in expected_tables}
    for row in column_rows:
        columns_by_table.setdefault(row["table_name"], {})[row["column_name"]] = ColumnInfo(
            name=row["column_name"],
            data_type=str(row["data_type"]),
            udt_name=str(row["udt_name"]),
            nullable=str(row["is_nullable"]).upper() == "YES",
            default=row["column_default"],
            identity=str(row["is_identity"]).upper() == "YES",
            generated=str(row["is_generated"]).upper() not in {"NEVER", "NO"},
        )

    pk_by_table: dict[str, list[str]] = {table: [] for table in expected_tables}
    for row in pk_rows:
        pk_by_table.setdefault(row["table_name"], []).append(row["column_name"])

    fk_by_table: dict[str, list[ForeignKeyInfo]] = {table: [] for table in expected_tables}
    for row in fk_rows:
        fk_by_table.setdefault(row["table_name"], []).append(
            ForeignKeyInfo(
                table_name=row["table_name"],
                column_name=row["column_name"],
                referenced_table=row["referenced_table"],
                referenced_column=row["referenced_column"],
                constraint_name=row["constraint_name"],
            )
        )

    tables: dict[str, TableInfo] = {}
    for table in expected_tables:
        tables[table] = TableInfo(
            name=table,
            columns=columns_by_table.get(table, {}),
            primary_key=tuple(pk_by_table.get(table, [])),
            foreign_keys=tuple(fk_by_table.get(table, [])),
        )
    return tables


def choose_column(
    table: TableInfo,
    aliases: Sequence[str],
    *,
    type_group: str | None = None,
    required: bool = False,
    semantic_name: str = "column",
) -> str | None:
    for alias in aliases:
        column = table.columns.get(alias)
        if column is None:
            continue
        if type_group == "text" and column.type_key not in TEXT_TYPES:
            continue
        if type_group == "integer" and column.type_key not in INTEGER_TYPES:
            continue
        if type_group == "json" and column.type_key not in JSON_TYPES:
            continue
        return column.name

    if required:
        raise SchemaMappingError(
            f"Nelze namapovat {semantic_name} v {SCHEMA}.{table.name}. "
            f"Hledané aliasy: {', '.join(aliases)}. "
            f"Dostupné sloupce: {', '.join(table.columns)}"
        )
    return None


def find_fk(table: TableInfo, referenced_table: str, aliases: Sequence[str] = ()) -> str | None:
    matches = [fk for fk in table.foreign_keys if fk.referenced_table == referenced_table]
    for alias in aliases:
        for match in matches:
            if match.column_name == alias:
                return match.column_name
    if len(matches) == 1:
        return matches[0].column_name
    for match in matches:
        lowered = match.column_name.lower()
        if referenced_table.rstrip("s") in lowered or referenced_table in lowered:
            return match.column_name
    return None


def require_table(tables: Mapping[str, TableInfo], name: str) -> TableInfo:
    table = tables[name]
    if not table.columns:
        raise SchemaMappingError(f"Chybí tabulka {SCHEMA}.{name} nebo nemá viditelné sloupce.")
    return table


def primary_key_column(table: TableInfo) -> str:
    if len(table.primary_key) != 1:
        raise SchemaMappingError(
            f"Tabulka {SCHEMA}.{table.name} musí mít právě jeden primární klíč. "
            f"Nalezeno: {table.primary_key or 'NIC'}"
        )
    return table.primary_key[0]


def git_snapshot(root: Path) -> dict[str, Any]:
    def run(*args: str) -> str | None:
        try:
            completed = subprocess.run(
                ["git", *args],
                cwd=root,
                text=True,
                capture_output=True,
                check=True,
            )
            return completed.stdout.strip()
        except (FileNotFoundError, subprocess.CalledProcessError):
            return None

    status = run("status", "--porcelain")
    return {
        "commit": run("rev-parse", "HEAD"),
        "branch": run("branch", "--show-current"),
        "dirty": bool(status),
        "dirty_entries": len(status.splitlines()) if status else 0,
    }


def load_manifest(path: Path, root: Path) -> tuple[dict[str, Any], bytes]:
    if not path.is_file():
        raise ImportBlocked(f"Manifest nebyl nalezen: {path}")
    data = path.read_bytes()
    try:
        payload = json.loads(data.decode("utf-8-sig"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ImportBlocked(f"Manifest není platný UTF-8 JSON: {path}: {exc}") from exc

    if payload.get("final_status") != "DOCUMENT_IMPORT_MANIFEST_READY":
        raise ImportBlocked(
            "Manifest nemá stav DOCUMENT_IMPORT_MANIFEST_READY: "
            f"{payload.get('final_status')}"
        )

    documents = payload.get("documents")
    if not isinstance(documents, list) or len(documents) != EXPECTED_DOCUMENTS:
        raise ImportBlocked(
            f"Manifest musí obsahovat {EXPECTED_DOCUMENTS} dokumentů; nalezeno "
            f"{len(documents) if isinstance(documents, list) else 'NEPLATNÝ FORMÁT'}."
        )

    for document in documents:
        if not document.get("import_eligible"):
            raise ImportBlocked(
                f"Dokument není způsobilý pro import: {document.get('document_id')}"
            )
        source_path = root / str(document.get("source_path"))
        if not source_path.is_file():
            raise ImportBlocked(f"Zdrojový dokument nebyl nalezen: {source_path}")
        actual_hash = sha256_bytes(source_path.read_bytes())
        expected_hash = str(document.get("sha256") or "")
        if actual_hash != expected_hash:
            raise ImportBlocked(
                f"SHA-256 se změnil od sestavení manifestu: {document.get('document_id')}\n"
                f"manifest: {expected_hash}\naktuálně : {actual_hash}\n"
                "Nejprve znovu sestav importní manifest."
            )
    return payload, data


def document_family(document_id: str) -> str:
    parts = document_id.split("-")
    return parts[1] if len(parts) >= 3 else "UNKNOWN"


def default_edition(document_id: str, manifest_edition: str | None) -> str:
    if manifest_edition:
        return manifest_edition
    family = document_family(document_id)
    return {"DOC": "TECH", "STD": "STANDARD", "REF": "REFERENCE"}.get(family, family)


def decode_markdown(data: bytes) -> str:
    return data.decode("utf-8-sig")


def clean_heading(value: str) -> str:
    value = re.sub(r"[`*_]+", "", value)
    value = re.sub(r"\s+#+\s*$", "", value)
    return value.strip()


def slugify(value: str) -> str:
    import unicodedata

    normalized = unicodedata.normalize("NFKD", value)
    ascii_value = "".join(ch for ch in normalized if not unicodedata.combining(ch))
    ascii_value = ascii_value.lower()
    ascii_value = re.sub(r"[^a-z0-9]+", "-", ascii_value).strip("-")
    return ascii_value[:240] or "section"


def parse_sections(text: str) -> list[dict[str, Any]]:
    lines = text.splitlines()
    headings: list[tuple[int, int, str]] = []
    for index, line in enumerate(lines):
        match = HEADING_PATTERN.match(line)
        if match:
            headings.append((index, len(match.group(1)), clean_heading(match.group(2))))

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
        end_index = headings[position + 1][0] if position + 1 < len(headings) else len(lines)
        content = "\n".join(lines[line_index:end_index]).rstrip() + "\n"

        while stack and stack[-1][0] >= level:
            stack.pop()
        parent_ordinal = stack[-1][1] if stack else None
        ordinal = position + 1
        stack.append((level, ordinal))

        base_slug = slugify(title)
        slug_counts[base_slug] = slug_counts.get(base_slug, 0) + 1
        anchor = base_slug if slug_counts[base_slug] == 1 else f"{base_slug}-{slug_counts[base_slug]}"

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


def extract_relations(text: str, own_document_id: str, known_ids: set[str]) -> set[str]:
    found = {match.group(0).upper() for match in DOCUMENT_ID_PATTERN.finditer(text)}
    found.discard(own_document_id.upper())
    return found & known_ids


def select_one(connection: Any, sql: str, params: Sequence[Any]) -> dict[str, Any] | None:
    with connection.cursor() as cursor:
        cursor.execute(sql, params)
        row = cursor.fetchone()
        if row is None:
            return None
        names = [description[0] for description in cursor.description]
        return dict(zip(names, row))


def insert_row(
    connection: Any,
    driver: DbDriver,
    table: TableInfo,
    values: Mapping[str, Any],
    *,
    returning: str | None = None,
) -> Any:
    filtered: dict[str, Any] = {}
    for key, value in values.items():
        if key not in table.columns or value is None:
            continue
        column = table.columns[key]
        if column.type_key in JSON_TYPES and not isinstance(value, driver.json_adapter):
            value = driver.adapt_json(value)
        filtered[key] = value

    missing_required = [
        column.name
        for column in table.columns.values()
        if not column.nullable
        and not column.has_server_value
        and column.name not in filtered
        and column.name not in table.primary_key
    ]
    if missing_required:
        raise SchemaMappingError(
            f"Pro INSERT do {SCHEMA}.{table.name} chybí povinné hodnoty: "
            + ", ".join(missing_required)
        )

    if not filtered:
        raise SchemaMappingError(f"Pro INSERT do {SCHEMA}.{table.name} nebyly namapovány žádné hodnoty.")

    columns = list(filtered)
    placeholders = ", ".join(["%s"] * len(columns))
    sql = (
        f"INSERT INTO {qualified(table.name)} "
        f"({', '.join(quote_identifier(column) for column in columns)}) "
        f"VALUES ({placeholders})"
    )
    if returning:
        sql += f" RETURNING {quote_identifier(returning)}"

    with connection.cursor() as cursor:
        cursor.execute(sql, [filtered[column] for column in columns])
        if returning:
            row = cursor.fetchone()
            return row[0]
    return None


def update_row(
    connection: Any,
    table: TableInfo,
    values: Mapping[str, Any],
    where_column: str,
    where_value: Any,
) -> int:
    filtered = {
        key: value
        for key, value in values.items()
        if key in table.columns and value is not None and key != where_column
    }
    if not filtered:
        return 0

    assignments = ", ".join(f"{quote_identifier(key)} = %s" for key in filtered)
    sql = (
        f"UPDATE {qualified(table.name)} SET {assignments} "
        f"WHERE {quote_identifier(where_column)} = %s"
    )
    with connection.cursor() as cursor:
        cursor.execute(sql, [*filtered.values(), where_value])
        return int(cursor.rowcount or 0)


def table_mapping(tables: Mapping[str, TableInfo]) -> dict[str, dict[str, str | None]]:
    documents = require_table(tables, "documents")
    versions = require_table(tables, "document_versions")
    sections = require_table(tables, "document_sections")
    import_runs = require_table(tables, "import_runs")

    document_pk = primary_key_column(documents)
    version_pk = primary_key_column(versions)
    import_run_pk = primary_key_column(import_runs)

    document_code = choose_column(
        documents,
        ("document_code", "document_id", "document_identifier", "code", "identifier", "doc_code", "doc_id"),
        type_group="text",
        required=True,
        semantic_name="textové Document ID",
    )
    document_title = choose_column(
        documents,
        ("title", "document_title", "name"),
        type_group="text",
        required=True,
        semantic_name="název dokumentu",
    )
    version_document_fk = find_fk(
        versions,
        "documents",
        ("document_pk", "document_id", "document_ref_id", "document_record_id"),
    )
    if not version_document_fk:
        raise SchemaMappingError("Nelze najít cizí klíč document_versions -> documents.")
    version_label = choose_column(
        versions,
        ("version", "version_label", "document_version", "version_number"),
        type_group="text",
        required=True,
        semantic_name="verze dokumentu",
    )
    version_hash = choose_column(
        versions,
        ("content_hash_sha256", "content_sha256", "sha256", "content_hash", "source_sha256", "file_sha256", "hash"),
        type_group="text",
        required=True,
        semantic_name="SHA-256 verze",
    )
    version_content = choose_column(
        versions,
        ("content_markdown", "markdown_content", "content", "body_markdown", "body", "source_content"),
        type_group="text",
        required=True,
        semantic_name="Markdown obsah verze",
    )
    section_version_fk = find_fk(
        sections,
        "document_versions",
        ("document_version_id", "version_id", "document_version_pk", "version_pk"),
    )
    if not section_version_fk:
        raise SchemaMappingError("Nelze najít cizí klíč document_sections -> document_versions.")
    section_title = choose_column(
        sections,
        ("title", "section_title", "heading", "heading_text", "name"),
        type_group="text",
        required=True,
        semantic_name="název sekce",
    )
    section_content = choose_column(
        sections,
        ("content_markdown", "markdown_content", "content", "body_markdown", "body"),
        type_group="text",
        required=True,
        semantic_name="obsah sekce",
    )

    return {
        "documents": {
            "pk": document_pk,
            "code": document_code,
            "title": document_title,
            "family": choose_column(documents, ("document_family", "document_type", "family", "doc_type", "category")),
            "edition": choose_column(documents, ("edition", "document_edition")),
            "current_version": choose_column(documents, ("current_version_label", "current_version", "version", "latest_version")),
            "current_status": choose_column(documents, ("current_status", "status", "document_status")),
            "source_path": choose_column(documents, ("canonical_file_path", "canonical_path", "source_file_path", "source_path", "file_path", "markdown_path", "relative_path", "path")),
            "source_of_truth": choose_column(documents, ("source_of_truth", "source_system", "authority_source")),
            "active": choose_column(documents, ("is_active", "active", "enabled")),
            "created_at": choose_column(documents, ("created_at",)),
            "updated_at": choose_column(documents, ("updated_at", "modified_at")),
        },
        "document_versions": {
            "pk": version_pk,
            "document_fk": version_document_fk,
            "version": version_label,
            "hash": version_hash,
            "content": version_content,
            "title": choose_column(versions, ("title", "document_title", "version_title")),
            "status": choose_column(versions, ("status", "document_status", "version_status")),
            "edition": choose_column(versions, ("edition", "document_edition")),
            "version_note": choose_column(versions, ("change_summary", "version_note", "note", "version_comment")),
            "source_path": choose_column(versions, ("source_file_path", "source_path", "file_path", "markdown_path", "relative_path", "path")),
            "source_filename": choose_column(versions, ("source_filename", "filename", "file_name")),
            "source_git_commit": choose_column(versions, ("source_git_commit", "git_commit", "commit_sha", "source_commit")),
            "source_modified_at": choose_column(versions, ("source_modified_at", "file_modified_at", "modified_at")),
            "imported_by": choose_column(versions, ("imported_by", "created_by")),
            "metadata": choose_column(versions, ("metadata", "details", "attributes")),
            "byte_size": choose_column(versions, ("byte_size", "file_size", "size_bytes")),
            "line_count": choose_column(versions, ("line_count", "lines_count", "source_line_count")),
            "is_current": choose_column(versions, ("is_current", "current", "is_latest")),
            "import_run_fk": find_fk(versions, "import_runs", ("import_run_pk", "import_run_id", "run_id")),
            "imported_at": choose_column(versions, ("imported_at", "created_at", "captured_at")),
        },
        "document_sections": {
            "version_fk": section_version_fk,
            "document_fk": find_fk(sections, "documents", ("document_id", "document_pk")),
            "ordinal": choose_column(sections, ("section_order", "ordinal", "position", "sequence_no", "sort_order", "section_no")),
            "level": choose_column(sections, ("heading_level", "level", "depth")),
            "title": section_title,
            "anchor": choose_column(sections, ("anchor_slug", "anchor", "slug", "section_key", "anchor_id")),
            "content": section_content,
            "parent_ordinal": choose_column(sections, ("parent_ordinal", "parent_section_order", "parent_position")),
            "created_at": choose_column(sections, ("created_at", "imported_at")),
        },
        "import_runs": {
            "pk": import_run_pk,
            "run_uuid": choose_column(import_runs, ("run_uuid", "import_uuid", "batch_uuid")),
            "status": choose_column(import_runs, ("status", "run_status", "import_status"), required=True, semantic_name="stav importního běhu"),
            "source_type": choose_column(import_runs, ("source_type", "import_type", "source_kind")),
            "source_root": choose_column(import_runs, ("source_root", "project_root", "root_path")),
            "manifest_path": choose_column(import_runs, ("manifest_path", "source_manifest", "manifest_file")),
            "manifest_sha256": choose_column(import_runs, ("manifest_hash_sha256", "manifest_sha256", "manifest_hash", "source_sha256")),
            "started_at": choose_column(import_runs, ("started_at", "created_at", "run_started_at")),
            "completed_at": choose_column(import_runs, ("completed_at", "finished_at", "run_completed_at")),
            "documents_total": choose_column(import_runs, ("documents_total", "documents_discovered", "candidate_count", "total_documents")),
            "documents_inserted": choose_column(import_runs, ("documents_inserted", "inserted_documents")),
            "documents_updated": choose_column(import_runs, ("documents_updated", "updated_documents")),
            "versions_inserted": choose_column(import_runs, ("versions_inserted", "inserted_versions")),
            "sections_inserted": choose_column(import_runs, ("sections_inserted", "inserted_sections")),
            "relations_inserted": choose_column(import_runs, ("relations_inserted", "inserted_relations")),
            "warnings": choose_column(import_runs, ("warnings", "warning_details", "warnings_json")),
            "details": choose_column(import_runs, ("details", "summary", "result_json", "metadata")),
            "error_message": choose_column(import_runs, ("error_message", "error", "failure_reason")),
        },
    }


def optional_mapping(tables: Mapping[str, TableInfo]) -> dict[str, dict[str, str | None]]:
    result: dict[str, dict[str, str | None]] = {}

    relations = tables["document_relations"]
    if relations.columns:
        document_fks = [fk for fk in relations.foreign_keys if fk.referenced_table == "documents"]
        source_fk = next(
            (fk.column_name for fk in document_fks if any(token in fk.column_name.lower() for token in ("source", "from", "parent"))),
            None,
        )
        target_fk = next(
            (fk.column_name for fk in document_fks if any(token in fk.column_name.lower() for token in ("target", "to", "child", "related"))),
            None,
        )
        if not source_fk and len(document_fks) >= 1:
            source_fk = document_fks[0].column_name
        if not target_fk and len(document_fks) >= 2:
            target_fk = next((fk.column_name for fk in document_fks if fk.column_name != source_fk), None)
        result["document_relations"] = {
            "source_fk": source_fk,
            "target_fk": target_fk,
            "relation_type": choose_column(relations, ("relation_type", "type", "relationship_type")),
            "source_context": choose_column(relations, ("source_context", "context", "description", "note")),
            "import_run_fk": find_fk(relations, "import_runs", ("import_run_pk", "import_run_id", "run_id")),
            "created_at": choose_column(relations, ("created_at", "imported_at")),
        }

    history = tables["document_status_history"]
    if history.columns:
        result["document_status_history"] = {
            "document_fk": find_fk(history, "documents", ("document_id", "document_pk")),
            "version_fk": find_fk(history, "document_versions", ("document_version_id", "version_id")),
            "old_status": choose_column(history, ("old_status", "previous_status", "from_status")),
            "new_status": choose_column(history, ("new_status", "status", "to_status")),
            "reason": choose_column(history, ("reason", "change_reason", "note", "description")),
            "import_run_fk": find_fk(history, "import_runs", ("import_run_pk", "import_run_id", "run_id")),
            "changed_at": choose_column(history, ("changed_at", "created_at", "recorded_at")),
        }
    return result


def print_mapping(tables: Mapping[str, TableInfo], mapping: Mapping[str, Mapping[str, str | None]]) -> None:
    print("DETEKOVANÉ DATABÁZOVÉ MAPOVÁNÍ")
    print("-" * 79)
    for table_name, fields in mapping.items():
        print(f"{SCHEMA}.{table_name}")
        for semantic, column in fields.items():
            if column:
                print(f"  {semantic:<22}: {column}")
        print()


def fetch_document_by_code(
    connection: Any,
    table: TableInfo,
    mapping: Mapping[str, str | None],
    code: str,
) -> dict[str, Any] | None:
    pk = str(mapping["pk"])
    code_column = str(mapping["code"])
    status_column = mapping.get("current_status")
    selected = [pk, code_column]
    if status_column:
        selected.append(str(status_column))
    sql = (
        f"SELECT {', '.join(quote_identifier(column) for column in selected)} "
        f"FROM {qualified(table.name)} WHERE {quote_identifier(code_column)} = %s"
    )
    return select_one(connection, sql, (code,))



def get_check_constraint_definition(
    connection: Any,
    *,
    table_name: str,
    constraint_name: str,
) -> str:
    row = select_one(
        connection,
        """
        SELECT pg_get_constraintdef(c.oid, true) AS constraint_definition
        FROM pg_constraint AS c
        JOIN pg_class AS t
          ON t.oid = c.conrelid
        JOIN pg_namespace AS n
          ON n.oid = t.relnamespace
        WHERE n.nspname = %s
          AND t.relname = %s
          AND c.conname = %s
          AND c.contype = 'c'
        """,
        (SCHEMA, table_name, constraint_name),
    )
    if not row or not row.get("constraint_definition"):
        raise SchemaMappingError(
            f"CHECK constraint {SCHEMA}.{table_name}.{constraint_name} nebyl nalezen."
        )
    return str(row["constraint_definition"])


def extract_check_constraint_values(definition: str) -> list[str]:
    """
    Vytáhne textové literály z definice CHECK constraintu PostgreSQL.

    Podporuje běžné tvary:
    - status IN ('RUNNING', 'SUCCESS', 'FAILED')
    - status = ANY (ARRAY['RUNNING'::text, 'SUCCESS'::text, ...])
    """
    values: list[str] = []
    for raw_value in re.findall(r"'((?:''|[^'])*)'", definition):
        value = raw_value.replace("''", "'").strip()
        if value and value not in values:
            values.append(value)
    return values


def resolve_import_run_success_status(
    connection: Any,
) -> tuple[str, list[str], str]:
    constraint_name = "ck_documentation_import_runs_status"
    definition = get_check_constraint_definition(
        connection,
        table_name="import_runs",
        constraint_name=constraint_name,
    )
    allowed_values = extract_check_constraint_values(definition)

    if not allowed_values:
        raise SchemaMappingError(
            f"Z constraintu {constraint_name} nelze určit povolené hodnoty. "
            f"Definice: {definition}"
        )

    by_upper = {value.upper(): value for value in allowed_values}

    preferred_success_states = (
        "SUCCESS",
        "SUCCEEDED",
        "DONE",
        "FINISHED",
        "COMPLETED_OK",
        "IMPORT_COMPLETED",
        "APPLIED",
        "READY",
        "OK",
        "COMPLETE",
    )
    for candidate in preferred_success_states:
        if candidate in by_upper:
            return by_upper[candidate], allowed_values, definition

    non_success_states = {
        "RUNNING",
        "STARTED",
        "PENDING",
        "QUEUED",
        "FAILED",
        "ERROR",
        "BLOCKED",
        "CANCELLED",
        "CANCELED",
        "PARTIAL",
        "WARNING",
    }
    fallback_values = [
        value
        for value in allowed_values
        if value.upper() not in non_success_states
    ]
    if len(fallback_values) == 1:
        return fallback_values[0], allowed_values, definition

    raise SchemaMappingError(
        "Nelze bezpečně vybrat úspěšný stav importního běhu. "
        f"Povolené hodnoty: {', '.join(allowed_values)}. "
        f"Definice constraintu: {definition}"
    )

def create_import_run(
    connection: Any,
    driver: DbDriver,
    table: TableInfo,
    mapping: Mapping[str, str | None],
    *,
    root: Path,
    manifest_path: Path,
    manifest_hash: str,
    mode: str,
    git_info: Mapping[str, Any],
) -> Any:
    now = utc_now()
    values = {
        mapping.get("run_uuid"): uuid.uuid4(),
        mapping.get("status"): "RUNNING",
        mapping.get("source_type"): "MARKDOWN_MANIFEST",
        mapping.get("source_root"): str(root),
        mapping.get("manifest_path"): str(manifest_path.relative_to(root) if manifest_path.is_relative_to(root) else manifest_path),
        mapping.get("manifest_sha256"): manifest_hash,
        mapping.get("started_at"): now,
        mapping.get("documents_total"): EXPECTED_DOCUMENTS,
        mapping.get("warnings"): [],
        mapping.get("details"): {
            "mode": mode,
            "source_of_truth": "HYBRID",
            "git": dict(git_info),
        },
    }
    clean_values = {key: value for key, value in values.items() if key}
    return insert_row(
        connection,
        driver,
        table,
        clean_values,
        returning=str(mapping["pk"]),
    )


def finalize_import_run(
    connection: Any,
    driver: DbDriver,
    table: TableInfo,
    mapping: Mapping[str, str | None],
    run_id: Any,
    status: str,
    counters: ImportCounters,
    warnings: list[str],
    error_message: str | None,
) -> None:
    values: dict[str, Any] = {
        str(mapping["status"]): status,
    }
    optional_values = {
        mapping.get("completed_at"): utc_now(),
        mapping.get("documents_inserted"): counters.documents_inserted,
        mapping.get("documents_updated"): counters.documents_updated,
        mapping.get("versions_inserted"): counters.versions_inserted,
        mapping.get("sections_inserted"): counters.sections_inserted,
        mapping.get("relations_inserted"): counters.relations_inserted,
        mapping.get("warnings"): warnings,
        mapping.get("details"): counters.as_dict(),
        mapping.get("error_message"): error_message,
    }
    values.update({str(key): value for key, value in optional_values.items() if key})

    # JSON adaptace pro UPDATE.
    for column_name in list(values):
        column = table.columns[column_name]
        if column.type_key in JSON_TYPES:
            values[column_name] = driver.adapt_json(values[column_name])

    update_row(connection, table, values, str(mapping["pk"]), run_id)


def upsert_document(
    connection: Any,
    driver: DbDriver,
    table: TableInfo,
    mapping: Mapping[str, str | None],
    document: Mapping[str, Any],
    counters: ImportCounters,
) -> tuple[Any, str | None, bool]:
    code = str(document["document_id"])
    existing = fetch_document_by_code(connection, table, mapping, code)
    now = utc_now()
    old_status = None
    if existing and mapping.get("current_status"):
        old_status = existing.get(str(mapping["current_status"]))

    values = {
        str(mapping["code"]): code,
        str(mapping["title"]): document.get("title"),
    }
    optional_values = {
        mapping.get("family"): document_family(code),
        mapping.get("edition"): default_edition(code, document.get("edition")),
        mapping.get("current_version"): document.get("version"),
        mapping.get("current_status"): document.get("status"),
        mapping.get("source_path"): document.get("source_path"),
        mapping.get("source_of_truth"): "HYBRID",
        mapping.get("active"): document.get("status") in {"ACTIVE", "APPROVED", "REVIEW"},
        mapping.get("updated_at"): now,
    }
    values.update({str(key): value for key, value in optional_values.items() if key})

    if existing:
        update_count = update_row(connection, table, values, str(mapping["pk"]), existing[str(mapping["pk"])])
        if update_count:
            counters.documents_updated += 1
        else:
            counters.documents_unchanged += 1
        return existing[str(mapping["pk"])], old_status, False

    if mapping.get("created_at"):
        values[str(mapping["created_at"])] = now
    document_pk = insert_row(
        connection,
        driver,
        table,
        values,
        returning=str(mapping["pk"]),
    )
    counters.documents_inserted += 1
    return document_pk, old_status, True


def existing_version(
    connection: Any,
    table: TableInfo,
    mapping: Mapping[str, str | None],
    document_pk: Any,
    version: str,
    sha256: str,
) -> tuple[dict[str, Any] | None, dict[str, Any] | None]:
    pk = str(mapping["pk"])
    doc_fk = str(mapping["document_fk"])
    version_col = str(mapping["version"])
    hash_col = str(mapping["hash"])

    same_hash_sql = (
        f"SELECT {quote_identifier(pk)}, {quote_identifier(version_col)}, {quote_identifier(hash_col)} "
        f"FROM {qualified(table.name)} "
        f"WHERE {quote_identifier(doc_fk)} = %s AND {quote_identifier(hash_col)} = %s "
        f"ORDER BY {quote_identifier(pk)} DESC LIMIT 1"
    )
    same_hash = select_one(connection, same_hash_sql, (document_pk, sha256))

    same_version_sql = (
        f"SELECT {quote_identifier(pk)}, {quote_identifier(version_col)}, {quote_identifier(hash_col)} "
        f"FROM {qualified(table.name)} "
        f"WHERE {quote_identifier(doc_fk)} = %s AND {quote_identifier(version_col)} = %s "
        f"ORDER BY {quote_identifier(pk)} DESC LIMIT 1"
    )
    same_version = select_one(connection, same_version_sql, (document_pk, version))
    return same_hash, same_version


def insert_version(
    connection: Any,
    driver: DbDriver,
    table: TableInfo,
    mapping: Mapping[str, str | None],
    document: Mapping[str, Any],
    document_pk: Any,
    import_run_id: Any,
    root: Path,
    source_git_commit: str | None,
    allow_version_rewrite: bool,
    counters: ImportCounters,
) -> tuple[Any, bool, str]:
    source_path = root / str(document["source_path"])
    data = source_path.read_bytes()
    text = decode_markdown(data)
    version = str(document["version"])
    sha256 = str(document["sha256"])

    same_hash, same_version = existing_version(
        connection, table, mapping, document_pk, version, sha256
    )
    if same_hash:
        counters.versions_skipped_same_hash += 1
        return same_hash[str(mapping["pk"])], False, text

    if same_version and str(same_version[str(mapping["hash"])]) != sha256 and not allow_version_rewrite:
        raise ImportBlocked(
            f"CONTENT_CHANGED_WITHOUT_VERSION_BUMP: {document['document_id']} verze {version}. "
            "V databázi již existuje stejná verze s jiným SHA-256."
        )

    is_current_col = mapping.get("is_current")
    if is_current_col:
        sql = (
            f"UPDATE {qualified(table.name)} SET {quote_identifier(str(is_current_col))} = false "
            f"WHERE {quote_identifier(str(mapping['document_fk']))} = %s"
        )
        with connection.cursor() as cursor:
            cursor.execute(sql, (document_pk,))

    now = utc_now()
    values = {
        str(mapping["document_fk"]): document_pk,
        str(mapping["version"]): version,
        str(mapping["hash"]): sha256,
        str(mapping["content"]): text,
    }
    source_modified_at = datetime.fromtimestamp(
        source_path.stat().st_mtime,
        tz=timezone.utc,
    )
    optional_values = {
        mapping.get("title"): document.get("title"),
        mapping.get("status"): document.get("status"),
        mapping.get("edition"): default_edition(str(document["document_id"]), document.get("edition")),
        mapping.get("version_note"): document.get("version_note"),
        mapping.get("source_path"): document.get("source_path"),
        mapping.get("source_filename"): source_path.name,
        mapping.get("source_git_commit"): source_git_commit,
        mapping.get("source_modified_at"): source_modified_at,
        mapping.get("imported_by"): "25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py",
        mapping.get("metadata"): {
            "document_id": document.get("document_id"),
            "manifest_selection": document.get("selection"),
            "source_of_truth": "HYBRID",
        },
        mapping.get("byte_size"): len(data),
        mapping.get("line_count"): len(text.splitlines()),
        mapping.get("is_current"): True,
        mapping.get("import_run_fk"): import_run_id,
        mapping.get("imported_at"): now,
    }
    values.update({str(key): value for key, value in optional_values.items() if key})

    version_pk = insert_row(
        connection,
        driver,
        table,
        values,
        returning=str(mapping["pk"]),
    )
    counters.versions_inserted += 1
    return version_pk, True, text


def insert_sections(
    connection: Any,
    driver: DbDriver,
    table: TableInfo,
    mapping: Mapping[str, str | None],
    document_pk: Any,
    version_pk: Any,
    text: str,
    counters: ImportCounters,
) -> None:
    now = utc_now()
    for section in parse_sections(text):
        values = {
            str(mapping["version_fk"]): version_pk,
            str(mapping["title"]): section["title"],
            str(mapping["content"]): section["content"],
        }
        optional_values = {
            mapping.get("document_fk"): document_pk,
            mapping.get("ordinal"): section["ordinal"],
            mapping.get("level"): section["level"],
            mapping.get("anchor"): section["anchor"],
            mapping.get("parent_ordinal"): section["parent_ordinal"],
            mapping.get("created_at"): now,
        }
        values.update({str(key): value for key, value in optional_values.items() if key})
        insert_row(connection, driver, table, values)
        counters.sections_inserted += 1


def insert_status_history(
    connection: Any,
    driver: DbDriver,
    table: TableInfo,
    mapping: Mapping[str, str | None],
    *,
    document_pk: Any,
    version_pk: Any,
    old_status: str | None,
    new_status: str,
    import_run_id: Any,
    document_created: bool,
    counters: ImportCounters,
) -> None:
    document_fk = mapping.get("document_fk")
    new_status_col = mapping.get("new_status")
    if not document_fk or not new_status_col:
        return
    if not document_created and old_status == new_status:
        return

    values = {
        str(document_fk): document_pk,
        str(new_status_col): new_status,
    }
    optional_values = {
        mapping.get("version_fk"): version_pk,
        mapping.get("old_status"): old_status,
        mapping.get("reason"): "CANONICAL_MARKDOWN_IMPORT",
        mapping.get("import_run_fk"): import_run_id,
        mapping.get("changed_at"): utc_now(),
    }
    values.update({str(key): value for key, value in optional_values.items() if key})
    insert_row(connection, driver, table, values)
    counters.status_history_inserted += 1


def insert_relations(
    connection: Any,
    driver: DbDriver,
    table: TableInfo,
    mapping: Mapping[str, str | None],
    relations: Iterable[tuple[str, str]],
    document_pks: Mapping[str, Any],
    import_run_id: Any,
    counters: ImportCounters,
) -> list[str]:
    warnings: list[str] = []
    source_fk = mapping.get("source_fk")
    target_fk = mapping.get("target_fk")
    if not source_fk or not target_fk:
        warnings.append("RELATION_TABLE_MAPPING_INCOMPLETE")
        return warnings

    for source_code, target_code in sorted(set(relations)):
        source_pk = document_pks[source_code]
        target_pk = document_pks[target_code]
        relation_type_col = mapping.get("relation_type")

        where_parts = [
            f"{quote_identifier(str(source_fk))} = %s",
            f"{quote_identifier(str(target_fk))} = %s",
        ]
        params: list[Any] = [source_pk, target_pk]
        if relation_type_col:
            where_parts.append(f"{quote_identifier(str(relation_type_col))} = %s")
            params.append("REFERENCES")
        sql = (
            f"SELECT 1 FROM {qualified(table.name)} WHERE "
            + " AND ".join(where_parts)
            + " LIMIT 1"
        )
        if select_one(connection, sql, params):
            counters.relations_skipped += 1
            continue

        values = {
            str(source_fk): source_pk,
            str(target_fk): target_pk,
        }
        optional_values = {
            relation_type_col: "REFERENCES",
            mapping.get("source_context"): "Automaticky detekováno z kanonického Markdown dokumentu.",
            mapping.get("import_run_fk"): import_run_id,
            mapping.get("created_at"): utc_now(),
        }
        values.update({str(key): value for key, value in optional_values.items() if key})
        insert_row(connection, driver, table, values)
        counters.relations_inserted += 1
    return warnings


def write_report(root: Path, payload: Mapping[str, Any]) -> Path:
    reports_dir = root / "reports" / "documentation"
    reports_dir.mkdir(parents=True, exist_ok=True)
    timestamp = utc_now().astimezone().strftime("%Y%m%d_%H%M%S")
    path = reports_dir / f"{REPORT_PREFIX}_{timestamp}.json"
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2, default=str), encoding="utf-8")
    latest = reports_dir / f"{REPORT_PREFIX}_latest.json"
    latest.write_text(json.dumps(payload, ensure_ascii=False, indent=2, default=str), encoding="utf-8")
    return path


def main() -> int:
    args = parse_args()
    root = project_root()
    mode = "APPLY" if args.apply else "DRY_RUN"
    started_at = utc_now()
    manifest_path = Path(args.manifest) if args.manifest else root / MANIFEST_RELATIVE_PATH
    if not manifest_path.is_absolute():
        manifest_path = root / manifest_path

    counters = ImportCounters()
    warnings: list[str] = []
    report: dict[str, Any] = {
        "started_at": started_at.isoformat(),
        "mode": mode,
        "project_root": str(root),
        "manifest_path": str(manifest_path),
        "final_status": "STARTING",
    }

    print("MATCHMATRIX CANONICAL DOCUMENT DATABASE IMPORT")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"MODE               : {mode}")
    print(f"MANIFEST           : {manifest_path}")

    connection = None
    import_run_id = None
    try:
        manifest, manifest_bytes = load_manifest(manifest_path, root)
        manifest_hash = sha256_bytes(manifest_bytes)
        git_info = git_snapshot(root)
        report["manifest_sha256"] = manifest_hash
        report["git"] = git_info
        print(f"MANIFEST SHA-256   : {manifest_hash}")
        print(f"GIT COMMIT         : {git_info.get('commit') or '-'}")
        print(f"GIT DIRTY          : {git_info.get('dirty')}")
        print()

        driver = load_driver()
        dsn, connect_kwargs, public_connection = connection_settings(root, args.dsn)
        report["driver"] = driver.name
        report["connection"] = public_connection
        print(f"DB DRIVER          : {driver.name}")
        print(
            "DB TARGET          : "
            f"{public_connection['user']}@{public_connection['host']}:"
            f"{public_connection['port']}/{public_connection['dbname']}"
        )

        connection = driver.connect(dsn, connect_kwargs)
        connection.autocommit = False

        tables = inspect_schema(connection)
        mapping = table_mapping(tables)
        optional = optional_mapping(tables)
        all_mapping = {**mapping, **optional}
        report["mapping"] = all_mapping
        print()
        print_mapping(tables, all_mapping)

        final_db_status, allowed_run_statuses, run_status_constraint = (
            resolve_import_run_success_status(connection)
        )
        report["import_run_status_policy"] = {
            "constraint_name": "ck_documentation_import_runs_status",
            "constraint_definition": run_status_constraint,
            "allowed_values": allowed_run_statuses,
            "selected_success_status": final_db_status,
        }

        print("IMPORT RUN STATUS POLICY")
        print("-" * 79)
        print(
            "POVOLENÉ STAVY     : "
            + ", ".join(allowed_run_statuses)
        )
        print(f"ÚSPĚŠNÝ STAV       : {final_db_status}")
        print()

        import_runs_table = require_table(tables, "import_runs")
        import_run_id = create_import_run(
            connection,
            driver,
            import_runs_table,
            mapping["import_runs"],
            root=root,
            manifest_path=manifest_path,
            manifest_hash=manifest_hash,
            mode=mode,
            git_info=git_info,
        )
        print(f"IMPORT RUN ID      : {import_run_id}")
        print()

        documents_table = require_table(tables, "documents")
        versions_table = require_table(tables, "document_versions")
        sections_table = require_table(tables, "document_sections")
        status_table = tables["document_status_history"]

        document_pks: dict[str, Any] = {}
        relation_pairs: set[tuple[str, str]] = set()
        known_ids = {str(document["document_id"]) for document in manifest["documents"]}

        print("IMPORT DOKUMENTŮ")
        print("-" * 79)
        for document in manifest["documents"]:
            code = str(document["document_id"])
            document_pk, old_status, document_created = upsert_document(
                connection,
                driver,
                documents_table,
                mapping["documents"],
                document,
                counters,
            )
            document_pks[code] = document_pk

            version_pk, version_created, text = insert_version(
                connection,
                driver,
                versions_table,
                mapping["document_versions"],
                document,
                document_pk,
                import_run_id,
                root,
                str(git_info.get("commit") or "") or None,
                args.allow_version_rewrite,
                counters,
            )

            if version_created:
                insert_sections(
                    connection,
                    driver,
                    sections_table,
                    mapping["document_sections"],
                    document_pk,
                    version_pk,
                    text,
                    counters,
                )

            if status_table.columns and "document_status_history" in optional:
                insert_status_history(
                    connection,
                    driver,
                    status_table,
                    optional["document_status_history"],
                    document_pk=document_pk,
                    version_pk=version_pk,
                    old_status=old_status,
                    new_status=str(document["status"]),
                    import_run_id=import_run_id,
                    document_created=document_created,
                    counters=counters,
                )

            for target in extract_relations(text, code, known_ids):
                relation_pairs.add((code, target))

            version_state = "INSERTED" if version_created else "SAME_SHA256"
            document_state = "INSERTED" if document_created else "UPDATED"
            print(
                f"{code:<15} | DOC {document_state:<8} | VERSION {version_state:<11} | "
                f"sections={len(parse_sections(text)) if version_created else 0}"
            )

        if not args.skip_relations and tables["document_relations"].columns:
            relation_mapping = optional.get("document_relations", {})
            relation_warnings = insert_relations(
                connection,
                driver,
                tables["document_relations"],
                relation_mapping,
                relation_pairs,
                document_pks,
                import_run_id,
                counters,
            )
            warnings.extend(relation_warnings)
        elif args.skip_relations:
            warnings.append("RELATION_IMPORT_SKIPPED_BY_ARGUMENT")
        else:
            warnings.append("RELATION_TABLE_NOT_AVAILABLE")

        # `final_db_status` byl bezpečně vybrán přímo z databázového
        # CHECK constraintu `ck_documentation_import_runs_status`.
        finalize_import_run(
            connection,
            driver,
            import_runs_table,
            mapping["import_runs"],
            import_run_id,
            final_db_status,
            counters,
            warnings,
            None,
        )

        if args.apply:
            connection.commit()
            final_status = "DOCUMENT_IMPORT_APPLIED"
        else:
            connection.rollback()
            final_status = "DOCUMENT_IMPORT_DRY_RUN_READY"

        report.update(
            {
                "completed_at": utc_now().isoformat(),
                "import_run_id": import_run_id,
                "counters": counters.as_dict(),
                "warnings": warnings,
                "final_status": final_status,
            }
        )
        report_path = write_report(root, report)

        print()
        print("SOUHRN")
        print("-" * 79)
        for key, value in counters.as_dict().items():
            print(f"{key:<29}: {value}")
        print(f"warnings                     : {len(warnings)}")
        print(f"REPORT                       : {report_path}")
        print(f"FINAL STATUS                 : {final_status}")
        return 0

    except Exception as exc:
        if connection is not None:
            try:
                connection.rollback()
            except Exception:
                pass
        report.update(
            {
                "completed_at": utc_now().isoformat(),
                "import_run_id": import_run_id,
                "counters": counters.as_dict(),
                "warnings": warnings,
                "error_type": type(exc).__name__,
                "error_message": str(exc),
                "traceback": traceback.format_exc(),
                "final_status": "DOCUMENT_IMPORT_BLOCKED",
            }
        )
        report_path = write_report(root, report)
        print()
        print("IMPORT BLOKOVÁN")
        print("-" * 79)
        print(f"{type(exc).__name__}: {exc}")
        print(f"REPORT             : {report_path}")
        print("FINAL STATUS       : DOCUMENT_IMPORT_BLOCKED")
        return 1
    finally:
        if connection is not None:
            try:
                connection.close()
            except Exception:
                pass


if __name__ == "__main__":
    raise SystemExit(main())
