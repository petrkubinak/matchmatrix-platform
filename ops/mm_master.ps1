# mm_master.ps1 - MatchMatrix Owner Ops Console
# Spuštění: powershell -ExecutionPolicy Bypass -File C:\MatchMatrix-platform\ops\mm_master.ps1

$ErrorActionPreference = "Stop"

$Global:PG_CONTAINER = "matchmatrix_postgres"
$Global:PG_USER = "matchmatrix"
$Global:PG_DB = "matchmatrix"
$Global:PG_PASSWORD = "matchmatrix_pass"

# Load env/config
. "C:\MatchMatrix-platform\ops\mm_env.ps1"

function Ensure-Tools {
  if (-not $env:DATABASE_URL) { throw "DATABASE_URL není nastaven. Nastav setx DATABASE_URL 'postgresql://...'" }

  $docker = Get-Command docker -ErrorAction SilentlyContinue
  if (-not $docker) { throw "docker není v PATH. Nainstaluj Docker Desktop nebo přidej docker do PATH." }

  # ověření, že kontejner existuje a běží
  $chk = cmd /c "docker ps --format ""{{.Names}}"" | findstr /i ""$($Global:PG_CONTAINER)"""
  if (-not $chk) { throw "Postgres container '$($Global:PG_CONTAINER)' neběží (docker ps ho nevidí)." }

  if (-not (Test-Path $Global:API_FOOTBALL_PIPELINE)) {
    throw "Nenalezen API_FOOTBALL_PIPELINE: $Global:API_FOOTBALL_PIPELINE"
  }

  if (-not (Test-Path $Global:LOG_DIR)) { New-Item -ItemType Directory -Path $Global:LOG_DIR | Out-Null }
}

function New-LogFile([string]$name) {
  $date = (Get-Date).ToString("yyyy-MM-dd")
  $dir = Join-Path $Global:LOG_DIR $date
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $ts = (Get-Date).ToString("HHmmss")
  return (Join-Path $dir "$ts-$name.log")
}

function Psql-Query([string]$sql) {
  $tmp = New-TemporaryFile
  Set-Content -Path $tmp -Value $sql -Encoding UTF8

  # pošleme soubor do kontejneru přes stdin a psql ho načte jako script
  $cmd = "docker exec -e PGPASSWORD=$($Global:PG_PASSWORD) -i $($Global:PG_CONTAINER) " +
         "psql -U $($Global:PG_USER) -d $($Global:PG_DB) -X -q -t -A -f -"

  $out = Get-Content -Raw $tmp | cmd /c $cmd 2>&1

  Remove-Item $tmp -Force
  return $out
}

function Psql-Exec([string]$sql, [string]$logfile) {
  $tmp = New-TemporaryFile
  Set-Content -Path $tmp -Value $sql -Encoding UTF8

  $cmd = "docker exec -e PGPASSWORD=$($Global:PG_PASSWORD) -i $($Global:PG_CONTAINER) " +
         "psql -U $($Global:PG_USER) -d $($Global:PG_DB) -v ON_ERROR_STOP=1 -f -"

  Get-Content -Raw $tmp | cmd /c $cmd *>> $logfile

  Remove-Item $tmp -Force
}

function Psql-Query([string]$sql) {
  $tmp = New-TemporaryFile
  Set-Content -Path $tmp -Value $sql -Encoding UTF8

  # pošleme soubor do kontejneru přes stdin a psql ho načte jako script
  $cmd = "docker exec -e PGPASSWORD=$($Global:PG_PASSWORD) -i $($Global:PG_CONTAINER) " +
         "psql -U $($Global:PG_USER) -d $($Global:PG_DB) -X -q -t -A -f -"

  $out = Get-Content -Raw $tmp | cmd /c $cmd 2>&1

  Remove-Item $tmp -Force
  return $out
}

function Psql-Exec([string]$sql, [string]$logfile) {
  $tmp = New-TemporaryFile
  Set-Content -Path $tmp -Value $sql -Encoding UTF8

  $cmd = "docker exec -e PGPASSWORD=$($Global:PG_PASSWORD) -i $($Global:PG_CONTAINER) " +
         "psql -U $($Global:PG_USER) -d $($Global:PG_DB) -v ON_ERROR_STOP=1 -f -"

  Get-Content -Raw $tmp | cmd /c $cmd *>> $logfile

  Remove-Item $tmp -Force
}

function Get-IngestTargets([string]$provider) {
  $sql = @"
select id, sport_code, canonical_league_id, provider, provider_league_id, season, tier,
       fixtures_days_back, fixtures_days_forward, odds_days_forward, enabled, coalesce(notes,'')
from ops.ingest_targets
where enabled=true and provider='$provider'
order by tier asc, id asc;
"@
  $raw = Psql-Query $sql
  # vrací řádky "col|col|..."
  $lines = $raw -split "`n" | Where-Object { $_.Trim() -ne "" }
  $rows = @()
  foreach ($ln in $lines) {
    $p = $ln.Split("|")
    $rows += [pscustomobject]@{
      id = [int]$p[0]
      sport_code = $p[1]
      canonical_league_id = [int]$p[2]
      provider = $p[3]
      provider_league_id = $p[4]
      season = $p[5]
      tier = [int]$p[6]
      fixtures_days_back = [int]$p[7]
      fixtures_days_forward = [int]$p[8]
      odds_days_forward = [int]$p[9]
      enabled = $p[10]
      notes = $p[11]
    }
  }
  return $rows
}

function JobRun-Start([string]$job_code, $paramsObj) {
  $jc = $job_code.Replace("'", "''")
  $paramsJson = ($paramsObj | ConvertTo-Json -Compress)

  # escape single quotes pro SQL string literal
  $paramsSql = $paramsJson.Replace("'", "''")

  $sql = @"
insert into ops.job_runs(job_code, params, status)
values ('$jc', '$paramsSql'::jsonb, 'running')
returning id;
"@

  $id = (Psql-Query $sql).Trim()
  return [int]$id
}

function JobRun-Finish([int]$id, [string]$status, [string]$message, $detailsObj) {
  $msgEsc = $message.Replace("'","''")
  $stEsc = $status.Replace("'","''")
  $detailsJson = ($detailsObj | ConvertTo-Json -Compress)
  $detailsSql = $detailsJson.Replace("'", "''")

  $sql = @"
update ops.job_runs
set status='$stEsc',
    finished_at=now(),
    message='$msgEsc',
    details='$detailsSql'::jsonb
where id=$id;
"@
  Psql-Exec $sql (New-LogFile "db")
}

function Run-ApiFootballPipeline([int]$leagueId, [int]$season, [string]$logfile) {
  Write-Host "  -> API-Football pipeline: LeagueId=$leagueId Season=$season"
  & powershell -ExecutionPolicy Bypass -File $Global:API_FOOTBALL_PIPELINE -LeagueId $leagueId -Season $season *>> $logfile
}

function Show-Menu {
  Clear-Host
  Write-Host "==============================="
  Write-Host " MatchMatrix - Owner OPS Console"
  Write-Host "==============================="
  Write-Host "DB: $env:DATABASE_URL"
  Write-Host ""
  Write-Host "1) Daily Run (API-Football targets): fixtures+teams+matches (+ později odds)"
  Write-Host "2) Ingest API-Football (vypsat targets a vybrat jeden)"
  Write-Host "3) Healthcheck (quick) - základní počty + poslední job_runs"
  Write-Host "4) Zobrazit ingest targets"
  Write-Host "5) Zobrazit poslední job runs"
  Write-Host ""
  Write-Host "0) Konec"
  Write-Host ""
}

function Action-DailyRun {
  $log = New-LogFile "daily_run"
  $jr = JobRun-Start "daily_run" '{"mode":"daily","provider":"api_football"}'
  try {
    Add-Content $log "=== DAILY RUN START $(Get-Date) job_run_id=$jr ==="

    $targets = Get-IngestTargets "api_football"
    if ($targets.Count -eq 0) { throw "Nemáš žádné enabled ops.ingest_targets pro provider=api_football." }

    foreach ($t in $targets) {
      $leagueId = [int]$t.provider_league_id
      $season = 2025
      if ($t.season -match '^\d+$') { $season = [int]$t.season }
      Run-ApiFootballPipeline $leagueId $season $log
    }

    Add-Content $log "=== DAILY RUN OK $(Get-Date) ==="
    JobRun-Finish $jr "success" "Daily run OK" @{ logfile = $log; provider = "api_football"; league_id = $leagueId; season = $season }
    Write-Host "Hotovo. Log: $log"
  }
  catch {
    Add-Content $log "=== DAILY RUN FAILED $(Get-Date) ==="
    Add-Content $log $_.Exception.Message
    JobRun-Finish $jr "failed" $_.Exception.Message @{ logfile = $log }
    Write-Host "CHYBA: $($_.Exception.Message)"
    Write-Host "Log: $log"
  }
  Pause
}

function Action-IngestSingle {
  $targets = Get-IngestTargets "api_football"
  if ($targets.Count -eq 0) { Write-Host "Žádné targets."; Pause; return }

  Write-Host ""
  Write-Host "API-Football targets:"
  foreach ($t in $targets) {
    Write-Host ("[{0}] league_id={1} season={2} tier={3} notes={4}" -f $t.id, $t.provider_league_id, $t.season, $t.tier, $t.notes)
  }
  $pick = Read-Host "Zadej ID targetu"
  $sel = $targets | Where-Object { $_.id -eq [int]$pick } | Select-Object -First 1
  if (-not $sel) { Write-Host "Neplatný výběr."; Pause; return }

  $log = New-LogFile "ingest_api_football"
  $paramsObj = @{
  target_id = [int]$sel.id
  league_id = [string]$sel.provider_league_id
  season    = [string]$sel.season
  }
  $params = ($paramsObj | ConvertTo-Json -Compress)
  $jr = JobRun-Start "ingest_fixtures" $paramsObj
  try {
    Add-Content $log "=== INGEST START $(Get-Date) job_run_id=$jr ==="
    $leagueId = [int]$sel.provider_league_id
    $season = 2025
    if ($sel.season -match '^\d+$') { $season = [int]$sel.season }
    Run-ApiFootballPipeline $leagueId $season $log
    Add-Content $log "=== INGEST OK $(Get-Date) ==="
    JobRun-Finish $jr "success" "Ingest OK" @{ logfile = $log }
    Write-Host "OK. Log: $log"
  }
  catch {
    Add-Content $log "=== INGEST FAILED $(Get-Date) ==="
    Add-Content $log $_.Exception.Message
    JobRun-Finish $jr "failed" $_.Exception.Message @{ logfile = $log }
    Write-Host "CHYBA: $($_.Exception.Message)"
    Write-Host "Log: $log"
  }
  Pause
}

function Action-Healthcheck {
  $log = New-LogFile "healthcheck"
  $jr = JobRun-Start "daily_healthcheck" '{"mode":"quick"}'
  try {
    Add-Content $log "=== HEALTHCHECK START $(Get-Date) job_run_id=$jr ==="

    $counts = Psql-Query "select 'matches' as t, count(*) from public.matches union all select 'odds', count(*) from public.odds;"
    Add-Content $log $counts

    $lastRuns = Psql-Query "select id||'|'||job_code||'|'||status||'|'||started_at from ops.job_runs order by started_at desc limit 10;"
    Add-Content $log "`nLast job_runs:"
    Add-Content $log $lastRuns

    JobRun-Finish $jr "success" "Healthcheck OK" @{ logfile = $log }
    Write-Host "Healthcheck OK. Log: $log"
  }
  catch {
    Add-Content $log $_.Exception.Message
    JobRun-Finish $jr "failed" $_.Exception.Message @{ logfile = $log }
    Write-Host "CHYBA: $($_.Exception.Message)"
    Write-Host "Log: $log"
  }
  Pause
}

function Action-ShowTargets {
  $raw = Psql-Query "select id||' | '||sport_code||' | '||provider||' | '||provider_league_id||' | season='||season||' | tier='||tier||' | enabled='||enabled||' | '||coalesce(notes,'') from ops.ingest_targets order by enabled desc, tier, id;"
  Write-Host $raw
  Pause
}

function Action-ShowJobRuns {
  $raw = Psql-Query "select id||' | '||job_code||' | '||status||' | '||started_at||' -> '||coalesce(finished_at::text,'')||' | '||coalesce(message,'') from ops.job_runs order by started_at desc limit 30;"
  Write-Host $raw
  Pause
}

# ===== MAIN =====
Ensure-Tools

while ($true) {
  Show-Menu
  $c = Read-Host "Vyber akci"
  switch ($c) {
    "1" { Action-DailyRun }
    "2" { Action-IngestSingle }
    "3" { Action-Healthcheck }
    "4" { Action-ShowTargets }
    "5" { Action-ShowJobRuns }
    "0" { break }
    default { Write-Host "Neplatná volba"; Start-Sleep -Seconds 1 }
  }
}