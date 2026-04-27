import os
from pathlib import Path
from datetime import datetime
import psycopg2

DB_CONFIG = {
    "host": os.getenv("PGHOST", "localhost"),
    "port": int(os.getenv("PGPORT", "5432")),
    "dbname": os.getenv("PGDATABASE", "matchmatrix"),
    "user": os.getenv("PGUSER", "matchmatrix"),
    "password": os.getenv("PGPASSWORD", "matchmatrix_pass"),
}

BASE_REPORTS_DIR = Path(r"C:\MatchMatrix-platform\reports")

SCHEMA_CONFIG = [
    ("ops", "přehled_sloupců_tabulek_OPS"),
    ("staging", "přehled_sloupců_tabulek_staging"),
    ("public", "přehled_sloupců_tabulek_public"),
]

PUBLIC_TABLE_WHITELIST = [
    "matches",
    "teams",
    "team_provider_map",
    "team_aliases",
    "leagues",
    "odds",
    "players",
    "player_provider_map",
    "player_season_statistics"
]

def get_connection():
    return psycopg2.connect(**DB_CONFIG)

def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)

def write_pipe_table(file_path: Path, headers, rows):
    with open(file_path, "w", encoding="utf-8") as f:
        f.write("|" + "|".join(headers) + "|\n")
        f.write("|" + "|".join(["-" * len(h) for h in headers]) + "|\n")
        for row in rows:
            vals = []
            for val in row:
                if val is None:
                    vals.append("")
                else:
                    vals.append(str(val).replace("\n", " ").replace("\r", " "))
            f.write("|" + "|".join(vals) + "|\n")

def fetch_columns(cur, schema_name: str, whitelist=None):
    sql = """
        SELECT
            c.table_schema,
            c.table_name,
            c.ordinal_position,
            c.column_name,
            c.data_type,
            c.udt_name,
            c.is_nullable,
            c.column_default
        FROM information_schema.columns c
        WHERE c.table_schema = %s
    """
    params = [schema_name]
    if whitelist:
        sql += " AND c.table_name = ANY(%s)"
        params.append(whitelist)
    sql += " ORDER BY c.table_name, c.ordinal_position"
    cur.execute(sql, params)
    return cur.fetchall()

def fetch_counts(cur, schema_name: str, whitelist=None):
    sql = """
        SELECT
            c.table_name,
            COUNT(*) AS column_count
        FROM information_schema.columns c
        WHERE c.table_schema = %s
    """
    params = [schema_name]
    if whitelist:
        sql += " AND c.table_name = ANY(%s)"
        params.append(whitelist)
    sql += " GROUP BY c.table_name ORDER BY c.table_name"
    cur.execute(sql, params)
    return cur.fetchall()

def fetch_constraints(cur, schema_name: str, whitelist=None):
    sql = """
        SELECT
            tc.table_name,
            tc.constraint_name,
            tc.constraint_type,
            kcu.column_name,
            ccu.table_schema AS foreign_table_schema,
            ccu.table_name AS foreign_table_name,
            ccu.column_name AS foreign_column_name
        FROM information_schema.table_constraints tc
        LEFT JOIN information_schema.key_column_usage kcu
               ON tc.constraint_name = kcu.constraint_name
              AND tc.table_schema = kcu.table_schema
              AND tc.table_name = kcu.table_name
        LEFT JOIN information_schema.constraint_column_usage ccu
               ON tc.constraint_name = ccu.constraint_name
              AND tc.table_schema = ccu.table_schema
        WHERE tc.table_schema = %s
    """
    params = [schema_name]
    if whitelist:
        sql += " AND tc.table_name = ANY(%s)"
        params.append(whitelist)
    sql += " ORDER BY tc.table_name, tc.constraint_name, kcu.ordinal_position NULLS FIRST"
    cur.execute(sql, params)
    return cur.fetchall()

def export_schema(schema_name: str, folder_name: str, whitelist=None):
    today = datetime.now().strftime("%Y%m%d")
    out_dir = BASE_REPORTS_DIR / folder_name / today
    ensure_dir(out_dir)

    with get_connection() as conn:
        with conn.cursor() as cur:
            columns_rows = fetch_columns(cur, schema_name, whitelist)
            count_rows = fetch_counts(cur, schema_name, whitelist)
            constraints_rows = fetch_constraints(cur, schema_name, whitelist)

    write_pipe_table(
        out_dir / f"{schema_name}_1_columns.txt",
        ["table_schema", "table_name", "ordinal_position", "column_name", "data_type", "udt_name", "is_nullable", "column_default"],
        columns_rows
    )
    write_pipe_table(
        out_dir / f"{schema_name}_2_table_counts.txt",
        ["table_name", "column_count"],
        count_rows
    )
    write_pipe_table(
        out_dir / f"{schema_name}_3_constraints.txt",
        ["table_name", "constraint_name", "constraint_type", "column_name", "foreign_table_schema", "foreign_table_name", "foreign_column_name"],
        constraints_rows
    )

    print(f"[OK] {schema_name} -> {out_dir}")

def main():
    print("======================================")
    print("MATCHMATRIX SCHEMA REPORT EXPORT")
    print("======================================")

    for schema_name, folder_name in SCHEMA_CONFIG:
        whitelist = PUBLIC_TABLE_WHITELIST if schema_name == "public" else None
        export_schema(schema_name, folder_name, whitelist)

    print("DONE")

if __name__ == "__main__":
    main()