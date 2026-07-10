Set-Location "C:\MatchMatrix-Platform"

$Panel = "tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"
$History = "tools\histori\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW_STEP_04_SOURCE_SELECTION_FOUNDATION.py"

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

$OldRows = @'
        tab_documentation.rowconfigure(1, weight=2)
        tab_documentation.rowconfigure(2, weight=1)
        tab_documentation.rowconfigure(3, weight=1)
        tab_documentation.rowconfigure(4, weight=1)
'@

$NewRows = @'
        tab_documentation.rowconfigure(1, weight=0)
        tab_documentation.rowconfigure(2, weight=2)
        tab_documentation.rowconfigure(3, weight=1)
        tab_documentation.rowconfigure(4, weight=1)
        tab_documentation.rowconfigure(5, weight=1)
'@

$Text = Replace-Exactly-Once `
    -Source $Text `
    -OldValue $OldRows `
    -NewValue $NewRows `
    -Label "Řádky záložky Dokumentace"

$GlossaryAnchor = '        # V20.1.Q2 - KLIKACÍ SLOVNÍK A VÝKLADOVÝ REJSTŘÍK'

$WorkflowUi = @'
        # V20.1.Q3 - ŘÍZENÝ DOKUMENTAČNÍ WORKFLOW
        # CO:
        # - Výběr jednoho zdrojového Markdown dokumentu.
        # K ČEMU:
        # - Založí izolovaný workspace pro navazující A17 až A24.
        # KDE:
        # - Horní část záložky DOKUMENTACE.
        # JAK:
        # - Tlačítko VYBRAT DOKUMENT vytvoří pracovní kopii a manifest.
        documentation_workflow_frame = tk.Frame(
            tab_documentation,
            bg="#100918",
            highlightbackground=CARD_BORDER,
            highlightthickness=1
        )
        documentation_workflow_frame.grid(
            row=1,
            column=0,
            columnspan=2,
            sticky="ew",
            padx=4,
            pady=4
        )
        documentation_workflow_frame.columnconfigure(1, weight=1)
        documentation_workflow_frame.columnconfigure(3, weight=1)

        tk.Label(
            documentation_workflow_frame,
            text="🧭 ŘÍZENÝ DOKUMENTAČNÍ WORKFLOW",
            bg="#100918",
            fg="#d8b4fe",
            font=("Segoe UI", 10, "bold")
        ).grid(
            row=0,
            column=0,
            columnspan=4,
            sticky="w",
            padx=8,
            pady=(6, 4)
        )

        workflow_action_bar = tk.Frame(
            documentation_workflow_frame,
            bg="#100918"
        )
        workflow_action_bar.grid(
            row=1,
            column=0,
            columnspan=4,
            sticky="ew",
            padx=6,
            pady=(0, 5)
        )

        self.make_button(
            workflow_action_bar,
            "📄 VYBRAT DOKUMENT",
            "#6d45b8",
            self.documentation_select_source_document
        )

        tk.Label(
            documentation_workflow_frame,
            text="DOKUMENT:",
            bg="#100918",
            fg=MUTED,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        ).grid(
            row=2,
            column=0,
            sticky="w",
            padx=(8, 4),
            pady=2
        )

        self.documentation_workflow_document_value = tk.Label(
            documentation_workflow_frame,
            text="NEVYBRÁN",
            bg="#100918",
            fg=TEXT,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        )
        self.documentation_workflow_document_value.grid(
            row=2,
            column=1,
            sticky="ew",
            padx=(0, 8),
            pady=2
        )

        tk.Label(
            documentation_workflow_frame,
            text="STAV:",
            bg="#100918",
            fg=MUTED,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        ).grid(
            row=2,
            column=2,
            sticky="w",
            padx=(8, 4),
            pady=2
        )

        self.documentation_workflow_status_value = tk.Label(
            documentation_workflow_frame,
            text="NEVYBRÁN DOKUMENT",
            bg="#100918",
            fg=YELLOW,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        )
        self.documentation_workflow_status_value.grid(
            row=2,
            column=3,
            sticky="ew",
            padx=(0, 8),
            pady=2
        )

        tk.Label(
            documentation_workflow_frame,
            text="KROK:",
            bg="#100918",
            fg=MUTED,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        ).grid(
            row=3,
            column=0,
            sticky="w",
            padx=(8, 4),
            pady=(2, 6)
        )

        self.documentation_workflow_step_value = tk.Label(
            documentation_workflow_frame,
            text="-",
            bg="#100918",
            fg=TEXT,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        )
        self.documentation_workflow_step_value.grid(
            row=3,
            column=1,
            sticky="ew",
            padx=(0, 8),
            pady=(2, 6)
        )

        tk.Label(
            documentation_workflow_frame,
            text="WORKSPACE:",
            bg="#100918",
            fg=MUTED,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        ).grid(
            row=3,
            column=2,
            sticky="w",
            padx=(8, 4),
            pady=(2, 6)
        )

        self.documentation_workflow_workspace_value = tk.Label(
            documentation_workflow_frame,
            text="-",
            bg="#100918",
            fg="#cdb7df",
            font=("Segoe UI", 7),
            anchor="w",
            justify="left",
            wraplength=650
        )
        self.documentation_workflow_workspace_value.grid(
            row=3,
            column=3,
            sticky="ew",
            padx=(0, 8),
            pady=(2, 6)
        )

        self._documentation_update_workflow_ui()

        # V20.1.Q2 - KLIKACÍ SLOVNÍK A VÝKLADOVÝ REJSTŘÍK
'@

$Text = Replace-Exactly-Once `
    -Source $Text `
    -OldValue $GlossaryAnchor `
    -NewValue $WorkflowUi `
    -Label "UI dokumentačního workflow"

$OldGlossaryGrid = @'
        glossary_frame.grid(
            row=1,
            column=0,
            columnspan=2,
            sticky="nsew",
            padx=4,
            pady=4
        )
'@

$NewGlossaryGrid = @'
        glossary_frame.grid(
            row=2,
            column=0,
            columnspan=2,
            sticky="nsew",
            padx=4,
            pady=4
        )
'@

$Text = Replace-Exactly-Once `
    -Source $Text `
    -OldValue $OldGlossaryGrid `
    -NewValue $NewGlossaryGrid `
    -Label "Přesun glossary rámce"

$OldSections = @'
        self.documentation_kpi_tree = self.create_section(
            tab_documentation,
            "📚 STAV DOKUMENTAČNÍ DATABÁZE",
            2,
            0,
            2
        )

        self.documentation_documents_tree = self.create_section(
            tab_documentation,
            "📄 AKTUÁLNÍ DOKUMENTY",
            3,
            0
        )

        self.documentation_import_runs_tree = self.create_section(
            tab_documentation,
            "⏱ POSLEDNÍ IMPORTNÍ BĚHY",
            3,
            1
        )

        self.documentation_relations_tree = self.create_section(
            tab_documentation,
            "🔗 VAZBY DOKUMENTŮ",
            4,
            0
        )

        self.documentation_history_tree = self.create_section(
            tab_documentation,
            "🧾 HISTORIE STAVŮ",
            4,
            1
        )
'@

$NewSections = @'
        self.documentation_kpi_tree = self.create_section(
            tab_documentation,
            "📚 STAV DOKUMENTAČNÍ DATABÁZE",
            3,
            0,
            2
        )

        self.documentation_documents_tree = self.create_section(
            tab_documentation,
            "📄 AKTUÁLNÍ DOKUMENTY",
            4,
            0
        )

        self.documentation_import_runs_tree = self.create_section(
            tab_documentation,
            "⏱ POSLEDNÍ IMPORTNÍ BĚHY",
            4,
            1
        )

        self.documentation_relations_tree = self.create_section(
            tab_documentation,
            "🔗 VAZBY DOKUMENTŮ",
            5,
            0
        )

        self.documentation_history_tree = self.create_section(
            tab_documentation,
            "🧾 HISTORIE STAVŮ",
            5,
            1
        )
'@

$Text = Replace-Exactly-Once `
    -Source $Text `
    -OldValue $OldSections `
    -NewValue $NewSections `
    -Label "Přesun dokumentačních sekcí"

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
Write-Host "=== Q3 DOCUMENTATION WORKFLOW UI ===" -ForegroundColor Cyan

Select-String `
    -Path $Panel `
    -Pattern `
        "ŘÍZENÝ DOKUMENTAČNÍ WORKFLOW",
        "documentation_workflow_document_value",
        "documentation_workflow_status_value",
        "documentation_workflow_step_value",
        "documentation_workflow_workspace_value" |
    Select-Object LineNumber, Line |
    Format-Table -AutoSize

Write-Host ""
Write-Host "PYTHON SYNTAX: OK" -ForegroundColor Green
