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

WATCH_EXT = {
    ".py", ".ps1", ".sql", ".md", ".json", ".yml", ".yaml",
    ".txt", ".csv", ".bat", ".cmd", ".psm1", ".psd1"
}

IGNORE_DIRS = {
    ".git", "__pycache__", ".venv", "node_modules", ".idea", ".vs",
    "dist", "build", "reports", "file_audit", "audit"
}

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

# ==========================================================
# BARVY - TicketMatrixPlatform styl
# ==========================================================
BG = "#1C1330"             # tmavě fialová
CARD = "#2A1B47"           # karta
CARD_2 = "#332055"         # zvýrazněná karta
FG = "#F6EEFF"             # hlavní text
MUTED = "#C9B8E8"          # sekundární text
ACCENT = "#C77DFF"         # světle fialová
ACCENT_2 = "#FF8BD1"       # růžová
ACCENT_3 = "#8B5CF6"       # sytější fialová
GOOD = "#54E38E"
WARN = "#FFC857"
BAD = "#FF6B8A"
LINE = "#5B3A8A"
TEXTBOX_BG = "#130C23"

# ==========================================================
# POMOCNÉ FUNKCE
# ==========================================================
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
        "planner_status": [],
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

    planner_status_sql = """
    select
        coalesce(entity,'?') as entity,
        coalesce(status,'?') as status,
        count(*)::bigint as cnt
    from ops.ingest_planner
    group by entity, status
    order by entity, status;
    """

    # OPRAVA podle tvého screenshotu
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

    # Toto čte provider až z api_request_log
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
        ("planner_status", planner_status_sql),
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


def make_plain_list(rows, bullet="- "):
    if not rows:
        return f"{bullet}bez záznamu"
    return "\n".join(f"{bullet}{r}" for r in rows)


def percent(part, total):
    try:
        if total == 0:
            return 0
        return max(0, min(100, int(round(part / total * 100))))
    except Exception:
        return 0


def open_path(path: Path):
    try:
        os.startfile(path)
    except Exception as e:
        messagebox.showerror("Chyba", f"Nelze otevřít cestu:\n{path}\n\n{e}")


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
        next_steps.append("zkontrolovat připojení panelu k databázi")
        next_steps.append("po opravě znovu spustit FULL audit")
        next_steps.append("ověřit OPS tabulky a stav planneru")

    return f"""# TicketMatrixPlatform – denní přehled vývoje

Datum: {today}  
Čas kontroly systému: {time_txt}

---

## 1. Co je TicketMatrixPlatform

TicketMatrixPlatform je datová a analytická platforma pro sportovní data.
Systém sbírá data ze zdrojů, ukládá je do databáze, připravuje statistiky
a vytváří podklady pro budoucí predikce a inteligentní práci s tikety.

Interní pracovní název projektu je zatím MatchMatrix.

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
- přímý přehled o databázi, OPS tabulkách a API budgetu
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
git commit -m "TicketMatrixPlatform / MatchMatrix update"
git push
"""


# ==========================================================
# UI KOMPONENTY
# ==========================================================
class MetricCard(tk.Frame):
    def __init__(self, parent, title, value="0", subtitle="", color=ACCENT):
        super().__init__(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        self.configure(padx=12, pady=10)

        self.title_lbl = tk.Label(
            self,
            text=title,
            bg=CARD,
            fg=MUTED,
            font=("Segoe UI", 10, "bold")
        )
        self.title_lbl.pack(anchor="w")

        self.value_lbl = tk.Label(
            self,
            text=value,
            bg=CARD,
            fg=FG,
            font=("Segoe UI", 20, "bold")
        )
        self.value_lbl.pack(anchor="w", pady=(2, 0))

        self.sub_lbl = tk.Label(
            self,
            text=subtitle,
            bg=CARD,
            fg=color,
            font=("Segoe UI", 9)
        )
        self.sub_lbl.pack(anchor="w", pady=(4, 0))

    def update_card(self, value, subtitle="", color=ACCENT):
        self.value_lbl.config(text=str(value))
        self.sub_lbl.config(text=subtitle, fg=color)


class ProgressBarCard(tk.Frame):
    def __init__(self, parent, title, color=ACCENT):
        super().__init__(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        self.color = color
        self.configure(padx=12, pady=10)

        self.title_lbl = tk.Label(
            self,
            text=title,
            bg=CARD,
            fg=MUTED,
            font=("Segoe UI", 10, "bold")
        )
        self.title_lbl.pack(anchor="w")

        self.value_lbl = tk.Label(
            self,
            text="0 %",
            bg=CARD,
            fg=FG,
            font=("Segoe UI", 16, "bold")
        )
        self.value_lbl.pack(anchor="w", pady=(4, 2))

        self.canvas = tk.Canvas(
            self,
            height=16,
            bg=CARD,
            highlightthickness=0,
            bd=0
        )
        self.canvas.pack(fill="x", pady=(2, 2))

        self.sub_lbl = tk.Label(
            self,
            text="",
            bg=CARD,
            fg=MUTED,
            font=("Segoe UI", 9)
        )
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


# ==========================================================
# HLAVNÍ APLIKACE
# ==========================================================
class MissionControlV6:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("TicketMatrixPlatform Mission Control V6")
        self.root.geometry("1340x860")
        self.root.minsize(1160, 760)
        self.root.configure(bg=BG)

        self.target_vars = {
            name: tk.BooleanVar(
                value=(name in ["Celý projekt", "Workers", "Ingest", "API-Football", "Scripts", "Dump"])
            )
            for name in FILE_TARGETS
        }

        self.db_enabled = tk.BooleanVar(value=True)
        self.git_enabled = tk.BooleanVar(value=True)
        self.progress_enabled = tk.BooleanVar(value=True)

        self.last_run_dir = None
        self.last_report_path = None

        self._setup_style()
        self._build_ui()

        self.log("Panel připraven.")
        self.log("V6: opraven DB audit pro ops.api_budget_status a přidána vizualizace projektu.")
        self.log("Branding směřuje na TicketMatrixPlatform, interní název projektu zůstává MatchMatrix.")

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

        style.configure(
            "Accent.TButton",
            background=ACCENT_3,
            foreground=FG,
            borderwidth=0,
            padding=8,
            font=("Segoe UI", 10, "bold")
        )
        style.map(
            "Accent.TButton",
            background=[("active", ACCENT), ("pressed", ACCENT_2)],
            foreground=[("active", BG), ("pressed", BG)]
        )

        style.configure(
            "Ghost.TButton",
            background=CARD_2,
            foreground=FG,
            borderwidth=0,
            padding=8,
            font=("Segoe UI", 10)
        )
        style.map(
            "Ghost.TButton",
            background=[("active", ACCENT_3), ("pressed", ACCENT)],
            foreground=[("active", FG), ("pressed", BG)]
        )

    def _make_section_label(self, parent, text):
        return tk.Label(parent, text=text, bg=BG, fg=ACCENT_2, font=("Segoe UI", 10, "bold"))

    def _build_ui(self):
        main = ttk.Frame(self.root, style="MM.TFrame", padding=14)
        main.pack(fill="both", expand=True)

        header = tk.Frame(main, bg=BG)
        header.pack(fill="x", pady=(0, 10))

        tk.Label(
            header,
            text="TICKETMATRIXPLATFORM MISSION CONTROL V6",
            bg=BG,
            fg=FG,
            font=("Segoe UI", 22, "bold")
        ).pack(anchor="w")

        tk.Label(
            header,
            text="Tmavě fialový dashboard pro audit projektu, databáze, Git stavu a vývojového posunu",
            bg=BG,
            fg=MUTED,
            font=("Segoe UI", 10)
        ).pack(anchor="w", pady=(2, 4))

        tk.Label(header, text=f"Project root: {PROJECT_ROOT}", bg=BG, fg=MUTED, font=("Segoe UI", 9)).pack(anchor="w")
        tk.Label(header, text=f"Reports root: {REPORT_ROOT}", bg=BG, fg=MUTED, font=("Segoe UI", 9)).pack(anchor="w")

        top_split = tk.Frame(main, bg=BG)
        top_split.pack(fill="x", pady=(6, 10))

        left_opts = ttk.LabelFrame(top_split, text="Výběr kontrol", style="MM.TLabelframe", padding=10)
        left_opts.pack(side="left", fill="both", expand=True, padx=(0, 8))

        right_actions = ttk.LabelFrame(top_split, text="Akce", style="MM.TLabelframe", padding=10)
        right_actions.pack(side="left", fill="y")

        files_frame = tk.Frame(left_opts, bg=BG)
        files_frame.pack(fill="x")

        self._make_section_label(files_frame, "FILE AUDIT").grid(row=0, column=0, sticky="w", padx=4, pady=(0, 6), columnspan=4)

        row = 1
        col = 0
        for name in FILE_TARGETS:
            ttk.Checkbutton(
                files_frame,
                text=name,
                variable=self.target_vars[name],
                style="MM.TCheckbutton"
            ).grid(row=row, column=col, sticky="w", padx=6, pady=3)
            col += 1
            if col >= 4:
                row += 1
                col = 0

        more = tk.Frame(left_opts, bg=BG)
        more.pack(fill="x", pady=(10, 0))

        self._make_section_label(more, "DALŠÍ KONTROLY").grid(row=0, column=0, sticky="w", padx=4, pady=(0, 6), columnspan=3)

        ttk.Checkbutton(more, text="DB audit", variable=self.db_enabled, style="MM.TCheckbutton").grid(row=1, column=0, sticky="w", padx=6, pady=3)
        ttk.Checkbutton(more, text="Git audit + GitHub reminder", variable=self.git_enabled, style="MM.TCheckbutton").grid(row=1, column=1, sticky="w", padx=6, pady=3)
        ttk.Checkbutton(more, text="Vytvořit lidský progress report", variable=self.progress_enabled, style="MM.TCheckbutton").grid(row=1, column=2, sticky="w", padx=6, pady=3)

        ttk.Button(right_actions, text="Spustit FULL audit", style="Accent.TButton", command=self.run_full_audit).pack(fill="x", pady=4)
        ttk.Button(right_actions, text="Otevřít poslední report", style="Ghost.TButton", command=self.open_last_report).pack(fill="x", pady=4)
        ttk.Button(right_actions, text="Otevřít audit složku", style="Ghost.TButton", command=lambda: open_path(REPORT_ROOT)).pack(fill="x", pady=4)
        ttk.Button(right_actions, text="Vyčistit log", style="Ghost.TButton", command=self.clear_all).pack(fill="x", pady=4)

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
        body.add(left, minsize=460)
        body.add(right, minsize=560)

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

    def selected_targets(self):
        names = [name for name, var in self.target_vars.items() if var.get()]
        return names if names else ["Celý projekt"]

    def update_cards(self, summary, git_status, db_status):
        total_files = summary.get("total_files", 0)
        total_changes = summary.get("new", 0) + summary.get("modified", 0) + summary.get("deleted", 0)

        self.card_files.update_card(total_files, "naskenované soubory", ACCENT)
        self.card_changes.update_card(
            total_changes,
            f"NEW {summary.get('new', 0)} | MOD {summary.get('modified', 0)} | DEL {summary.get('deleted', 0)}",
            ACCENT_2
        )
        self.card_git.update_card(git_status.get("branch", "-"), "aktivní větev", ACCENT)

        if db_status.get("ok"):
            core_map = {name: cnt for name, cnt in db_status["core_counts"]}
            self.card_db.update_card(core_map.get("matches", 0), "zápasy v DB", GOOD)
        else:
            self.card_db.update_card("CHYBA", "DB audit nedokončen", BAD)

        # Ingest / pipeline
        if db_status.get("ok"):
            pmap = {name: cnt for name, cnt in db_status["player_counts"]}
            import_cnt = pmap.get("players_import", 0)
            staging_cnt = pmap.get("stg_provider_players", 0)
            public_cnt = pmap.get("public_players", 0)

            ingest_pct = min(
                100,
                int((percent(staging_cnt, max(import_cnt, 1)) * 0.4) + (percent(public_cnt, max(staging_cnt, 1)) * 0.6))
            )
            self.bar_ingest.update_bar(
                ingest_pct,
                f"import {import_cnt} → staging {staging_cnt} → public {public_cnt}"
            )

            core_map = {name: cnt for name, cnt in db_status["core_counts"]}
            ops_map = {name: cnt for name, cnt in db_status["ops_counts"]}

            db_points = 0
            db_points += 25 if core_map.get("leagues", 0) > 0 else 0
            db_points += 25 if core_map.get("teams", 0) > 0 else 0
            db_points += 25 if core_map.get("matches", 0) > 0 else 0
            db_points += 25 if ops_map.get("job_runs", 0) > 0 else 0

            self.bar_db.update_bar(
                db_points,
                f"leagues {core_map.get('leagues', 0)}, teams {core_map.get('teams', 0)}, matches {core_map.get('matches', 0)}"
            )
        else:
            self.bar_ingest.update_bar(10, "pipeline nelze dopočítat bez DB")
            self.bar_db.update_bar(5, "nejprve opravit DB audit")

        git_lines = git_status.get("short_status", "").splitlines()
        dirty = len([x for x in git_lines if x.strip() and "Čisté" not in x and "ERROR" not in x])
        git_ready = 100 if dirty == 0 else max(5, 100 - min(95, dirty * 3))
        self.bar_git.update_bar(git_ready, f"neuložené změny: {dirty}")

    def run_full_audit(self):
        self.clear_all()
        self.log("Spouštím FULL audit...")
        self.stats("=== TICKETMATRIXPLATFORM MISSION CONTROL V6 ===")
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

        save_csv(files_csv, current_rows, ["relative_path", "path", "size_bytes", "created_at", "modified_at", "mtime_epoch"])
        save_csv(changes_csv, changes, ["change_type", "relative_path", "path", "size_bytes", "created_at", "modified_at", "mtime_epoch"])

        snapshot_json.write_text(json.dumps(current_rows, ensure_ascii=False, indent=2), encoding="utf-8")
        latest_snapshot_path.write_text(json.dumps(current_rows, ensure_ascii=False, indent=2), encoding="utf-8")

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
            "planner_status": [],
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

                if db_status["budget_status"]:
                    self.stats("=== API BUDGET STATUS ===")
                    for sport_code, request_day, used, limit_, remaining in db_status["budget_status"]:
                        self.stats(f"{request_day} | {sport_code}: used={used}, limit={limit_}, remaining={remaining}")
                    self.stats("")

                if db_status["request_overview"]:
                    self.stats("=== API REQUEST OVERVIEW ===")
                    for provider, account_name, sport_code, request_count in db_status["request_overview"]:
                        self.stats(f"{provider} | {account_name} | {sport_code} | requests={request_count}")
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

        self.update_cards(summary, git_status, db_status)

        report_md = run_dir / "MATCHMATRIX_AUDIT_REPORT.md"
        technical_lines = []

        technical_lines.append("# TicketMatrixPlatform – technický audit")
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

            technical_lines.append("- API budget status:")
            technical_lines.extend([
                f"  - {sport_code} | {request_day} | used={used} | limit={limit_} | remaining={remaining}"
                for sport_code, request_day, used, limit_, remaining in db_status["budget_status"]
            ])
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

        (REPORT_ROOT / "latest_report.md").write_text(report_md.read_text(encoding="utf-8"), encoding="utf-8")
        if progress_md:
            (REPORT_ROOT / "latest_progress.md").write_text(progress_md.read_text(encoding="utf-8"), encoding="utf-8")

        save_csv(REPORT_ROOT / "latest_files.csv", current_rows, ["relative_path", "path", "size_bytes", "created_at", "modified_at", "mtime_epoch"])
        save_csv(REPORT_ROOT / "latest_changes.csv", changes, ["change_type", "relative_path", "path", "size_bytes", "created_at", "modified_at", "mtime_epoch"])

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
    app = MissionControlV6()
    app.root.mainloop()


if __name__ == "__main__":
    main()