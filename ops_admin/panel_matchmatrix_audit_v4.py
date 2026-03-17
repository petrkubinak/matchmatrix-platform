
import os
import subprocess
import datetime
from pathlib import Path
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox

PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
REPORT_ROOT = PROJECT_ROOT / "reports" / "audit"

WATCH_EXT = {".py",".ps1",".sql",".md",".json",".yml",".yaml",".txt",".csv",".bat",".cmd"}

IGNORE_DIRS = {".git","__pycache__",".venv","node_modules","reports"}

def scan_files(root):
    files = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS]
        for f in filenames:
            p = Path(dirpath) / f
            if p.suffix.lower() in WATCH_EXT:
                files.append((str(p), p.stat().st_mtime))
    return files

def get_git_status():
    try:
        branch = subprocess.check_output("git rev-parse --abbrev-ref HEAD", cwd=PROJECT_ROOT, shell=True).decode().strip()
        status = subprocess.check_output("git status --short", cwd=PROJECT_ROOT, shell=True).decode().strip()
        return branch, status
    except:
        return "unknown","git not available"

def count_db_mock():
    # placeholder numbers – in future can query PostgreSQL
    return {
        "Leagues":851,
        "Teams":2418,
        "Matches":1211,
        "Players":480
    }

def generate_progress_report(file_count, git_branch, git_changes):
    now = datetime.datetime.now()
    report = f"""
# MatchMatrix – denní přehled vývoje

Datum: {now.strftime("%Y-%m-%d")}
Čas auditu: {now.strftime("%H:%M")}

---

## Co je MatchMatrix

MatchMatrix je systém, který sbírá sportovní data,
ukládá je do databáze a připravuje statistiky pro analýzu
a budoucí predikce sportovních zápasů.

---

## Co se dnes zkontrolovalo

Projektová složka:
{PROJECT_ROOT}

Počet sledovaných souborů:
{file_count}

---

## Stav databáze (orientační)

"""
    db = count_db_mock()
    for k,v in db.items():
        report += f"{k}: {v}\n"

    report += f"""

---

## Stav Git repozitáře

Aktuální větev: {git_branch}

Změny:
{git_changes if git_changes else "žádné neuložené změny"}

---

## Co projekt aktuálně umí

✔ stahovat sportovní data  
✔ ukládat je do databáze  
✔ kontrolovat stav systému  
✔ auditovat změny v projektu  

---

## Doporučené další kroky

1. pokračovat ve vývoji statistik hráčů
2. připravit feature tabulky pro predikce
3. pravidelně ukládat změny do GitHub

"""
    return report

class Panel:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("MatchMatrix OPS Control Center V4")
        self.root.geometry("900x650")

        ttk.Label(self.root,text="MATCHMATRIX OPS CONTROL CENTER V4",font=("Segoe UI",16,"bold")).pack(pady=10)

        frame = ttk.Frame(self.root)
        frame.pack(pady=10)

        ttk.Button(frame,text="Spustit FULL AUDIT",command=self.full_audit,width=25).grid(row=0,column=0,padx=10)
        ttk.Button(frame,text="Otevřít audit složku",command=self.open_reports,width=25).grid(row=0,column=1,padx=10)
        ttk.Button(frame,text="Vyčistit log",command=self.clear_log,width=25).grid(row=0,column=2,padx=10)

        self.log = scrolledtext.ScrolledText(self.root,height=30)
        self.log.pack(fill="both",expand=True,padx=10,pady=10)

        self.write("Panel připraven.")

        self.root.mainloop()

    def write(self,msg):
        t = datetime.datetime.now().strftime("%H:%M:%S")
        self.log.insert(tk.END,f"[{t}] {msg}\n")
        self.log.see(tk.END)

    def clear_log(self):
        self.log.delete(1.0,tk.END)

    def open_reports(self):
        REPORT_ROOT.mkdir(parents=True,exist_ok=True)
        os.startfile(REPORT_ROOT)

    def full_audit(self):
        self.write("Spouštím audit projektu...")

        files = scan_files(PROJECT_ROOT)
        self.write(f"Nalezeno sledovaných souborů: {len(files)}")

        branch, git_status = get_git_status()
        self.write(f"Git branch: {branch}")

        report = generate_progress_report(len(files),branch,git_status)

        now = datetime.datetime.now()
        outdir = REPORT_ROOT / now.strftime("%Y-%m-%d") / now.strftime("%H-%M-%S")
        outdir.mkdir(parents=True,exist_ok=True)

        path = outdir / "MATCHMATRIX_PROGRESS.md"
        with open(path,"w",encoding="utf8") as f:
            f.write(report)

        self.write(f"Report vytvořen: {path}")
        self.write("Audit dokončen.")

if __name__ == "__main__":
    Panel()
