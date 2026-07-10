# -*- coding: utf-8 -*-
from __future__ import annotations

import os
import py_compile
import tempfile
from pathlib import Path

PATCH_MARKER = "V20.1.Q3 STEP 09 - A17 FINDINGS UI"

TARGETS = [
    Path(r"C:\MatchMatrix-Platform\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"),
    Path(r"\\192.168.3.119\matchmatrix\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"),
]

REPLACEMENTS = [('        self.documentation_workflow_last_status = "NEVYBRÁN DOKUMENT"\n        self.documentation_workflow_last_output = None\n        self.documentation_workflow_process = None\n        self.documentation_workflow_running = False\n', '        self.documentation_workflow_last_status = "NEVYBRÁN DOKUMENT"\n        self.documentation_workflow_last_output = None\n\n        # V20.1.Q3 STEP 09 - A17 FINDINGS UI\n        self.documentation_workflow_findings = []\n        self.documentation_workflow_report_json = None\n        self.documentation_workflow_report_markdown = None\n\n        self.documentation_workflow_process = None\n        self.documentation_workflow_running = False\n', 'runtime stav A17'), ('        self.make_button(\n            workflow_action_bar,\n            "🔎 A17 AUDIT",\n            "#0f6a42",\n            self.documentation_run_a17\n        )\n', '        self.make_button(\n            workflow_action_bar,\n            "🔎 A17 AUDIT",\n            "#0f6a42",\n            self.documentation_run_a17\n        )\n        self.make_button(\n            workflow_action_bar,\n            "📋 A17 NÁLEZY",\n            "#7b4ab8",\n            self.documentation_show_a17_findings\n        )\n        self.make_button(\n            workflow_action_bar,\n            "📄 OTEVŘÍT REPORT",\n            "#355c8a",\n            self.documentation_open_a17_report\n        )\n', 'tlačítka A17'), ('        self.documentation_workflow_workspace_value.grid(\n            row=3,\n            column=3,\n            sticky="ew",\n            padx=(0, 8),\n            pady=(2, 6)\n        )\n\n        self._documentation_update_workflow_ui()\n', '        self.documentation_workflow_workspace_value.grid(\n            row=3,\n            column=3,\n            sticky="ew",\n            padx=(0, 8),\n            pady=(2, 6)\n        )\n\n        tk.Label(\n            documentation_workflow_frame,\n            text="A17 NÁLEZY:",\n            bg="#100918",\n            fg=MUTED,\n            font=("Segoe UI", 8, "bold"),\n            anchor="w"\n        ).grid(\n            row=4,\n            column=0,\n            sticky="w",\n            padx=(8, 4),\n            pady=(2, 7)\n        )\n\n        self.documentation_workflow_findings_value = tk.Label(\n            documentation_workflow_frame,\n            text="-",\n            bg="#100918",\n            fg=MUTED,\n            font=("Segoe UI", 8, "bold"),\n            anchor="w",\n            justify="left",\n            wraplength=1050\n        )\n        self.documentation_workflow_findings_value.grid(\n            row=4,\n            column=1,\n            columnspan=3,\n            sticky="ew",\n            padx=(0, 8),\n            pady=(2, 7)\n        )\n\n        self._documentation_update_workflow_ui()\n', 'GUI řádek A17 nálezů'), ('            self.documentation_workflow_status_value.config(\n                text=status_text,\n                fg=status_color\n            )\n\n\n    def documentation_select_source_document(self):\n', '            self.documentation_workflow_status_value.config(\n                text=status_text,\n                fg=status_color\n            )\n\n        if hasattr(self, "documentation_workflow_findings_value"):\n            all_findings = list(\n                getattr(self, "documentation_workflow_findings", []) or []\n            )\n            problem_findings = [\n                item\n                for item in all_findings\n                if isinstance(item, dict)\n                and str(item.get("result", "")).strip().upper() != "PASS"\n            ]\n\n            report_ready = bool(\n                getattr(self, "documentation_workflow_report_json", None)\n                or getattr(\n                    self,\n                    "documentation_workflow_report_markdown",\n                    None\n                )\n            )\n\n            if not report_ready:\n                findings_text = "-"\n                findings_color = MUTED\n            elif not problem_findings:\n                findings_text = (\n                    f"BEZ PROBLÉMOVÝCH NÁLEZŮ | "\n                    f"KONTROLY CELKEM: {len(all_findings)}"\n                )\n                findings_color = GREEN\n            else:\n                result_parts = []\n                for result_name in ("FAIL", "PARTIAL", "MANUAL_REVIEW"):\n                    result_count = sum(\n                        1\n                        for item in problem_findings\n                        if str(\n                            item.get("result", "")\n                        ).strip().upper() == result_name\n                    )\n                    if result_count:\n                        result_parts.append(\n                            f"{result_name}: {result_count}"\n                        )\n\n                findings_text = f"K ŘEŠENÍ: {len(problem_findings)}"\n                if result_parts:\n                    findings_text += " | " + " | ".join(result_parts)\n\n                serious = any(\n                    str(item.get("result", "")).strip().upper() == "FAIL"\n                    or str(\n                        item.get("severity", "")\n                    ).strip().upper() in ("CRITICAL", "HIGH")\n                    for item in problem_findings\n                )\n                findings_color = RED if serious else YELLOW\n\n            self.documentation_workflow_findings_value.config(\n                text=findings_text,\n                fg=findings_color\n            )\n\n\n    def documentation_select_source_document(self):\n', 'aktualizace GUI A17'), ('        self.documentation_workflow_last_output = source_snapshot\n        self.documentation_workflow_process = None\n', '        self.documentation_workflow_last_output = source_snapshot\n        self.documentation_workflow_findings = []\n        self.documentation_workflow_report_json = None\n        self.documentation_workflow_report_markdown = None\n        self.documentation_workflow_process = None\n', 'reset při výběru dokumentu'), ('        self.documentation_workflow_last_status = (\n            "A17 BĚŽÍ NA PC2"\n        )\n        self.documentation_workflow_last_output = None\n        self.documentation_workflow_process = None\n', '        self.documentation_workflow_last_status = (\n            "A17 BĚŽÍ NA PC2"\n        )\n        self.documentation_workflow_last_output = None\n        self.documentation_workflow_findings = []\n        self.documentation_workflow_report_json = None\n        self.documentation_workflow_report_markdown = None\n        self.documentation_workflow_process = None\n', 'reset při spuštění A17'), ('            self.documentation_workflow_last_output = (\n                report_md_path\n            )\n\n            self._documentation_update_workflow_ui()\n', '            self.documentation_workflow_last_output = (\n                report_md_path\n            )\n            self.documentation_workflow_findings = list(\n                report_payload.get("findings") or []\n            )\n            self.documentation_workflow_report_json = (\n                report_json_path\n                if os.path.isfile(report_json_path)\n                else None\n            )\n            self.documentation_workflow_report_markdown = (\n                report_md_path\n                if os.path.isfile(report_md_path)\n                else None\n            )\n\n            self._documentation_update_workflow_ui()\n', 'uložení findings po A17'), ('        self.documentation_workflow_last_output = (\n            stdout_path or output_text\n        )\n\n        self._documentation_update_workflow_ui()\n', '        self.documentation_workflow_last_output = (\n            stdout_path or output_text\n        )\n        self.documentation_workflow_findings = []\n        self.documentation_workflow_report_json = None\n        self.documentation_workflow_report_markdown = None\n\n        self._documentation_update_workflow_ui()\n', 'reset findings při chybě A17'), ('    def open_matchmatrix_path(self, relative_path):\n', '    def _documentation_a17_problem_findings(self):\n        # V20.1.Q3 STEP 09 - pouze kontroly vyžadující pozornost.\n        findings = list(\n            getattr(self, "documentation_workflow_findings", []) or []\n        )\n        return [\n            item\n            for item in findings\n            if isinstance(item, dict)\n            and str(item.get("result", "")).strip().upper() != "PASS"\n        ]\n\n\n    def documentation_open_a17_report(self):\n        # V20.1.Q3 STEP 09 - otevře Markdown nebo JSON report.\n        report_path = (\n            getattr(\n                self,\n                "documentation_workflow_report_markdown",\n                None\n            )\n            or getattr(\n                self,\n                "documentation_workflow_report_json",\n                None\n            )\n        )\n\n        if not report_path:\n            messagebox.showwarning(\n                "A17 – report",\n                "Nejprve spusť audit A17."\n            )\n            return\n\n        if not os.path.isfile(report_path):\n            messagebox.showerror(\n                "A17 – report",\n                f"Report nebyl nalezen:\\\\n\\\\n{report_path}"\n            )\n            return\n\n        try:\n            os.startfile(report_path)\n        except Exception as exc:\n            messagebox.showerror(\n                "A17 – report",\n                f"Report se nepodařilo otevřít:\\\\n\\\\n{exc}"\n            )\n\n\n    def documentation_show_a17_findings(self):\n        # V20.1.Q3 STEP 09 - samostatné okno detailu nálezů.\n        all_findings = list(\n            getattr(self, "documentation_workflow_findings", []) or []\n        )\n\n        report_ready = bool(\n            getattr(self, "documentation_workflow_report_json", None)\n            or getattr(\n                self,\n                "documentation_workflow_report_markdown",\n                None\n            )\n        )\n\n        if not report_ready:\n            messagebox.showwarning(\n                "A17 – nálezy",\n                "Nejprve spusť audit A17."\n            )\n            return\n\n        problem_findings = self._documentation_a17_problem_findings()\n\n        detail_window = tk.Toplevel(self)\n        detail_window.title("MatchMatrix – A17 – detail nálezů")\n        detail_window.geometry("1120x680")\n        detail_window.minsize(900, 560)\n        detail_window.configure(bg=PANEL_1)\n        detail_window.transient(self)\n        detail_window.columnconfigure(0, weight=1)\n        detail_window.rowconfigure(1, weight=3)\n        detail_window.rowconfigure(2, weight=2)\n\n        summary_text = (\n            f"Kontroly celkem: {len(all_findings)} | "\n            f"K řešení: {len(problem_findings)}"\n        )\n\n        tk.Label(\n            detail_window,\n            text=summary_text,\n            bg=PANEL_1,\n            fg=GREEN if not problem_findings else YELLOW,\n            font=("Segoe UI", 11, "bold"),\n            anchor="w"\n        ).grid(\n            row=0,\n            column=0,\n            sticky="ew",\n            padx=12,\n            pady=(12, 8)\n        )\n\n        table_frame = tk.Frame(detail_window, bg=PANEL_1)\n        table_frame.grid(\n            row=1,\n            column=0,\n            sticky="nsew",\n            padx=12,\n            pady=(0, 8)\n        )\n        table_frame.columnconfigure(0, weight=1)\n        table_frame.rowconfigure(0, weight=1)\n\n        columns = (\n            "rule_id",\n            "result",\n            "severity",\n            "category",\n            "title"\n        )\n        findings_tree = ttk.Treeview(\n            table_frame,\n            columns=columns,\n            show="headings",\n            selectmode="browse"\n        )\n\n        headings = {\n            "rule_id": "PRAVIDLO",\n            "result": "VÝSLEDEK",\n            "severity": "ZÁVAŽNOST",\n            "category": "KATEGORIE",\n            "title": "NÁZEV",\n        }\n        widths = {\n            "rule_id": 190,\n            "result": 145,\n            "severity": 100,\n            "category": 125,\n            "title": 420,\n        }\n\n        for column_name in columns:\n            findings_tree.heading(\n                column_name,\n                text=headings[column_name]\n            )\n            findings_tree.column(\n                column_name,\n                width=widths[column_name],\n                anchor=(\n                    "w"\n                    if column_name in ("rule_id", "title")\n                    else "center"\n                ),\n                stretch=(column_name == "title")\n            )\n\n        scrollbar_y = ttk.Scrollbar(\n            table_frame,\n            orient="vertical",\n            command=findings_tree.yview\n        )\n        scrollbar_x = ttk.Scrollbar(\n            table_frame,\n            orient="horizontal",\n            command=findings_tree.xview\n        )\n        findings_tree.configure(\n            yscrollcommand=scrollbar_y.set,\n            xscrollcommand=scrollbar_x.set\n        )\n\n        findings_tree.grid(row=0, column=0, sticky="nsew")\n        scrollbar_y.grid(row=0, column=1, sticky="ns")\n        scrollbar_x.grid(row=1, column=0, sticky="ew")\n\n        detail_text = tk.Text(\n            detail_window,\n            bg="#0e0915",\n            fg=TEXT,\n            insertbackground=TEXT,\n            relief="flat",\n            wrap="word",\n            font=("Consolas", 10),\n            padx=10,\n            pady=10\n        )\n        detail_text.grid(\n            row=2,\n            column=0,\n            sticky="nsew",\n            padx=12,\n            pady=(0, 8)\n        )\n        detail_text.config(state="disabled")\n\n        for finding_index, finding in enumerate(problem_findings):\n            findings_tree.insert(\n                "",\n                "end",\n                iid=str(finding_index),\n                values=(\n                    finding.get("rule_id", "-"),\n                    finding.get("result", "-"),\n                    finding.get("severity", "-"),\n                    finding.get("category", "-"),\n                    finding.get("title", "-")\n                )\n            )\n\n        def render_finding_detail(event=None):\n            selected = findings_tree.selection()\n            if not selected:\n                return\n\n            try:\n                finding = problem_findings[int(selected[0])]\n            except Exception:\n                return\n\n            evidence = finding.get("evidence") or []\n            if isinstance(evidence, (list, tuple)):\n                evidence_text = "\\\\n".join(\n                    f"- {item}"\n                    for item in evidence\n                )\n            else:\n                evidence_text = str(evidence)\n\n            detail_lines = [\n                f"PRAVIDLO: {finding.get(\'rule_id\', \'-\')}",\n                f"NÁZEV: {finding.get(\'title\', \'-\')}",\n                f"VÝSLEDEK: {finding.get(\'result\', \'-\')}",\n                f"ZÁVAŽNOST: {finding.get(\'severity\', \'-\')}",\n                f"KATEGORIE: {finding.get(\'category\', \'-\')}",\n                f"STANDARD: {finding.get(\'standard\', \'-\')}",\n                "",\n                "POPIS:",\n                str(finding.get("description", "-")),\n                "",\n                "DŮKAZY:",\n                evidence_text or "-",\n                "",\n                "DOPORUČENÍ:",\n                str(finding.get("recommendation", "-")),\n            ]\n\n            detail_text.config(state="normal")\n            detail_text.delete("1.0", "end")\n            detail_text.insert("1.0", "\\\\n".join(detail_lines))\n            detail_text.config(state="disabled")\n\n        findings_tree.bind(\n            "<<TreeviewSelect>>",\n            render_finding_detail\n        )\n\n        if problem_findings:\n            findings_tree.selection_set("0")\n            findings_tree.focus("0")\n            findings_tree.see("0")\n            render_finding_detail()\n        else:\n            detail_text.config(state="normal")\n            detail_text.insert(\n                "1.0",\n                (\n                    "Audit neobsahuje žádný nález typu FAIL, "\n                    "PARTIAL nebo MANUAL_REVIEW.\\\\n\\\\n"\n                    "Úplný výsledek je dostupný v reportu A17."\n                )\n            )\n            detail_text.config(state="disabled")\n\n        button_frame = tk.Frame(detail_window, bg=PANEL_1)\n        button_frame.grid(\n            row=3,\n            column=0,\n            sticky="ew",\n            padx=12,\n            pady=(0, 12)\n        )\n\n        tk.Button(\n            button_frame,\n            text="OTEVŘÍT REPORT",\n            command=self.documentation_open_a17_report,\n            bg="#355c8a",\n            fg="white",\n            activebackground="#4270a6",\n            activeforeground="white",\n            relief="flat",\n            font=("Segoe UI", 9, "bold"),\n            padx=12,\n            pady=6,\n            cursor="hand2"\n        ).pack(side="left")\n\n        tk.Button(\n            button_frame,\n            text="ZAVŘÍT",\n            command=detail_window.destroy,\n            bg="#4c4257",\n            fg="white",\n            activebackground="#62566f",\n            activeforeground="white",\n            relief="flat",\n            font=("Segoe UI", 9, "bold"),\n            padx=12,\n            pady=6,\n            cursor="hand2"\n        ).pack(side="right")\n\n\n    def open_matchmatrix_path(self, relative_path):\n', 'metody detailu A17')]


def read_source(path):
    raw = path.read_bytes()
    has_bom = raw.startswith(b"\xef\xbb\xbf")
    if has_bom:
        raw = raw[3:]
    text = raw.decode("utf-8")
    newline = "\r\n" if "\r\n" in text else "\n"
    return text.replace("\r\n", "\n"), has_bom, newline


def patch_source(source):
    if PATCH_MARKER in source:
        return source

    patched = source

    for old, new, label in REPLACEMENTS:
        count = patched.count(old)
        if count != 1:
            raise RuntimeError(
                f"{label}: očekávána 1 kotva, nalezeno {count}."
            )
        patched = patched.replace(old, new, 1)

    return patched


def write_temp(target, source, has_bom, newline):
    payload = source.replace("\n", newline).encode("utf-8")
    if has_bom:
        payload = b"\xef\xbb\xbf" + payload

    handle = tempfile.NamedTemporaryFile(
        mode="wb",
        prefix=target.stem + "_STEP09_",
        suffix=".py",
        dir=str(target.parent),
        delete=False,
    )
    temp_path = Path(handle.name)

    try:
        handle.write(payload)
    finally:
        handle.close()

    return temp_path


def main():
    missing = [str(path) for path in TARGETS if not path.is_file()]
    if missing:
        print("ERROR: Chybí cílový soubor:")
        for item in missing:
            print(f"  - {item}")
        return 1

    staged = {}

    try:
        for target in TARGETS:
            source, has_bom, newline = read_source(target)
            patched = patch_source(source)

            if patched == source:
                print(f"ALREADY PATCHED: {target}")
                continue

            temp_path = write_temp(
                target,
                patched,
                has_bom,
                newline,
            )
            py_compile.compile(str(temp_path), doraise=True)
            staged[target] = temp_path

        for target, temp_path in staged.items():
            os.replace(temp_path, target)
            print(f"UPDATED: {target}")

        for target in TARGETS:
            py_compile.compile(str(target), doraise=True)
            print(f"PYTHON SYNTAX OK: {target}")

        if staged:
            print("FINAL STATUS: A17_FINDINGS_UI_PATCH_APPLIED")
        else:
            print("FINAL STATUS: A17_FINDINGS_UI_ALREADY_PRESENT")

        return 0

    except Exception as exc:
        print(f"ERROR: {exc}")

        for temp_path in staged.values():
            try:
                if temp_path.exists():
                    temp_path.unlink()
            except Exception:
                pass

        return 1


if __name__ == "__main__":
    raise SystemExit(main())
