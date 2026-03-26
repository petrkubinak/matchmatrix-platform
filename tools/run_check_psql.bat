@echo off
echo =========================================
echo MATCHMATRIX - CHECK PSQL PATH
echo =========================================

powershell -ExecutionPolicy Bypass -File "C:\MatchMatrix-platform\db\debug\011_find_psql_path.ps1"

echo.
echo =========================================
echo HOTOVO - stiskni libovolnou klavesu
echo =========================================
pause