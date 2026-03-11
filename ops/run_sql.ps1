param(
    [string]$file
)

Get-Content $file |
docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix