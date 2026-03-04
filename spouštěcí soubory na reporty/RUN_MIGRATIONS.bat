@echo off
setlocal
cd /d C:\MATCHMATRIX-PLATFORM

set DB_CONTAINER=matchmatrix_postgres
set DB_USER=matchmatrix
set DB_NAME=matchmatrix

echo Applying migrations from db\migrations
echo.

REM 1) zajisti tabulku migrací
docker exec -i %DB_CONTAINER% psql -U %DB_USER% -d %DB_NAME% -v ON_ERROR_STOP=1 ^
  < db\migrations\000_create_schema_migrations.sql

REM 2) projdi všechny .sql migrace (kromě 000) a aplikuj jen ty, co nejsou zapsané v ops.schema_migrations
for %%F in (db\migrations\*.sql) do (
  if /I not "%%~nxF"=="000_create_schema_migrations.sql" (
    echo --- Checking %%~nxF
    docker exec -i %DB_CONTAINER% psql -U %DB_USER% -d %DB_NAME% -t -A ^
      -c "SELECT 1 FROM ops.schema_migrations WHERE filename='%%~nxF' LIMIT 1;" | findstr "1" >nul
    if errorlevel 1 (
      echo Applying %%~nxF
      docker exec -i %DB_CONTAINER% psql -U %DB_USER% -d %DB_NAME% -v ON_ERROR_STOP=1 < "%%F"
      docker exec -i %DB_CONTAINER% psql -U %DB_USER% -d %DB_NAME% -v ON_ERROR_STOP=1 ^
        -c "INSERT INTO ops.schema_migrations(filename) VALUES ('%%~nxF');"
    ) else (
      echo Skipping %%~nxF (already applied)
    )
    echo.
  )
)

echo Done.
pause