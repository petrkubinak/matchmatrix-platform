import psycopg2
from psycopg2.extras import RealDictCursor
from pathlib import Path


OUTPUT_FILE = Path(r"C:\MatchMatrix-platform\workers\legacy_to_staging_bridge_report.txt")


def get_conn():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="matchmatrix",
        user="matchmatrix",
        password="matchmatrix_pass",
    )


def write_line(lines, text=""):
    lines.append(text)


def table_count(conn, full_table_name: str) -> int:
    with conn.cursor() as cur:
        cur.execute(f"SELECT COUNT(*) FROM {full_table_name}")
        return cur.fetchone()[0]


def sample_rows(conn, full_table_name: str, limit: int = 2):
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(f"SELECT * FROM {full_table_name} LIMIT %s", (limit,))
        return cur.fetchall()


def inspect_legacy_tables(conn, lines):
    legacy_tables = [
        "staging.api_football_fixtures",
        "staging.api_football_leagues",
        "staging.api_football_odds",
        "staging.api_football_teams",
        "staging.api_hockey_leagues",
        "staging.api_hockey_leagues_raw",
        "staging.api_hockey_teams",
        "staging.api_hockey_teams_raw",
    ]

    write_line(lines, "=== LEGACY -> STAGING BRIDGE INSPECTION ===")
    write_line(lines)

    existing = []

    for table_name in legacy_tables:
        try:
            cnt = table_count(conn, table_name)
            existing.append((table_name, cnt))
            write_line(lines, f"[OK] {table_name} | rows={cnt}")
        except Exception as e:
            conn.rollback()
            write_line(lines, f"[MISSING/ERROR] {table_name} | {e}")

    write_line(lines)
    return existing


def inspect_unified_tables(conn, lines):
    unified_tables = [
        "staging.stg_api_payloads",
        "staging.stg_provider_leagues",
        "staging.stg_provider_teams",
        "staging.stg_provider_players",
        "staging.stg_provider_fixtures",
        "staging.stg_provider_odds",
        "staging.stg_provider_events",
        "staging.stg_provider_team_stats",
        "staging.stg_provider_player_stats",
    ]

    write_line(lines, "=== UNIFIED STAGING TABLES ===")
    write_line(lines)

    for table_name in unified_tables:
        try:
            cnt = table_count(conn, table_name)
            write_line(lines, f"[OK] {table_name} | rows={cnt}")
        except Exception as e:
            conn.rollback()
            write_line(lines, f"[MISSING/ERROR] {table_name} | {e}")

    write_line(lines)


def inspect_samples(conn, tables_with_rows, lines, max_tables=4):
    write_line(lines, "=== SAMPLE ROWS FROM LEGACY TABLES ===")
    write_line(lines)

    shown = 0

    for table_name, cnt in tables_with_rows:
        if cnt <= 0:
            continue

        if shown >= max_tables:
            write_line(lines, "... dalsi tabulky preskoceny kvuli velikosti vypisu ...")
            write_line(lines)
            break

        write_line(lines, f"[SAMPLE] {table_name}")
        rows = sample_rows(conn, table_name, limit=2)

        for i, row in enumerate(rows, start=1):
            write_line(lines, f"  Row {i}:")
            for k, v in row.items():
                value = str(v)
                if len(value) > 300:
                    value = value[:300] + " ...[zkraceno]"
                write_line(lines, f"    {k} = {value}")
        write_line(lines)

        shown += 1


def save_report(lines):
    OUTPUT_FILE.write_text("\n".join(lines), encoding="utf-8")


def main():
    conn = get_conn()
    lines = []

    try:
        legacy = inspect_legacy_tables(conn, lines)
        inspect_unified_tables(conn, lines)
        inspect_samples(conn, legacy, lines, max_tables=4)

        write_line(lines, "=== SUMMARY ===")
        write_line(lines, "Bridge inspection finished.")
        write_line(lines, "Dalsi krok bude mapovani legacy tabulek do unified staging.")

        save_report(lines)

        print(f"Report ulozen do: {OUTPUT_FILE}")

    finally:
        conn.close()


if __name__ == "__main__":
    main()