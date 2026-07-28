# =============================================================================
# MatchMatrix
# INSTALOVAT_OPRAVENY_AUDIT_MM_REF_20260728_V1.ps1
#
# Jednorázově nahradí starý obsah aktivního auditu správnou verzí,
# ověří engine a následně audit spustí.
# =============================================================================

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ExpectedMarker = "A_REF_SYNC_AUDIT_V1_1_RAW_TEXT_REGEX"

if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    throw "Nelze určit umístění instalačního skriptu."
}

$ToolsDir = Split-Path -Parent $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ToolsDir

$TargetFile = Join-Path $PSScriptRoot `
    "AUDIT_MM_REF_001_002_PRESNY_V1.ps1"

$HistoryDir = Join-Path $ProjectRoot "tools\histori"

Write-Host ""
Write-Host "MATCHMATRIX - INSTALACE OPRAVENÉHO AUDITU" -ForegroundColor Cyan
Write-Host ("=" * 78)
Write-Host "PROJECT_ROOT : $ProjectRoot"
Write-Host "TARGET       : $TargetFile"
Write-Host ""

New-Item -ItemType Directory -Path $HistoryDir -Force | Out-Null

if (Test-Path -LiteralPath $TargetFile -PathType Leaf) {
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $ArchiveFile = Join-Path $HistoryDir `
        "AUDIT_MM_REF_001_002_PRESNY_PREVIOUS_$Timestamp.ps1"

    Copy-Item `
        -LiteralPath $TargetFile `
        -Destination $ArchiveFile `
        -Force

    Write-Host "PŮVODNÍ VERZE ARCHIVOVÁNA:"
    Write-Host $ArchiveFile
    Write-Host ""
}

$EncodedContent = @"
77u/IyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQojIE1hdGNoTWF0cml4CiMgQVVESVRfTU1fUkVGXzAwMV8wMDJfUFJFU05ZX1YxLnBzMQojCiMgRU5HSU5FOgojICAgQV9SRUZfU1lOQ19BVURJVF9WMV8xX1JBV19URVhUX1JFR0VYCiMKIyBDTzoKIyAgIFDFmWVzbsSbIHBvcm92bsOhIHBvam15IHYgTU0tUkVGLTAwMSBzIGtsaWthY8OtbSByZWpzdMWZw61rZW0gTU0tUkVGLTAwMi4KIwojIEsgxIxFTVU6CiMgICBaamlzdMOtIGNoeWLEm2rDrWPDrSBhIG5hZGJ5dGXEjW7DqSBwb2pteSBiZXogemFwb8SNw610w6Fuw60gbWV0YWRhdCwKIyAgIHNvdWhybsWvIG5lYm8gaGlzdG9yaWUgdmVyesOtLgojCiMgS0RFOgojICAgdG9vbHNcZG9jdW1lbnRhdGlvblxBVURJVF9NTV9SRUZfMDAxXzAwMl9QUkVTTllfVjEucHMxCiMKIyBKQUs6CiMgICBQUk9KRUNUX1JPT1Qgb2R2b2TDrSB6ZSBzdsOpaG8gdW3DrXN0xJtuw60uCiMgICBGdW5ndWplIGxva8OhbG7EmyBuYSBQQzIgaSB6IFBDMSBwxZllcyBVTkMuCiMgICBNYXJrZG93biBuYcSNw610w6EgamFrbyBjZWzDvSB0ZXh0OyBuZXDFmWVkw6F2w6EgcHLDoXpkbsOpIMWZw6Fka3kgZG8gcGFyYW1ldHLFryBmdW5rY8OtLgojID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09CgokRXJyb3JBY3Rpb25QcmVmZXJlbmNlID0gIlN0b3AiClNldC1TdHJpY3RNb2RlIC1WZXJzaW9uIExhdGVzdAoKJEVuZ2luZSA9ICJBX1JFRl9TWU5DX0FVRElUX1YxXzFfUkFXX1RFWFRfUkVHRVgiCgppZiAoW3N0cmluZ106OklzTnVsbE9yV2hpdGVTcGFjZSgkUFNTY3JpcHRSb290KSkgewogICAgdGhyb3cgIk5lbHplIHVyxI1pdCBQU1NjcmlwdFJvb3QuIFNrcmlwdCBtdXPDrSBiw710IHNwdcWhdMSbbiB6ZSBzb3Vib3J1IC5wczEuIgp9CgokVG9vbHNEaXIgPSBTcGxpdC1QYXRoIC1QYXJlbnQgJFBTU2NyaXB0Um9vdAokUHJvamVjdFJvb3QgPSBTcGxpdC1QYXRoIC1QYXJlbnQgJFRvb2xzRGlyCgokUmVmMDAxID0gSm9pbi1QYXRoICRQcm9qZWN0Um9vdCBgCiAgICAiZG9jc1wxMF9SRUZFUkVOQ0VcTU0tUkVGLTAwMV9TTE9WTklLX0NJWklDSF9QT0pNVV9NQVRDSE1BVFJJWC5tZCIKCiRSZWYwMDIgPSBKb2luLVBhdGggJFByb2plY3RSb290IGAKICAgICJkb2NzXDEwX1JFRkVSRU5DRVxNTS1SRUYtMDAyX1ZZS0xBRE9WWV9SRUpTVFJJS19QT0pNVV9NQVRDSE1BVFJJWC5tZCIKCldyaXRlLUhvc3QgIiIKV3JpdGUtSG9zdCAiTUFUQ0hNQVRSSVggLSBQxZhFU07DnSBBVURJVCBNTS1SRUYtMDAxIC8gTU0tUkVGLTAwMiIgLUZvcmVncm91bmRDb2xvciBDeWFuCldyaXRlLUhvc3QgKCI9IiAqIDc4KQpXcml0ZS1Ib3N0ICJFTkdJTkUgICAgICA6ICRFbmdpbmUiCldyaXRlLUhvc3QgIlNDUklQVF9ST09UIDogJFBTU2NyaXB0Um9vdCIKV3JpdGUtSG9zdCAiUFJPSkVDVF9ST09UOiAkUHJvamVjdFJvb3QiCldyaXRlLUhvc3QgIk1NLVJFRi0wMDEgIDogJFJlZjAwMSIKV3JpdGUtSG9zdCAiTU0tUkVGLTAwMiAgOiAkUmVmMDAyIgpXcml0ZS1Ib3N0ICIiCgppZiAoLW5vdCAoVGVzdC1QYXRoIC1MaXRlcmFsUGF0aCAkUmVmMDAxIC1QYXRoVHlwZSBMZWFmKSkgewogICAgdGhyb3cgIkNoeWLDrSBNTS1SRUYtMDAxOiAkUmVmMDAxIgp9CgppZiAoLW5vdCAoVGVzdC1QYXRoIC1MaXRlcmFsUGF0aCAkUmVmMDAyIC1QYXRoVHlwZSBMZWFmKSkgewogICAgdGhyb3cgIkNoeWLDrSBNTS1SRUYtMDAyOiAkUmVmMDAyIgp9CgokVGV4dDAwMSA9IEdldC1Db250ZW50IC1MaXRlcmFsUGF0aCAkUmVmMDAxIC1SYXcgLUVuY29kaW5nIFVURjgKJFRleHQwMDIgPSBHZXQtQ29udGVudCAtTGl0ZXJhbFBhdGggJFJlZjAwMiAtUmF3IC1FbmNvZGluZyBVVEY4CgppZiAoW3N0cmluZ106OklzTnVsbE9yV2hpdGVTcGFjZSgkVGV4dDAwMSkpIHsKICAgIHRocm93ICJNTS1SRUYtMDAxIGplIHByw6F6ZG7DvTogJFJlZjAwMSIKfQoKaWYgKFtzdHJpbmddOjpJc051bGxPcldoaXRlU3BhY2UoJFRleHQwMDIpKSB7CiAgICB0aHJvdyAiTU0tUkVGLTAwMiBqZSBwcsOhemRuw706ICRSZWYwMDIiCn0KCiRQYXR0ZXJuMDAxID0gJyg/bXMpXiNccyszXC5ccytQxZlla2xhZG92w70gc2xvdm7DrWtccypccj9cbig/PGJvZHk+Lio/KSg/PV4jXHMrNFwuXHMrU291aHJuIHZlcnplKScKJFBhdHRlcm4wMDIgPSAnKD9tcyleI1xzKzJcLlxzK0tsaWthY8OtIHJlanN0xZnDrWtccypccj9cbig/PGJvZHk+Lio/KSg/PV4jXHMrM1wuXHMrVsO9a2xhZHkgcG9qbcWvKScKCiRNYXRjaDAwMSA9IFtyZWdleF06Ok1hdGNoKCRUZXh0MDAxLCAkUGF0dGVybjAwMSkKJE1hdGNoMDAyID0gW3JlZ2V4XTo6TWF0Y2goJFRleHQwMDIsICRQYXR0ZXJuMDAyKQoKaWYgKC1ub3QgJE1hdGNoMDAxLlN1Y2Nlc3MpIHsKICAgIHRocm93ICJWIE1NLVJFRi0wMDEgbmVieWxhIG5hbGV6ZW5hIHNla2NlIDMuIFDFmWVrbGFkb3bDvSBzbG92bsOtay4iCn0KCmlmICgtbm90ICRNYXRjaDAwMi5TdWNjZXNzKSB7CiAgICB0aHJvdyAiViBNTS1SRUYtMDAyIG5lYnlsYSBuYWxlemVuYSBzZWtjZSAyLiBLbGlrYWPDrSByZWpzdMWZw61rLiIKfQoKJEJvZHkwMDEgPSAkTWF0Y2gwMDEuR3JvdXBzWyJib2R5Il0uVmFsdWUKJEJvZHkwMDIgPSAkTWF0Y2gwMDIuR3JvdXBzWyJib2R5Il0uVmFsdWUKCiRUZXJtczAwMSA9IFtTeXN0ZW0uQ29sbGVjdGlvbnMuR2VuZXJpYy5MaXN0W3N0cmluZ11dOjpuZXcoKQokVGVybXMwMDIgPSBbU3lzdGVtLkNvbGxlY3Rpb25zLkdlbmVyaWMuTGlzdFtzdHJpbmddXTo6bmV3KCkKCmZvcmVhY2ggKCRMaW5lIGluICgkQm9keTAwMSAtc3BsaXQgIlxyP1xuIikpIHsKICAgIGlmICgkTGluZSAtbWF0Y2ggJ15cfFxzKihbXnxdKz8pXHMqXHxccyooW158XSs/KVxzKlx8JCcpIHsKICAgICAgICAkVGVybSA9ICRNYXRjaGVzWzFdLlRyaW0oKQoKICAgICAgICBpZiAoCiAgICAgICAgICAgICRUZXJtIC1uZSAiQ2l6w60gdsO9cmF6IiAtYW5kCiAgICAgICAgICAgICRUZXJtIC1uZSAiLS0tIiAtYW5kCiAgICAgICAgICAgIC1ub3QgW3N0cmluZ106OklzTnVsbE9yV2hpdGVTcGFjZSgkVGVybSkKICAgICAgICApIHsKICAgICAgICAgICAgJFRlcm1zMDAxLkFkZCgkVGVybSkKICAgICAgICB9CiAgICB9Cn0KCmZvcmVhY2ggKCRMaW5lIGluICgkQm9keTAwMiAtc3BsaXQgIlxyP1xuIikpIHsKICAgIGlmICgKICAgICAgICAkTGluZSAtbWF0Y2ggJ15cfFxzKihbXnxdKz8pXHMqXHxccyooW158XSs/KVxzKlx8XHMqXFtPdGV2xZnDrXQgdsO9a2xhZFxdXChbXildK1wpXHMqXHwnCiAgICApIHsKICAgICAgICAkVGVybSA9ICRNYXRjaGVzWzFdLlRyaW0oKQoKICAgICAgICBpZiAoLW5vdCBbc3RyaW5nXTo6SXNOdWxsT3JXaGl0ZVNwYWNlKCRUZXJtKSkgewogICAgICAgICAgICAkVGVybXMwMDIuQWRkKCRUZXJtKQogICAgICAgIH0KICAgIH0KfQoKJFVuaXF1ZTAwMSA9IEAoJFRlcm1zMDAxIHwgU29ydC1PYmplY3QgLVVuaXF1ZSkKJFVuaXF1ZTAwMiA9IEAoJFRlcm1zMDAyIHwgU29ydC1PYmplY3QgLVVuaXF1ZSkKCiRNaXNzaW5nID0gQCgKICAgICRVbmlxdWUwMDEgfAogICAgV2hlcmUtT2JqZWN0IHsgJF8gLW5vdGluICRVbmlxdWUwMDIgfSB8CiAgICBTb3J0LU9iamVjdAopCgokRXh0cmEgPSBAKAogICAgJFVuaXF1ZTAwMiB8CiAgICBXaGVyZS1PYmplY3QgeyAkXyAtbm90aW4gJFVuaXF1ZTAwMSB9IHwKICAgIFNvcnQtT2JqZWN0CikKCldyaXRlLUhvc3QgIlbDnVNMRURFSyIKV3JpdGUtSG9zdCAoIi0iICogNzgpCldyaXRlLUhvc3QgIk1NLVJFRi0wMDEgcG9qbcWvICA6ICQoJFVuaXF1ZTAwMS5Db3VudCkiCldyaXRlLUhvc3QgIk1NLVJFRi0wMDIgdsO9a2xhZMWvOiAkKCRVbmlxdWUwMDIuQ291bnQpIgpXcml0ZS1Ib3N0ICJDaHliw60gdiBNTS1SRUYtMDAyOiAkKCRNaXNzaW5nLkNvdW50KSIKV3JpdGUtSG9zdCAiTmF2w61jIHYgTU0tUkVGLTAwMjogJCgkRXh0cmEuQ291bnQpIgoKV3JpdGUtSG9zdCAiIgpXcml0ZS1Ib3N0ICI9PT0gUE9KTVkgQ0hZQsSaSsONQ8ONIFYgTU0tUkVGLTAwMiA9PT0iIC1Gb3JlZ3JvdW5kQ29sb3IgWWVsbG93CgppZiAoJE1pc3NpbmcuQ291bnQgLWVxIDApIHsKICAgIFdyaXRlLUhvc3QgIsW9w6FkbsOpLiIKfQplbHNlIHsKICAgICRNaXNzaW5nIHwgRm9yRWFjaC1PYmplY3QgeyBXcml0ZS1Ib3N0ICItICRfIiB9Cn0KCldyaXRlLUhvc3QgIiIKV3JpdGUtSG9zdCAiPT09IFBPSk1ZIE5BVsONQyBWIE1NLVJFRi0wMDIgPT09IiAtRm9yZWdyb3VuZENvbG9yIFllbGxvdwoKaWYgKCRFeHRyYS5Db3VudCAtZXEgMCkgewogICAgV3JpdGUtSG9zdCAixb3DoWRuw6kuIgp9CmVsc2UgewogICAgJEV4dHJhIHwgRm9yRWFjaC1PYmplY3QgeyBXcml0ZS1Ib3N0ICItICRfIiB9Cn0KCldyaXRlLUhvc3QgIiIKV3JpdGUtSG9zdCAoIj0iICogNzgpCldyaXRlLUhvc3QgIkFVRElUIERPS09OxIxFTiIgLUZvcmVncm91bmRDb2xvciBHcmVlbgo=
"@

$CleanBase64 = $EncodedContent -replace "\s", ""
$NewBytes = [Convert]::FromBase64String($CleanBase64)

$TemporaryFile = "$TargetFile.new"
[System.IO.File]::WriteAllBytes($TemporaryFile, $NewBytes)

$TemporaryVerification = Select-String `
    -LiteralPath $TemporaryFile `
    -Pattern $ExpectedMarker `
    -Quiet

if (-not $TemporaryVerification) {
    Remove-Item -LiteralPath $TemporaryFile -Force -ErrorAction SilentlyContinue
    throw "Nově vytvořená kopie neobsahuje očekávaný engine."
}

Move-Item `
    -LiteralPath $TemporaryFile `
    -Destination $TargetFile `
    -Force

$Verification = Select-String `
    -LiteralPath $TargetFile `
    -Pattern $ExpectedMarker `
    -Quiet

if (-not $Verification) {
    throw "Kontrola aktivního souboru po nahrazení selhala."
}

Write-Host "AKTIVNÍ AUDIT BYL ÚSPĚŠNĚ NAHRAZEN." -ForegroundColor Green
Write-Host ""

Get-Item -LiteralPath $TargetFile |
    Select-Object FullName, Length, LastWriteTime

Write-Host ""
Write-Host "OVĚŘENÝ ENGINE:"
Select-String `
    -LiteralPath $TargetFile `
    -Pattern $ExpectedMarker

Write-Host ""
Write-Host "SPOUŠTÍM OPRAVENÝ AUDIT..." -ForegroundColor Cyan
Write-Host ""

& powershell.exe `
    -NoProfile `
    -ExecutionPolicy Bypass `
    -File $TargetFile

if ($LASTEXITCODE -ne 0) {
    throw "Opravený audit skončil návratovým kódem $LASTEXITCODE."
}

Write-Host ""
Write-Host "INSTALACE I AUDIT BYLY DOKONČENY." -ForegroundColor Green
Write-Host ""
Write-Host "Jednorázový instalační soubor může být nyní přesunut do tools\histori."
