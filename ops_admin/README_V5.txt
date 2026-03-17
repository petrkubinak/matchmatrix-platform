
MATCHMATRIX MISSION CONTROL V5

ULOŽENÍ SOUBORŮ

1) Python panel:
C:\MatchMatrix-platform\ops_admin\panel_matchmatrix_audit_v5.py

2) Spouštěč bez černého okna:
C:\Users\Petr\Desktop\MatchMatrix_Mission_Control_V5.vbs

SPUŠTĚNÍ
- Dvojklik na soubor MatchMatrix_Mission_Control_V5.vbs

CO UMÍ V5
- audit celého projektu i vybraných částí
- porovnání s minulým během
- CSV + JSON + Markdown reporty
- Git audit
- DB audit (pokud funguje psycopg2 a PostgreSQL)
- lidsky čitelný progress report i pro laika

DŮLEŽITÉ
Pro DB audit je ideální mít nainstalováno:
pip install psycopg2-binary

VÝSTUPY
C:\MatchMatrix-platform\reports\audit\YYYY-MM-DD\HH-MM-SS\

Součástí běhu budou typicky:
- MATCHMATRIX_AUDIT_REPORT.md
- MATCHMATRIX_PROGRESS.md
- files.csv
- changes.csv
- snapshot.json
