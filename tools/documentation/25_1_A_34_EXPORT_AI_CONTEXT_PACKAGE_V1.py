"""
MATCHMATRIX – A34 EXPORT AI CONTEXT PACKAGE V1
==============================================

CO TO JE:
- Read-only exportní nástroj pro vytvoření jednotného kontextového balíčku
  MatchMatrix určeného pro pokračování práce v novém chatu.
- Balíček spojuje poslední NAV, denní zápis, projektový snapshot, Git stav,
  stav dokumentační databáze, A33 audit a datový přehled aktivního sportu.

K ČEMU TO JE:
- Uživatel nemusí při každém novém chatu ručně hledat několik dokumentů
  a reportů.
- Jeden soubor MATCHMATRIX_AI_CONTEXT_PACKAGE_LATEST.md poskytne AI
  dostatečný přehled o projektu, databázi, dokumentaci a místě pokračování.
- ZIP zachová úplné technické podklady a kontrolní manifest.

KDE:
- Aktivní skript:
  tools/documentation/25_1_A_34_EXPORT_AI_CONTEXT_PACKAGE_V1.py
- Výstupy:
  reports/documentation/ai_context_package/

JAK:
1. Ověří hlavní Git repozitář.
2. Zablokuje běh při skutečných neuložených změnách.
3. Volitelně spustí A33 pouze pro čtení.
4. Načte dokumentační databázový snapshot.
5. Načte stav všech sportů a aktivního sportu.
6. Vyhledá poslední MM-NAV, MM-DL a MM-PS.
7. Vytvoří hlavní Markdown, JSON podklady, manifest SHA-256 a ZIP.
8. Aktualizuje soubory *_LATEST.*.

BEZPEČNOST:
- Skript neprovádí INSERT, UPDATE, DELETE, DDL ani COMMIT do databáze.
- Databázové dotazy běží v transakci READ ONLY a končí ROLLBACK.
- Heslo, token, API klíč ani přihlašovací URL se nezapisují do výstupů.
- DB konfigurace se načte z prostředí nebo bezpečně vyčte z aktivního
  panelu pomocí AST bez spuštění panelu.
- Skript nepoužívá git add, commit, push, stash ani reset.

ENGINE_VERSION:
A34_AI_CONTEXT_PACKAGE_V1_0
"""

from __future__ import annotations

import argparse
import ast
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import traceback
import zipfile
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

try:
    import psycopg2
    import psycopg2.extras
except ImportError as exc:
    raise SystemExit(
        "CHYBA: Chybí knihovna psycopg2. Spusť A34 stejným Pythonem jako Q3 panel."
    ) from exc


ENGINE_VERSION = "A34_AI_CONTEXT_PACKAGE_V1_0"
FINAL_STATUS_CREATED = "AI_CONTEXT_PACKAGE_CREATED"
FINAL_STATUS_VALIDATED = "AI_CONTEXT_PACKAGE_VALIDATED"
FINAL_STATUS_BLOCKED = "AI_CONTEXT_PACKAGE_BLOCKED"

DEFAULT_SPORT_CODE = "FB"
DEFAULT_SPORT_NAME = "Fotbal"
DEFAULT_ACTIVE_AREA = "Fotbal – referenční sport, provideři a datová matice"

GENERATED_GIT_PATH_PREFIXES = (
    "reports/documentation/ai_context_package/",
    "reports/documentation/database_audit/",
    "reports/documentation/database_growth/",
    "reports/documentation/standardization/panel_workspaces/",
)

TEXT_SUFFIXES = {
    ".md", ".txt", ".json", ".csv", ".sql", ".yaml", ".yml", ".log"
}

SECRET_PATTERNS = (
    re.compile(
        r"(?im)^(\s*(?:password|passwd|pwd|api[_ -]?key|access[_ -]?token|"
        r"refresh[_ -]?token|secret)\s*[:=]\s*)([^\s\"']+)"
    ),
    re.compile(
        r"(?i)(authorization\s*:\s*bearer\s+)([A-Za-z0-9._~+/=-]{8,})"
    ),
    re.compile(
        r"(?i)\b(postgresql|postgres)://([^:\s/@]+):([^@\s/]+)@"
    ),
)


@dataclass(frozen=True)
class QueryResult:
    name: str
    ok: bool
    rows: list[dict[str, Any]]
    error: str | None = None


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def local_now() -> datetime:
    return datetime.now().astimezone()


def iso_now() -> str:
    return local_now().isoformat(timespec="seconds")


def json_default(value: Any) -> Any:
    if isinstance(value, (datetime,)):
        return value.isoformat()
    if isinstance(value, Path):
        return str(value)
    if hasattr(value, "as_tuple"):
        return str(value)
    return str(value)


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(
            payload,
            ensure_ascii=False,
            indent=2,
            default=json_default,
        ) + "\n",
        encoding="utf-8",
    )


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.rstrip() + "\n", encoding="utf-8")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def safe_relative(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except Exception:
        return path.as_posix()


def scrub_text(text: str) -> tuple[str, int]:
    """Odstraní pouze hodnoty, které vypadají jako skutečné tajné údaje."""
    redactions = 0
    result = text

    for pattern in SECRET_PATTERNS:
        if pattern.pattern.startswith("(?i)\\b(postgresql"):
            def replace_uri(match: re.Match[str]) -> str:
                nonlocal redactions
                redactions += 1
                return f"{match.group(1)}://{match.group(2)}:[REDACTED]@"
            result = pattern.sub(replace_uri, result)
        else:
            def replace_value(match: re.Match[str]) -> str:
                nonlocal redactions
                redactions += 1
                return f"{match.group(1)}[REDACTED]"
            result = pattern.sub(replace_value, result)

    return result, redactions


def copy_text_scrubbed(source: Path, target: Path) -> int:
    text = source.read_text(encoding="utf-8-sig", errors="replace")
    clean, redactions = scrub_text(text)
    write_text(target, clean)
    return redactions


def run_command(
    command: Sequence[str],
    *,
    cwd: Path,
    timeout: int = 120,
    check: bool = False,
) -> subprocess.CompletedProcess[str]:
    completed = subprocess.run(
        list(command),
        cwd=str(cwd),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=timeout,
        shell=False,
    )
    if check and completed.returncode != 0:
        raise RuntimeError(
            f"Příkaz skončil kódem {completed.returncode}: {' '.join(command)}\n"
            f"{completed.stdout[-3000:]}"
        )
    return completed


def resolve_project_root(explicit: str | None) -> Path:
    if explicit:
        root = Path(explicit).expanduser().resolve()
        if not (root / ".git").exists():
            raise RuntimeError(f"Zadaný project root není Git repozitář: {root}")
        return root

    script = Path(__file__).resolve()

    # Standardní umístění tools/documentation/A34.py -> parents[2] = repo root.
    for candidate in (script.parents[2], script.parents[1], Path.cwd()):
        if (candidate / ".git").exists():
            return candidate.resolve()

    raise RuntimeError(
        "Nelze odvodit kořen projektu. Použij --project-root C:\\MatchMatrix-platform."
    )


def git_output(project_root: Path, *args: str) -> str:
    completed = run_command(
        ["git", "-C", str(project_root), *args],
        cwd=project_root,
        timeout=30,
    )
    if completed.returncode != 0:
        raise RuntimeError(
            f"Git příkaz selhal ({completed.returncode}): git {' '.join(args)}\n"
            f"{completed.stdout[-2000:]}"
        )
    return completed.stdout.strip()


def normalize_porcelain_path(line: str) -> str:
    payload = line[3:].strip() if len(line) >= 4 else line.strip()
    if " -> " in payload:
        payload = payload.split(" -> ", 1)[1].strip()
    return payload.strip('"').replace("\\", "/")


def collect_git_snapshot(project_root: Path) -> dict[str, Any]:
    branch = git_output(project_root, "rev-parse", "--abbrev-ref", "HEAD")
    commit = git_output(project_root, "rev-parse", "HEAD")
    commit_short = git_output(project_root, "rev-parse", "--short=12", "HEAD")
    subject = git_output(project_root, "log", "-1", "--pretty=%s")
    repo_root = git_output(project_root, "rev-parse", "--show-toplevel")

    status_raw = git_output(
        project_root,
        "status",
        "--porcelain=v1",
        "--untracked-files=all",
    )
    status_lines = [line for line in status_raw.splitlines() if line.strip()]

    ignored_generated: list[str] = []
    effective_changes: list[str] = []
    for line in status_lines:
        path = normalize_porcelain_path(line)
        if any(path.startswith(prefix) for prefix in GENERATED_GIT_PATH_PREFIXES):
            ignored_generated.append(line)
        else:
            effective_changes.append(line)

    upstream = ""
    ahead = None
    behind = None
    try:
        upstream = git_output(
            project_root,
            "rev-parse",
            "--abbrev-ref",
            "--symbolic-full-name",
            "@{u}",
        )
        counts = git_output(
            project_root,
            "rev-list",
            "--left-right",
            "--count",
            f"HEAD...{upstream}",
        ).split()
        if len(counts) == 2:
            ahead, behind = int(counts[0]), int(counts[1])
    except Exception:
        upstream = "NEOVĚŘENO"

    return {
        "branch": branch,
        "commit": commit,
        "commit_short": commit_short,
        "subject": subject,
        "repo_root": repo_root,
        "upstream": upstream,
        "ahead": ahead,
        "behind": behind,
        "worktree_clean": not effective_changes,
        "effective_changes": effective_changes,
        "ignored_generated_changes": ignored_generated,
        "collected_at": iso_now(),
    }


def find_active_panel(project_root: Path) -> Path:
    exact = (
        project_root
        / "tools"
        / "matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"
    )
    if exact.is_file():
        return exact

    candidates = sorted(
        (project_root / "tools").glob(
            "matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW*.py"
        ),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )
    if candidates:
        return candidates[0]

    raise RuntimeError(
        "Aktivní Q3 panel nebyl nalezen v tools/. "
        "DB konfiguraci nelze bezpečně odvodit."
    )


def parse_db_config_from_panel(panel_path: Path) -> dict[str, Any]:
    """
    Načte pouze literál DB_CONFIG pomocí AST.
    Panel se neimportuje ani nespouští.
    """
    source = panel_path.read_text(encoding="utf-8-sig", errors="replace")
    tree = ast.parse(source, filename=str(panel_path))

    for node in tree.body:
        if not isinstance(node, (ast.Assign, ast.AnnAssign)):
            continue

        targets: list[ast.expr] = []
        value: ast.expr | None = None

        if isinstance(node, ast.Assign):
            targets = list(node.targets)
            value = node.value
        else:
            targets = [node.target]
            value = node.value

        if value is None:
            continue

        for target in targets:
            if isinstance(target, ast.Name) and target.id == "DB_CONFIG":
                config = ast.literal_eval(value)
                if not isinstance(config, dict):
                    raise RuntimeError("DB_CONFIG v panelu není slovník.")
                required = {"host", "port", "dbname", "user", "password"}
                missing = required - set(config)
                if missing:
                    raise RuntimeError(
                        "DB_CONFIG v panelu neobsahuje: " + ", ".join(sorted(missing))
                    )
                return dict(config)

    raise RuntimeError("V aktivním panelu nebyl nalezen DB_CONFIG.")


def load_db_config(project_root: Path) -> tuple[dict[str, Any], str]:
    """
    Priorita:
    1. MATCHMATRIX_DATABASE_URL
    2. MATCHMATRIX_DB_* proměnné
    3. AST čtení DB_CONFIG z aktivního panelu
    """
    database_url = os.environ.get("MATCHMATRIX_DATABASE_URL", "").strip()
    if database_url:
        return {"dsn": database_url}, "MATCHMATRIX_DATABASE_URL"

    env_values = {
        "host": os.environ.get("MATCHMATRIX_DB_HOST"),
        "port": os.environ.get("MATCHMATRIX_DB_PORT"),
        "dbname": os.environ.get("MATCHMATRIX_DB_NAME"),
        "user": os.environ.get("MATCHMATRIX_DB_USER"),
        "password": os.environ.get("MATCHMATRIX_DB_PASSWORD"),
    }
    if all(value not in (None, "") for value in env_values.values()):
        env_values["port"] = int(str(env_values["port"]))
        return env_values, "MATCHMATRIX_DB_*"

    panel_path = find_active_panel(project_root)
    return parse_db_config_from_panel(panel_path), (
        f"AST:{safe_relative(panel_path, project_root)}"
    )


def sanitized_db_descriptor(config: Mapping[str, Any], source: str) -> dict[str, Any]:
    if "dsn" in config:
        return {
            "source": source,
            "target": "DSN – citlivé části nezobrazeny",
        }
    return {
        "source": source,
        "host": str(config.get("host") or ""),
        "port": int(config.get("port") or 5432),
        "dbname": str(config.get("dbname") or ""),
        "user": str(config.get("user") or ""),
        "password": "[REDACTED]",
    }


def connect_read_only(config: Mapping[str, Any]):
    if "dsn" in config:
        conn = psycopg2.connect(str(config["dsn"]))
    else:
        conn = psycopg2.connect(**dict(config))
    conn.set_session(
        readonly=True,
        autocommit=False,
        isolation_level="REPEATABLE READ",
    )
    return conn


def query_rows(conn, name: str, sql: str, params: Sequence[Any] | None = None) -> QueryResult:
    try:
        with conn.cursor(
            cursor_factory=psycopg2.extras.RealDictCursor
        ) as cursor:
            cursor.execute("SAVEPOINT a34_query")
            try:
                cursor.execute(sql, params)
                rows = [dict(row) for row in cursor.fetchall()]
                cursor.execute("RELEASE SAVEPOINT a34_query")
                return QueryResult(name=name, ok=True, rows=rows)
            except Exception as exc:
                cursor.execute("ROLLBACK TO SAVEPOINT a34_query")
                cursor.execute("RELEASE SAVEPOINT a34_query")
                return QueryResult(
                    name=name,
                    ok=False,
                    rows=[],
                    error=f"{type(exc).__name__}: {exc}",
                )
    except Exception as exc:
        return QueryResult(
            name=name,
            ok=False,
            rows=[],
            error=f"{type(exc).__name__}: {exc}",
        )


def query_scalar_count(
    conn,
    name: str,
    sql: str,
    params: Sequence[Any] | None = None,
) -> QueryResult:
    result = query_rows(conn, name, sql, params)
    return result


def result_payload(result: QueryResult) -> dict[str, Any]:
    return {
        "name": result.name,
        "ok": result.ok,
        "rows": result.rows,
        "error": result.error,
    }


def collect_documentation_database_snapshot(conn) -> dict[str, Any]:
    summary = query_rows(
        conn,
        "documentation_summary",
        """
        SELECT
            (SELECT COUNT(*) FROM documentation.documents) AS documents,
            (SELECT COUNT(*) FROM documentation.document_versions) AS versions_total,
            (
                SELECT COUNT(*)
                FROM documentation.document_versions
                WHERE is_current = true
            ) AS current_versions,
            (SELECT COUNT(*) FROM documentation.document_sections) AS sections,
            (SELECT COUNT(*) FROM documentation.document_relations) AS relations,
            (
                SELECT COUNT(*)
                FROM documentation.document_status_history
            ) AS status_history,
            (SELECT COUNT(*) FROM documentation.import_runs) AS import_runs,
            (
                SELECT COUNT(*)
                FROM documentation.documents
                WHERE COALESCE(is_active, false) = true
            ) AS active_documents;
        """,
    )

    latest_documents = query_rows(
        conn,
        "latest_documents",
        """
        SELECT
            document_id,
            title,
            document_type,
            edition,
            current_version_label,
            current_status,
            source_of_truth,
            is_active,
            updated_at
        FROM documentation.documents
        ORDER BY updated_at DESC NULLS LAST, document_id
        LIMIT 30;
        """,
    )

    latest_imports = query_rows(
        conn,
        "latest_import_runs",
        """
        SELECT
            import_run_pk,
            started_at,
            finished_at,
            import_status,
            source_root,
            details
        FROM documentation.import_runs
        ORDER BY import_run_pk DESC
        LIMIT 20;
        """,
    )

    latest_relations = query_rows(
        conn,
        "latest_relations",
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
        ORDER BY r.created_at DESC NULLS LAST
        LIMIT 30;
        """,
    )

    latest_status_history = query_rows(
        conn,
        "latest_status_history",
        """
        SELECT
            d.document_id,
            h.previous_status,
            h.new_status,
            h.change_reason,
            h.changed_at
        FROM documentation.document_status_history AS h
        LEFT JOIN documentation.documents AS d
          ON d.document_pk = h.document_pk
        ORDER BY h.changed_at DESC NULLS LAST
        LIMIT 30;
        """,
    )

    return {
        "collected_at": iso_now(),
        "transaction_mode": "READ ONLY / REPEATABLE READ / ROLLBACK",
        "summary": result_payload(summary),
        "latest_documents": result_payload(latest_documents),
        "latest_import_runs": result_payload(latest_imports),
        "latest_relations": result_payload(latest_relations),
        "latest_status_history": result_payload(latest_status_history),
    }


def collect_all_sports_snapshot(conn) -> dict[str, Any]:
    queries = (
        (
            "sports",
            """
            SELECT *
            FROM public.sports
            ORDER BY sport_code;
            """,
            None,
        ),
        (
            "canonical_providers_count",
            "SELECT COUNT(*) AS row_count FROM public.data_providers;",
            None,
        ),
        (
            "provider_sport_matrix_count",
            "SELECT COUNT(*) AS row_count FROM ops.provider_sport_matrix;",
            None,
        ),
        (
            "provider_entity_coverage_count",
            "SELECT COUNT(*) AS row_count FROM ops.provider_entity_coverage;",
            None,
        ),
        (
            "ingest_entity_plan_count",
            "SELECT COUNT(*) AS row_count FROM ops.ingest_entity_plan;",
            None,
        ),
        (
            "provider_worker_registry_count",
            "SELECT COUNT(*) AS row_count FROM ops.provider_worker_registry;",
            None,
        ),
        (
            "provider_accounts_count",
            "SELECT COUNT(*) AS row_count FROM ops.provider_accounts;",
            None,
        ),
        (
            "coverage_by_sport_and_status",
            """
            SELECT
                sport_code,
                COALESCE(coverage_status, 'UNKNOWN') AS coverage_status,
                COUNT(*) AS row_count
            FROM ops.provider_entity_coverage
            GROUP BY sport_code, COALESCE(coverage_status, 'UNKNOWN')
            ORDER BY sport_code, coverage_status;
            """,
            None,
        ),
        (
            "sport_completion_dashboard",
            """
            SELECT *
            FROM ops.v_sport_completion_dashboard_v2
            ORDER BY sport_code;
            """,
            None,
        ),
        (
            "provider_matrix",
            """
            SELECT *
            FROM ops.provider_sport_matrix
            ORDER BY sport_code, provider;
            """,
            None,
        ),
    )

    payload: dict[str, Any] = {
        "collected_at": iso_now(),
        "transaction_mode": "READ ONLY / REPEATABLE READ / ROLLBACK",
        "queries": {},
    }

    for name, sql, params in queries:
        payload["queries"][name] = result_payload(
            query_rows(conn, name, sql, params)
        )

    return payload


def collect_active_sport_snapshot(
    conn,
    *,
    sport_code: str,
    sport_name: str,
) -> dict[str, Any]:
    code = sport_code.strip().upper()

    queries = (
        (
            "sport_definition",
            """
            SELECT *
            FROM public.sports
            WHERE UPPER(sport_code) = %s
            LIMIT 1;
            """,
            (code,),
        ),
        (
            "sport_completion",
            """
            SELECT *
            FROM ops.v_sport_completion_dashboard_v2
            WHERE UPPER(sport_code) = %s
            LIMIT 1;
            """,
            (code,),
        ),
        (
            "provider_entity_coverage",
            """
            SELECT *
            FROM ops.provider_entity_coverage
            WHERE UPPER(sport_code) = %s
            ORDER BY provider, entity_type;
            """,
            (code,),
        ),
        (
            "ingest_entity_plan",
            """
            SELECT *
            FROM ops.ingest_entity_plan
            WHERE UPPER(sport_code) = %s
            ORDER BY provider, entity_type;
            """,
            (code,),
        ),
        (
            "provider_worker_registry",
            """
            SELECT *
            FROM ops.provider_worker_registry
            WHERE UPPER(sport_code) = %s
            ORDER BY provider, entity_type;
            """,
            (code,),
        ),
        (
            "provider_sport_matrix",
            """
            SELECT *
            FROM ops.provider_sport_matrix
            WHERE UPPER(sport_code) = %s
            ORDER BY provider;
            """,
            (code,),
        ),
        (
            "public_leagues_count",
            """
            SELECT COUNT(*) AS row_count
            FROM public.leagues AS entity
            JOIN public.sports AS sport
              ON sport.sport_id = entity.sport_id
            WHERE UPPER(sport.sport_code) = %s;
            """,
            (code,),
        ),
        (
            "public_teams_count",
            """
            SELECT COUNT(*) AS row_count
            FROM public.teams AS entity
            JOIN public.sports AS sport
              ON sport.sport_id = entity.sport_id
            WHERE UPPER(sport.sport_code) = %s;
            """,
            (code,),
        ),
        (
            "public_matches_count",
            """
            SELECT COUNT(*) AS row_count
            FROM public.matches AS entity
            JOIN public.sports AS sport
              ON sport.sport_id = entity.sport_id
            WHERE UPPER(sport.sport_code) = %s;
            """,
            (code,),
        ),
        (
            "public_players_count",
            """
            SELECT COUNT(*) AS row_count
            FROM public.players AS entity
            JOIN public.sports AS sport
              ON sport.sport_id = entity.sport_id
            WHERE UPPER(sport.sport_code) = %s;
            """,
            (code,),
        ),
        (
            "public_coaches_count",
            """
            SELECT COUNT(*) AS row_count
            FROM public.coaches AS entity
            JOIN public.sports AS sport
              ON sport.sport_id = entity.sport_id
            WHERE UPPER(sport.sport_code) = %s;
            """,
            (code,),
        ),
    )

    payload: dict[str, Any] = {
        "sport_code": code,
        "sport_name": sport_name,
        "collected_at": iso_now(),
        "transaction_mode": "READ ONLY / REPEATABLE READ / ROLLBACK",
        "queries": {},
    }

    for name, sql, params in queries:
        payload["queries"][name] = result_payload(
            query_rows(conn, name, sql, params)
        )

    return payload


def run_a33(project_root: Path) -> dict[str, Any]:
    script = (
        project_root
        / "tools"
        / "documentation"
        / "25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py"
    )
    if not script.is_file():
        raise RuntimeError(f"A33 skript nebyl nalezen: {script}")

    started_at = iso_now()
    completed = run_command(
        [sys.executable, str(script)],
        cwd=project_root,
        timeout=900,
    )
    finished_at = iso_now()

    result = {
        "script": safe_relative(script, project_root),
        "python": sys.executable,
        "started_at": started_at,
        "finished_at": finished_at,
        "return_code": completed.returncode,
        "output_tail": completed.stdout[-12000:],
    }
    if completed.returncode != 0:
        raise RuntimeError(
            "A33 audit selhal.\n"
            + completed.stdout[-4000:]
        )
    return result


def latest_file(directory: Path, pattern: str) -> Path | None:
    if not directory.is_dir():
        return None
    candidates = [path for path in directory.glob(pattern) if path.is_file()]
    if not candidates:
        return None
    return max(
        candidates,
        key=lambda path: (
            path.stat().st_mtime_ns,
            path.name.lower(),
        ),
    )


def find_latest_documents(project_root: Path) -> dict[str, Path | None]:
    history = project_root / "docs" / "09_HISTORY"
    return {
        "latest_nav": latest_file(
            history / "NAVÁZÁNÍ_NA_CHAT",
            "MM-NAV-*.md",
        ),
        "latest_daily_log": latest_file(
            history / "DENNÍ_ZÁPISY",
            "MM-DL-*.md",
        ),
        "latest_project_snapshot": latest_file(
            history / "PROJECT_SNAPSHOTS",
            "MM-PS-*.md",
        ),
    }


def sport_audit_slug(sport_code: str, sport_name: str) -> str:
    explicit = {
        "FB": "football",
        "HB": "handball",
        "HK": "hockey",
        "BK": "basketball",
        "BSB": "baseball",
        "TN": "tennis",
        "CK": "cricket",
        "MMA": "mma",
        "AFB": "american_football",
        "VB": "volleyball",
        "FH": "floorball",
        "DRT": "darts",
        "ESP": "esports",
        "RUG": "rugby",
    }
    code = sport_code.strip().upper()
    if code in explicit:
        return explicit[code]

    value = sport_name.strip().lower()
    value = re.sub(r"[^a-z0-9]+", "_", value)
    return value.strip("_") or code.lower()


def collect_related_report_files(
    project_root: Path,
    *,
    sport_code: str,
    sport_name: str,
) -> list[Path]:
    report_root = project_root / "reports" / "documentation"
    files: list[Path] = []

    fixed = (
        report_root / "database_audit" / "database_structure_audit_latest.md",
        report_root / "database_audit" / "database_structure_audit_latest.json",
        report_root / "database_growth" / "documentation_database_growth_latest.md",
        report_root / "database_growth" / "documentation_database_growth_latest.json",
    )
    for path in fixed:
        if path.is_file():
            files.append(path)

    database_audit = report_root / "database_audit"
    slug = sport_audit_slug(sport_code, sport_name)

    if database_audit.is_dir():
        for pattern in (
            f"{slug}_*.json",
            f"{slug}_*.md",
            "all_sports_*_latest.json",
            "all_sports_*_latest.md",
            "all_sports_*_snapshot_*.json",
            "all_sports_*_snapshot_*.md",
        ):
            candidate = latest_file(database_audit, pattern)
            if candidate and candidate not in files:
                files.append(candidate)

    # Poslední A24/A7 pipeline report.
    history_reports = sorted(
        report_root.glob("history_document_database_pipeline_*.json"),
        key=lambda p: p.stat().st_mtime_ns,
        reverse=True,
    )
    if history_reports:
        files.append(history_reports[0])

    return files


def copy_selected_sources(
    project_root: Path,
    package_dir: Path,
    documents: Mapping[str, Path | None],
    related_reports: Sequence[Path],
) -> tuple[dict[str, Any], int]:
    copied: dict[str, Any] = {}
    redactions = 0

    docs_dir = package_dir / "documents"
    reports_dir = package_dir / "reports"

    for logical_name, source in documents.items():
        if source is None:
            copied[logical_name] = {
                "available": False,
                "source": None,
                "package_path": None,
            }
            continue

        target = docs_dir / f"{logical_name}.md"
        redactions += copy_text_scrubbed(source, target)
        copied[logical_name] = {
            "available": True,
            "source": safe_relative(source, project_root),
            "package_path": safe_relative(target, package_dir),
            "sha256": sha256_file(target),
        }

    copied_reports: list[dict[str, Any]] = []
    used_names: set[str] = set()
    for source in related_reports:
        base_name = source.name
        target_name = base_name
        counter = 2
        while target_name.lower() in used_names:
            target_name = f"{source.stem}_{counter}{source.suffix}"
            counter += 1
        used_names.add(target_name.lower())

        target = reports_dir / target_name
        if source.suffix.lower() in TEXT_SUFFIXES:
            redactions += copy_text_scrubbed(source, target)
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)

        copied_reports.append({
            "source": safe_relative(source, project_root),
            "package_path": safe_relative(target, package_dir),
            "sha256": sha256_file(target),
        })

    copied["related_reports"] = copied_reports
    return copied, redactions


def extract_summary_row(snapshot: Mapping[str, Any]) -> Mapping[str, Any]:
    summary = snapshot.get("summary")
    if not isinstance(summary, Mapping):
        return {}
    rows = summary.get("rows")
    if isinstance(rows, list) and rows and isinstance(rows[0], Mapping):
        return rows[0]
    return {}


def query_first_row(
    payload: Mapping[str, Any],
    query_name: str,
) -> Mapping[str, Any]:
    queries = payload.get("queries")
    if not isinstance(queries, Mapping):
        return {}
    query = queries.get(query_name)
    if not isinstance(query, Mapping):
        return {}
    rows = query.get("rows")
    if isinstance(rows, list) and rows and isinstance(rows[0], Mapping):
        return rows[0]
    return {}


def markdown_table_from_mapping(
    mapping: Mapping[str, Any],
    labels: Mapping[str, str] | None = None,
) -> str:
    if not mapping:
        return "_Údaj není dostupný._"
    labels = labels or {}
    lines = ["| Položka | Hodnota |", "|---|---|"]
    for key, value in mapping.items():
        label = labels.get(key, key)
        rendered = str(value).replace("|", "\\|")
        lines.append(f"| {label} | {rendered} |")
    return "\n".join(lines)


def read_package_document(package_dir: Path, logical_name: str) -> str | None:
    path = package_dir / "documents" / f"{logical_name}.md"
    if not path.is_file():
        return None
    return path.read_text(encoding="utf-8", errors="replace").strip()


def build_main_markdown(
    *,
    package_id: str,
    project_root: Path,
    package_dir: Path,
    sport_code: str,
    sport_name: str,
    active_area: str,
    git_snapshot: Mapping[str, Any],
    db_descriptor: Mapping[str, Any],
    documentation_snapshot: Mapping[str, Any],
    all_sports_snapshot: Mapping[str, Any],
    active_sport_snapshot: Mapping[str, Any],
    a33_run: Mapping[str, Any] | None,
    copied_sources: Mapping[str, Any],
    warnings: Sequence[str],
    redaction_count: int,
) -> str:
    doc_summary = extract_summary_row(documentation_snapshot)

    sport_counts = {
        "Soutěže": query_first_row(
            active_sport_snapshot, "public_leagues_count"
        ).get("row_count", "NEOVĚŘENO"),
        "Týmy": query_first_row(
            active_sport_snapshot, "public_teams_count"
        ).get("row_count", "NEOVĚŘENO"),
        "Zápasy": query_first_row(
            active_sport_snapshot, "public_matches_count"
        ).get("row_count", "NEOVĚŘENO"),
        "Hráči": query_first_row(
            active_sport_snapshot, "public_players_count"
        ).get("row_count", "NEOVĚŘENO"),
        "Trenéři": query_first_row(
            active_sport_snapshot, "public_coaches_count"
        ).get("row_count", "NEOVĚŘENO"),
    }

    git_table = {
        "Větev": git_snapshot.get("branch"),
        "Commit": git_snapshot.get("commit"),
        "Popis commitu": git_snapshot.get("subject"),
        "Upstream": git_snapshot.get("upstream"),
        "Ahead": git_snapshot.get("ahead"),
        "Behind": git_snapshot.get("behind"),
        "Pracovní strom": (
            "ČISTÝ" if git_snapshot.get("worktree_clean") else "NEČISTÝ"
        ),
    }

    doc_labels = {
        "documents": "Dokumenty",
        "versions_total": "Verze celkem",
        "current_versions": "Aktuální verze",
        "sections": "Sekce",
        "relations": "Vazby",
        "status_history": "Historie stavů",
        "import_runs": "Importní běhy",
        "active_documents": "Aktivní dokumenty",
    }

    warning_lines = (
        "\n".join(f"- {warning}" for warning in warnings)
        if warnings
        else "- Nebylo zjištěno žádné blokující upozornění."
    )

    source_lines: list[str] = []
    for key in (
        "latest_nav",
        "latest_daily_log",
        "latest_project_snapshot",
    ):
        item = copied_sources.get(key)
        if isinstance(item, Mapping) and item.get("available"):
            source_lines.append(
                f"- **{key}:** `{item.get('source')}` "
                f"→ `{item.get('package_path')}`"
            )
        else:
            source_lines.append(f"- **{key}:** NENALEZEN")

    related = copied_sources.get("related_reports")
    if isinstance(related, list):
        for item in related:
            if isinstance(item, Mapping):
                source_lines.append(
                    f"- **report:** `{item.get('source')}` "
                    f"→ `{item.get('package_path')}`"
                )

    nav_text = read_package_document(package_dir, "latest_nav")
    daily_text = read_package_document(package_dir, "latest_daily_log")
    snapshot_text = read_package_document(
        package_dir,
        "latest_project_snapshot",
    )

    appendices: list[str] = []
    for label, marker, content in (
        ("Poslední navázání do chatu", "LATEST_NAV", nav_text),
        ("Poslední denní zápis", "LATEST_DAILY_LOG", daily_text),
        ("Poslední projektový snapshot", "LATEST_PROJECT_SNAPSHOT", snapshot_text),
    ):
        if content:
            appendices.append(
                f"""
# Příloha – {label}

<!-- BEGIN {marker} -->

{content}

<!-- END {marker} -->
""".strip()
            )

    a33_text = (
        f"Spuštěn v tomto běhu, návratový kód `{a33_run.get('return_code')}`."
        if a33_run
        else "V tomto běhu nebyl A33 znovu spuštěn; byly použity poslední dostupné výstupy."
    )

    markdown = f"""
# MatchMatrix – AI CONTEXT PACKAGE

## 1. Identifikace balíčku

| Položka | Hodnota |
|---|---|
| Package ID | `{package_id}` |
| Engine | `{ENGINE_VERSION}` |
| Vytvořeno | `{iso_now()}` |
| Projekt | `MatchMatrix-platform` |
| Kořen repozitáře | `{project_root}` |
| Aktivní sport | `{sport_code}` – {sport_name} |
| Aktivní oblast | {active_area} |
| Režim databáze | `READ ONLY / REPEATABLE READ / ROLLBACK` |
| Citlivé hodnoty | Nejsou součástí balíčku |
| Provedená redakce | {redaction_count} hodnot |

---

## 2. Pokyn pro AI

Tento soubor je řízený kontextový balíček projektu MatchMatrix.

Při pokračování práce:

1. používej poslední NAV jako bezprostřední stav a místo navázání,
2. projektový snapshot používej jako širší dlouhodobý kontext,
3. databázové snapshoty považuj za stav platný pro uvedený Git commit,
4. nevyvozuj, že návrhové databázové objekty již existují,
5. nerozšiřuj databázi bez schválené dokumentace, validace a rollbacku,
6. postupuj po jednom jasném technickém kroku,
7. zachovej technické kódy dohledatelné a panelové názvy v češtině,
8. při nejasnosti mezi dokumentací a databázovým auditem výslovně popiš rozdíl,
9. nevkládej do dokumentace ani výstupů hesla, tokeny nebo API klíče,
10. aktivní referenční sport je nyní **{sport_name} ({sport_code})**.

---

## 3. Git snapshot

{markdown_table_from_mapping(git_table)}

---

## 4. Dokumentační databáze

Zdroj připojení:

```json
{json.dumps(db_descriptor, ensure_ascii=False, indent=2, default=json_default)}
```

{markdown_table_from_mapping(doc_summary, doc_labels)}

---

## 5. A33 – audit struktury databáze

{a33_text}

Poslední čitelné A33 soubory jsou přiloženy v podsložce `reports/`.
A33 je zdroj strukturálního přehledu; obsahovou úplnost jednotlivých sportů
popisují samostatné datové snapshoty.

---

## 6. Stav všech sportů

Úplný strojově čitelný stav je v:

```text
snapshots/all_sports_data_snapshot.json
```

---

## 7. Aktivní sport – {sport_name} ({sport_code})

{markdown_table_from_mapping(sport_counts)}

Úplný strojově čitelný stav je v:

```text
snapshots/active_sport_snapshot.json
```

---

## 8. Ověřené zdroje balíčku

{chr(10).join(source_lines)}

---

## 9. Upozornění a omezení

{warning_lines}

---

## 10. Doporučený první krok v novém chatu

Nejprve přečíst přílohu **Poslední navázání do chatu** a potvrdit,
že Git commit a databázový snapshot odpovídají aktuálnímu stavu.
Potom pokračovat jediným krokem uvedeným v NAV.

---

## 11. Technické soubory balíčku

```text
MATCHMATRIX_AI_CONTEXT_PACKAGE.md
documents/latest_nav.md
documents/latest_daily_log.md
documents/latest_project_snapshot.md
snapshots/git_snapshot.json
snapshots/documentation_database_snapshot.json
snapshots/all_sports_data_snapshot.json
snapshots/active_sport_snapshot.json
snapshots/a33_run.json
reports/*
package_manifest.json
```
""".strip()

    if appendices:
        markdown += "\n\n---\n\n" + "\n\n---\n\n".join(appendices)

    clean, _ = scrub_text(markdown)
    return clean.rstrip() + "\n"


def build_manifest(
    *,
    package_id: str,
    package_dir: Path,
    project_root: Path,
    sport_code: str,
    sport_name: str,
    final_status: str,
    warnings: Sequence[str],
) -> dict[str, Any]:
    files: list[dict[str, Any]] = []
    for path in sorted(package_dir.rglob("*")):
        if not path.is_file():
            continue
        if path.name == "package_manifest.json":
            continue
        files.append({
            "path": safe_relative(path, package_dir),
            "size_bytes": path.stat().st_size,
            "sha256": sha256_file(path),
        })

    return {
        "package_id": package_id,
        "engine_version": ENGINE_VERSION,
        "final_status": final_status,
        "created_at": iso_now(),
        "project_root": str(project_root),
        "sport_code": sport_code,
        "sport_name": sport_name,
        "warnings": list(warnings),
        "file_count": len(files),
        "files": files,
    }


def create_zip(package_dir: Path, zip_path: Path) -> None:
    zip_path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(
        zip_path,
        mode="w",
        compression=zipfile.ZIP_DEFLATED,
        compresslevel=9,
    ) as archive:
        for path in sorted(package_dir.rglob("*")):
            if path.is_file():
                archive.write(
                    path,
                    arcname=f"{package_dir.name}/{safe_relative(path, package_dir)}",
                )


def validate_required_inputs(
    *,
    git_snapshot: Mapping[str, Any],
    latest_documents: Mapping[str, Path | None],
) -> list[str]:
    blockers: list[str] = []

    if not git_snapshot.get("worktree_clean"):
        changes = git_snapshot.get("effective_changes") or []
        rendered = "\n".join(str(line) for line in changes[:20])
        blockers.append(
            "Git pracovní strom obsahuje skutečné neuložené změny:\n" + rendered
        )

    if latest_documents.get("latest_nav") is None:
        blockers.append("Nebyl nalezen poslední MM-NAV dokument.")

    if latest_documents.get("latest_daily_log") is None:
        blockers.append("Nebyl nalezen poslední MM-DL dokument.")

    return blockers


def create_package(args: argparse.Namespace) -> dict[str, Any]:
    project_root = resolve_project_root(args.project_root)
    sport_code = args.sport_code.strip().upper()
    sport_name = args.sport_name.strip()
    active_area = args.active_area.strip()

    git_snapshot = collect_git_snapshot(project_root)
    latest_documents = find_latest_documents(project_root)
    blockers = validate_required_inputs(
        git_snapshot=git_snapshot,
        latest_documents=latest_documents,
    )

    if blockers:
        raise RuntimeError("\n\n".join(blockers))

    db_config, db_config_source = load_db_config(project_root)
    db_descriptor = sanitized_db_descriptor(
        db_config,
        db_config_source,
    )

    conn = None
    try:
        conn = connect_read_only(db_config)
        documentation_snapshot = collect_documentation_database_snapshot(conn)
        all_sports_snapshot = collect_all_sports_snapshot(conn)
        active_sport_snapshot = collect_active_sport_snapshot(
            conn,
            sport_code=sport_code,
            sport_name=sport_name,
        )
    finally:
        if conn is not None:
            try:
                conn.rollback()
            finally:
                conn.close()

    warnings: list[str] = []

    if latest_documents.get("latest_project_snapshot") is None:
        warnings.append(
            "Nebyl nalezen MM-PS projektový snapshot. "
            "Balíček je použitelný, ale postrádá širší dlouhodobý snapshot."
        )

    if git_snapshot.get("ahead") not in (None, 0):
        warnings.append(
            f"Lokální větev je před upstreamem o {git_snapshot.get('ahead')} commitů."
        )
    if git_snapshot.get("behind") not in (None, 0):
        warnings.append(
            f"Lokální větev je za upstreamem o {git_snapshot.get('behind')} commitů."
        )

    # Povinné dotazy nesmí selhat.
    doc_summary = documentation_snapshot.get("summary")
    if not isinstance(doc_summary, Mapping) or not doc_summary.get("ok"):
        raise RuntimeError(
            "Nelze načíst souhrn dokumentační databáze: "
            + str(
                doc_summary.get("error")
                if isinstance(doc_summary, Mapping)
                else "neznámá chyba"
            )
        )

    if args.validate_only:
        return {
            "final_status": FINAL_STATUS_VALIDATED,
            "project_root": str(project_root),
            "sport_code": sport_code,
            "sport_name": sport_name,
            "git_snapshot": git_snapshot,
            "db_descriptor": db_descriptor,
            "latest_documents": {
                key: str(value) if value else None
                for key, value in latest_documents.items()
            },
            "warnings": warnings,
        }

    timestamp = local_now().strftime("%Y%m%d_%H%M%S")
    package_id = f"{timestamp}_MATCHMATRIX_AI_CONTEXT_PACKAGE"
    output_root = (
        project_root
        / "reports"
        / "documentation"
        / "ai_context_package"
    )
    package_dir = output_root / package_id
    package_dir.mkdir(parents=True, exist_ok=False)

    a33_run: dict[str, Any] | None = None
    if not args.skip_a33:
        try:
            a33_run = run_a33(project_root)
        except Exception:
            # A33 je povinný při běžném produkčním exportu.
            shutil.rmtree(package_dir, ignore_errors=True)
            raise

    snapshots_dir = package_dir / "snapshots"
    write_json(snapshots_dir / "git_snapshot.json", git_snapshot)
    write_json(
        snapshots_dir / "documentation_database_snapshot.json",
        documentation_snapshot,
    )
    write_json(
        snapshots_dir / "all_sports_data_snapshot.json",
        all_sports_snapshot,
    )
    write_json(
        snapshots_dir / "active_sport_snapshot.json",
        active_sport_snapshot,
    )
    write_json(
        snapshots_dir / "a33_run.json",
        a33_run or {
            "skipped": True,
            "reason": "--skip-a33",
            "recorded_at": iso_now(),
        },
    )

    related_reports = collect_related_report_files(
        project_root,
        sport_code=sport_code,
        sport_name=sport_name,
    )
    copied_sources, redaction_count = copy_selected_sources(
        project_root,
        package_dir,
        latest_documents,
        related_reports,
    )

    main_markdown = build_main_markdown(
        package_id=package_id,
        project_root=project_root,
        package_dir=package_dir,
        sport_code=sport_code,
        sport_name=sport_name,
        active_area=active_area,
        git_snapshot=git_snapshot,
        db_descriptor=db_descriptor,
        documentation_snapshot=documentation_snapshot,
        all_sports_snapshot=all_sports_snapshot,
        active_sport_snapshot=active_sport_snapshot,
        a33_run=a33_run,
        copied_sources=copied_sources,
        warnings=warnings,
        redaction_count=redaction_count,
    )
    main_md = package_dir / "MATCHMATRIX_AI_CONTEXT_PACKAGE.md"
    write_text(main_md, main_markdown)

    source_index = {
        "package_id": package_id,
        "created_at": iso_now(),
        "copied_sources": copied_sources,
        "redaction_count": redaction_count,
    }
    write_json(package_dir / "source_index.json", source_index)

    manifest = build_manifest(
        package_id=package_id,
        package_dir=package_dir,
        project_root=project_root,
        sport_code=sport_code,
        sport_name=sport_name,
        final_status=FINAL_STATUS_CREATED,
        warnings=warnings,
    )
    manifest_path = package_dir / "package_manifest.json"
    write_json(manifest_path, manifest)

    zip_path = output_root / f"{package_id}.zip"
    create_zip(package_dir, zip_path)

    latest_md = output_root / "MATCHMATRIX_AI_CONTEXT_PACKAGE_LATEST.md"
    latest_zip = output_root / "MATCHMATRIX_AI_CONTEXT_PACKAGE_LATEST.zip"
    latest_manifest = output_root / "MATCHMATRIX_AI_CONTEXT_PACKAGE_LATEST_MANIFEST.json"

    shutil.copy2(main_md, latest_md)
    shutil.copy2(zip_path, latest_zip)
    shutil.copy2(manifest_path, latest_manifest)

    return {
        "final_status": FINAL_STATUS_CREATED,
        "package_id": package_id,
        "package_dir": str(package_dir),
        "main_markdown": str(main_md),
        "zip_path": str(zip_path),
        "latest_markdown": str(latest_md),
        "latest_zip": str(latest_zip),
        "latest_manifest": str(latest_manifest),
        "warnings": warnings,
        "file_count": manifest.get("file_count"),
        "git_commit": git_snapshot.get("commit"),
        "sport_code": sport_code,
        "sport_name": sport_name,
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="MatchMatrix A34 – vytvoření AI Context Package."
    )
    parser.add_argument(
        "--project-root",
        help="Kořen repozitáře. Standardně se odvodí ze cesty skriptu.",
    )
    parser.add_argument(
        "--sport-code",
        default=DEFAULT_SPORT_CODE,
        help=f"Aktivní sportovní kód. Výchozí: {DEFAULT_SPORT_CODE}.",
    )
    parser.add_argument(
        "--sport-name",
        default=DEFAULT_SPORT_NAME,
        help=f"Český název aktivního sportu. Výchozí: {DEFAULT_SPORT_NAME}.",
    )
    parser.add_argument(
        "--active-area",
        default=DEFAULT_ACTIVE_AREA,
        help="Aktuální pracovní oblast pro hlavní Markdown.",
    )
    parser.add_argument(
        "--skip-a33",
        action="store_true",
        help=(
            "Nevykoná nový A33 audit a použije poslední dostupné výstupy. "
            "Určeno pouze pro řízené testování."
        ),
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Ověří Git, dokumenty a databázové připojení bez vytvoření balíčku.",
    )
    return parser


def print_result(result: Mapping[str, Any]) -> None:
    print("=" * 79)
    print("MATCHMATRIX AI CONTEXT PACKAGE")
    print("=" * 79)
    print(f"ENGINE       : {ENGINE_VERSION}")
    print(f"FINAL STATUS : {result.get('final_status')}")
    print(f"SPORT        : {result.get('sport_code')} – {result.get('sport_name')}")

    if result.get("package_id"):
        print(f"PACKAGE ID   : {result.get('package_id')}")
        print(f"PACKAGE DIR  : {result.get('package_dir')}")
        print(f"LATEST MD    : {result.get('latest_markdown')}")
        print(f"LATEST ZIP   : {result.get('latest_zip')}")
        print(f"FILES        : {result.get('file_count')}")

    warnings = result.get("warnings") or []
    print(f"WARNINGS     : {len(warnings)}")
    for warning in warnings:
        print(f"  - {warning}")

    print("=" * 79)
    print(f"__MM_A34_FINAL_STATUS__={result.get('final_status')}")
    if result.get("package_dir"):
        print(f"__MM_A34_PACKAGE_DIR__={result.get('package_dir')}")
    if result.get("latest_markdown"):
        print(f"__MM_A34_LATEST_MD__={result.get('latest_markdown')}")
    if result.get("latest_zip"):
        print(f"__MM_A34_LATEST_ZIP__={result.get('latest_zip')}")


def main() -> int:
    args = build_parser().parse_args()

    try:
        result = create_package(args)
        print_result(result)
        return 0
    except KeyboardInterrupt:
        print("CHYBA: Běh byl přerušen uživatelem.", file=sys.stderr)
        print(f"__MM_A34_FINAL_STATUS__={FINAL_STATUS_BLOCKED}")
        return 130
    except Exception as exc:
        safe_message, _ = scrub_text(f"{type(exc).__name__}: {exc}")
        print("=" * 79, file=sys.stderr)
        print("MATCHMATRIX AI CONTEXT PACKAGE – CHYBA", file=sys.stderr)
        print("=" * 79, file=sys.stderr)
        print(safe_message, file=sys.stderr)
        if os.environ.get("MATCHMATRIX_A34_DEBUG") == "1":
            trace, _ = scrub_text(traceback.format_exc())
            print(trace, file=sys.stderr)
        print(f"__MM_A34_FINAL_STATUS__={FINAL_STATUS_BLOCKED}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
