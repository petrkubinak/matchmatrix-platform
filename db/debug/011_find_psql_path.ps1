Get-Command psql -ErrorAction SilentlyContinue

$possible = @(
    "C:\Program Files\PostgreSQL\17\bin\psql.exe",
    "C:\Program Files\PostgreSQL\16\bin\psql.exe",
    "C:\Program Files\PostgreSQL\15\bin\psql.exe",
    "C:\Program Files\PostgreSQL\14\bin\psql.exe",
    "C:\Program Files\PostgreSQL\13\bin\psql.exe"
)

$possible | ForEach-Object {
    [PSCustomObject]@{
        Path   = $_
        Exists = Test-Path $_
    }
}