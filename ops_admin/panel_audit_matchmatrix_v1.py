import csv
import hashlib
import json
import os
import sys
import subprocess
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
import tkinter as tk
from tkinter import ttk, messagebox

APP_TITLE = "MatchMatrix Audit Panel V1"

# ============================================================
# Nastavení cest projektu
# ============================================================
PATHS = {
    "workers": r"C:\MatchMatrix-platform\workers",
    "ingest": r"C:\MatchMatrix-platform\ingest",
    "api_football": r"C:\MatchMatrix-platform\ingest\API-Football",
    "scripts": r"C:\MatchMatrix-platform\MatchMatrix-platform\Scripts",
    "dump": r"C:\MatchMatrix-platform\MatchMatrix-platform\Dump",
}

DESKTOP = os.path.join(os.path.expanduser("~"), "Desktop")
DEFAULT_OUTPUT_BASE = os.path.join(DESKTOP, "MatchMatrix_Audit")

EXCLUDED_DIR_NAMES = {
    "__pycache__", ".git", ".venv", "venv", "node_modules"
}

TEXT_EXTS = {
    ".py", ".ps1", ".sql", ".md", ".txt", ".json", ".yml", ".yaml",
    ".ini", ".cfg", ".bat", ".cmd", ".psm1", ".csv"
}

# ============================================================
# Datové struktury
# ============================================================
@dataclass
class FileInfo:
    source_key: str
    root_path: str
    relative_path: str
    full_path: str
    extension: str
    size_bytes: int
    created_at: str
    modified_at: str


# ============================================================
# Pomocné funkce
# ============================================================
def ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def dt_to_str(ts: float) -> str:
    return datetime.fromtimestamp(ts).strftime("%Y-%m-%d %H:%M:%S")


def safe_read_text_head(filepath: str, max_bytes: int = 4000) -> str:
    try:
        with open(filepath, "rb") as f:
            raw = f.read(max_bytes)
        return raw.decode("utf-8", errors="replace")
    except Exception:
        return ""


def quick_signature(filepath: str) -> str:
    """
    Rychlý podpis souboru pro rozlišení MODIFIED.
    Není to plný hash, ale stačí pro audit změn mezi dny.
    """
    try:
        stat = os.stat(filepath)
        head = safe_read_text_head(filepath, 3000)
        payload = f"{stat.st_size}|{int(stat.st_mtime)}|{head[:1500]}".encode("utf-8", errors="replace")
        return hashlib.md5(payload).hexdigest()
    except Exception:
        return ""


def normalize(path: str) -> str:
    return os.path.normpath(path)


def walk_files(source_key: str, root_path: str):
    root_path = normalize(root_path)
    if not os.path.exists(root_path):
        return

    for dirpath, dirnames, filenames in os.walk(root_path):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDED_DIR_NAMES]
        for filename in filenames:
            full_path = os.path.join(dirpath, filename)
            try:
                stat = os.stat(full_path)
            except OSError:
                continue

            rel = os.path.relpath(full_path, root_path)
            ext = Path(filename).suffix.lower()
            yield FileInfo(
                source_key=source_key,
                root_path=root_path,
                relative_path=rel,
                full_path=full_path,
                extension=ext,
                size_bytes=stat.st_size,
                created_at=dt_to_str(stat.st_ctime),
                modified_at=dt_to_str(stat.st_mtime),
            )


def build_snapshot(selected_keys):
    files = []
    for key in selected_keys:
        root = PATHS[key]
        for fi in walk_files(key, root) or []:
            row = {
                "source_key": fi.source_key,
                "root_path": fi.root_path,
                "relative_path": fi.relative_path,
                "full_path": fi.full_path,
                "extension": fi.extension,
                "size_bytes": fi.size_bytes,
                "created_at": fi.created_at,
                "modified_at": fi.modified_at,
                "signature": quick_signature(fi.full_path),
            }
            files.append(row)
    files.sort(key=lambda x: (x["source_key"], x["relative_path"].lower()))
    return files


def load_previous_snapshot(output_base: str):
    latest = os.path.join(output_base, "latest_snapshot.json")
    if not os.path.exists(latest):
        return []
    try:
        with open(latest, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return []


def index_snapshot(snapshot_rows):
    return {
        f"{row['source_key']}|{row['relative_path'].lower()}": row
        for row in snapshot_rows
    }


def compare_snapshots(old_rows, new_rows):
    old_idx = index_snapshot(old_rows)
    new_idx = index_snapshot(new_rows)
    changes = []

    for key, new_row in new_idx.items():
        old_row = old_idx.get(key)
        if old_row is None:
            changes.append({
                "change_type": "NEW",
                **new_row,
                "old_size_bytes": "",
                "old_modified_at": "",
            })
        else:
            if (
                old_row.get("signature") != new_row.get("signature")
                or str(old_row.get("size_bytes")) != str(new_row.get("size_bytes"))
                or old_row.get("modified_at") != new_row.get("modified_at")
            ):
                changes.append({
                    "change_type": "MODIFIED",
                    **new_row,
                    "old_size_bytes": old_row.get("size_bytes", ""),
                    "old_modified_at": old_row.get("modified_at", ""),
                })

    for key, old_row in old_idx.items():
        if key not in new_idx:
            changes.append({
                "change_type": "DELETED",
                **old_row,
                "old_size_bytes": old_row.get("size_bytes", ""),
                "old_modified_at": old_row.get("modified_at", ""),
            })

    changes.sort(key=lambda x: (x["change_type"], x["source_key"], x["relative_path"].lower()))
    return changes


def summarize(snapshot_rows, changes):
    by_source = {}
    by_ext = {}
    for row in snapshot_rows:
        src = row["source_key"]
        by_source[src] = by_source.get(src, 0) + 1
        ext = row["extension"] or "[no_ext]"
        by_ext[ext] = by_ext.get(ext, 0) + 1

    by_change = {"NEW": 0, "MODIFIED": 0, "DELETED": 0}
    for ch in changes:
        by_change[ch["change_type"]] = by_change.get(ch["change_type"], 0) + 1

    latest_modified = sorted(snapshot_rows, key=lambda x: x["modified_at"], reverse=True)[:40]

    return {
        "files_total": len(snapshot_rows),
        "by_source": dict(sorted(by_source.items())),
        "by_extension": dict(sorted(by_ext.items(), key=lambda kv: (-kv[1], kv[0]))),
        "by_change": by_change,
        "latest_modified": latest_modified,
    }


def write_json(path: str, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def write_csv(path: str, rows):
    ensure_dir(os.path.dirname(path))
    if not rows:
        with open(path, "w", encoding="utf-8-sig", newline="") as f:
            f.write("")
        return
    fieldnames = list(rows[0].keys())
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def make_markdown_report(run_dt: datetime, selected_keys, summary, changes, run_folder: str):
    lines = []
    lines.append("# MatchMatrix – audit souborů")
    lines.append("")
    lines.append(f"**Datum spuštění:** {run_dt.strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"**Složka reportu:** `{run_folder}`")
    lines.append("")
    lines.append("## Kontrolované oblasti")
    lines.append("")
    for key in selected_keys:
        lines.append(f"- **{key}** → `{PATHS[key]}`")
    lines.append("")
    lines.append("## Souhrn")
    lines.append("")
    lines.append(f"- Celkem souborů: **{summary['files_total']}**")
    lines.append(f"- Nové soubory: **{summary['by_change'].get('NEW', 0)}**")
    lines.append(f"- Změněné soubory: **{summary['by_change'].get('MODIFIED', 0)}**")
    lines.append(f"- Smazané soubory: **{summary['by_change'].get('DELETED', 0)}**")
    lines.append("")

    lines.append("## Počet souborů podle oblasti")
    lines.append("")
    for key, cnt in summary["by_source"].items():
        lines.append(f"- {key}: **{cnt}**")
    lines.append("")

    lines.append("## Nejčastější typy souborů")
    lines.append("")
    for ext, cnt in list(summary["by_extension"].items())[:20]:
        lines.append(f"- {ext}: **{cnt}**")
    lines.append("")

    lines.append("## Poslední změněné soubory")
    lines.append("")
    for row in summary["latest_modified"][:25]:
        lines.append(
            f"- [{row['source_key']}] `{row['relative_path']}` | změna: {row['modified_at']} | velikost: {row['size_bytes']} B"
        )
    lines.append("")

    lines.append("## Změny oproti minulému běhu")
    lines.append("")
    if not changes:
        lines.append("- Nebyly zjištěny žádné změny oproti minulému snapshotu.")
    else:
        for ch_type in ["NEW", "MODIFIED", "DELETED"]:
            group = [x for x in changes if x["change_type"] == ch_type]
            if not group:
                continue
            lines.append(f"### {ch_type}")
            lines.append("")
            for row in group[:200]:
                extra = ""
                if ch_type == "MODIFIED":
                    extra = f" | původní změna: {row.get('old_modified_at', '')}"
                lines.append(
                    f"- [{row['source_key']}] `{row['relative_path']}` | změna: {row['modified_at']} | velikost: {row['size_bytes']} B{extra}"
                )
            if len(group) > 200:
                lines.append(f"- ... dalších {len(group) - 200} položek je v CSV reportu.")
            lines.append("")

    lines.append("## Vygenerované soubory")
    lines.append("")
    lines.append("- `snapshot.json`")
    lines.append("- `files.csv`")
    lines.append("- `changes.csv`")
    lines.append("- `report.md`")
    lines.append("")
    return "\n".join(lines)


def write_text(path: str, text: str):
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


def copy_latest(output_base: str, run_folder: str):
    pairs = [
        ("snapshot.json", "latest_snapshot.json"),
        ("files.csv", "latest_files.csv"),
        ("changes.csv", "latest_changes.csv"),
        ("report.md", "latest_report.md"),
    ]
    for src_name, dst_name in pairs:
        src = os.path.join(run_folder, src_name)
        dst = os.path.join(output_base, dst_name)
        with open(src, "rb") as fsrc, open(dst, "wb") as fdst:
            fdst.write(fsrc.read())


def open_path(path: str):
    try:
        if sys.platform.startswith("win"):
            os.startfile(path)  # type: ignore[attr-defined]
        elif sys.platform == "darwin":
            subprocess.Popen(["open", path])
        else:
            subprocess.Popen(["xdg-open", path])
    except Exception as e:
        messagebox.showwarning("Otevření souboru", f"Nepodařilo se otevřít:\n{path}\n\n{e}")


def run_audit(selected_keys, output_base: str):
    ensure_dir(output_base)
    now = datetime.now()
    date_folder = os.path.join(output_base, now.strftime("%Y-%m-%d"))
    run_folder = os.path.join(date_folder, now.strftime("%H%M%S"))
    ensure_dir(run_folder)

    old_snapshot = load_previous_snapshot(output_base)
    new_snapshot = build_snapshot(selected_keys)
    changes = compare_snapshots(old_snapshot, new_snapshot)
    summary = summarize(new_snapshot, changes)

    snapshot_path = os.path.join(run_folder, "snapshot.json")
    files_csv_path = os.path.join(run_folder, "files.csv")
    changes_csv_path = os.path.join(run_folder, "changes.csv")
    report_md_path = os.path.join(run_folder, "report.md")

    write_json(snapshot_path, new_snapshot)
    write_csv(files_csv_path, new_snapshot)
    write_csv(changes_csv_path, changes)
    report_md = make_markdown_report(now, selected_keys, summary, changes, run_folder)
    write_text(report_md_path, report_md)
    copy_latest(output_base, run_folder)

    return {
        "run_folder": run_folder,
        "report_md_path": report_md_path,
        "files_csv_path": files_csv_path,
        "changes_csv_path": changes_csv_path,
        "files_total": summary["files_total"],
        "new_count": summary["by_change"].get("NEW", 0),
        "modified_count": summary["by_change"].get("MODIFIED", 0),
        "deleted_count": summary["by_change"].get("DELETED", 0),
    }


# ============================================================
# GUI
# ============================================================
class AuditPanel(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title(APP_TITLE)
        self.geometry("980x760")
        self.minsize(920, 680)

        self.vars = {key: tk.BooleanVar(value=True) for key in PATHS.keys()}
        self.output_var = tk.StringVar(value=DEFAULT_OUTPUT_BASE)
        self.last_report_path = None
        self.last_run_folder = None

        self._build_ui()

    def _build_ui(self):
        root = ttk.Frame(self, padding=16)
        root.pack(fill="both", expand=True)

        title = ttk.Label(root, text="MatchMatrix Audit Panel V1", font=("Segoe UI", 18, "bold"))
        title.pack(anchor="w")

        subtitle = ttk.Label(
            root,
            text="Kontrola projektových souborů, změn oproti minulému běhu a ukládání reportů do složek podle data spuštění.",
            wraplength=900,
        )
        subtitle.pack(anchor="w", pady=(4, 14))

        top = ttk.LabelFrame(root, text="1. Výběr kontrolovaných oblastí", padding=12)
        top.pack(fill="x", pady=(0, 12))

        for key, path in PATHS.items():
            row = ttk.Frame(top)
            row.pack(fill="x", pady=4)
            ttk.Checkbutton(row, text=key, variable=self.vars[key]).pack(side="left")
            ttk.Label(row, text=path).pack(side="left", padx=14)

        controls = ttk.Frame(top)
        controls.pack(fill="x", pady=(8, 0))
        ttk.Button(controls, text="Vybrat vše", command=self.select_all).pack(side="left")
        ttk.Button(controls, text="Zrušit vše", command=self.clear_all).pack(side="left", padx=8)
        ttk.Button(controls, text="Pouze workers + ingest + API-Football", command=self.select_core).pack(side="left")

        out = ttk.LabelFrame(root, text="2. Výstupní složka", padding=12)
        out.pack(fill="x", pady=(0, 12))
        ttk.Label(out, text="Výstupy budou ukládány do podsložek YYYY-MM-DD\\HHMMSS").pack(anchor="w")
        out_row = ttk.Frame(out)
        out_row.pack(fill="x", pady=(8, 0))
        ttk.Entry(out_row, textvariable=self.output_var).pack(side="left", fill="x", expand=True)
        ttk.Button(out_row, text="Otevřít složku", command=self.open_output_base).pack(side="left", padx=8)

        actions = ttk.LabelFrame(root, text="3. Spuštění kontrol", padding=12)
        actions.pack(fill="x", pady=(0, 12))

        buttons = ttk.Frame(actions)
        buttons.pack(fill="x")
        ttk.Button(buttons, text="Spustit audit vybraných oblastí", command=self.run_selected).pack(side="left")
        ttk.Button(buttons, text="Spustit kompletní audit", command=self.run_all).pack(side="left", padx=8)
        ttk.Button(buttons, text="Otevřít poslední report", command=self.open_last_report).pack(side="left", padx=8)
        ttk.Button(buttons, text="Otevřít poslední složku běhu", command=self.open_last_run_folder).pack(side="left", padx=8)

        info = ttk.LabelFrame(root, text="4. Log a výstup", padding=12)
        info.pack(fill="both", expand=True)

        self.text = tk.Text(info, wrap="word", font=("Consolas", 10))
        self.text.pack(fill="both", expand=True)
        self.log("Panel připraven.")
        self.log(f"Výchozí výstupní složka: {DEFAULT_OUTPUT_BASE}")

    def log(self, msg: str):
        ts = datetime.now().strftime("%H:%M:%S")
        self.text.insert("end", f"[{ts}] {msg}\n")
        self.text.see("end")
        self.update_idletasks()

    def get_selected(self):
        return [k for k, var in self.vars.items() if var.get()]

    def select_all(self):
        for var in self.vars.values():
            var.set(True)
        self.log("Vybrány všechny oblasti.")

    def clear_all(self):
        for var in self.vars.values():
            var.set(False)
        self.log("Výběr vyčištěn.")

    def select_core(self):
        for k, var in self.vars.items():
            var.set(k in {"workers", "ingest", "api_football"})
        self.log("Vybrány základní ingest složky.")

    def open_output_base(self):
        ensure_dir(self.output_var.get())
        open_path(self.output_var.get())

    def open_last_report(self):
        if not self.last_report_path or not os.path.exists(self.last_report_path):
            messagebox.showinfo("Poslední report", "Zatím nebyl vytvořen žádný report v tomto běhu panelu.")
            return
        open_path(self.last_report_path)

    def open_last_run_folder(self):
        if not self.last_run_folder or not os.path.exists(self.last_run_folder):
            messagebox.showinfo("Poslední běh", "Zatím nebyla vytvořena žádná složka běhu v tomto běhu panelu.")
            return
        open_path(self.last_run_folder)

    def run_selected(self):
        selected = self.get_selected()
        if not selected:
            messagebox.showwarning("Audit", "Nejprve vyber alespoň jednu oblast.")
            return
        self._execute_audit(selected)

    def run_all(self):
        self._execute_audit(list(PATHS.keys()))

    def _execute_audit(self, selected):
        output_base = self.output_var.get().strip()
        if not output_base:
            messagebox.showwarning("Audit", "Výstupní složka nesmí být prázdná.")
            return

        self.log("=")
        self.log(f"Spouštím audit: {', '.join(selected)}")
        self.log(f"Výstupní složka: {output_base}")
        missing = [PATHS[k] for k in selected if not os.path.exists(PATHS[k])]
        if missing:
            self.log("Upozornění: některé cesty neexistují:")
            for p in missing:
                self.log(f" - {p}")

        try:
            result = run_audit(selected, output_base)
            self.last_report_path = result["report_md_path"]
            self.last_run_folder = result["run_folder"]
            self.log("Audit dokončen.")
            self.log(f"Složka běhu: {result['run_folder']}")
            self.log(f"Celkem souborů: {result['files_total']}")
            self.log(f"NEW={result['new_count']} | MODIFIED={result['modified_count']} | DELETED={result['deleted_count']}")
            self.log(f"Report: {result['report_md_path']}")
            self.log(f"CSV soubory: {result['files_csv_path']} | {result['changes_csv_path']}")
            messagebox.showinfo(
                "Audit hotov",
                "Audit byl dokončen.\n\n"
                f"Složka běhu:\n{result['run_folder']}\n\n"
                f"Souborů: {result['files_total']}\n"
                f"NEW: {result['new_count']}\n"
                f"MODIFIED: {result['modified_count']}\n"
                f"DELETED: {result['deleted_count']}"
            )
        except Exception as e:
            self.log(f"CHYBA: {e}")
            messagebox.showerror("Audit – chyba", str(e))


def main():
    app = AuditPanel()
    app.mainloop()


if __name__ == "__main__":
    main()
