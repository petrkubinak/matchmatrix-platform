
import csv
import datetime as dt
import json
import os
from pathlib import Path
import subprocess
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox

PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
REPORT_ROOT = PROJECT_ROOT / "reports" / "audit"

WATCH_EXT = {".py",".ps1",".sql",".md",".json",".yml",".yaml",".txt",".csv",".bat",".cmd",".psm1",".psd1"}
IGNORE_DIRS = {".git","__pycache__",".venv","node_modules",".idea",".vs","dist","build"}
IGNORE_PREFIXES = [
    str((PROJECT_ROOT / "reports" / "audit")).lower(),
]

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

FILE_TARGETS = {
    "Celý projekt": PROJECT_ROOT,
    "Workers": PROJECT_ROOT / "workers",
    "Ingest": PROJECT_ROOT / "ingest",
    "API-Football": PROJECT_ROOT / "ingest" / "API-Football",
    "Scripts": PROJECT_ROOT / "MatchMatrix-platform" / "Scripts",
    "Dump": PROJECT_ROOT / "MatchMatrix-platform" / "Dump",
    "DB": PROJECT_ROOT / "db",
    "Docs": PROJECT_ROOT / "docs",
}

def now_str():
    return dt.datetime.now().strftime("%H:%M:%S")

def safe_mkdir(path: Path):
    path.mkdir(parents=True, exist_ok=True)

def should_skip_dir(path_str: str) -> bool:
    low = path_str.lower()
    return any(low.startswith(prefix) for prefix in IGNORE_PREFIXES)

def scan_files(root: Path):
    rows = []
    if not root.exists():
        return rows
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS]
        if should_skip_dir(dirpath):
            dirnames[:] = []
            continue
        for f in filenames:
            p = Path(dirpath) / f
            if p.suffix.lower() not in WATCH_EXT:
                continue
            try:
                st = p.stat()
                rows.append({
                    "path": str(p),
                    "relative_path": str(p.relative_to(PROJECT_ROOT)) if PROJECT_ROOT in p.parents or p == PROJECT_ROOT else str(p),
                    "size_bytes": st.st_size,
                    "modified_at": dt.datetime.fromtimestamp(st.st_mtime).strftime("%Y-%m-%d %H:%M:%S"),
                    "created_at": dt.datetime.fromtimestamp(st.st_ctime).strftime("%Y-%m-%d %H:%M:%S"),
                    "mtime_epoch": round(st.st_mtime, 3),
                })
            except Exception:
                pass
    rows.sort(key=lambda x: x["relative_path"].lower())
    return rows

def dict_by_path(rows):
    return {r["relative_path"]: r for r in rows}

def compare_snapshots(old_rows, new_rows):
    old_map = dict_by_path(old_rows)
    new_map = dict_by_path(new_rows)
    changes = []

    for rel, row in new_map.items():
        if rel not in old_map:
            changes.append({"change_type": "NEW", **row})
        else:
            old = old_map[rel]
            if old["mtime_epoch"] != row["mtime_epoch"] or old["size_bytes"] != row["size_bytes"]:
                changes.append({"change_type": "MODIFIED", **row})

    for rel, row in old_map.items():
        if rel not in new_map:
            changes.append({
                "change_type": "DELETED",
                "path": row["path"],
                "relative_path": rel,
                "size_bytes": row["size_bytes"],
                "modified_at": row["modified_at"],
                "created_at": row["created_at"],
                "mtime_epoch": row["mtime_epoch"],
            })
    changes.sort(key=lambda x: (x["change_type"], x["relative_path"].lower()))
    return changes

def run_git_command(args):
    try:
        result = subprocess.check_output(args, cwd=PROJECT_ROOT, shell=True, stderr=subprocess.STDOUT)
        return result.decode("utf-8", errors="replace").strip()
    except subprocess.CalledProcessError as e:
        return e.output.decode("utf-8", errors="replace").strip()
    except Exception as e:
        return f"ERROR: {e}"

def get_git_status():
    branch = run_git_command("git rev-parse --abbrev-ref HEAD")
    last_commit = run_git_command('git log -1 --pretty=format:"%h | %ad | %s" --date=iso')
    short_status = run_git_command("git status --short")
    return {
        "branch": branch,
        "last_commit": last_commit,
        "short_status": short_status if short_status else "Čisté, bez neuložených změn.",
    }

def try_db_query(sql):
    try:
        import psycopg2
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute(sql)
        rows = cur.fetchall()
        cur.close()
        conn.close()
        return rows, None
    except Exception as e:
        return None, str(e)

def get_db_status():
    status = {
        "ok": False,
        "error": None,
        "core_counts": [],
        "ops_counts": [],
        "player_counts": [],
        "recent_jobs": [],
        "planner_status": [],
        "budget_status": [],
    }

    core_sql = """
    select 'leagues' as name, count(*)::bigint from public.leagues
    union all select 'teams', count(*)::bigint from public.teams
    union all select 'matches', count(*)::bigint from public.matches
    union all select 'players', count(*)::bigint from public.players
    order by 1;
    """
    ops_sql = """
    select 'ingest_planner' as name, count(*)::bigint from ops.ingest_planner
    union all select 'scheduler_queue', count(*)::bigint from ops.scheduler_queue
    union all select 'provider_jobs', count(*)::bigint from ops.provider_jobs
    union all select 'job_runs', count(*)::bigint from ops.job_runs
    order by 1;
    """
    player_sql = """
    select 'players_import' as name, count(*)::bigint from staging.players_import
    union all select 'stg_provider_players', count(*)::bigint from staging.stg_provider_players
    union all select 'public_players', count(*)::bigint from public.players
    union all select 'player_match_statistics', count(*)::bigint from public.player_match_statistics
    order by 1;
    """
    recent_jobs_sql = """
    select coalesce(job_code,'?') as job_code,
           coalesce(status,'?') as status,
           to_char(started_at, 'YYYY-MM-DD HH24:MI:SS') as started_at
    from ops.job_runs
    order by started_at desc
    limit 10;
    """
    planner_status_sql = """
    select coalesce(entity,'?') as entity,
           coalesce(status,'?') as status,
           count(*)::bigint as cnt
    from ops.ingest_planner
    group by entity, status
    order by entity, status;
    """
    budget_sql = """
    select coalesce(provider,'?') as provider,
           coalesce(sport_code,'?') as sport_code,
           requests_used,
           requests_limit,
           requests_remaining
    from ops.api_budget_status
    order by provider, sport_code;
    """

    for key, sql in [
        ("core_counts", core_sql),
        ("ops_counts", ops_sql),
        ("player_counts", player_sql),
        ("recent_jobs", recent_jobs_sql),
        ("planner_status", planner_status_sql),
        ("budget_status", budget_sql),
    ]:
        rows, err = try_db_query(sql)
        if err:
            status["error"] = err
            return status
        status[key] = rows

    status["ok"] = True
    return status

def save_csv(path: Path, rows, fieldnames):
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({k: row.get(k, "") for k in fieldnames})

def load_previous_snapshot(latest_snapshot: Path):
    if not latest_snapshot.exists():
        return []
    try:
        return json.loads(latest_snapshot.read_text(encoding="utf-8"))
    except Exception:
        return []

def make_plain_list(rows, bullet="- "):
    if not rows:
        return f"{bullet}bez záznamu"
    return "\n".join(f"{bullet}{r}" for r in rows)

def build_progress_text(summary, db_status, git_status, selected_targets):
    today = dt.datetime.now().strftime("%d.%m.%Y")
    time_txt = dt.datetime.now().strftime("%H:%M")
    new_count = summary["new"]
    mod_count = summary["modified"]
    del_count = summary["deleted"]
    total = summary["total_files"]

    file_comment = []
    if new_count:
        file_comment.append(f"bylo přidáno {new_count} nových souborů")
    if mod_count:
        file_comment.append(f"u {mod_count} souborů proběhla úprava")
    if del_count:
        file_comment.append(f"{del_count} souborů bylo odstraněno")
    if not file_comment:
        file_comment.append("nebyly zjištěny žádné změny proti minulému auditu")

    core_map = {name: cnt for name, cnt in db_status["core_counts"]} if db_status["ok"] else {}
    player_map = {name: cnt for name, cnt in db_status["player_counts"]} if db_status["ok"] else {}

    recent_paths = [c["relative_path"] for c in summary["top_changes"][:8]]
    git_lines = git_status["short_status"].splitlines() if git_status["short_status"] else []
    git_preview = git_lines[:8]

    next_steps = []
    if db_status["ok"]:
        if player_map.get("public_players", 0) == 0:
            next_steps.append("doplnit hlavní tabulku hráčů v public vrstvě")
        else:
            next_steps.append("navázat dalším rozšířením players pipeline")
        next_steps.append("zkontrolovat poslední job_runs a případné warningy")
        next_steps.append("pokračovat ve feature engine pro týmy a hráče")
    else:
        next_steps.append("opravit připojení panelu k databázi")
        next_steps.append("po opravě znovu spustit FULL audit")
        next_steps.append("ověřit OPS tabulky a stav planneru")

    return f"""# MatchMatrix – denní přehled vývoje

Datum: {today}  
Čas kontroly systému: {time_txt}

---

## 1. Co je MatchMatrix

MatchMatrix je datová a analytická platforma pro sportovní data.
Systém sbírá data ze zdrojů, ukládá je do databáze, připravuje statistiky
a vytváří podklady pro budoucí predikce a inteligentní práci s tikety.

---

## 2. Co se dnes zkontrolovalo

Byl zkontrolován projekt v těchto částech:

{make_plain_list(selected_targets)}

Celkem bylo projito {total} sledovaných souborů.

Ve srovnání s minulým auditem:
- {file_comment[0]}
""" + ("\n".join(f"- {line}" for line in file_comment[1:]) if len(file_comment) > 1 else "") + f"""

---

## 3. Stav databáze

""" + (
f"""Databáze je dostupná a základní stav je následující:

- ligy: {core_map.get('leagues', 0)}
- týmy: {core_map.get('teams', 0)}
- zápasy: {core_map.get('matches', 0)}
- hráči: {core_map.get('players', 0)}

Player pipeline přehled:
- import hráčů: {player_map.get('players_import', 0)}
- staging hráčů: {player_map.get('stg_provider_players', 0)}
- public hráči: {player_map.get('public_players', 0)}
- statistiky hráčů na zápas: {player_map.get('player_match_statistics', 0)}
""" if db_status["ok"] else
f"""Databázový audit se nepodařilo načíst.

Důvod:
{db_status["error"]}

To znamená, že panel momentálně nevidí do PostgreSQL a je potřeba
zkontrolovat připojení nebo běh kontejneru s databází.
"""
) + f"""

---

## 4. Stav systému a repozitáře

Git větev:
- {git_status["branch"]}

Poslední commit:
- {git_status["last_commit"]}

Aktuální neuložené změny:
{make_plain_list(git_preview)}

Pokud zde vidíš změny, které mají zůstat, je dobré je po práci uložit do Git a GitHub.

---

## 5. Kam jsme se dnes posunuli

Na základě dnešního auditu je vidět, že projekt má:
- funkční kontrolu souborů
- přehled o změnách proti minulému běhu
- kontrolu Git stavu
""" + (
"""
- přímý přehled o databázi a OPS tabulkách
""" if db_status["ok"] else """
- připravený databázový audit, ale je potřeba opravit připojení
"""
) + f"""

Hlavní změněné soubory dnes:
{make_plain_list(recent_paths)}

---

## 6. V čem budeme pokračovat

Doporučené další kroky:
- {next_steps[0]}
- {next_steps[1]}
- {next_steps[2]}

---

## 7. Doporučení před ukončením práce

Nezapomenout:
- zkontrolovat změněné soubory
- uložit důležité skripty
- vytvořit Git commit
- poslat změny na GitHub

Doporučené příkazy:
git add .
git commit -m "MatchMatrix update"
git push
"""

def open_path(path: Path):
    try:
        os.startfile(path)
    except Exception as e:
        messagebox.showerror("Chyba", f"Nelze otevřít cestu:\n{path}\n\n{e}")

class MissionControlApp:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("MatchMatrix Mission Control V5")
        self.root.geometry("1180x780")
        self.root.minsize(1000, 680)

        self.target_vars = {name: tk.BooleanVar(value=(name in ["Celý projekt", "Workers", "Ingest", "API-Football", "Scripts", "Dump"])) for name in FILE_TARGETS}
        self.db_enabled = tk.BooleanVar(value=True)
        self.git_enabled = tk.BooleanVar(value=True)
        self.progress_enabled = tk.BooleanVar(value=True)

        self.last_run_dir = None
        self.last_report_path = None

        self.build_ui()
        self.log("Panel připraven.")
        self.log("Tip: FULL audit vytvoří technický report i lidsky psaný progres.")

    def build_ui(self):
        top = ttk.Frame(self.root, padding=12)
        top.pack(fill="x")

        ttk.Label(top, text="MATCHMATRIX MISSION CONTROL V5", font=("Segoe UI", 18, "bold")).pack(anchor="w")
        ttk.Label(top, text=f"Project root: {PROJECT_ROOT}").pack(anchor="w", pady=(4, 0))
        ttk.Label(top, text=f"Reports root: {REPORT_ROOT}").pack(anchor="w")

        options = ttk.LabelFrame(self.root, text="Výběr kontrol", padding=12)
        options.pack(fill="x", padx=12, pady=8)

        files_frame = ttk.LabelFrame(options, text="File audit", padding=10)
        files_frame.pack(fill="x", pady=(0,8))

        row = 0
        col = 0
        for name in FILE_TARGETS:
            ttk.Checkbutton(files_frame, text=name, variable=self.target_vars[name]).grid(row=row, column=col, sticky="w", padx=6, pady=4)
            col += 1
            if col >= 4:
                row += 1
                col = 0

        more_frame = ttk.LabelFrame(options, text="Další kontroly", padding=10)
        more_frame.pack(fill="x")

        ttk.Checkbutton(more_frame, text="DB audit", variable=self.db_enabled).grid(row=0, column=0, sticky="w", padx=6, pady=4)
        ttk.Checkbutton(more_frame, text="Git audit + GitHub reminder", variable=self.git_enabled).grid(row=0, column=1, sticky="w", padx=6, pady=4)
        ttk.Checkbutton(more_frame, text="Vytvořit lidský progress report", variable=self.progress_enabled).grid(row=0, column=2, sticky="w", padx=6, pady=4)

        actions = ttk.LabelFrame(self.root, text="Akce", padding=12)
        actions.pack(fill="x", padx=12, pady=8)

        ttk.Button(actions, text="Spustit FULL audit", command=self.run_full_audit).pack(side="left", padx=6)
        ttk.Button(actions, text="Otevřít poslední report", command=self.open_last_report).pack(side="left", padx=6)
        ttk.Button(actions, text="Otevřít audit složku", command=lambda: open_path(REPORT_ROOT)).pack(side="left", padx=6)
        ttk.Button(actions, text="Vyčistit log", command=self.clear_log).pack(side="left", padx=6)

        center = ttk.Panedwindow(self.root, orient="horizontal")
        center.pack(fill="both", expand=True, padx=12, pady=(0, 12))

        left = ttk.Frame(center)
        right = ttk.Frame(center)
        center.add(left, weight=2)
        center.add(right, weight=3)

        self.stats_text = scrolledtext.ScrolledText(left, wrap="word", font=("Consolas", 10))
        self.stats_text.pack(fill="both", expand=True)

        self.log_text = scrolledtext.ScrolledText(right, wrap="word", font=("Consolas", 10))
        self.log_text.pack(fill="both", expand=True)

    def log(self, msg):
        self.log_text.insert("end", f"[{now_str()}] {msg}\n")
        self.log_text.see("end")
        self.root.update_idletasks()

    def stats(self, msg):
        self.stats_text.insert("end", msg + "\n")
        self.stats_text.see("end")
        self.root.update_idletasks()

    def clear_log(self):
        self.log_text.delete("1.0", "end")
        self.stats_text.delete("1.0", "end")

    def open_last_report(self):
        if self.last_report_path and Path(self.last_report_path).exists():
            open_path(Path(self.last_report_path))
        else:
            messagebox.showinfo("Info", "Zatím není k dispozici žádný report.")

    def selected_targets(self):
        names = [name for name, var in self.target_vars.items() if var.get()]
        if not names:
            return ["Celý projekt"]
        return names

    def run_full_audit(self):
        self.clear_log()
        self.log("Spouštím FULL audit...")
        self.stats("=== MATCHMATRIX MISSION CONTROL V5 ===")
        self.stats(f"Čas spuštění: {dt.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        self.stats("")

        selected_names = self.selected_targets()

        safe_mkdir(REPORT_ROOT)
        run_dir = REPORT_ROOT / dt.datetime.now().strftime("%Y-%m-%d") / dt.datetime.now().strftime("%H-%M-%S")
        safe_mkdir(run_dir)
        self.last_run_dir = run_dir

        latest_snapshot_path = REPORT_ROOT / "latest_snapshot.json"

        all_rows = []
        for name in selected_names:
            path = FILE_TARGETS[name]
            self.log(f"Kontroluji: {name} -> {path}")
            rows = scan_files(path)
            self.stats(f"{name}: {len(rows)} sledovaných souborů")
            all_rows.extend(rows)

        # deduplicate when 'Celý projekt' + subfolders are selected
        unique = {}
        for row in all_rows:
            unique[row["relative_path"]] = row
        current_rows = list(unique.values())
        current_rows.sort(key=lambda x: x["relative_path"].lower())

        old_rows = load_previous_snapshot(latest_snapshot_path)
        changes = compare_snapshots(old_rows, current_rows)
        new_count = sum(1 for c in changes if c["change_type"] == "NEW")
        mod_count = sum(1 for c in changes if c["change_type"] == "MODIFIED")
        del_count = sum(1 for c in changes if c["change_type"] == "DELETED")

        self.stats("")
        self.stats(f"Celkem po deduplikaci: {len(current_rows)} souborů")
        self.stats(f"Nové: {new_count}")
        self.stats(f"Upravené: {mod_count}")
        self.stats(f"Smazané: {del_count}")
        self.stats("")

        files_csv = run_dir / "files.csv"
        changes_csv = run_dir / "changes.csv"
        snapshot_json = run_dir / "snapshot.json"

        save_csv(files_csv, current_rows, ["relative_path","path","size_bytes","created_at","modified_at","mtime_epoch"])
        save_csv(changes_csv, changes, ["change_type","relative_path","path","size_bytes","created_at","modified_at","mtime_epoch"])
        snapshot_json.write_text(json.dumps(current_rows, ensure_ascii=False, indent=2), encoding="utf-8")
        latest_snapshot_path.write_text(json.dumps(current_rows, ensure_ascii=False, indent=2), encoding="utf-8")

        git_status = {"branch":"neprováděno","last_commit":"neprováděno","short_status":"neprováděno"}
        if self.git_enabled.get():
            self.log("Spouštím Git audit...")
            git_status = get_git_status()
            self.stats("=== GIT ===")
            self.stats(f"Branch: {git_status['branch']}")
            self.stats(f"Last commit: {git_status['last_commit']}")
            self.stats(git_status["short_status"])
            self.stats("")

        db_status = {"ok":False, "error":"DB audit nebyl spuštěn.", "core_counts":[], "ops_counts":[], "player_counts":[], "recent_jobs":[], "planner_status":[], "budget_status":[]}
        if self.db_enabled.get():
            self.log("Spouštím DB audit...")
            db_status = get_db_status()
            self.stats("=== DATABASE ===")
            if db_status["ok"]:
                self.stats("Připojení k DB: OK")
                for name, cnt in db_status["core_counts"]:
                    self.stats(f"{name}: {cnt}")
                self.stats("")
                self.stats("=== OPS ===")
                for name, cnt in db_status["ops_counts"]:
                    self.stats(f"{name}: {cnt}")
                self.stats("")
                self.stats("=== PLAYER PIPELINE ===")
                for name, cnt in db_status["player_counts"]:
                    self.stats(f"{name}: {cnt}")
                self.stats("")
                self.stats("=== POSLEDNÍ JOB RUNS ===")
                for job_code, status, started_at in db_status["recent_jobs"]:
                    self.stats(f"{started_at} | {job_code} | {status}")
                self.stats("")
                if db_status["budget_status"]:
                    self.stats("=== API BUDGET ===")
                    for provider, sport_code, used, limit_, remaining in db_status["budget_status"]:
                        self.stats(f"{provider}/{sport_code}: used={used}, limit={limit_}, remaining={remaining}")
                    self.stats("")
            else:
                self.stats(f"DB audit chyba: {db_status['error']}")
                self.stats("")

        summary = {
            "total_files": len(current_rows),
            "new": new_count,
            "modified": mod_count,
            "deleted": del_count,
            "top_changes": changes[:20],
        }

        # technical markdown report
        report_md = run_dir / "MATCHMATRIX_AUDIT_REPORT.md"
        technical_lines = []
        technical_lines.append("# MatchMatrix – technický audit")
        technical_lines.append("")
        technical_lines.append(f"Datum a čas: {dt.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        technical_lines.append(f"Project root: {PROJECT_ROOT}")
        technical_lines.append("")
        technical_lines.append("## Vybrané cíle")
        technical_lines.extend([f"- {name}" for name in selected_names])
        technical_lines.append("")
        technical_lines.append("## Souhrn souborů")
        technical_lines.append(f"- Celkem souborů: {len(current_rows)}")
        technical_lines.append(f"- NEW: {new_count}")
        technical_lines.append(f"- MODIFIED: {mod_count}")
        technical_lines.append(f"- DELETED: {del_count}")
        technical_lines.append("")
        technical_lines.append("## Top změny")
        if changes[:20]:
            technical_lines.extend([f"- {c['change_type']}: {c['relative_path']}" for c in changes[:20]])
        else:
            technical_lines.append("- Bez změn proti minulému auditu.")
        technical_lines.append("")
        technical_lines.append("## Git")
        technical_lines.append(f"- Branch: {git_status['branch']}")
        technical_lines.append(f"- Last commit: {git_status['last_commit']}")
        technical_lines.append("```")
        technical_lines.append(git_status["short_status"])
        technical_lines.append("```")
        technical_lines.append("")
        technical_lines.append("## Databáze")
        if db_status["ok"]:
            technical_lines.append("- Připojení: OK")
            technical_lines.append("- Core counts:")
            technical_lines.extend([f"  - {name}: {cnt}" for name, cnt in db_status["core_counts"]])
            technical_lines.append("- OPS counts:")
            technical_lines.extend([f"  - {name}: {cnt}" for name, cnt in db_status["ops_counts"]])
            technical_lines.append("- Player pipeline:")
            technical_lines.extend([f"  - {name}: {cnt}" for name, cnt in db_status["player_counts"]])
        else:
            technical_lines.append(f"- Chyba DB: {db_status['error']}")
        technical_lines.append("")
        technical_lines.append("## Připomenutí")
        technical_lines.append("- Nezapomenout zkontrolovat a uložit změny do GitHub.")
        report_md.write_text("\n".join(technical_lines), encoding="utf-8")

        progress_md = None
        if self.progress_enabled.get():
            self.log("Generuji lidsky čitelný progress report...")
            progress_md = run_dir / "MATCHMATRIX_PROGRESS.md"
            progress_md.write_text(build_progress_text(summary, db_status, git_status, selected_names), encoding="utf-8")

        # latest files
        (REPORT_ROOT / "latest_report.md").write_text(report_md.read_text(encoding="utf-8"), encoding="utf-8")
        if progress_md:
            (REPORT_ROOT / "latest_progress.md").write_text(progress_md.read_text(encoding="utf-8"), encoding="utf-8")
        save_csv(REPORT_ROOT / "latest_files.csv", current_rows, ["relative_path","path","size_bytes","created_at","modified_at","mtime_epoch"])
        save_csv(REPORT_ROOT / "latest_changes.csv", changes, ["change_type","relative_path","path","size_bytes","created_at","modified_at","mtime_epoch"])

        self.last_report_path = progress_md or report_md

        self.log(f"Technický report: {report_md}")
        if progress_md:
            self.log(f"Progress report: {progress_md}")
        self.log(f"Složka běhu: {run_dir}")
        self.log("Audit dokončen.")
        self.stats("=== HOTOVO ===")
        self.stats(f"Technický report: {report_md}")
        if progress_md:
            self.stats(f"Progress report: {progress_md}")

def main():
    safe_mkdir(REPORT_ROOT)
    app = MissionControlApp()
    app.root.mainloop()

if __name__ == "__main__":
    main()
