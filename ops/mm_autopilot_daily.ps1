# C:\MATCHMATRIX-PLATFORM\ops\mm_autopilot_daily.ps1
$ErrorActionPreference = "Stop"

# ===== Settings =====
$Root      = "C:\MATCHMATRIX-PLATFORM"
$Repo      = Join-Path $Root "MatchMatrix-platform"
$GenDir    = Join-Path $Repo "Scripts\03_generation"
$MailCfg   = Join-Path $Root "ops\mm_mail_config.ps1"

$Container = "matchmatrix_postgres"

# DB (same as docker / agreed defaults)
$DbName = "matchmatrix"
$DbUser = "matchmatrix"
$DbPass = "matchmatrix"

# Ingest runner
$IngestRunner = Join-Path $Root "ingest\API-Football\run_api_football_pipeline.ps1"

# Ingest params (example defaults)
$LeagueId = 39
$Season   = 2025

# ===== Time windows (PHASE 1 standard) =====
# Fixtures: -2 days back to +7 days forward
$FixturesFrom = (Get-Date).AddDays(-2).ToString("yyyy-MM-dd")
$FixturesTo   = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")

# Odds: today to +3 days forward
$OddsFrom = (Get-Date).ToString("yyyy-MM-dd")
$OddsTo   = (Get-Date).AddDays(3).ToString("yyyy-MM-dd")

# ===== Logs =====
$today  = Get-Date -Format "yyyy-MM-dd"
$logDir = Join-Path $Root ("logs\" + $today)
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

$ts = Get-Date -Format "HHmmss"
$logIngest = Join-Path $logDir ("0700_ingest_api_football_{0}.log" -f $ts)
$logMerge  = Join-Path $logDir ("0710_merge_db_{0}.log" -f $ts)
$logAudit  = Join-Path $logDir ("0720_audit_{0}.log" -f $ts)
$report    = Join-Path $logDir ("0730_daily_report_{0}.txt" -f $ts)

function Write-Log([string]$path, [string]$text) {
  $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $line  = ("[{0}] {1}" -f $stamp, $text)

  $max = 30
  for ($i=1; $i -le $max; $i++) {
    try {
      $dir = Split-Path -Parent $path
      if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

      $fs = [System.IO.File]::Open($path,
        [System.IO.FileMode]::Append,
        [System.IO.FileAccess]::Write,
        [System.IO.FileShare]::ReadWrite)

      $sw = New-Object System.IO.StreamWriter($fs, [System.Text.UTF8Encoding]::new($true))
      $sw.WriteLine($line)
      $sw.Flush()
      $sw.Dispose()
      $fs.Dispose()
      return
    } catch {
      Start-Sleep -Milliseconds 200
      if ($i -eq $max) { throw }
    }
  }
}

function Send-MM-Mail([string]$subject, [string]$body, [string]$attachmentPath) {
  . $MailCfg

  $secure = ConvertTo-SecureString $MM_MAIL.Password -AsPlainText -Force
  $cred   = New-Object System.Management.Automation.PSCredential($MM_MAIL.User, $secure)

  $msg = New-Object System.Net.Mail.MailMessage
  $msg.From = $MM_MAIL.From
  $msg.To.Add($MM_MAIL.To)
  $msg.Subject = $subject
  $msg.Body = $body
  $msg.IsBodyHtml = $false

  if (Test-Path $attachmentPath) {
    $att = New-Object System.Net.Mail.Attachment($attachmentPath)
    $msg.Attachments.Add($att) | Out-Null
  }

  $client = New-Object System.Net.Mail.SmtpClient($MM_MAIL.SmtpServer, $MM_MAIL.Port)
  $client.EnableSsl  = [bool]$MM_MAIL.UseSsl
  $client.Credentials = $cred
  $client.Send($msg)

  $msg.Dispose()
  $client.Dispose()
}

# ===== Start =====
$start = Get-Date
$runId = (Get-Date -Format "yyyyMMdd_HHmmss")

Write-Log $report "MatchMatrix / TicketMatrix - DAILY REPORT"
Write-Log $report ("Date: {0}" -f $today)
Write-Log $report ("Run: {0}" -f $runId)
Write-Log $report ("DB: {0} (user={1})" -f $DbName, $DbUser)
Write-Log $report ("Fixtures window: {0} -> {1}" -f $FixturesFrom, $FixturesTo)
Write-Log $report ("Odds window:     {0} -> {1}" -f $OddsFrom, $OddsTo)
Write-Log $report ("Container: {0}" -f $Container)
Write-Log $report ""

$okIngest = $false
$okMerge  = $false
$okAudit  = $false
$failMsg  = ""

try {
  # 1) INGEST
  if (Test-Path $IngestRunner) {
    Write-Log $report ("1) INGEST: start (LeagueId={0}, Season={1})" -f $LeagueId, $Season)
    Write-Log $logIngest ("Start ingest runner: {0}" -f $IngestRunner)

    & powershell -ExecutionPolicy Bypass -File $IngestRunner `
      -LeagueId $LeagueId -Season $Season `
      -FixturesFrom $FixturesFrom -FixturesTo $FixturesTo `
      -OddsFrom $OddsFrom -OddsTo $OddsTo `
      2>&1 | Tee-Object -FilePath $logIngest

    $okIngest = $true
    Write-Log $report "1) INGEST: OK"
  } else {
    Write-Log $report ("1) INGEST: SKIP (not found: {0})" -f $IngestRunner)
  }

  Write-Log $report ""

  # 2) MERGE (031-034 streamed into psql inside container)
  Write-Log $report "2) MERGE: start (031-034 stream to psql, no include paths)"

  $sqlFiles = @(
    "031_upsert_leagues_api_football.sql",
    "032_upsert_teams_api_football.sql",
    "033_upsert_league_teams_api_football.sql",
    "034_upsert_matches_api_football.sql"
  ) | ForEach-Object { Join-Path $GenDir $_ }

  foreach ($f in $sqlFiles) {
    if (-not (Test-Path $f)) { throw ("Missing SQL file: {0}" -f $f) }
  }

  $nl = "`n"
  $sqlStream = "\set ON_ERROR_STOP on$nlBEGIN;$nl"
  foreach ($f in $sqlFiles) {
    $sqlStream += "$nl-- ===== FILE: $f =====$nl"
    $sqlStream += (Get-Content -Raw -Encoding UTF8 $f) + $nl
  }
  $sqlStream += "COMMIT;$nl"

  $cmd = "export PGPASSWORD='$DbPass'; psql -v ON_ERROR_STOP=1 -U $DbUser -d $DbName"
  $sqlStream | docker exec -i $Container bash -lc $cmd 2>&1 | Tee-Object -FilePath $logMerge

  $okMerge = $true
  Write-Log $report "2) MERGE: OK"
  Write-Log $report ""

  # 3) AUDIT (basic counts)
  Write-Log $report "3) AUDIT: start"
  $auditSql = @"
\set ON_ERROR_STOP on
select now() as audit_time;
select 'leagues' as t, count(*) as cnt from public.leagues;
select 'teams'   as t, count(*) as cnt from public.teams;
select 'matches' as t, count(*) as cnt from public.matches;
"@
  $auditSql | docker exec -i $Container bash -lc $cmd 2>&1 | Tee-Object -FilePath $logAudit

  $okAudit = $true
  Write-Log $report "3) AUDIT: OK"
  Write-Log $report ""

} catch {
  $failMsg = $_.Exception.Message
  Write-Log $report ("FAIL: {0}" -f $failMsg)
}

$end = Get-Date
$dur = New-TimeSpan -Start $start -End $end

Write-Log $report "Summary:"
Write-Log $report ("- Ingest: {0}" -f ($(if($okIngest){"OK"} else {"FAIL/SKIP"})))
Write-Log $report ("- Merge : {0}" -f ($(if($okMerge) {"OK"} else {"FAIL"})))
Write-Log $report ("- Audit : {0}" -f ($(if($okAudit) {"OK"} else {"FAIL"})))
Write-Log $report ("- Time  : {0:hh\:mm\:ss}" -f $dur)
Write-Log $report ""
Write-Log $report "Logs:"
Write-Log $report $logIngest
Write-Log $report $logMerge
Write-Log $report $logAudit
Write-Log $report $report

# Email
try {
  $status  = ($(if($okMerge -and $okAudit){"OK"} else {"FAIL"}))
  $subject = ("MatchMatrix Daily {0} 07:00 - {1}" -f $today, $status)
  $body    = Get-Content -Raw -Encoding UTF8 $report
  Send-MM-Mail -subject $subject -body $body -attachmentPath $report
} catch {
  Write-Log $report ("MAIL FAIL: {0}" -f $_.Exception.Message)
}