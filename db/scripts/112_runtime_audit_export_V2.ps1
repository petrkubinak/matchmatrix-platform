# ============================================================
# 112 - RUNTIME AUDIT EXPORT V2
# Export přes Docker container matchmatrix_postgres
# ============================================================

$PROJECT_ROOT = "C:\MatchMatrix-platform"
$OUTPUT_DIR   = "$PROJECT_ROOT\reports"
$CONTAINER    = "matchmatrix_postgres"
$DB_NAME      = "matchmatrix"
$DB_USER      = "matchmatrix"

if (!(Test-Path $OUTPUT_DIR)) {
    New-Item -ItemType Directory -Path $OUTPUT_DIR | Out-Null
}

$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$TXT_FILE  = "$OUTPUT_DIR\runtime_audit_$TIMESTAMP.txt"

# SQL dotaz pro export do chatu
$query = @"
SELECT
    provider || ' | ' ||
    sport_code || ' | ' ||
    entity || ' | ' ||
    current_state || ' | ' ||
    COALESCE(last_run_group, '-') || ' | ' ||
    COALESCE(next_action, '-') AS line
FROM ops.v_runtime_entity_audit_summary
ORDER BY sport_code, provider, entity;
"@

Write-Host "======================================"
Write-Host "RUNTIME AUDIT EXPORT START"
Write-Host "Container: $CONTAINER"
Write-Host "Output   : $TXT_FILE"
Write-Host "======================================"

# Nejprve ověření, že kontejner běží
$dockerCheck = docker ps --format "{{.Names}}" | Select-String -Pattern "^$CONTAINER$"
if (-not $dockerCheck) {
    Write-Host "ERROR: Docker container '$CONTAINER' není spuštěný."
    exit 1
}

# Spuštění psql uvnitř kontejneru a zápis do TXT
docker exec $CONTAINER psql -U $DB_USER -d $DB_NAME -t -A -c $query |
    Out-File -FilePath $TXT_FILE -Encoding utf8

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: export selhal."
    exit 1
}

Write-Host "======================================"
Write-Host "EXPORT HOTOV"
Write-Host "TXT: $TXT_FILE"
Write-Host "======================================"