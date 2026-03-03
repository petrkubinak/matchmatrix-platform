param(
  [string]$Mode = "daily"  # daily | weekly | all
)

$Base   = "C:\MATCHMATRIX-PLATFORM"
$Checks = Join-Path $Base "db\checks"
$OutDir = Join-Path $Base "reports"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$Today = Get-Date -Format "yyyy-MM-dd"
$Ts    = Get-Date -Format "yyyyMMdd_HHmmss"

# === Docker DB container settings ===
$DbContainer = "matchmatrix_postgres"   # <- tvoje DB
$DbUser      = "matchmatrix"
$DbName      = "matchmatrix"

function Run-SqlFileDocker($SqlFile, $OutFile) {
  $sqlPath = Join-Path $Checks $SqlFile
  $outPath = Join-Path $OutDir $OutFile

  if (!(Test-Path $sqlPath)) {
    Write-Host "SQL file not found: $sqlPath"
    exit 1
  }

  Write-Host "Running $SqlFile -> $outPath"

  $sqlText = Get-Content -Raw -Path $sqlPath

  $cmd = @(
    "exec","-i",$DbContainer,
    "psql","-U",$DbUser,"-d",$DbName,"-v","ON_ERROR_STOP=1"
  )

  $sqlText | docker @cmd | Out-File -FilePath $outPath -Encoding utf8
}

if ($Mode -eq "daily" -or $Mode -eq "all") {
  Run-SqlFileDocker "MATCHMATRIX_DAILY_STATUS.sql" "$Today`_DAILY_STATUS_$Ts.txt"
}

if ($Mode -eq "weekly" -or $Mode -eq "all") {
  Run-SqlFileDocker "MATCHMATRIX_WEEKLY_DIAGNOSTICS.sql" "$Today`_WEEKLY_DIAGNOSTICS_$Ts.txt"
}

Write-Host "Done. Reports in: $OutDir"