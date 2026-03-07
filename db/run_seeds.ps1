$container = "matchmatrix_postgres"
$db = "matchmatrix"
$user = "matchmatrix"

Get-ChildItem "C:\MatchMatrix-platform\db\seeds\*.sql" | Sort-Object Name | ForEach-Object {
    Write-Host "Running seed:" $_.Name
    Get-Content -Raw $_.FullName | docker exec -i $container psql -U $user -d $db
}