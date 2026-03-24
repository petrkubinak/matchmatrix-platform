import datetime as dt
import os
from pathlib import Path
import subprocess
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox

PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
REPORT_ROOT = PROJECT_ROOT / "reports" / "audit"
SYSTEM_TREE_EXPORTER = PROJECT_ROOT / "tools" / "export_system_tree_v1.py"
LATEST_SYSTEM_TREE = REPORT_ROOT / "latest_system_tree.txt"

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

# -----------------------------------------
# Projektové cesty pro navigator
# -----------------------------------------
NAV_PATHS = {
    "Projekt root": PROJECT_ROOT,
    "Workers": PROJECT_ROOT / "workers",
    "Ingest": PROJECT_ROOT / "ingest",
    "API-Football": PROJECT_ROOT / "ingest" / "API-Football",
    "DB": PROJECT_ROOT / "db",
    "Reports": PROJECT_ROOT / "reports",
    "OPS Admin": PROJECT_ROOT / "ops_admin",
    "Frontend root": PROJECT_ROOT / "fronted",
    "MatchMatrix web": PROJECT_ROOT / "fronted" / "matchmatrix-web",
    "Docs": PROJECT_ROOT / "docs",
    "Dump": PROJECT_ROOT / "MatchMatrix-platform" / "Dump",
    "Scripts": PROJECT_ROOT / "MatchMatrix-platform" / "Scripts",
}

WATCH_EXT = {
    ".py", ".ps1", ".sql", ".md", ".json", ".yml", ".yaml",
    ".txt", ".csv", ".bat", ".cmd", ".psm1", ".psd1", ".tsx", ".ts", ".js", ".jsx"
}

IGNORE_DIRS = {
    ".git", "__pycache__", ".venv", "node_modules", ".idea", ".vs",
    "dist", "build", ".next"
}

IGNORE_PREFIXES = [
    str((PROJECT_ROOT / "reports" / "audit")).lower(),
]

# -----------------------------------------
# Barvy
# -----------------------------------------
BG = "#1C1330"
CARD = "#2A1B47"
CARD_2 = "#332055"
FG = "#F6EEFF"
MUTED = "#C9B8E8"
ACCENT = "#C77DFF"
ACCENT_2 = "#FF8BD1"
ACCENT_3 = "#8B5CF6"
GOOD = "#54E38E"
WARN = "#FFC857"
BAD = "#FF6B8A"
LINE = "#5B3A8A"
TEXTBOX_BG = "#130C23"


# -----------------------------------------
# Pomocné funkce
# -----------------------------------------
def now_str():
    return dt.datetime.now().strftime("%H:%M:%S")


def safe_mkdir(path: Path):
    path.mkdir(parents=True, exist_ok=True)


def open_path(path: Path):
    try:
        if not path.exists():
            messagebox.showwarning("Chybí cesta", f"Cesta neexistuje:\n{path}")
            return
        os.startfile(path)
    except Exception as e:
        messagebox.showerror("Chyba", f"Nelze otevřít cestu:\n{path}\n\n{e}")


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

        for filename in filenames:
            p = Path(dirpath) / filename
            if p.suffix.lower() not in WATCH_EXT:
                continue

            try:
                st = p.stat()
                rows.append({
                    "path": str(p),
                    "relative_path": (
                        str(p.relative_to(PROJECT_ROOT))
                        if PROJECT_ROOT in p.parents or p == PROJECT_ROOT
                        else str(p)
                    ),
                    "size_bytes": st.st_size,
                    "modified_at": dt.datetime.fromtimestamp(st.st_mtime),
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
                "mtime_epoch": row["mtime_epoch"],
            })

    changes.sort(key=lambda x: (x["change_type"], x["relative_path"].lower()))
    return changes


def read_latest_snapshot(snapshot_path: Path):
    if not snapshot_path.exists():
        return []

    rows = []
    try:
        lines = snapshot_path.read_text(encoding="utf-8").splitlines()
        for line in lines:
            parts = line.split(" | ")
            if len(parts) >= 4:
                rows.append({
                    "relative_path": parts[0],
                    "path": parts[1],
                    "size_bytes": int(parts[2]),
                    "mtime_epoch": float(parts[3]),
                    "modified_at": dt.datetime.fromtimestamp(float(parts[3])),
                })
    except Exception:
        return []

    return rows


def write_latest_snapshot(snapshot_path: Path, rows):
    lines = []
    for r in rows:
        lines.append(f"{r['relative_path']} | {r['path']} | {r['size_bytes']} | {r['mtime_epoch']}")
    snapshot_path.write_text("\n".join(lines), encoding="utf-8")


def run_git_command(args):
    try:
        result = subprocess.check_output(
            args,
            cwd=PROJECT_ROOT,
            shell=True,
            stderr=subprocess.STDOUT
        )
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

def run_system_tree_export():
    if not SYSTEM_TREE_EXPORTER.exists():
        return False, f"Chybí exporter: {SYSTEM_TREE_EXPORTER}"

    try:
        result = subprocess.run(
            [r"C:\Python314\python.exe", str(SYSTEM_TREE_EXPORTER)],
            cwd=str(PROJECT_ROOT),
            capture_output=True,
            text=True,
            check=True,
        )
        return True, result.stdout.strip()
    except subprocess.CalledProcessError as e:
        output = (e.stdout or "") + "\n" + (e.stderr or "")
        return False, output.strip()
    except Exception as e:
        return False, str(e)

def try_db_query(sql: str):
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
        "budget_status": [],
        "request_overview": [],
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
    select
        coalesce(job_code,'?') as job_code,
        coalesce(status,'?') as status,
        to_char(started_at, 'YYYY-MM-DD HH24:MI:SS') as started_at
    from ops.job_runs
    order by started_at desc
    limit 10;
    """

    budget_sql = """
    select
        coalesce(sport_code,'?') as sport_code,
        to_char(request_day, 'YYYY-MM-DD') as request_day,
        requests_used,
        requests_limit,
        requests_remaining
    from ops.api_budget_status
    order by request_day desc, sport_code;
    """

    request_overview_sql = """
    select
        coalesce(provider,'?') as provider,
        coalesce(account_name,'?') as account_name,
        coalesce(sport_code,'?') as sport_code,
        sum(request_count)::bigint as request_count
    from ops.api_request_log
    group by provider, account_name, sport_code
    order by request_count desc, provider, sport_code
    limit 10;
    """

    for key, sql in [
        ("core_counts", core_sql),
        ("ops_counts", ops_sql),
        ("player_counts", player_sql),
        ("recent_jobs", recent_jobs_sql),
        ("budget_status", budget_sql),
        ("request_overview", request_overview_sql),
    ]:
        rows, err = try_db_query(sql)
        if err:
            status["error"] = err
            return status
        status[key] = rows

    status["ok"] = True
    return status


def make_plain_list(items, bullet="- "):
    if not items:
        return f"{bullet}bez záznamu"
    return "\n".join(f"{bullet}{x}" for x in items)


def percent(part, total):
    try:
        if total == 0:
            return 0
        return max(0, min(100, int(round(part / total * 100))))
    except Exception:
        return 0


# -----------------------------------------
# Reporty
# -----------------------------------------
def build_audit_report(summary, db_status, git_status, selected_targets):
    lines = []
    lines.append("# TicketMatrixPlatform – technický audit")
    lines.append("")
    lines.append(f"Datum a čas: {dt.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"Project root: {PROJECT_ROOT}")
    lines.append("")

    lines.append("## Vybrané části projektu")
    lines.extend([f"- {x}" for x in selected_targets])
    lines.append("")

    lines.append("## Souhrn souborů")
    lines.append(f"- Celkem souborů: {summary['total_files']}")
    lines.append(f"- NEW: {summary['new']}")
    lines.append(f"- MODIFIED: {summary['modified']}")
    lines.append(f"- DELETED: {summary['deleted']}")
    lines.append("")

    lines.append("## Nejvýznamnější změny")
    if summary["top_changes"]:
        for c in summary["top_changes"][:20]:
            lines.append(f"- {c['change_type']}: {c['relative_path']}")
    else:
        lines.append("- Bez změn proti minulému auditu.")
    lines.append("")

    lines.append("## Git")
    lines.append(f"- Branch: {git_status['branch']}")
    lines.append(f"- Last commit: {git_status['last_commit']}")
    lines.append("```")
    lines.append(git_status["short_status"])
    lines.append("```")
    lines.append("")

    lines.append("## Databáze")
    if db_status["ok"]:
        lines.append("- Připojení: OK")
        lines.append("- Core counts:")
        for name, cnt in db_status["core_counts"]:
            lines.append(f"  - {name}: {cnt}")

        lines.append("- OPS counts:")
        for name, cnt in db_status["ops_counts"]:
            lines.append(f"  - {name}: {cnt}")

        lines.append("- Player pipeline:")
        for name, cnt in db_status["player_counts"]:
            lines.append(f"  - {name}: {cnt}")

        lines.append("- API budget:")
        for sport_code, request_day, used, limit_, remaining in db_status["budget_status"]:
            lines.append(f"  - {request_day} | {sport_code} | used={used} | limit={limit_} | remaining={remaining}")
    else:
        lines.append(f"- Chyba DB: {db_status['error']}")
    lines.append("")

    lines.append("## Navigator")
    for name, path in NAV_PATHS.items():
        status = "FOUND" if path.exists() else "MISSING"
        lines.append(f"- {name}: {status} | {path}")

    return "\n".join(lines)


def build_progress_report(summary, db_status, git_status, selected_targets):
    today = dt.datetime.now().strftime("%d.%m.%Y")
    time_txt = dt.datetime.now().strftime("%H:%M")

    file_comment = []
    if summary["new"]:
        file_comment.append(f"bylo přidáno {summary['new']} nových souborů")
    if summary["modified"]:
        file_comment.append(f"u {summary['modified']} souborů proběhla úprava")
    if summary["deleted"]:
        file_comment.append(f"{summary['deleted']} souborů bylo odstraněno")
    if not file_comment:
        file_comment.append("nebyly zjištěny žádné změny proti minulému auditu")

    core_map = {name: cnt for name, cnt in db_status["core_counts"]} if db_status["ok"] else {}
    player_map = {name: cnt for name, cnt in db_status["player_counts"]} if db_status["ok"] else {}

    git_lines = git_status["short_status"].splitlines() if git_status["short_status"] else []
    git_preview = git_lines[:8]

    changed_paths = [c["relative_path"] for c in summary["top_changes"][:8]]

    next_steps = []
    if db_status["ok"]:
        next_steps.append("dokončit vizuální styl webu TicketMatrixPlatform")
        next_steps.append("navázat frontend na reálná data z databáze")
        next_steps.append("pokračovat v players pipeline a Ticket Intelligence vrstvě")
    else:
        next_steps.append("opravit připojení panelu k databázi")
        next_steps.append("znovu spustit FULL audit")
        next_steps.append("ověřit OPS tabulky a webový frontend")

    report = f"""# TicketMatrixPlatform – denní přehled vývoje

Datum: {today}  
Čas kontroly systému: {time_txt}

---

## 1. Co je TicketMatrixPlatform

TicketMatrixPlatform je sportovní datová a analytická platforma.
Interní pracovní název projektu je zatím MatchMatrix.

Cílem systému je:
- sbírat sportovní data
- ukládat je do databáze
- počítat statistiky a predikce
- připravovat inteligentní práci s tikety

---

## 2. Co se dnes zkontrolovalo

Byly zkontrolovány tyto části projektu:

{make_plain_list(selected_targets)}

Celkem bylo projito {summary['total_files']} sledovaných souborů.

Ve srovnání s minulým auditem:
"""
    report += "\n".join(f"- {x}" for x in file_comment)
    report += f"""

---

## 3. Stav databáze
"""
    if db_status["ok"]:
        report += f"""
Databáze je dostupná a základní stav je následující:

- ligy: {core_map.get('leagues', 0)}
- týmy: {core_map.get('teams', 0)}
- zápasy: {core_map.get('matches', 0)}
- hráči: {core_map.get('players', 0)}

Player pipeline přehled:
- import hráčů: {player_map.get('players_import', 0)}
- staging hráčů: {player_map.get('stg_provider_players', 0)}
- public hráči: {player_map.get('public_players', 0)}
- statistiky hráčů na zápas: {player_map.get('player_match_statistics', 0)}
"""
    else:
        report += f"""
Databázový audit se nepodařilo načíst.

Důvod:
{db_status["error"]}

To znamená, že panel momentálně nevidí do PostgreSQL a je potřeba zkontrolovat připojení.
"""

    report += f"""

---

## 4. Stav systému a repozitáře

Git větev:
- {git_status["branch"]}

Poslední commit:
- {git_status["last_commit"]}

Aktuální neuložené změny:
{make_plain_list(git_preview)}

---

## 5. Kam jsme se dnes posunuli

Na základě dnešního auditu je vidět, že projekt má:
- funkční audit souborů
- přehled změn proti minulému běhu
- kontrolu Git stavu
- Project Navigator pro rychlé otevření hlavních částí projektu
"""

    if db_status["ok"]:
        report += "- přímý přehled o databázi, OPS tabulkách a API budgetu\n"
    else:
        report += "- připravený databázový audit, ale je potřeba opravit připojení\n"

    report += f"""

Hlavní změněné soubory dnes:
{make_plain_list(changed_paths)}

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
git commit -m "TicketMatrixPlatform update"
git push
"""
    return report


# -----------------------------------------
# UI komponenty
# -----------------------------------------
class MetricCard(tk.Frame):
    def __init__(self, parent, title, value="0", subtitle="", color=ACCENT):
        super().__init__(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        self.configure(padx=12, pady=10)

        self.title_lbl = tk.Label(self, text=title, bg=CARD, fg=MUTED, font=("Segoe UI", 10, "bold"))
        self.title_lbl.pack(anchor="w")

        self.value_lbl = tk.Label(self, text=value, bg=CARD, fg=FG, font=("Segoe UI", 20, "bold"))
        self.value_lbl.pack(anchor="w", pady=(2, 0))

        self.sub_lbl = tk.Label(self, text=subtitle, bg=CARD, fg=color, font=("Segoe UI", 9))
        self.sub_lbl.pack(anchor="w", pady=(4, 0))

    def update_card(self, value, subtitle="", color=ACCENT):
        self.value_lbl.config(text=str(value))
        self.sub_lbl.config(text=subtitle, fg=color)


class ProgressBarCard(tk.Frame):
    def __init__(self, parent, title, color=ACCENT):
        super().__init__(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        self.color = color
        self.configure(padx=12, pady=10)

        self.title_lbl = tk.Label(self, text=title, bg=CARD, fg=MUTED, font=("Segoe UI", 10, "bold"))
        self.title_lbl.pack(anchor="w")

        self.value_lbl = tk.Label(self, text="0 %", bg=CARD, fg=FG, font=("Segoe UI", 16, "bold"))
        self.value_lbl.pack(anchor="w", pady=(4, 2))

        self.canvas = tk.Canvas(self, height=16, bg=CARD, highlightthickness=0, bd=0)
        self.canvas.pack(fill="x", pady=(2, 2))

        self.sub_lbl = tk.Label(self, text="", bg=CARD, fg=MUTED, font=("Segoe UI", 9))
        self.sub_lbl.pack(anchor="w", pady=(4, 0))

        self._value = 0
        self.bind("<Configure>", lambda e: self.redraw(self._value))

    def redraw(self, value):
        self._value = max(0, min(100, int(value)))
        self.canvas.delete("all")
        w = max(20, self.canvas.winfo_width())
        self.canvas.create_rectangle(0, 2, w, 14, fill="#24173C", outline=LINE)
        fill_w = int((w - 2) * (self._value / 100))
        self.canvas.create_rectangle(1, 3, max(1, fill_w), 13, fill=self.color, outline=self.color)

    def update_bar(self, value, subtitle=""):
        self.value_lbl.config(text=f"{int(value)} %")
        self.sub_lbl.config(text=subtitle)
        self.redraw(value)


# -----------------------------------------
# Hlavní panel
# -----------------------------------------
class MissionControlV7:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("TicketMatrixPlatform Mission Control V7")
        self.root.geometry("1440x900")
        self.root.minsize(1240, 780)
        self.root.configure(bg=BG)

        self.db_enabled = tk.BooleanVar(value=True)
        self.git_enabled = tk.BooleanVar(value=True)
        self.progress_enabled = tk.BooleanVar(value=True)

        self.last_report_path = None
        self.last_run_dir = None

        self._setup_style()
        self._build_ui()

        self.log("Panel připraven.")
        self.log("V7: přidán Project Navigator a výstupy zredukovány pouze na 2 reporty.")

    def _setup_style(self):
        style = ttk.Style()
        try:
            style.theme_use("clam")
        except Exception:
            pass

        style.configure("MM.TFrame", background=BG)
        style.configure("MM.TLabelframe", background=BG, foreground=FG, bordercolor=LINE)
        style.configure("MM.TLabelframe.Label", background=BG, foreground=ACCENT_2, font=("Segoe UI", 10, "bold"))
        style.configure("MM.TCheckbutton", background=BG, foreground=FG, font=("Segoe UI", 10))
        style.map("MM.TCheckbutton", background=[("active", BG)], foreground=[("active", FG)])

        style.configure("Accent.TButton", background=ACCENT_3, foreground=FG, borderwidth=0, padding=8, font=("Segoe UI", 10, "bold"))
        style.map("Accent.TButton", background=[("active", ACCENT), ("pressed", ACCENT_2)], foreground=[("active", BG), ("pressed", BG)])

        style.configure("Ghost.TButton", background=CARD_2, foreground=FG, borderwidth=0, padding=8, font=("Segoe UI", 10))
        style.map("Ghost.TButton", background=[("active", ACCENT_3), ("pressed", ACCENT)], foreground=[("active", FG), ("pressed", BG)])

    def _build_ui(self):
        main = ttk.Frame(self.root, style="MM.TFrame", padding=14)
        main.pack(fill="both", expand=True)

        header = tk.Frame(main, bg=BG)
        header.pack(fill="x", pady=(0, 10))

        tk.Label(
            header,
            text="TICKETMATRIXPLATFORM MISSION CONTROL V7",
            bg=BG,
            fg=FG,
            font=("Segoe UI", 22, "bold")
        ).pack(anchor="w")

        tk.Label(
            header,
            text="Audit projektu + databáze + Git + Project Navigator",
            bg=BG,
            fg=MUTED,
            font=("Segoe UI", 10)
        ).pack(anchor="w", pady=(2, 4))

        tk.Label(header, text=f"Project root: {PROJECT_ROOT}", bg=BG, fg=MUTED, font=("Segoe UI", 9)).pack(anchor="w")
        tk.Label(header, text=f"Reports root: {REPORT_ROOT}", bg=BG, fg=MUTED, font=("Segoe UI", 9)).pack(anchor="w")

        top = tk.Frame(main, bg=BG)
        top.pack(fill="x", pady=(0, 10))

        settings = ttk.LabelFrame(top, text="Kontroly", style="MM.TLabelframe", padding=10)
        settings.pack(side="left", fill="both", expand=True, padx=(0, 8))

        navigator = ttk.LabelFrame(top, text="Project Navigator", style="MM.TLabelframe", padding=10)
        navigator.pack(side="left", fill="y")

        ttk.Checkbutton(settings, text="DB audit", variable=self.db_enabled, style="MM.TCheckbutton").grid(row=0, column=0, sticky="w", padx=6, pady=4)
        ttk.Checkbutton(settings, text="Git audit + GitHub reminder", variable=self.git_enabled, style="MM.TCheckbutton").grid(row=0, column=1, sticky="w", padx=6, pady=4)
        ttk.Checkbutton(settings, text="Lidsky čitelný progress report", variable=self.progress_enabled, style="MM.TCheckbutton").grid(row=0, column=2, sticky="w", padx=6, pady=4)

        ttk.Button(settings, text="Spustit FULL audit", style="Accent.TButton", command=self.run_full_audit).grid(row=1, column=0, padx=6, pady=8, sticky="w")
        ttk.Button(settings, text="Otevřít poslední report", style="Ghost.TButton", command=self.open_last_report).grid(row=1, column=1, padx=6, pady=8, sticky="w")
        ttk.Button(settings, text="Otevřít system tree", style="Ghost.TButton", command=lambda: open_path(LATEST_SYSTEM_TREE)).grid(row=1, column=2, padx=6, pady=8, sticky="w")
        ttk.Button(settings, text="Otevřít audit složku", style="Ghost.TButton", command=lambda: open_path(REPORT_ROOT)).grid(row=1, column=3, padx=6, pady=8, sticky="w")
        ttk.Button(settings, text="Vyčistit log", style="Ghost.TButton", command=self.clear_all).grid(row=1, column=4, padx=6, pady=8, sticky="w")

        nav_row = 0
        nav_col = 0
        for name, path in NAV_PATHS.items():
            ttk.Button(
                navigator,
                text=name,
                style="Ghost.TButton",
                command=lambda p=path: open_path(p)
            ).grid(row=nav_row, column=nav_col, padx=4, pady=4, sticky="ew")
            nav_col += 1
            if nav_col >= 2:
                nav_col = 0
                nav_row += 1

        dashboard = tk.Frame(main, bg=BG)
        dashboard.pack(fill="x", pady=(0, 10))

        row1 = tk.Frame(dashboard, bg=BG)
        row1.pack(fill="x", pady=(0, 8))

        self.card_files = MetricCard(row1, "Sledované soubory", "0", "čeká na audit", ACCENT)
        self.card_files.pack(side="left", fill="both", expand=True, padx=4)

        self.card_changes = MetricCard(row1, "Dnešní změny", "0", "NEW / MOD / DEL", ACCENT_2)
        self.card_changes.pack(side="left", fill="both", expand=True, padx=4)

        self.card_git = MetricCard(row1, "Git branch", "-", "repo stav", ACCENT)
        self.card_git.pack(side="left", fill="both", expand=True, padx=4)

        self.card_db = MetricCard(row1, "Databáze", "-", "čeká na audit", WARN)
        self.card_db.pack(side="left", fill="both", expand=True, padx=4)

        row2 = tk.Frame(dashboard, bg=BG)
        row2.pack(fill="x")

        self.bar_ingest = ProgressBarCard(row2, "INGEST / PIPELINE", ACCENT)
        self.bar_ingest.pack(side="left", fill="both", expand=True, padx=4)

        self.bar_db = ProgressBarCard(row2, "DATABÁZE / OPS", ACCENT_3)
        self.bar_db.pack(side="left", fill="both", expand=True, padx=4)

        self.bar_git = ProgressBarCard(row2, "GIT / GITHUB READY", ACCENT_2)
        self.bar_git.pack(side="left", fill="both", expand=True, padx=4)

        body = tk.PanedWindow(main, orient="horizontal", bg=BG, sashwidth=8, sashrelief="flat")
        body.pack(fill="both", expand=True)

        left = tk.Frame(body, bg=BG)
        right = tk.Frame(body, bg=BG)
        body.add(left, minsize=500)
        body.add(right, minsize=600)

        left_wrap = ttk.LabelFrame(left, text="Vizualizace a přehled", style="MM.TLabelframe", padding=8)
        left_wrap.pack(fill="both", expand=True, padx=(0, 6))

        right_wrap = ttk.LabelFrame(right, text="Log běhu", style="MM.TLabelframe", padding=8)
        right_wrap.pack(fill="both", expand=True)

        self.stats_text = scrolledtext.ScrolledText(
            left_wrap,
            wrap="word",
            font=("Consolas", 10),
            bg=TEXTBOX_BG,
            fg=FG,
            insertbackground=FG,
            relief="flat",
            padx=10,
            pady=10
        )
        self.stats_text.pack(fill="both", expand=True)

        self.log_text = scrolledtext.ScrolledText(
            right_wrap,
            wrap="word",
            font=("Consolas", 10),
            bg=TEXTBOX_BG,
            fg=FG,
            insertbackground=FG,
            relief="flat",
            padx=10,
            pady=10
        )
        self.log_text.pack(fill="both", expand=True)

    def log(self, msg):
        self.log_text.insert("end", f"[{now_str()}] {msg}\n")
        self.log_text.see("end")
        self.root.update_idletasks()

    def stats(self, msg):
        self.stats_text.insert("end", msg + "\n")
        self.stats_text.see("end")
        self.root.update_idletasks()

    def clear_all(self):
        self.log_text.delete("1.0", "end")
        self.stats_text.delete("1.0", "end")

    def open_last_report(self):
        if self.last_report_path and Path(self.last_report_path).exists():
            open_path(Path(self.last_report_path))
        else:
            messagebox.showinfo("Info", "Zatím není k dispozici žádný report.")

    def update_cards(self, summary, git_status, db_status):
        total_files = summary["total_files"]
        total_changes = summary["new"] + summary["modified"] + summary["deleted"]

        self.card_files.update_card(total_files, "naskenované soubory", ACCENT)
        self.card_changes.update_card(total_changes, f"NEW {summary['new']} | MOD {summary['modified']} | DEL {summary['deleted']}", ACCENT_2)
        self.card_git.update_card(git_status["branch"], "aktivní větev", ACCENT)

        if db_status["ok"]:
            core_map = {name: cnt for name, cnt in db_status["core_counts"]}
            self.card_db.update_card(core_map.get("matches", 0), "zápasy v DB", GOOD)
        else:
            self.card_db.update_card("CHYBA", "DB audit nedokončen", BAD)

        if db_status["ok"]:
            pmap = {name: cnt for name, cnt in db_status["player_counts"]}
            import_cnt = pmap.get("players_import", 0)
            staging_cnt = pmap.get("stg_provider_players", 0)
            public_cnt = pmap.get("public_players", 0)

            ingest_pct = min(
                100,
                int((percent(staging_cnt, max(import_cnt, 1)) * 0.4) + (percent(public_cnt, max(staging_cnt, 1)) * 0.6))
            )
            self.bar_ingest.update_bar(ingest_pct, f"import {import_cnt} → staging {staging_cnt} → public {public_cnt}")

            core_map = {name: cnt for name, cnt in db_status["core_counts"]}
            ops_map = {name: cnt for name, cnt in db_status["ops_counts"]}

            db_points = 0
            db_points += 25 if core_map.get("leagues", 0) > 0 else 0
            db_points += 25 if core_map.get("teams", 0) > 0 else 0
            db_points += 25 if core_map.get("matches", 0) > 0 else 0
            db_points += 25 if ops_map.get("job_runs", 0) > 0 else 0
            self.bar_db.update_bar(db_points, f"leagues {core_map.get('leagues', 0)}, teams {core_map.get('teams', 0)}, matches {core_map.get('matches', 0)}")
        else:
            self.bar_ingest.update_bar(10, "pipeline nelze dopočítat bez DB")
            self.bar_db.update_bar(5, "nejprve opravit DB audit")

        git_lines = git_status["short_status"].splitlines()
        dirty = len([x for x in git_lines if x.strip() and "Čisté" not in x and "ERROR" not in x])
        git_ready = 100 if dirty == 0 else max(5, 100 - min(95, dirty * 3))
        self.bar_git.update_bar(git_ready, f"neuložené změny: {dirty}")

    def run_full_audit(self):
        self.clear_all()
        self.log("Spouštím FULL audit...")
        self.log("Generuji SYSTEM TREE export...")
        ok_tree, tree_msg = run_system_tree_export()

        if ok_tree:
            self.log("SYSTEM TREE export OK.")
            self.stats(f"SYSTEM TREE: OK -> {LATEST_SYSTEM_TREE}")
            self.stats("")
        else:
            self.log(f"SYSTEM TREE export ERROR: {tree_msg}")
            self.stats("SYSTEM TREE: ERROR")
            self.stats(tree_msg)
            self.stats("")
        self.stats("=== TICKETMATRIXPLATFORM MISSION CONTROL V7 ===")
        self.stats(f"Čas spuštění: {dt.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        self.stats("")

        safe_mkdir(REPORT_ROOT)
        run_dir = REPORT_ROOT / dt.datetime.now().strftime("%Y-%m-%d")
        safe_mkdir(run_dir)
        self.last_run_dir = run_dir

        latest_snapshot_path = REPORT_ROOT / "latest_snapshot.txt"

        self.log("Kontroluji celý projekt...")
        current_rows = scan_files(PROJECT_ROOT)
        self.stats(f"Celý projekt: {len(current_rows)} sledovaných souborů")

        old_rows = read_latest_snapshot(latest_snapshot_path)
        changes = compare_snapshots(old_rows, current_rows)

        new_count = sum(1 for c in changes if c["change_type"] == "NEW")
        mod_count = sum(1 for c in changes if c["change_type"] == "MODIFIED")
        del_count = sum(1 for c in changes if c["change_type"] == "DELETED")

        self.stats("")
        self.stats(f"Celkem souborů: {len(current_rows)}")
        self.stats(f"Nové: {new_count}")
        self.stats(f"Upravené: {mod_count}")
        self.stats(f"Smazané: {del_count}")
        self.stats("")

        write_latest_snapshot(latest_snapshot_path, current_rows)

        git_status = {
            "branch": "neprováděno",
            "last_commit": "neprováděno",
            "short_status": "neprováděno"
        }

        if self.git_enabled.get():
            self.log("Spouštím Git audit...")
            git_status = get_git_status()
            self.stats("=== GIT ===")
            self.stats(f"Branch: {git_status['branch']}")
            self.stats(f"Last commit: {git_status['last_commit']}")
            self.stats(git_status["short_status"])
            self.stats("")

        db_status = {
            "ok": False,
            "error": "DB audit nebyl spuštěn.",
            "core_counts": [],
            "ops_counts": [],
            "player_counts": [],
            "recent_jobs": [],
            "budget_status": [],
            "request_overview": [],
        }

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
            else:
                self.stats(f"DB audit chyba: {db_status['error']}")
                self.stats("")

        self.stats("=== PROJECT NAVIGATOR STATUS ===")
        for name, path in NAV_PATHS.items():
            status = "FOUND" if path.exists() else "MISSING"
            self.stats(f"{name}: {status}")
        self.stats("")

        summary = {
            "total_files": len(current_rows),
            "new": new_count,
            "modified": mod_count,
            "deleted": del_count,
            "top_changes": changes[:20],
        }

        self.update_cards(summary, git_status, db_status)

        audit_report = build_audit_report(summary, db_status, git_status, ["Celý projekt"])
        progress_report = build_progress_report(summary, db_status, git_status, ["Celý projekt"])

        audit_path = run_dir / "MATCHMATRIX_AUDIT_REPORT.md"
        progress_path = run_dir / "MATCHMATRIX_PROGRESS.md"

        audit_path.write_text(audit_report, encoding="utf-8")
        progress_path.write_text(progress_report, encoding="utf-8")

        (REPORT_ROOT / "latest_audit_report.md").write_text(audit_report, encoding="utf-8")
        (REPORT_ROOT / "latest_progress_report.md").write_text(progress_report, encoding="utf-8")

        self.last_report_path = progress_path

        self.log(f"Audit report: {audit_path}")
        self.log(f"Progress report: {progress_path}")
        self.log(f"System tree: {LATEST_SYSTEM_TREE}")
        self.log("Výstup zredukován jen na 2 reporty + system tree.")
        self.log("Audit dokončen.")

        self.stats("=== HOTOVO ===")
        self.stats(f"Audit report: {audit_path}")
        self.stats(f"Progress report: {progress_path}")
        self.stats(f"System tree: {LATEST_SYSTEM_TREE}")


def main():
    safe_mkdir(REPORT_ROOT)
    app = MissionControlV7()
    app.root.mainloop()


if __name__ == "__main__":
    main()