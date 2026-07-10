# MATCHMATRIX
# Q3 STEP 07 - A17 REMOTE PANEL BINDING
# CO:
# - Přidá do panelu Q3 tlačítko A17 AUDIT.
# K ČEMU:
# - Audit se spouští z panelu na PC1, ale skutečně se vykoná na PC2 přes WinRM.
# KDE:
# - Aktivní panel na PC2 a synchronizovaná klientská kopie na PC1.
# JAK:
# - Vytvoří historickou kopii, upraví konfiguraci, UI a běhové metody,
#   poté provede syntaktickou kontrolu na PC1 i PC2.

$ErrorActionPreference = "Stop"

if ($env:COMPUTERNAME -ieq "MATCHMATRIX") {
    throw "Tento instalační skript spusťte v PowerShellu na PC1 (MATCHMATRIX-OPS), nikoli na PC2."
}

$RemoteHost = "192.168.3.119"
$RemotePanel = "\\192.168.3.119\matchmatrix\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"
$LocalPanel = "C:\MatchMatrix-Platform\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"
$RemoteHistory = "\\192.168.3.119\matchmatrix\tools\histori\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW_STEP_07_BEFORE_A17_PANEL_BINDING.py"
$RemotePython = "C:\Users\Admin\AppData\Local\Python\pythoncore-3.14-64\python.exe"
$RemotePanelLocalPath = "C:\MatchMatrix-Platform\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py"

if (-not (Test-Path -LiteralPath $RemotePanel)) {
    throw "Aktivní Q3 panel na PC2 nebyl nalezen: $RemotePanel"
}

if (-not (Test-Path -LiteralPath $RemoteHistory)) {
    Copy-Item -LiteralPath $RemotePanel -Destination $RemoteHistory
}

$Text = [System.IO.File]::ReadAllText(
    $RemotePanel,
    [System.Text.Encoding]::UTF8
)

function Insert-After-Regex-Exactly-Once {
    param(
        [string]$Source,
        [string]$Pattern,
        [string]$Insertion,
        [string]$Label
    )

    $Matches = [regex]::Matches(
        $Source,
        $Pattern
    )

    if ($Matches.Count -ne 1) {
        throw "$Label – očekáván 1 výskyt, nalezeno: $($Matches.Count)"
    }

    $Match = $Matches[0]
    $Position = $Match.Index + $Match.Length

    return ($Source.Substring(0, $Position) + $Insertion + $Source.Substring($Position))
}

if ($Text -notmatch '(?m)^import base64\s*$') {
    $ImportMatches = [regex]::Matches(
        $Text,
        '(?m)^import json\s*$'
    )

    if ($ImportMatches.Count -ne 1) {
        throw "Import json – očekáván 1 výskyt, nalezeno: $($ImportMatches.Count)"
    }

    $ImportMatch = $ImportMatches[0]
    $ImportPosition = $ImportMatch.Index + $ImportMatch.Length

    $Text = $Text.Substring(0, $ImportPosition) + "`r`nimport base64" + $Text.Substring($ImportPosition)
}

if ($Text -notmatch '(?m)^DOCUMENTATION_REMOTE_HOST\s*=') {
    $ConfigAnchor = 'DOCUMENTATION_EXECUTION_MODE = "REMOTE_PC2"'
    $ConfigCount = (
        [regex]::Matches(
            $Text,
            [regex]::Escape($ConfigAnchor)
        )
    ).Count

    if ($ConfigCount -ne 1) {
        throw "Konfigurace REMOTE_PC2 – očekáván 1 výskyt, nalezeno: $ConfigCount"
    }

    $ConfigReplacement = @'
DOCUMENTATION_EXECUTION_MODE = "REMOTE_PC2"
DOCUMENTATION_REMOTE_HOST = "192.168.3.119"
DOCUMENTATION_REMOTE_PROJECT_ROOT = r"C:\MatchMatrix-Platform"
'@

    $Text = $Text.Replace(
        $ConfigAnchor,
        $ConfigReplacement.TrimEnd()
    )
}

if ($Text -notmatch '🔎 A17 AUDIT') {
    $ButtonPattern = '(?ms)        self\.make_button\(\r?\n            workflow_action_bar,\r?\n            "📄 VYBRAT DOKUMENT",\r?\n            "#6d45b8",\r?\n            self\.documentation_select_source_document\r?\n        \)'

    $ButtonInsertion = @'

        self.make_button(
            workflow_action_bar,
            "🔎 A17 AUDIT",
            "#0f6a42",
            self.documentation_run_a17
        )
'@

    $Text = Insert-After-Regex-Exactly-Once `
        -Source $Text `
        -Pattern $ButtonPattern `
        -Insertion $ButtonInsertion `
        -Label "Tlačítko VYBRAT DOKUMENT"
}

if ($Text -notmatch '(?m)^    def documentation_run_a17\(self\):') {
    $MethodAnchor = '    def open_matchmatrix_path(self, relative_path):'
    $MethodCount = (
        [regex]::Matches(
            $Text,
            [regex]::Escape($MethodAnchor)
        )
    ).Count

    if ($MethodCount -ne 1) {
        throw "Kotva open_matchmatrix_path – očekáván 1 výskyt, nalezeno: $MethodCount"
    }

    $Methods = @'

    def _documentation_to_remote_pc2_path(self, path_value):
        """
        V20.1.Q3 - převede cestu dostupnou z PC1 na lokální cestu PC2.
        """
        if not path_value:
            return None

        candidate = os.path.normpath(str(path_value))
        candidate_case = os.path.normcase(candidate)

        remote_root = os.path.normpath(
            DOCUMENTATION_REMOTE_PROJECT_ROOT
        )
        remote_root_case = os.path.normcase(remote_root)

        if (
            candidate_case == remote_root_case
            or candidate_case.startswith(remote_root_case + os.sep)
        ):
            return candidate

        for source_root in (DOCUMENTATION_ROOT, BASE_DIR):
            root_norm = os.path.normpath(source_root)
            root_case = os.path.normcase(root_norm)

            if candidate_case == root_case:
                return remote_root

            if candidate_case.startswith(root_case + os.sep):
                relative_path = candidate[
                    len(root_norm):
                ].lstrip("\\/")

                return os.path.normpath(
                    os.path.join(
                        remote_root,
                        relative_path
                    )
                )

        raise ValueError(
            "Cestu nelze převést na lokální cestu PC2: "
            + candidate
        )


    def _documentation_powershell_literal(self, value):
        """
        V20.1.Q3 - bezpečný PowerShell textový literál.
        """
        return "'" + str(value).replace("'", "''") + "'"


    def _documentation_decode_process_output(self, raw_output):
        """
        V20.1.Q3 - dekóduje výstup Windows PowerShellu.
        """
        if raw_output is None:
            return ""

        if isinstance(raw_output, str):
            return raw_output

        for encoding_name in (
            "utf-8-sig",
            "utf-8",
            "cp1250",
            "cp852",
            "mbcs",
        ):
            try:
                return raw_output.decode(encoding_name)
            except (UnicodeDecodeError, LookupError):
                continue

        return raw_output.decode(
            "utf-8",
            errors="replace"
        )


    def documentation_run_a17(self):
        """
        V20.1.Q3 - spustí audit A17 vzdáleně na PC2.
        """
        if self.documentation_workflow_running:
            messagebox.showwarning(
                "Dokumentační workflow",
                "Jiný krok dokumentačního workflow právě běží."
            )
            return

        if (
            not self.documentation_workflow_document
            or not self.documentation_workflow_workspace
        ):
            messagebox.showwarning(
                "A17 – audit dokumentu",
                "Nejprve vyber zdrojový Markdown dokument."
            )
            return

        if not os.path.isfile(
            self.documentation_workflow_document
        ):
            messagebox.showerror(
                "A17 – audit dokumentu",
                (
                    "Pracovní kopie dokumentu nebyla nalezena:\n\n"
                    f"{self.documentation_workflow_document}"
                )
            )
            return

        self.documentation_workflow_running = True
        self.documentation_workflow_step = "A17 AUDIT"
        self.documentation_workflow_last_status = (
            "A17 BĚŽÍ NA PC2"
        )
        self.documentation_workflow_last_output = None
        self.documentation_workflow_process = None
        self.documentation_workflow_started_at = (
            datetime.now().astimezone().isoformat()
        )
        self.documentation_workflow_finished_at = None

        self._documentation_update_workflow_ui()

        worker_thread = threading.Thread(
            target=self._documentation_run_a17_worker,
            daemon=True
        )
        worker_thread.start()


    def _documentation_run_a17_worker(self):
        """
        V20.1.Q3 - pracovní vlákno vzdáleného auditu A17.
        """
        try:
            remote_document = (
                self._documentation_to_remote_pc2_path(
                    self.documentation_workflow_document
                )
            )

            remote_workspace = (
                self._documentation_to_remote_pc2_path(
                    self.documentation_workflow_workspace
                )
            )

            remote_a17_script = (
                self._documentation_to_remote_pc2_path(
                    DOCUMENTATION_SCRIPTS["A17"]
                )
            )

            remote_output_dir = os.path.join(
                remote_workspace,
                "a17"
            )

            ps_host = self._documentation_powershell_literal(
                DOCUMENTATION_REMOTE_HOST
            )
            ps_python = self._documentation_powershell_literal(
                DOCUMENTATION_PYTHON_EXE
            )
            ps_script = self._documentation_powershell_literal(
                remote_a17_script
            )
            ps_document = self._documentation_powershell_literal(
                remote_document
            )
            ps_output = self._documentation_powershell_literal(
                remote_output_dir
            )
            ps_project = self._documentation_powershell_literal(
                DOCUMENTATION_REMOTE_PROJECT_ROOT
            )

            powershell_script = f"""
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$OutputEncoding = [Console]::OutputEncoding

try {{
    Invoke-Command `
        -ComputerName {ps_host} `
        -ScriptBlock {{
            param(
                $PythonExe,
                $AuditScript,
                $DocumentPath,
                $OutputDir,
                $ProjectRoot
            )

            $ErrorActionPreference = "Stop"
            [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
            $OutputEncoding = [Console]::OutputEncoding

            Set-Location -LiteralPath $ProjectRoot

            New-Item `
                -ItemType Directory `
                -Path $OutputDir `
                -Force |
                Out-Null

            & $PythonExe `
                $AuditScript `
                --document $DocumentPath `
                --document-type AUTO `
                --output-dir $OutputDir `
                --stdout-findings 20

            $AuditExitCode = $LASTEXITCODE

            Write-Output (
                "__MM_A17_EXIT_CODE__=" + $AuditExitCode
            )

            if ($AuditExitCode -ne 0) {{
                throw (
                    "A17 skončil návratovým kódem "
                    + $AuditExitCode
                )
            }}
        }} `
        -ArgumentList `
            {ps_python}, `
            {ps_script}, `
            {ps_document}, `
            {ps_output}, `
            {ps_project}

    exit 0
}}
catch {{
    Write-Error $_
    exit 1
}}
"""

            encoded_command = base64.b64encode(
                powershell_script.encode("utf-16le")
            ).decode("ascii")

            command = [
                "powershell.exe",
                "-NoProfile",
                "-NonInteractive",
                "-ExecutionPolicy",
                "Bypass",
                "-EncodedCommand",
                encoded_command,
            ]

            creation_flags = getattr(
                subprocess,
                "CREATE_NO_WINDOW",
                0
            )

            process = subprocess.Popen(
                command,
                cwd=BASE_DIR,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=False,
                creationflags=creation_flags
            )

            self.documentation_workflow_process = process

            raw_output, _ = process.communicate()

            output_text = (
                self._documentation_decode_process_output(
                    raw_output
                )
            )

            local_exit_code = process.returncode

            marker_match = re.search(
                r"__MM_A17_EXIT_CODE__=(-?\d+)",
                output_text
            )

            remote_exit_code = (
                int(marker_match.group(1))
                if marker_match
                else None
            )

            success = (
                local_exit_code == 0
                and remote_exit_code == 0
            )

            self.after(
                0,
                lambda: self._documentation_finish_a17(
                    success=success,
                    output_text=output_text,
                    local_exit_code=local_exit_code,
                    remote_exit_code=remote_exit_code
                )
            )

        except Exception as exc:
            self.after(
                0,
                lambda error=exc: self._documentation_finish_a17(
                    success=False,
                    output_text=str(error),
                    local_exit_code=-1,
                    remote_exit_code=None
                )
            )


    def _documentation_finish_a17(
        self,
        success,
        output_text,
        local_exit_code,
        remote_exit_code
    ):
        """
        V20.1.Q3 - dokončí A17 v hlavním vlákně panelu.
        """
        self.documentation_workflow_running = False
        self.documentation_workflow_process = None
        self.documentation_workflow_finished_at = (
            datetime.now().astimezone().isoformat()
        )

        a17_dir = os.path.join(
            self.documentation_workflow_workspace,
            "a17"
        )

        stdout_path = os.path.join(
            a17_dir,
            "a17_panel_stdout.txt"
        )

        try:
            os.makedirs(
                a17_dir,
                exist_ok=True
            )

            with open(
                stdout_path,
                "w",
                encoding="utf-8"
            ) as output_handle:
                output_handle.write(output_text or "")

        except Exception:
            stdout_path = None

        report_json_path = os.path.join(
            a17_dir,
            "document_compliance_audit_latest.json"
        )

        report_md_path = os.path.join(
            a17_dir,
            "document_compliance_audit_latest.md"
        )

        report_payload = {}
        report_error = None

        if success:
            try:
                with open(
                    report_json_path,
                    "r",
                    encoding="utf-8-sig"
                ) as report_handle:
                    report_payload = json.load(report_handle)
            except Exception as exc:
                success = False
                report_error = str(exc)

        score = report_payload.get(
            "compliance_score_percent"
        )
        compliance_status = report_payload.get(
            "compliance_status"
        )
        final_status = report_payload.get(
            "final_status"
        )

        manifest_payload = {}

        try:
            if (
                self.documentation_workflow_manifest
                and os.path.isfile(
                    self.documentation_workflow_manifest
                )
            ):
                with open(
                    self.documentation_workflow_manifest,
                    "r",
                    encoding="utf-8-sig"
                ) as manifest_handle:
                    manifest_payload = json.load(
                        manifest_handle
                    )

            manifest_payload["workflow_status"] = (
                "A17_COMPLETED"
                if success
                else "A17_FAILED"
            )

            manifest_payload["a17"] = {
                "finished_at": (
                    self.documentation_workflow_finished_at
                ),
                "success": bool(success),
                "local_exit_code": local_exit_code,
                "remote_exit_code": remote_exit_code,
                "compliance_score_percent": score,
                "compliance_status": compliance_status,
                "final_status": final_status,
                "report_json": (
                    report_json_path
                    if os.path.isfile(report_json_path)
                    else None
                ),
                "report_markdown": (
                    report_md_path
                    if os.path.isfile(report_md_path)
                    else None
                ),
                "stdout_log": stdout_path,
            }

            if self.documentation_workflow_manifest:
                with open(
                    self.documentation_workflow_manifest,
                    "w",
                    encoding="utf-8"
                ) as manifest_handle:
                    json.dump(
                        manifest_payload,
                        manifest_handle,
                        ensure_ascii=False,
                        indent=2
                    )

        except Exception:
            pass

        if success:
            score_text = (
                f"{float(score):.2f} %"
                if score is not None
                else "-"
            )

            status_text = (
                str(compliance_status or "AUDIT READY")
            )

            self.documentation_workflow_step = "A17"
            self.documentation_workflow_last_status = (
                f"A17 HOTOVO | {score_text} | {status_text}"
            )
            self.documentation_workflow_last_output = (
                report_md_path
            )

            self._documentation_update_workflow_ui()

            messagebox.showinfo(
                "A17 – audit dokončen",
                (
                    "Audit dokumentu proběhl na PC2.\n\n"
                    f"Skóre souladu: {score_text}\n"
                    f"Stav: {status_text}\n\n"
                    f"Report:\n{report_md_path}"
                )
            )
            return

        self.documentation_workflow_step = "A17"
        self.documentation_workflow_last_status = (
            "CHYBA A17"
        )
        self.documentation_workflow_last_output = (
            stdout_path or output_text
        )

        self._documentation_update_workflow_ui()

        detail_parts = [
            f"Lokální návratový kód: {local_exit_code}",
            f"Vzdálený návratový kód: {remote_exit_code}",
        ]

        if report_error:
            detail_parts.append(
                f"Načtení reportu: {report_error}"
            )

        output_tail = (output_text or "")[-2500:]

        messagebox.showerror(
            "A17 – audit selhal",
            (
                "\n".join(detail_parts)
                + "\n\nPoslední výstup:\n"
                + output_tail
            )
        )
'@

    $Text = $Text.Replace(
        $MethodAnchor,
        $Methods + "`r`n" + $MethodAnchor
    )
}

$Utf8Bom = New-Object System.Text.UTF8Encoding($true)

[System.IO.File]::WriteAllText(
    $RemotePanel,
    $Text,
    $Utf8Bom
)

Copy-Item `
    -LiteralPath $RemotePanel `
    -Destination $LocalPanel `
    -Force

py.exe -3.14 -m py_compile $LocalPanel

if ($LASTEXITCODE -ne 0) {
    throw "Syntaktická kontrola lokální kopie panelu na PC1 selhala."
}

$RemoteCompileResult = Invoke-Command `
    -ComputerName $RemoteHost `
    -ScriptBlock {
        param(
            $PythonExe,
            $PanelPath
        )

        & $PythonExe -m py_compile $PanelPath

        if ($LASTEXITCODE -ne 0) {
            throw "Syntaktická kontrola panelu na PC2 selhala."
        }

        "REMOTE PYTHON SYNTAX: OK"
    } `
    -ArgumentList `
        $RemotePython, `
        $RemotePanelLocalPath

Write-Host ""
Write-Host "=== Q3 STEP 07 - A17 REMOTE PANEL BINDING ===" -ForegroundColor Cyan

Select-String `
    -Path $LocalPanel `
    -Pattern `
        "import base64",
        "DOCUMENTATION_REMOTE_HOST",
        "DOCUMENTATION_REMOTE_PROJECT_ROOT",
        "🔎 A17 AUDIT",
        "def documentation_run_a17",
        "def _documentation_run_a17_worker",
        "def _documentation_finish_a17" |
    Select-Object LineNumber, Line |
    Format-Table -AutoSize

Write-Host ""
Write-Host $RemoteCompileResult
Write-Host "LOCAL PYTHON SYNTAX: OK" -ForegroundColor Green
Write-Host "HISTORY: $RemoteHistory"
Write-Host "REMOTE PANEL: $RemotePanel"
Write-Host "LOCAL PANEL : $LocalPanel"
