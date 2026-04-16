# 606_find_fb_coaches_worker_binding.ps1
# Účel:
# dohledat v projektu všechny stopy k FB coaches ingest flow:
# worker, parser, staging insert, job binding
# Spouštět ve VS terminálu (PowerShell)

$ProjectRoot = "C:\MatchMatrix-platform"
$OutFile = "C:\MatchMatrix-platform\db\checks\606_find_fb_coaches_worker_binding_output.txt"

# Klíčová slova, která chceme dohledat
$patterns = @(
    "stg_provider_coaches",
    "provider_coaches",
    "coaches",
    "coachs",
    "coach_provider_map"
)

# Jen rozumné textové typy souborů
$include = @("*.py","*.ps1","*.sql","*.md","*.txt","*.json","*.yaml","*.yml")

"===== FB COACHES WORKER BINDING SEARCH =====" | Set-Content -Path $OutFile -Encoding UTF8
"ProjectRoot: $ProjectRoot" | Add-Content -Path $OutFile
"Timestamp : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -Path $OutFile
"" | Add-Content -Path $OutFile

foreach ($pattern in $patterns) {
    "----- PATTERN: $pattern -----" | Add-Content -Path $OutFile

    Get-ChildItem -Path $ProjectRoot -Recurse -File -Include $include -ErrorAction SilentlyContinue |
        Select-String -Pattern $pattern -SimpleMatch -ErrorAction SilentlyContinue |
        ForEach-Object {
            "{0}:{1}: {2}" -f $_.Path, $_.LineNumber, $_.Line.Trim()
        } | Add-Content -Path $OutFile

    "" | Add-Content -Path $OutFile
}

Write-Host ""
Write-Host "HOTOVO: $OutFile"