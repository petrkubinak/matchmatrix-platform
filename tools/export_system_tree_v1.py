from __future__ import annotations

import os
from pathlib import Path
from datetime import datetime

import psycopg2


# ============================================================
# MATCHMATRIX - EXPORT SYSTEM TREE V1
#
# Kam uložit:
# C:\MatchMatrix-platform\tools\export_system_tree_v1.py
#
# Co dělá:
# 1) načte strom DB objektů (schemas / tables / views / matviews / functions)
# 2) načte strom složek a souborů projektu
# 3) uloží vše do 1 textového souboru
#
# Spuštění:
# C:\Python314\python.exe C:\MatchMatrix-platform\tools\export_system_tree_v1.py
# ============================================================

PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
OUTPUT_DIR = PROJECT_ROOT / "reports" / "audit"
LATEST_OUTPUT = OUTPUT_DIR / "latest_system_tree.txt"

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

IGNORE_DIRS = {
    ".git",
    "__pycache__",
    ".venv",
    "node_modules",
    ".next",
    "dist",
    "build",
}

WATCH_EXT = {
    ".py", ".ps1", ".sql", ".md", ".json", ".yml", ".yaml",
    ".txt", ".csv", ".bat", ".cmd", ".psm1", ".psd1",
    ".tsx", ".ts", ".js", ".jsx", ".html", ".css"
}


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def fetch_rows(sql: str):
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(sql)
            return cur.fetchall()
    finally:
        conn.close()


def load_db_tree():
    schemas_sql = """
        SELECT schema_name
        FROM information_schema.schemata
        WHERE schema_name NOT IN ('pg_catalog', 'information_schema')
        ORDER BY
            CASE schema_name
                WHEN 'ops' THEN 1
                WHEN 'public' THEN 2
                WHEN 'staging' THEN 3
                WHEN 'work' THEN 4
                ELSE 100
            END,
            schema_name;
    """

    tables_sql = """
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_type = 'BASE TABLE'
          AND table_schema NOT IN ('pg_catalog', 'information_schema')
        ORDER BY table_schema, table_name;
    """

    views_sql = """
        SELECT table_schema, table_name
        FROM information_schema.views
        WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
        ORDER BY table_schema, table_name;
    """

    matviews_sql = """
        SELECT schemaname, matviewname
        FROM pg_matviews
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY schemaname, matviewname;
    """

    functions_sql = """
        SELECT n.nspname AS schema_name,
               p.proname AS function_name
        FROM pg_proc p
        JOIN pg_namespace n
          ON n.oid = p.pronamespace
        WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY n.nspname, p.proname;
    """

    schemas = [r[0] for r in fetch_rows(schemas_sql)]
    tables = fetch_rows(tables_sql)
    views = fetch_rows(views_sql)
    matviews = fetch_rows(matviews_sql)
    functions = fetch_rows(functions_sql)

    tree = {}
    for schema in schemas:
        tree[schema] = {
            "tables": [],
            "views": [],
            "matviews": [],
            "functions": [],
        }

    for schema, name in tables:
        tree.setdefault(schema, {"tables": [], "views": [], "matviews": [], "functions": []})
        tree[schema]["tables"].append(name)

    for schema, name in views:
        tree.setdefault(schema, {"tables": [], "views": [], "matviews": [], "functions": []})
        tree[schema]["views"].append(name)

    for schema, name in matviews:
        tree.setdefault(schema, {"tables": [], "views": [], "matviews": [], "functions": []})
        tree[schema]["matviews"].append(name)

    for schema, name in functions:
        tree.setdefault(schema, {"tables": [], "views": [], "matviews": [], "functions": []})
        tree[schema]["functions"].append(name)

    return tree


def build_db_tree_text(tree: dict) -> list[str]:
    lines: list[str] = []
    lines.append("============================================================")
    lines.append("DATABASE TREE")
    lines.append("============================================================")
    lines.append("")

    for schema, items in tree.items():
        lines.append(f"[SCHEMA] {schema}")

        lines.append("  [TABLES]")
        if items["tables"]:
            for name in items["tables"]:
                lines.append(f"    - {name}")
        else:
            lines.append("    - (none)")

        lines.append("  [VIEWS]")
        if items["views"]:
            for name in items["views"]:
                lines.append(f"    - {name}")
        else:
            lines.append("    - (none)")

        lines.append("  [MATERIALIZED VIEWS]")
        if items["matviews"]:
            for name in items["matviews"]:
                lines.append(f"    - {name}")
        else:
            lines.append("    - (none)")

        lines.append("  [FUNCTIONS]")
        if items["functions"]:
            for name in items["functions"]:
                lines.append(f"    - {name}")
        else:
            lines.append("    - (none)")

        lines.append("")

    return lines


def build_fs_tree(root: Path) -> list[str]:
    lines: list[str] = []
    lines.append("============================================================")
    lines.append("PROJECT FOLDER TREE")
    lines.append("============================================================")
    lines.append("")
    lines.append(str(root))

    def walk_dir(path: Path, prefix: str = ""):
        try:
            entries = sorted(
                [p for p in path.iterdir() if p.name not in IGNORE_DIRS],
                key=lambda p: (not p.is_dir(), p.name.lower())
            )
        except Exception:
            return

        count = len(entries)
        for idx, entry in enumerate(entries):
            connector = "└── " if idx == count - 1 else "├── "
            child_prefix = "    " if idx == count - 1 else "│   "

            if entry.is_dir():
                lines.append(f"{prefix}{connector}{entry.name}\\")
                walk_dir(entry, prefix + child_prefix)
            else:
                # necháme jen běžné projektové typy + README + env-like txt/json
                if entry.suffix.lower() in WATCH_EXT or entry.name.lower().startswith("readme"):
                    lines.append(f"{prefix}{connector}{entry.name}")

    walk_dir(root, "")
    lines.append("")
    return lines


def main() -> int:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    dated_output = OUTPUT_DIR / f"system_tree_{timestamp}.txt"

    lines: list[str] = []
    lines.append("MATCHMATRIX / TICKETMATRIXPLATFORM - SYSTEM TREE EXPORT")
    lines.append(f"Generated at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"Project root: {PROJECT_ROOT}")
    lines.append("")

    try:
        db_tree = load_db_tree()
        lines.extend(build_db_tree_text(db_tree))
    except Exception as e:
        lines.append("============================================================")
        lines.append("DATABASE TREE")
        lines.append("============================================================")
        lines.append("")
        lines.append(f"ERROR loading DB tree: {e}")
        lines.append("")

    lines.extend(build_fs_tree(PROJECT_ROOT))

    text = "\n".join(lines)

    dated_output.write_text(text, encoding="utf-8")
    LATEST_OUTPUT.write_text(text, encoding="utf-8")

    print("=" * 60)
    print("SYSTEM TREE EXPORT OK")
    print("=" * 60)
    print("Saved:", dated_output)
    print("Saved:", LATEST_OUTPUT)
    print("=" * 60)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())