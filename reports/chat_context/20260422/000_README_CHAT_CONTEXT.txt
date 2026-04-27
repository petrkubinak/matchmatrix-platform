MATCHMATRIX â€“ CHAT CONTEXT BUNDLE

Tato sloĹľka obsahuje centralizovanĂ˝ kontext pro novĂ˝ chat.

Obsah typicky:
- MATCHMATRIX_MASTER_NAVAZANI.md
- runtime_audit_*.txt
- worker_file_scan*.csv
- api_football_backfill_status_*.txt
- ops_1_columns.txt / ops_2_table_counts.txt / ops_3_constraints.txt
- staging_1_columns.txt / staging_2_table_counts.txt / staging_3_constraints.txt
- public_1_columns.txt / public_2_table_counts.txt / public_3_constraints.txt

DoporuÄŤenĂ­ pro novĂ˝ chat:
1) vloĹľit MATCHMATRIX_MASTER_NAVAZANI.md
2) vloĹľit runtime_audit_*.txt
3) vloĹľit worker_file_scan*.csv
4) podle potĹ™eby vloĹľit schema exporty OPS / staging / public
5) pokud Ĺ™eĹˇĂ­me football, pĹ™iloĹľit i api_football_backfill_status_*.txt

Text pro novĂ˝ chat:
Navazujeme v MatchMatrix na aktuĂˇlnĂ­ multisport ingest pattern: kaĹľdĂ˝ sport mĂˇ vlastnĂ­ ingest sloĹľku, runy jsou ve workers, football je speciĂˇlnĂ­ vÄ›tev, non-FB sporty jedou pĹ™es spoleÄŤnĂ˝ technickĂ˝ pattern; aktuĂˇlnĂ­ pravda je v auditnĂ­ch tabulkĂˇch, runtime auditu, worker scan reportech a schema exportech. PokraÄŤujeme podle pĹ™iloĹľenĂ©ho bundle.
