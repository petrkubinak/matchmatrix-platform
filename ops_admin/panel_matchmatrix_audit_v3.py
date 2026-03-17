#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MatchMatrix Audit Panel V3
Autor: OpenAI
Popis:
- GUI panel pro audit projektu MatchMatrix
- File audit
- Dump audit
- Scripts audit
- PostgreSQL DB audit
- Git audit + připomenutí GitHub
- Výstupy ukládá do složek podle data a času spuštění

Doporučené umístění:
C:\MatchMatrix-platform\ops_admin\panel_matchmatrix_audit_v3.py
"""

import csv
import hashlib
import json
import os
import shutil
import socket
import subprocess
import sys
import traceback
from collections import defaultdict
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
import tkinter as tk
from tkinter import ttk, messagebox

# -----------------------------
# KONFIGURACE
# -----------------------------
PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
REPORTS_ROOT = PROJECT_ROOT / "reports" / "audit"

AUDIT_TARGETS = {
    "project_root": PROJECT_ROOT,
    "workers": PROJECT_ROOT / "workers",
    "ingest": PROJECT_ROOT / "ingest",
    "api_football": PROJECT_ROOT / "ingest" / "API-Football",
    "scripts": PROJECT_ROOT / "MatchMatrix-platform" / "Scripts",
    "dump": PROJECT_ROOT / "MatchMatrix-platform" / "Dump",
}

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

WATCH_EXTENSIONS = {
    ".py", ".ps1", ".sql", ".md", ".json", ".yml", ".yaml", ".txt",
    ".csv", ".psm1", ".bat", ".cmd", ".psd1", ".log"
}

IGNORE_DIR_NAMES = {
    ".git", "__pycache__", ".venv", "node_modules"
}

IGNORE_RELATIVE_PREFIXES = [
    r"reports\\audit",
]

# Pokud budeš chtít rozšířit kontroly DB, přidej sem další tabulky
DB_TABLES_TO_COUNT = [
    ("public", "sports"),
    ("public", "leagues"),
    ("public", "teams"),
    ("public", "matches"),
    ("public", "players"),
    ("public", "odds"),
    ("staging", "players_import"),
    ("staging", "stg_provider_players"),
]

OPS_TABLES_TO_COUNT = [
    ("ops", "ingest_targets"),
    ("ops", "league_import_plan"),
    ("ops", "jobs"),
    ("ops", "job_runs"),
]

PIPELINE_TABLES_TO_COUNT = [
    ("staging", "players_import"),
    ("staging", "stg_provider_players"),
    ("public", "players"),
]

# -----------------------------
# DATOVÉ TYPY
# -----------------------------
@dataclass
class FileRecord:
    category: str
    root_path: str
    relative_path: str
    full_path: str
    extension: str
    size_bytes: int
    created_at: str
    modified_at: str
    sha1_head: str

# -----------------------------
# POMOCNÉ FUNKCE
# -----------------------------
def now_ts():
    return datetime.now()

def fmt_dt(dt: datetime) -> str:
    return dt.strftime("%Y-%m-%d %H:%M:%S")

def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)

def safe_relpath(full: Path, root: Path) -> str:
    try:
        return str(full.relative_to(root))
    except Exception:
        return str(full)

def file_sha1_head(path: Path, limit: int = 65536) -> str:
    try:
        h = hashlib.sha1()
        with open(path, "rb") as f:
            h.update(f.read(limit))
        return h.hexdigest()
    except Exception:
        return ""

def dt_from_epoch(ts_value: float) -> str:
    try:
        return datetime.fromtimestamp(ts_value).strftime("%Y-%m-%d %H:%M:%S")
    except Exception:
        return ""

def run_cmd(cmd, cwd=None):
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            shell=False,
        )
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except FileNotFoundError:
        return 999, "", "Command not found"
    except Exception as e:
        return 998, "", str(e)

def write_csv(path: Path, rows, fieldnames):
    with open(path, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow(row)

def write_json(path: Path, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def copy_if_exists(src: Path, dst: Path):
    if src.exists():
        shutil.copy2(src, dst)

# -----------------------------
# FILE AUDIT
# -----------------------------
def scan_files(selected_categories):
    records = []
    missing_roots = []

    for category in selected_categories:
        root = AUDIT_TARGETS.get(category)
        if not root:
            continue
        if not root.exists():
            missing_roots.append((category, str(root)))
            continue

        for dirpath, dirnames, filenames in os.walk(root):
            dirp = Path(dirpath)

            # vyřadíme technické složky a audit reporty, aby se audit "nehádal" sám se sebou
            dirnames[:] = [
                d for d in dirnames
                if d not in IGNORE_DIR_NAMES
                and not any(
                    str((dirp / d)).lower().startswith(str((root / rel)).lower())
                    for rel in IGNORE_RELATIVE_PREFIXES
                )
            ]

            for name in filenames:
                full = dirp / name
                ext = full.suffix.lower()
                try:
                    stat = full.stat()
                    record = FileRecord(
                        category=category,
                        root_path=str(root),
                        relative_path=safe_relpath(full, root),
                        full_path=str(full),
                        extension=ext,
                        size_bytes=int(stat.st_size),
                        created_at=dt_from_epoch(stat.st_ctime),
                        modified_at=dt_from_epoch(stat.st_mtime),
                        sha1_head=file_sha1_head(full) if ext in WATCH_EXTENSIONS else "",
                    )
                    records.append(record)
                except Exception:
                    # záznam chyby necháváme jen do logu panelu
                    pass
    return records, missing_roots

def compare_snapshots(old_records, new_records):
    old_map = {r["category"] + "|" + r["relative_path"]: r for r in old_records}
    new_map = {r["category"] + "|" + r["relative_path"]: r for r in new_records}

    changes = []

    for key, newr in new_map.items():
        if key not in old_map:
            changes.append({
                "change_type": "NEW",
                "category": newr["category"],
                "relative_path": newr["relative_path"],
                "old_modified_at": "",
                "new_modified_at": newr["modified_at"],
                "old_size_bytes": "",
                "new_size_bytes": newr["size_bytes"],
            })
        else:
            oldr = old_map[key]
            modified = (
                str(oldr.get("modified_at", "")) != str(newr.get("modified_at", "")) or
                str(oldr.get("size_bytes", "")) != str(newr.get("size_bytes", "")) or
                str(oldr.get("sha1_head", "")) != str(newr.get("sha1_head", ""))
            )
            if modified:
                changes.append({
                    "change_type": "MODIFIED",
                    "category": newr["category"],
                    "relative_path": newr["relative_path"],
                    "old_modified_at": oldr.get("modified_at", ""),
                    "new_modified_at": newr.get("modified_at", ""),
                    "old_size_bytes": oldr.get("size_bytes", ""),
                    "new_size_bytes": newr.get("size_bytes", ""),
                })

    for key, oldr in old_map.items():
        if key not in new_map:
            changes.append({
                "change_type": "DELETED",
                "category": oldr["category"],
                "relative_path": oldr["relative_path"],
                "old_modified_at": oldr.get("modified_at", ""),
                "new_modified_at": "",
                "old_size_bytes": oldr.get("size_bytes", ""),
                "new_size_bytes": "",
            })

    changes.sort(key=lambda x: (x["change_type"], x["category"], x["relative_path"]))
    return changes

def summarize_files(records):
    by_category = defaultdict(lambda: {"files": 0, "bytes": 0})
    for r in records:
        by_category[r["category"]]["files"] += 1
        by_category[r["category"]]["bytes"] += int(r["size_bytes"])
    return by_category

# -----------------------------
# GIT AUDIT
# -----------------------------
def git_audit(project_root: Path):
    result = {
        "available": False,
        "repo_detected": False,
        "branch": "",
        "last_commit_hash": "",
        "last_commit_date": "",
        "last_commit_message": "",
        "status_porcelain": [],
        "modified_count": 0,
        "untracked_count": 0,
        "ahead_behind": "",
        "warning": "",
    }

    rc, out, err = run_cmd(["git", "--version"], cwd=str(project_root))
    if rc != 0:
        result["warning"] = "Git není dostupný v PATH."
        return result

    result["available"] = True

    rc, out, err = run_cmd(["git", "rev-parse", "--is-inside-work-tree"], cwd=str(project_root))
    if rc != 0 or out.lower() != "true":
        result["warning"] = "V PROJECT_ROOT nebyl nalezen Git repozitář."
        return result

    result["repo_detected"] = True

    rc, out, err = run_cmd(["git", "branch", "--show-current"], cwd=str(project_root))
    if rc == 0:
        result["branch"] = out.strip()

    rc, out, err = run_cmd(["git", "log", "-1", "--pretty=format:%H|%cd|%s", "--date=format:%Y-%m-%d %H:%M:%S"], cwd=str(project_root))
    if rc == 0 and "|" in out:
        parts = out.split("|", 2)
        result["last_commit_hash"] = parts[0]
        result["last_commit_date"] = parts[1]
        result["last_commit_message"] = parts[2]

    rc, out, err = run_cmd(["git", "status", "--porcelain"], cwd=str(project_root))
    if rc == 0:
        lines = [line for line in out.splitlines() if line.strip()]
        result["status_porcelain"] = lines
        result["modified_count"] = sum(1 for line in lines if not line.startswith("??"))
        result["untracked_count"] = sum(1 for line in lines if line.startswith("??"))

    rc, out, err = run_cmd(["git", "status", "-sb"], cwd=str(project_root))
    if rc == 0:
        first_line = out.splitlines()[0] if out.splitlines() else ""
        result["ahead_behind"] = first_line

    if result["modified_count"] or result["untracked_count"]:
        result["warning"] = "V projektu jsou změny, které ještě nejsou uložené do Git/GitHub."

    return result

# -----------------------------
# DB AUDIT
# -----------------------------
def db_audit():
    result = {
        "available": False,
        "connection_ok": False,
        "error": "",
        "schema_tables": [],
        "row_counts": [],
        "ops_counts": [],
        "pipeline_counts": [],
    }

    try:
        import psycopg2
    except Exception:
        result["error"] = "Není nainstalován psycopg2. Nainstaluj: pip install psycopg2-binary"
        return result

    result["available"] = True

    try:
        conn = psycopg2.connect(
            host=DB_CONFIG["host"],
            port=DB_CONFIG["port"],
            dbname=DB_CONFIG["dbname"],
            user=DB_CONFIG["user"],
            password=DB_CONFIG["password"],
        )
        conn.autocommit = True
        cur = conn.cursor()
        result["connection_ok"] = True

        cur.execute("""
            SELECT table_schema, COUNT(*) AS tables_count
            FROM information_schema.tables
            WHERE table_type='BASE TABLE'
              AND table_schema IN ('public','staging','ops','work')
            GROUP BY table_schema
            ORDER BY table_schema;
        """)
        result["schema_tables"] = [
            {"table_schema": row[0], "tables_count": row[1]}
            for row in cur.fetchall()
        ]

        for schema, table in DB_TABLES_TO_COUNT:
            try:
                cur.execute(f'SELECT COUNT(*) FROM "{schema}"."{table}";')
                cnt = cur.fetchone()[0]
                result["row_counts"].append({"schema": schema, "table_name": table, "row_count": cnt})
            except Exception as e:
                result["row_counts"].append({"schema": schema, "table_name": table, "row_count": f"ERR: {e}"})

        for schema, table in OPS_TABLES_TO_COUNT:
            try:
                cur.execute(f'SELECT COUNT(*) FROM "{schema}"."{table}";')
                cnt = cur.fetchone()[0]
                result["ops_counts"].append({"schema": schema, "table_name": table, "row_count": cnt})
            except Exception as e:
                result["ops_counts"].append({"schema": schema, "table_name": table, "row_count": f"ERR: {e}"})

        for schema, table in PIPELINE_TABLES_TO_COUNT:
            try:
                cur.execute(f'SELECT COUNT(*) FROM "{schema}"."{table}";')
                cnt = cur.fetchone()[0]
                result["pipeline_counts"].append({"schema": schema, "table_name": table, "row_count": cnt})
            except Exception as e:
                result["pipeline_counts"].append({"schema": schema, "table_name": table, "row_count": f"ERR: {e}"})

        cur.close()
        conn.close()
        return result
    except Exception as e:
        result["error"] = str(e)
        return result

# -----------------------------
# SNAPSHOT EXPORT
# -----------------------------
def export_project_snapshot(run_dir: Path):
    snapshot_dir = run_dir / "project_snapshot"
    ensure_dir(snapshot_dir)

    exported = []
    for key in ["workers", "scripts"]:
        src = AUDIT_TARGETS.get(key)
        if src and src.exists():
            dst = snapshot_dir / key
            if dst.exists():
                shutil.rmtree(dst)
            shutil.copytree(src, dst)
            exported.append(str(dst))

    zip_base = run_dir / f"MatchMatrix_Snapshot_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}"
    zip_path = shutil.make_archive(str(zip_base), "zip", root_dir=str(snapshot_dir))
    return zip_path, exported

# -----------------------------
# REPORT
# -----------------------------
def build_report(
    run_started: datetime,
    selected_categories,
    records,
    changes,
    missing_roots,
    git_info,
    db_info,
    export_zip_path=None,
):
    lines = []
    lines.append("# MATCHMATRIX AUDIT REPORT")
    lines.append("")
    lines.append(f"- Datum spuštění: {fmt_dt(run_started)}")
    lines.append(f"- Počítač: {socket.gethostname()}")
    lines.append(f"- Project root: `{PROJECT_ROOT}`")
    lines.append("")

    lines.append("## 1. FILE AUDIT")
    lines.append("")
    lines.append(f"- Vybrané kategorie: {', '.join(selected_categories) if selected_categories else 'žádné'}")
    lines.append(f"- Počet nalezených souborů: {len(records)}")
    lines.append(f"- Počet změn oproti minulému běhu: {len(changes)}")
    lines.append("")

    if missing_roots:
        lines.append("### Chybějící cesty")
        lines.append("")
        for cat, path in missing_roots:
            lines.append(f"- {cat}: `{path}`")
        lines.append("")

    summary = summarize_files(records)
    if summary:
        lines.append("### Souhrn dle kategorií")
        lines.append("")
        lines.append("| Kategorie | Soubory | Velikost (bytes) |")
        lines.append("|---|---:|---:|")
        for cat in sorted(summary.keys()):
            lines.append(f"| {cat} | {summary[cat]['files']} | {summary[cat]['bytes']} |")
        lines.append("")

    if changes:
        lines.append("### Změny oproti minulému běhu")
        lines.append("")
        lines.append("| Typ | Kategorie | Soubor | Stará změna | Nová změna |")
        lines.append("|---|---|---|---|---|")
        for c in changes[:300]:
            lines.append(f"| {c['change_type']} | {c['category']} | `{c['relative_path']}` | {c['old_modified_at']} | {c['new_modified_at']} |")
        if len(changes) > 300:
            lines.append("")
            lines.append(f"_V reportu je zobrazeno prvních 300 změn z celkových {len(changes)}._")
        lines.append("")
    else:
        lines.append("### Změny oproti minulému běhu")
        lines.append("")
        lines.append("- Nebyly zjištěny žádné změny.")
        lines.append("")

    lines.append("## 2. GIT / GITHUB AUDIT")
    lines.append("")
    if not git_info["available"]:
        lines.append(f"- Stav: Git není dostupný")
        lines.append(f"- Poznámka: {git_info['warning']}")
        lines.append("")
    elif not git_info["repo_detected"]:
        lines.append(f"- Stav: repozitář nenalezen")
        lines.append(f"- Poznámka: {git_info['warning']}")
        lines.append("")
    else:
        lines.append(f"- Branch: `{git_info['branch']}`")
        lines.append(f"- Last commit hash: `{git_info['last_commit_hash']}`")
        lines.append(f"- Last commit date: {git_info['last_commit_date']}")
        lines.append(f"- Last commit message: {git_info['last_commit_message']}")
        lines.append(f"- Git status summary: `{git_info['ahead_behind']}`")
        lines.append(f"- Modified files: {git_info['modified_count']}")
        lines.append(f"- Untracked files: {git_info['untracked_count']}")
        if git_info["warning"]:
            lines.append(f"- WARNING: **{git_info['warning']}**")
        lines.append("")

        if git_info["status_porcelain"]:
            lines.append("### Git status detail")
            lines.append("")
            lines.append("```text")
            for line in git_info["status_porcelain"][:200]:
                lines.append(line)
            if len(git_info["status_porcelain"]) > 200:
                lines.append(f"... truncated, total lines: {len(git_info['status_porcelain'])}")
            lines.append("```")
            lines.append("")

    lines.append("## 3. DATABASE AUDIT")
    lines.append("")
    if not db_info["available"]:
        lines.append(f"- Stav: DB audit není dostupný")
        lines.append(f"- Důvod: {db_info['error']}")
        lines.append("")
    elif not db_info["connection_ok"]:
        lines.append(f"- Stav: Připojení k DB selhalo")
        lines.append(f"- Důvod: {db_info['error']}")
        lines.append("")
    else:
        lines.append("- Stav: připojení k DB je v pořádku")
        lines.append("")

        if db_info["schema_tables"]:
            lines.append("### Schéma overview")
            lines.append("")
            lines.append("| Schema | Počet tabulek |")
            lines.append("|---|---:|")
            for r in db_info["schema_tables"]:
                lines.append(f"| {r['table_schema']} | {r['tables_count']} |")
            lines.append("")

        if db_info["row_counts"]:
            lines.append("### Základní row counts")
            lines.append("")
            lines.append("| Schema | Tabulka | Rows |")
            lines.append("|---|---|---:|")
            for r in db_info["row_counts"]:
                lines.append(f"| {r['schema']} | {r['table_name']} | {r['row_count']} |")
            lines.append("")

        if db_info["ops_counts"]:
            lines.append("### OPS status")
            lines.append("")
            lines.append("| Schema | Tabulka | Rows |")
            lines.append("|---|---|---:|")
            for r in db_info["ops_counts"]:
                lines.append(f"| {r['schema']} | {r['table_name']} | {r['row_count']} |")
            lines.append("")

        if db_info["pipeline_counts"]:
            lines.append("### Player pipeline status")
            lines.append("")
            lines.append("| Schema | Tabulka | Rows |")
            lines.append("|---|---|---:|")
            for r in db_info["pipeline_counts"]:
                lines.append(f"| {r['schema']} | {r['table_name']} | {r['row_count']} |")
            lines.append("")

    lines.append("## 4. DUMP / SCRIPTS NOTE")
    lines.append("")
    lines.append("- Dump audit je součást file auditu přes kategorii `dump`.")
    lines.append("- Scripts audit je součást file auditu přes kategorii `scripts`.")
    lines.append("")

    if export_zip_path:
        lines.append("## 5. PROJECT SNAPSHOT EXPORT")
        lines.append("")
        lines.append(f"- Export ZIP: `{export_zip_path}`")
        lines.append("")

    lines.append("## 6. DOPORUČENÍ PŘED UKONČENÍM PRÁCE")
    lines.append("")
    lines.append("- [ ] zkontrolovat změny ve workers / ingest / scripts")
    lines.append("- [ ] uložit SQL skripty")
    lines.append("- [ ] uložit Python workery")
    lines.append("- [ ] provést `git add .`")
    lines.append("- [ ] provést `git commit -m \"...\"`")
    lines.append("- [ ] provést `git push`")
    lines.append("- [ ] ověřit, že důležité změny jsou uložené i na GitHub")
    lines.append("")

    return "\n".join(lines)

# -----------------------------
# BĚH AUDITU
# -----------------------------
def perform_audit(selected_categories, do_db=True, do_git=True, do_export_snapshot=False, log_fn=None):
    run_started = now_ts()
    date_dir = REPORTS_ROOT / run_started.strftime("%Y-%m-%d")
    run_dir = date_dir / run_started.strftime("%H-%M-%S")
    ensure_dir(run_dir)
    ensure_dir(REPORTS_ROOT)

    def log(msg):
        if log_fn:
            log_fn(msg)

    log("Spouštím file audit...")
    records_dc, missing_roots = scan_files(selected_categories)
    records = [asdict(r) for r in records_dc]

    latest_snapshot = REPORTS_ROOT / "latest_snapshot.json"
    old_records = []
    if latest_snapshot.exists():
        try:
            old_records = json.loads(latest_snapshot.read_text(encoding="utf-8"))
        except Exception:
            old_records = []

    changes = compare_snapshots(old_records, records)

    files_csv = run_dir / "files.csv"
    changes_csv = run_dir / "changes.csv"
    snapshot_json = run_dir / "snapshot.json"

    write_csv(files_csv, records, [
        "category", "root_path", "relative_path", "full_path",
        "extension", "size_bytes", "created_at", "modified_at", "sha1_head"
    ])
    write_csv(changes_csv, changes, [
        "change_type", "category", "relative_path",
        "old_modified_at", "new_modified_at", "old_size_bytes", "new_size_bytes"
    ])
    write_json(snapshot_json, records)

    git_info = {
        "available": False, "repo_detected": False, "warning": "Git audit nebyl spuštěn.",
        "branch": "", "last_commit_hash": "", "last_commit_date": "", "last_commit_message": "",
        "status_porcelain": [], "modified_count": 0, "untracked_count": 0, "ahead_behind": ""
    }
    if do_git:
        log("Spouštím Git audit...")
        git_info = git_audit(PROJECT_ROOT)

    db_info = {
        "available": False, "connection_ok": False, "error": "DB audit nebyl spuštěn.",
        "schema_tables": [], "row_counts": [], "ops_counts": [], "pipeline_counts": []
    }
    if do_db:
        log("Spouštím DB audit...")
        db_info = db_audit()

    export_zip_path = None
    if do_export_snapshot:
        log("Vytvářím ZIP snapshot projektu...")
        try:
            export_zip_path, exported = export_project_snapshot(run_dir)
        except Exception as e:
            export_zip_path = f"ERR: {e}"

    report_text = build_report(
        run_started=run_started,
        selected_categories=selected_categories,
        records=records,
        changes=changes,
        missing_roots=missing_roots,
        git_info=git_info,
        db_info=db_info,
        export_zip_path=export_zip_path,
    )

    report_md = run_dir / "MATCHMATRIX_AUDIT_REPORT.md"
    report_md.write_text(report_text, encoding="utf-8")

    latest_report = REPORTS_ROOT / "latest_report.md"
    latest_files = REPORTS_ROOT / "latest_files.csv"
    latest_changes = REPORTS_ROOT / "latest_changes.csv"
    latest_snapshot_out = REPORTS_ROOT / "latest_snapshot.json"

    copy_if_exists(report_md, latest_report)
    copy_if_exists(files_csv, latest_files)
    copy_if_exists(changes_csv, latest_changes)
    copy_if_exists(snapshot_json, latest_snapshot_out)

    meta = {
        "run_started": fmt_dt(run_started),
        "selected_categories": selected_categories,
        "records_count": len(records),
        "changes_count": len(changes),
        "run_dir": str(run_dir),
        "report_md": str(report_md),
        "files_csv": str(files_csv),
        "changes_csv": str(changes_csv),
        "snapshot_json": str(snapshot_json),
        "latest_report": str(latest_report),
        "latest_files": str(latest_files),
        "latest_changes": str(latest_changes),
        "latest_snapshot": str(latest_snapshot_out),
    }
    write_json(run_dir / "run_meta.json", meta)

    log("Audit dokončen.")
    return meta

# -----------------------------
# GUI
# -----------------------------
class AuditPanel(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("MatchMatrix OPS Audit Panel V3 V2")
        self.geometry("980x760")
        self.minsize(900, 700)

        self.vars = {
            "workers": tk.BooleanVar(value=True),
            "ingest": tk.BooleanVar(value=True),
            "api_football": tk.BooleanVar(value=True),
            "scripts": tk.BooleanVar(value=True),
            "dump": tk.BooleanVar(value=True),
            "db_audit": tk.BooleanVar(value=True),
            "git_audit": tk.BooleanVar(value=True),
            "export_snapshot": tk.BooleanVar(value=False),
        }

        self._build_ui()

    def log(self, msg):
        ts = datetime.now().strftime("%H:%M:%S")
        self.txt_log.insert("end", f"[{ts}] {msg}\n")
        self.txt_log.see("end")
        self.update_idletasks()

    def _build_ui(self):
        top = ttk.Frame(self, padding=10)
        top.pack(fill="both", expand=True)

        title = ttk.Label(top, text="MATCHMATRIX OPS AUDIT PANEL V2", font=("Segoe UI", 16, "bold"))
        title.pack(anchor="w", pady=(0, 10))

        path_info = ttk.Label(
            top,
            text=f"Project root: {PROJECT_ROOT}\nReports root: {REPORTS_ROOT}",
            justify="left"
        )
        path_info.pack(anchor="w", pady=(0, 10))

        frm_checks = ttk.LabelFrame(top, text="FILE AUDIT", padding=10)
        frm_checks.pack(fill="x", pady=5)

        check_items = [
            ("workers", "Workers"),
            ("ingest", "Ingest"),
            ("api_football", "API-Football"),
            ("scripts", "Scripts"),
            ("dump", "Dump"),
        ]
        for i, (key, label) in enumerate(check_items):
            ttk.Checkbutton(frm_checks, text=label, variable=self.vars[key]).grid(row=0, column=i, sticky="w", padx=8, pady=4)

        frm_add = ttk.LabelFrame(top, text="DALŠÍ KONTROLY", padding=10)
        frm_add.pack(fill="x", pady=5)

        ttk.Checkbutton(frm_add, text="DB audit", variable=self.vars["db_audit"]).grid(row=0, column=0, sticky="w", padx=8, pady=4)
        ttk.Checkbutton(frm_add, text="Git audit + GitHub reminder", variable=self.vars["git_audit"]).grid(row=0, column=1, sticky="w", padx=8, pady=4)
        ttk.Checkbutton(frm_add, text="Export project snapshot ZIP", variable=self.vars["export_snapshot"]).grid(row=0, column=2, sticky="w", padx=8, pady=4)

        frm_buttons = ttk.LabelFrame(top, text="AKCE", padding=10)
        frm_buttons.pack(fill="x", pady=5)

        ttk.Button(frm_buttons, text="Spustit audit vybraných kontrol", command=self.run_selected).grid(row=0, column=0, padx=6, pady=4, sticky="w")
        ttk.Button(frm_buttons, text="Spustit FULL audit", command=self.run_full).grid(row=0, column=1, padx=6, pady=4, sticky="w")
        ttk.Button(frm_buttons, text="Otevřít latest report", command=self.open_latest_report).grid(row=0, column=2, padx=6, pady=4, sticky="w")
        ttk.Button(frm_buttons, text="Otevřít audit složku", command=self.open_reports_folder).grid(row=0, column=3, padx=6, pady=4, sticky="w")
        ttk.Button(frm_buttons, text="Vyčistit log", command=self.clear_log).grid(row=0, column=4, padx=6, pady=4, sticky="w")

        frm_log = ttk.LabelFrame(top, text="LOG", padding=10)
        frm_log.pack(fill="both", expand=True, pady=5)

        self.txt_log = tk.Text(frm_log, wrap="word", height=24)
        self.txt_log.pack(fill="both", expand=True)

        self.log("Panel připraven.")
        self.log("Doporučení: po důležitých změnách nezapomenout na Git commit a push.")

    def selected_categories(self):
        return [k for k in ["workers", "ingest", "api_football", "scripts", "dump"] if self.vars[k].get()]

    def run_selected(self):
        cats = self.selected_categories()
        if not cats:
            messagebox.showwarning("MatchMatrix Audit", "Vyber alespoň jednu FILE AUDIT kategorii.")
            return
        self._run(cats)

    def run_full(self):
        cats = ["workers", "ingest", "api_football", "scripts", "dump"]
        for c in cats:
            self.vars[c].set(True)
        self.vars["db_audit"].set(True)
        self.vars["git_audit"].set(True)
        self._run(cats)

    def _run(self, cats):
        try:
            self.log("--------------------------------------------------")
            self.log("Spouštím audit...")
            meta = perform_audit(
                selected_categories=cats,
                do_db=self.vars["db_audit"].get(),
                do_git=self.vars["git_audit"].get(),
                do_export_snapshot=self.vars["export_snapshot"].get(),
                log_fn=self.log,
            )
            self.log(f"Report: {meta['report_md']}")
            self.log(f"Složka běhu: {meta['run_dir']}")
            self.log("Hotovo.")
            messagebox.showinfo(
                "MatchMatrix Audit",
                f"Audit dokončen.\n\nReport:\n{meta['report_md']}\n\nSložka běhu:\n{meta['run_dir']}"
            )
        except Exception as e:
            self.log("CHYBA:")
            self.log(str(e))
            self.log(traceback.format_exc())
            messagebox.showerror("MatchMatrix Audit - chyba", f"{e}")

    def open_latest_report(self):
        path = REPORTS_ROOT / "latest_report.md"
        if not path.exists():
            messagebox.showwarning("MatchMatrix Audit", f"Soubor neexistuje:\n{path}")
            return
        os.startfile(str(path))

    def open_reports_folder(self):
        ensure_dir(REPORTS_ROOT)
        os.startfile(str(REPORTS_ROOT))

    def clear_log(self):
        self.txt_log.delete("1.0", "end")

def main():
    ensure_dir(REPORTS_ROOT)
    app = AuditPanel()
    app.mainloop()

if __name__ == "__main__":
    main()
