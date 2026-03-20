from __future__ import annotations

import os
import subprocess
import threading
import tkinter as tk
from datetime import datetime
from tkinter import scrolledtext, ttk

import psycopg2


# ============================================================
# MATCHMATRIX CONTROL PANEL V4
# SPORTS + ENTITIES + RUN_GROUP DB DRIVEN
# ============================================================

BASE_DIR = r"C:\MatchMatrix-platform"
PYTHON_EXE = r"C:\Python314\python.exe"

BATCH_RUNNER = os.path.join(BASE_DIR, "ingest", "run_unified_ingest_batch_v1.py")
SCHEDULER_RUNNER = os.path.join(BASE_DIR, "workers", "run_multisport_scheduler_v4.py")

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

FALLBACK_RUN_GROUP_OPTIONS = [
    "FOOTBALL_MAINTENANCE",
    "FOOTBALL_MAINTENANCE_TOP",
    "MAINTENANCE_FREE",
    "BACKFILL_FREE_2022",
    "BACKFILL_FREE_2023",
    "BACKFILL_FREE_2024",
    "MAINTENANCE_PRO",
    "BACKFILL_PRO_RECENT",
]

DEFAULT_PROVIDER_BY_SPORT = {
    "football": "api_football",
    "hockey": "api_hockey",
    "basketball": "api_basketball",
    "tennis": "api_tennis",
    "mma": "api_mma",
    "volleyball": "api_volleyball",
    "handball": "api_handball",
    "baseball": "api_baseball",
    "rugby": "api_rugby",
    "cricket": "api_cricket",
    "field_hockey": "api_field_hockey",
    "american_football": "api_american_football",
    "esports": "api_esports",
}


class MatchMatrixPanelV4:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("MatchMatrix Control Panel V4")
        self.root.geometry("1320x840")

        self.is_running = False

        self.db_sport_options: list[str] = []
        self.db_run_group_options: list[str] = []
        self.db_entity_options: list[str] = []

        self.build_header()
        self.build_selection_area()
        self.build_action_area()
        self.build_log_area()

        self.refresh_dynamic_options(initial=True)

    # --------------------------------------------------------
    # DB loaders
    # --------------------------------------------------------

    def get_connection(self):
        return psycopg2.connect(**DB_CONFIG)

    def load_sports_from_db(self) -> list[str]:
        sql = """
            SELECT DISTINCT sport_code
            FROM ops.ingest_targets
            WHERE enabled = TRUE
              AND COALESCE(BTRIM(sport_code), '') <> ''
            ORDER BY sport_code
        """
        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                return [row[0] for row in cur.fetchall()]
        finally:
            conn.close()

    def load_run_groups_from_db(self) -> list[str]:
        sql = """
            SELECT DISTINCT run_group
            FROM ops.ingest_targets
            WHERE enabled = TRUE
              AND COALESCE(BTRIM(run_group), '') <> ''
            ORDER BY run_group
        """
        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                return [row[0] for row in cur.fetchall()]
        finally:
            conn.close()

    def load_entities_from_db(self) -> list[str]:
        sql = """
            SELECT DISTINCT entity
            FROM ops.ingest_entity_plan
            WHERE enabled = TRUE
              AND COALESCE(BTRIM(entity), '') <> ''
            ORDER BY priority, entity
        """
        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                return [row[0] for row in cur.fetchall()]
        finally:
            conn.close()

    def refresh_dynamic_options(self, initial: bool = False) -> None:
        try:
            sports = self.load_sports_from_db()
            run_groups = self.load_run_groups_from_db()
            entities = self.load_entities_from_db()

            if not sports:
                sports = list(DEFAULT_PROVIDER_BY_SPORT.keys())

            if not run_groups:
                run_groups = FALLBACK_RUN_GROUP_OPTIONS[:]

            if not entities:
                entities = [
                    "leagues",
                    "teams",
                    "fixtures",
                    "odds",
                    "players",
                    "player_profiles",
                    "player_season_stats",
                    "player_stats",
                ]

            self.db_sport_options = sports
            self.db_run_group_options = run_groups
            self.db_entity_options = entities

            self.reload_sports_listbox()
            self.reload_run_group_combobox()
            self.reload_entities_listbox()

            if not initial:
                self.log_write("Dynamické volby načteny z DB.")
                self.log_write(f"Sporty: {', '.join(self.db_sport_options)}")
                self.log_write(f"Run groups: {', '.join(self.db_run_group_options)}")
                self.log_write(f"Entity: {', '.join(self.db_entity_options)}")

        except Exception as e:
            self.db_sport_options = list(DEFAULT_PROVIDER_BY_SPORT.keys())
            self.db_run_group_options = FALLBACK_RUN_GROUP_OPTIONS[:]
            self.db_entity_options = [
                "leagues",
                "teams",
                "fixtures",
                "odds",
                "players",
                "player_profiles",
                "player_season_stats",
                "player_stats",
            ]

            self.reload_sports_listbox()
            self.reload_run_group_combobox()
            self.reload_entities_listbox()

            if not initial:
                self.log_write(f"DB load warning: {e}")
                self.log_write("Použit fallback seznam sportů, entity a run_group.")

    # --------------------------------------------------------
    # UI
    # --------------------------------------------------------

    def build_header(self) -> None:
        header_frame = tk.Frame(self.root)
        header_frame.pack(fill="x", padx=10, pady=10)

        title = tk.Label(
            header_frame,
            text="MatchMatrix Control Panel V4",
            font=("Arial", 16, "bold"),
        )
        title.pack(anchor="w")

        subtitle = tk.Label(
            header_frame,
            text="Multi-sport + Multi-entity batch launcher (DB-driven sports/entities/run_groups)",
            font=("Arial", 10),
        )
        subtitle.pack(anchor="w")

    def build_selection_area(self) -> None:
        selection_frame = tk.LabelFrame(self.root, text="Batch výběr")
        selection_frame.pack(fill="x", padx=10, pady=5)

        # Levý blok: sporty
        sports_frame = tk.Frame(selection_frame)
        sports_frame.grid(row=0, column=0, padx=10, pady=10, sticky="nw")

        sports_label = tk.Label(sports_frame, text="Sporty")
        sports_label.pack(anchor="w")

        self.sports_listbox = tk.Listbox(
            sports_frame,
            selectmode=tk.MULTIPLE,
            exportselection=False,
            height=12,
            width=28,
        )
        self.sports_listbox.pack()

        sports_btn_frame = tk.Frame(sports_frame)
        sports_btn_frame.pack(fill="x", pady=5)

        tk.Button(
            sports_btn_frame,
            text="Vybrat vše",
            command=lambda: self.select_all(self.sports_listbox),
        ).pack(side="left", padx=2)

        tk.Button(
            sports_btn_frame,
            text="Vymazat",
            command=lambda: self.clear_selection(self.sports_listbox),
        ).pack(side="left", padx=2)

        tk.Button(
            sports_btn_frame,
            text="Refresh DB",
            command=self.refresh_dynamic_options,
        ).pack(side="left", padx=2)

        # Prostřední blok: entity
        entities_frame = tk.Frame(selection_frame)
        entities_frame.grid(row=0, column=1, padx=10, pady=10, sticky="nw")

        entities_label = tk.Label(entities_frame, text="Entity")
        entities_label.pack(anchor="w")

        self.entities_listbox = tk.Listbox(
            entities_frame,
            selectmode=tk.MULTIPLE,
            exportselection=False,
            height=12,
            width=28,
        )
        self.entities_listbox.pack()

        entities_btn_frame = tk.Frame(entities_frame)
        entities_btn_frame.pack(fill="x", pady=5)

        tk.Button(
            entities_btn_frame,
            text="Vybrat vše",
            command=lambda: self.select_all(self.entities_listbox),
        ).pack(side="left", padx=2)

        tk.Button(
            entities_btn_frame,
            text="Vymazat",
            command=lambda: self.clear_selection(self.entities_listbox),
        ).pack(side="left", padx=2)

        # Pravý blok: parametry
        params_frame = tk.Frame(selection_frame)
        params_frame.grid(row=0, column=2, padx=10, pady=10, sticky="nw")

        tk.Label(params_frame, text="Provider režim").grid(row=0, column=0, sticky="w", pady=3)
        self.provider_mode_var = tk.StringVar(value="auto")
        self.provider_mode_combo = ttk.Combobox(
            params_frame,
            textvariable=self.provider_mode_var,
            values=["auto", "manual"],
            state="readonly",
            width=24,
        )
        self.provider_mode_combo.grid(row=0, column=1, sticky="w", pady=3)
        self.provider_mode_combo.bind("<<ComboboxSelected>>", self.on_provider_mode_changed)

        tk.Label(params_frame, text="Manual provider").grid(row=1, column=0, sticky="w", pady=3)
        self.manual_provider_var = tk.StringVar(value="api_football")
        self.manual_provider_entry = tk.Entry(
            params_frame,
            textvariable=self.manual_provider_var,
            width=27,
            state="disabled",
        )
        self.manual_provider_entry.grid(row=1, column=1, sticky="w", pady=3)

        tk.Label(params_frame, text="Run group / režim").grid(row=2, column=0, sticky="w", pady=3)
        self.run_group_var = tk.StringVar(value="")
        self.run_group_combo = ttk.Combobox(
            params_frame,
            textvariable=self.run_group_var,
            values=[],
            state="readonly",
            width=24,
        )
        self.run_group_combo.grid(row=2, column=1, sticky="w", pady=3)

        tk.Label(params_frame, text="Limit").grid(row=3, column=0, sticky="w", pady=3)
        self.limit_var = tk.StringVar(value="5")
        self.limit_entry = tk.Entry(params_frame, textvariable=self.limit_var, width=27)
        self.limit_entry.grid(row=3, column=1, sticky="w", pady=3)

        tk.Label(params_frame, text="Max workers").grid(row=4, column=0, sticky="w", pady=3)
        self.max_workers_var = tk.StringVar(value="3")
        self.max_workers_entry = tk.Entry(params_frame, textvariable=self.max_workers_var, width=27)
        self.max_workers_entry.grid(row=4, column=1, sticky="w", pady=3)

        tk.Label(params_frame, text="Timeout sec").grid(row=5, column=0, sticky="w", pady=3)
        self.timeout_sec_var = tk.StringVar(value="300")
        self.timeout_sec_entry = tk.Entry(params_frame, textvariable=self.timeout_sec_var, width=27)
        self.timeout_sec_entry.grid(row=5, column=1, sticky="w", pady=3)

        tk.Label(params_frame, text="Profil entit").grid(row=6, column=0, sticky="w", pady=3)
        self.profile_var = tk.StringVar(value="custom")
        self.profile_combo = ttk.Combobox(
            params_frame,
            textvariable=self.profile_var,
            values=["custom", "core_ingest", "full_ingest", "players_only", "fixtures_only"],
            state="readonly",
            width=24,
        )
        self.profile_combo.grid(row=6, column=1, sticky="w", pady=3)
        self.profile_combo.bind("<<ComboboxSelected>>", self.on_profile_changed)

        tk.Label(
            params_frame,
            text="Sporty + entity + run_group se načítají z DB.",
            font=("Arial", 9),
            justify="left",
        ).grid(row=7, column=0, columnspan=2, sticky="w", pady=(8, 0))

    def build_action_area(self) -> None:
        action_frame = tk.LabelFrame(self.root, text="Akce")
        action_frame.pack(fill="x", padx=10, pady=5)

        tk.Button(
            action_frame,
            text="Spustit batch kombinace",
            width=24,
            command=self.run_batch_combinations_thread,
        ).pack(side="left", padx=5, pady=8)

        tk.Button(
            action_frame,
            text="Spustit multisport scheduler V4",
            width=24,
            command=self.run_scheduler_thread,
        ).pack(side="left", padx=5, pady=8)

        tk.Button(
            action_frame,
            text="Refresh sporty + entity + run_group z DB",
            width=32,
            command=self.refresh_dynamic_options,
        ).pack(side="left", padx=5, pady=8)

    def build_log_area(self) -> None:
        log_frame = tk.LabelFrame(self.root, text="Log")
        log_frame.pack(fill="both", expand=True, padx=10, pady=5)

        self.log_text = scrolledtext.ScrolledText(
            log_frame,
            wrap=tk.WORD,
            font=("Consolas", 10),
        )
        self.log_text.pack(fill="both", expand=True, padx=5, pady=5)

    # --------------------------------------------------------
    # UI helpers
    # --------------------------------------------------------

    def reload_sports_listbox(self) -> None:
        current_selection = [
            self.sports_listbox.get(i)
            for i in self.sports_listbox.curselection()
        ]

        self.sports_listbox.delete(0, tk.END)

        for sport in self.db_sport_options:
            self.sports_listbox.insert(tk.END, sport)

        for idx, sport in enumerate(self.db_sport_options):
            if sport in current_selection:
                self.sports_listbox.selection_set(idx)

    def reload_entities_listbox(self) -> None:
        current_selection = [
            self.entities_listbox.get(i)
            for i in self.entities_listbox.curselection()
        ]

        self.entities_listbox.delete(0, tk.END)

        for entity in self.db_entity_options:
            self.entities_listbox.insert(tk.END, entity)

        for idx, entity in enumerate(self.db_entity_options):
            if entity in current_selection:
                self.entities_listbox.selection_set(idx)

    def reload_run_group_combobox(self) -> None:
        current_value = self.run_group_var.get()
        self.run_group_combo["values"] = self.db_run_group_options

        if current_value and current_value in self.db_run_group_options:
            self.run_group_var.set(current_value)
        elif self.db_run_group_options:
            self.run_group_var.set(self.db_run_group_options[0])
        else:
            self.run_group_var.set("")

    def select_all(self, listbox: tk.Listbox) -> None:
        listbox.select_set(0, tk.END)

    def clear_selection(self, listbox: tk.Listbox) -> None:
        listbox.selection_clear(0, tk.END)

    def log_write(self, message: str) -> None:
        ts = datetime.now().strftime("%H:%M:%S")
        self.log_text.insert(tk.END, f"[{ts}] {message}\n")
        self.log_text.see(tk.END)
        self.root.update_idletasks()

    def on_provider_mode_changed(self, event=None) -> None:
        mode = self.provider_mode_var.get()
        if mode == "manual":
            self.manual_provider_entry.config(state="normal")
        else:
            self.manual_provider_entry.config(state="disabled")

    def on_profile_changed(self, event=None) -> None:
        profile = self.profile_var.get()

        profile_map = {
            "core_ingest": ["leagues", "teams", "fixtures", "odds"],
            "full_ingest": [
                "leagues",
                "teams",
                "fixtures",
                "odds",
                "players",
                "player_profiles",
                "player_season_stats",
                "player_stats",
            ],
            "players_only": [
                "players",
                "player_profiles",
                "player_season_stats",
                "player_stats",
            ],
            "fixtures_only": ["fixtures", "odds"],
        }

        if profile == "custom":
            return

        wanted = profile_map.get(profile, [])
        self.entities_listbox.selection_clear(0, tk.END)

        for idx, entity in enumerate(self.db_entity_options):
            if entity in wanted:
                self.entities_listbox.selection_set(idx)

        self.log_write(f"Použit profil entit: {profile}")

    # --------------------------------------------------------
    # Commands
    # --------------------------------------------------------

    def get_selected_sports(self) -> list[str]:
        return [self.sports_listbox.get(i) for i in self.sports_listbox.curselection()]

    def get_selected_entities(self) -> list[str]:
        return [self.entities_listbox.get(i) for i in self.entities_listbox.curselection()]

    def resolve_provider_for_sport(self, sport: str) -> str:
        if self.provider_mode_var.get() == "manual":
            provider = self.manual_provider_var.get().strip()
            return provider if provider else DEFAULT_PROVIDER_BY_SPORT.get(sport, f"api_{sport}")
        return DEFAULT_PROVIDER_BY_SPORT.get(sport, f"api_{sport}")

    def run_batch_combinations_thread(self) -> None:
        thread = threading.Thread(target=self.run_batch_combinations, daemon=True)
        thread.start()

    def run_scheduler_thread(self) -> None:
        thread = threading.Thread(target=self.run_scheduler, daemon=True)
        thread.start()

    def run_scheduler(self) -> None:
        cmd = [PYTHON_EXE, SCHEDULER_RUNNER]
        self.log_write("Spouštím scheduler:")
        self.log_write(" ".join(cmd))
        self.run_command_stream(cmd)

    def run_batch_combinations(self) -> None:
        selected_sports = self.get_selected_sports()
        selected_entities = self.get_selected_entities()

        if not selected_sports:
            self.log_write("Není vybrán žádný sport.")
            return

        if not selected_entities:
            self.log_write("Není vybrána žádná entity.")
            return

        run_group = self.run_group_var.get().strip()
        limit = self.limit_var.get().strip() or "5"
        max_workers = self.max_workers_var.get().strip() or "3"
        timeout_sec = self.timeout_sec_var.get().strip() or "300"

        for sport in selected_sports:
            provider = self.resolve_provider_for_sport(sport)

            for entity in selected_entities:
                cmd = [
                    PYTHON_EXE,
                    BATCH_RUNNER,
                    "--provider", provider,
                    "--sport", sport,
                    "--entity", entity,
                    "--limit", limit,
                    "--max-workers", max_workers,
                    "--timeout-sec", timeout_sec,
                ]

                if run_group:
                    cmd.extend(["--run-group", run_group])

                self.log_write("=" * 70)
                self.log_write(f"Spouštím batch: sport={sport}, entity={entity}, provider={provider}")
                self.log_write("CMD: " + " ".join(cmd))
                self.run_command_stream(cmd)

    def run_command_stream(self, cmd: list[str]) -> None:
        try:
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
                universal_newlines=True,
            )

            assert process.stdout is not None
            for line in process.stdout:
                self.log_write(line.rstrip())

            process.wait()

            if process.returncode == 0:
                self.log_write("Hotovo OK.")
            else:
                self.log_write(f"Proces skončil s chybovým kódem: {process.returncode}")

        except Exception as e:
            self.log_write(f"CHYBA při spuštění procesu: {e}")


def main():
    root = tk.Tk()
    app = MatchMatrixPanelV4(root)
    root.mainloop()


if __name__ == "__main__":
    main()