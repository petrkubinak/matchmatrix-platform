Set-Location "C:\MatchMatrix-Platform"

$Panel = "tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"
$History = "tools\histori\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW_STEP_03_RUNTIME_STATE.py"

if (-not (Test-Path $History)) {
    Copy-Item $Panel $History
}

$Text = [System.IO.File]::ReadAllText(
    (Resolve-Path $Panel),
    [System.Text.Encoding]::UTF8
)

function Replace-Exactly-Once {
    param(
        [string]$Source,
        [string]$OldValue,
        [string]$NewValue,
        [string]$Label
    )

    $Count = (
        [regex]::Matches(
            $Source,
            [regex]::Escape($OldValue)
        )
    ).Count

    if ($Count -ne 1) {
        throw "$Label – očekáván 1 výskyt, nalezeno: $Count"
    }

    return $Source.Replace(
        $OldValue,
        $NewValue
    )
}

$Text = Replace-Exactly-Once `
    -Source $Text `
    -OldValue "import shlex`nimport re" `
    -NewValue "import shlex`nimport shutil`nimport json`nimport re" `
    -Label "Import shutil a json"

$Text = Replace-Exactly-Once `
    -Source $Text `
    -OldValue "        self.documentation_workflow_document = None`n        self.documentation_workflow_workspace = None" `
    -NewValue "        self.documentation_workflow_document = None`n        self.documentation_workflow_source_original = None`n        self.documentation_workflow_manifest = None`n        self.documentation_workflow_workspace = None" `
    -Label "Rozšíření runtime stavu"

$MethodAnchor = '    def open_matchmatrix_path(self, relative_path):'

$Methods = @'
    def _documentation_workspace_slug(self, file_path):
        """
        V20.1.Q3 - vytvoří bezpečnou část názvu workspace.
        """
        stem = os.path.splitext(
            os.path.basename(
                str(file_path or "")
            )
        )[0]

        normalized = unicodedata.normalize(
            "NFKD",
            stem
        )

        ascii_text = "".join(
            character
            for character in normalized
            if not unicodedata.combining(character)
        )

        slug = re.sub(
            r"[^A-Za-z0-9]+",
            "_",
            ascii_text
        ).strip("_").upper()

        return slug[:80] or "DOCUMENT"


    def _documentation_update_workflow_ui(self):
        """
        V20.1.Q3 - obnoví popisky pracovního dokumentačního workflow.
        """
        document_text = (
            os.path.basename(
                self.documentation_workflow_document
            )
            if self.documentation_workflow_document
            else "NEVYBRÁN"
        )

        workspace_text = (
            self.documentation_workflow_workspace
            if self.documentation_workflow_workspace
            else "-"
        )

        step_text = self.documentation_workflow_step or "-"
        status_text = self.documentation_workflow_last_status or "-"

        if hasattr(self, "documentation_workflow_document_value"):
            self.documentation_workflow_document_value.config(
                text=document_text
            )

        if hasattr(self, "documentation_workflow_workspace_value"):
            self.documentation_workflow_workspace_value.config(
                text=workspace_text
            )

        if hasattr(self, "documentation_workflow_step_value"):
            self.documentation_workflow_step_value.config(
                text=step_text
            )

        if hasattr(self, "documentation_workflow_status_value"):
            status_upper = status_text.upper()

            if "CHYBA" in status_upper or "FAILED" in status_upper:
                status_color = RED
            elif self.documentation_workflow_document:
                status_color = GREEN
            else:
                status_color = YELLOW

            self.documentation_workflow_status_value.config(
                text=status_text,
                fg=status_color
            )


    def documentation_select_source_document(self):
        """
        V20.1.Q3 - vybere zdrojový Markdown
        a vytvoří izolovaný workspace.
        """
        if self.documentation_workflow_running:
            messagebox.showwarning(
                "Dokumentační workflow",
                "Nelze změnit dokument, dokud běží aktuální krok."
            )
            return

        initial_dir = (
            DOCUMENTATION_ROOT
            if os.path.isdir(DOCUMENTATION_ROOT)
            else BASE_DIR
        )

        selected_path = filedialog.askopenfilename(
            title="Vyber zdrojový Markdown dokument",
            initialdir=initial_dir,
            filetypes=[
                ("Markdown dokumenty", "*.md"),
                ("Všechny soubory", "*.*"),
            ]
        )

        if not selected_path:
            return

        selected_path = os.path.abspath(
            os.path.normpath(selected_path)
        )

        if not os.path.isfile(selected_path):
            messagebox.showwarning(
                "Dokumentační workflow",
                f"Vybraný soubor neexistuje:\n{selected_path}"
            )
            return

        if os.path.splitext(selected_path)[1].lower() != ".md":
            messagebox.showwarning(
                "Dokumentační workflow",
                "Vyber Markdown soubor s příponou .md."
            )
            return

        try:
            os.makedirs(
                DOCUMENTATION_WORKSPACE_ROOT,
                exist_ok=True
            )

            workspace_stamp = datetime.now().strftime(
                "%Y%m%d_%H%M%S"
            )

            workspace_slug = (
                self._documentation_workspace_slug(
                    selected_path
                )
            )

            workspace_path = os.path.join(
                DOCUMENTATION_WORKSPACE_ROOT,
                f"{workspace_stamp}_{workspace_slug}"
            )

            source_dir = os.path.join(
                workspace_path,
                "source"
            )

            os.makedirs(
                source_dir,
                exist_ok=False
            )

            source_snapshot = os.path.join(
                source_dir,
                os.path.basename(selected_path)
            )

            shutil.copy2(
                selected_path,
                source_snapshot
            )

            manifest_path = os.path.join(
                workspace_path,
                "documentation_workflow_manifest.json"
            )

            manifest_payload = {
                "contract_version": "1.0",
                "panel_version": "V20.1.Q3",
                "selected_at": datetime.now().astimezone().isoformat(),
                "source_original": selected_path,
                "source_snapshot": source_snapshot,
                "workspace": workspace_path,
                "workflow_status": "SOURCE_SELECTED",
            }

            with open(
                manifest_path,
                "w",
                encoding="utf-8"
            ) as manifest_handle:
                json.dump(
                    manifest_payload,
                    manifest_handle,
                    ensure_ascii=False,
                    indent=2
                )

        except Exception as exc:
            self.documentation_workflow_last_status = (
                "CHYBA PŘI VYTVOŘENÍ WORKSPACE"
            )

            self._documentation_update_workflow_ui()

            messagebox.showerror(
                "Dokumentační workflow",
                f"Workspace se nepodařilo vytvořit:\n\n{exc}"
            )
            return

        self.documentation_workflow_source_original = selected_path
        self.documentation_workflow_document = source_snapshot
        self.documentation_workflow_manifest = manifest_path
        self.documentation_workflow_workspace = workspace_path
        self.documentation_workflow_step = "ZDROJ"
        self.documentation_workflow_last_status = "DOKUMENT VYBRÁN"
        self.documentation_workflow_last_output = source_snapshot
        self.documentation_workflow_process = None
        self.documentation_workflow_running = False
        self.documentation_workflow_started_at = None
        self.documentation_workflow_finished_at = None

        self._documentation_update_workflow_ui()

        messagebox.showinfo(
            "Dokumentační workflow",
            (
                "Dokument byl bezpečně načten do samostatného workspace.\n\n"
                f"Zdroj:\n{selected_path}\n\n"
                f"Pracovní kopie:\n{source_snapshot}"
            )
        )


'@

$Text = Replace-Exactly-Once `
    -Source $Text `
    -OldValue $MethodAnchor `
    -NewValue ($Methods + $MethodAnchor) `
    -Label "Metody výběru dokumentu"

$Utf8Bom = New-Object System.Text.UTF8Encoding($true)

[System.IO.File]::WriteAllText(
    (Resolve-Path $Panel),
    $Text,
    $Utf8Bom
)

py.exe -3.14 -m py_compile $Panel

if ($LASTEXITCODE -ne 0) {
    throw "Python syntaktická kontrola selhala."
}

Write-Host ""
Write-Host "=== Q3 SOURCE SELECTION FOUNDATION ===" -ForegroundColor Cyan

Select-String `
    -Path $Panel `
    -Pattern `
        "import shutil",
        "import json",
        "documentation_workflow_source_original",
        "def _documentation_workspace_slug",
        "def _documentation_update_workflow_ui",
        "def documentation_select_source_document" |
    Select-Object LineNumber, Line |
    Format-Table -AutoSize

Write-Host ""
Write-Host "PYTHON SYNTAX: OK" -ForegroundColor Green
