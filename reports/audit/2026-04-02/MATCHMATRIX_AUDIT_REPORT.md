# TicketMatrixPlatform – technický audit

Datum a čas: 2026-04-02 23:57:21
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 1853
- NEW: 132
- MODIFIED: 3
- DELETED: 0

## Nejvýznamnější změny
- MODIFIED: db\sql\Script.sql
- MODIFIED: MatchMatrix-platform\.dbeaver\project-metadata.json
- MODIFIED: unmatched_theodds_165.sql
- NEW: db\audit\493_494_audit_suspicious_no_match_resolves.sql
- NEW: db\audit\493_audit_remaining_no_match_groups.sql
- NEW: db\audit\496_c_export_team_not_mapped_alias_candidates.sql
- NEW: db\fix\493_audit_remaining_no_match_groups.sql
- NEW: db\sql\496_k_find_last_4_canonical_targets.sql
- NEW: db\sql\496_l_find_last_4_via_maps.sql
- NEW: db\sql\496_m_seed_final_normalized_aliases.sql
- NEW: db\sql\496_n_audit_pair_missing_detail.sql
- NEW: db\sql\496_o_find_ambiguous_aliases.sql
- NEW: db\sql\496_p_bundesliga_duplicate_teams.sql
- NEW: db\sql\496_s_merge_union_berlin_safe_v2.sql
- NEW: db\sql\496_t_fc_st_pauli_duplicate_check.sql
- NEW: db\sql\496_u_merge_fc_st_pauli_safe.sql
- NEW: db\sql\496_v_ligue1_duplicate_check.sql
- NEW: db\sql\496_w_merge_lyon_safe.sql
- NEW: db\sql\496_x_merge_nice_safe.sql
- NEW: db\sql\496_y_merge_strasbourg_safe_v2.sql

## Git
- Branch: main
- Last commit: a5d20ae | 2026-04-02 11:37:42 +0200 | %1
```
M MatchMatrix-platform/.dbeaver/project-metadata.json
 M db/sql/Script.sql
 M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
 M unmatched_theodds_165.sql
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/493_494_audit_suspicious_no_match_resolves.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/493_audit_remaining_no_match_groups.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/495_fix_team_alias_blacklist_youth.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_audit_missing_fixture_coverage.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_b_audit_no_match_id_coverage.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_c_export_team_not_mapped_alias_candidates.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_d_seed_missing_team_aliases_FIX2.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_e_export_remaining_team_not_mapped.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_f_find_canonical_targets_for_remaining_aliases.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_g_seed_remaining_clear_aliases.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_i_export_last_6_team_not_mapped.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_j_seed_last_clear_aliases.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_k_find_last_4_canonical_targets.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_l_find_last_4_via_maps.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_m_seed_final_normalized_aliases.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_n_audit_pair_missing_detail.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_o_find_ambiguous_aliases.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_p_bundesliga_duplicate_teams.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_q_merge_union_berlin.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_r_merge_union_berlin_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_s_merge_union_berlin_safe_v2.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_t_fc_st_pauli_duplicate_check.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_u_merge_fc_st_pauli_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_v_ligue1_duplicate_check.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_w_merge_lyon_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_x_merge_nice_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_y_merge_strasbourg_safe_v2.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_z_auxerre_profile_check.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_a_merge_auxerre_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_b_merge_nantes_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_c_merge_angers_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_d_merge_rennes_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_e_merge_burnley_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_f_merge_crystal_palace_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_g_merge_newcastle_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_h_merge_bournemouth_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_i_merge_brighton_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_j_merge_leeds_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_k_merge_manchester_united_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_m_merge_cagliari_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_n_merge_psv_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_o_merge_barcelona_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_p_merge_nacional_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_q_merge_utrecht_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_r_merge_az_alkmaar_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_s_merge_como_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_t_merge_feyenoord_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_u_merge_nec_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_v_merge_udinese_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_w_merge_sevilla_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/501_inspect_odds_table.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/502_find_theodds_raw_tables.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/503_debug_theodds_from_raw.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/504_inspect_matches_columns.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/505_debug_theodds_match_linking.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/506_inspect_api_raw_payloads_theodds.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/508_debug_theodds_valid_match_linking.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/509_debug_real_madrid_and_sporting_arsenal.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/510_merge_real_madrid_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/511_batch_merge_remaining_duplicates.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/511_merge_arsenal_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_a_merge_psg_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_b_merge_atletico_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_c_merge_valencia_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_d_merge_real_sociedad_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_e_merge_alaves_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_f_merge_rayo_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_g_merge_mallorca_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_h_merge_real_madrid_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_i_merge_villarreal_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_j_merge_getafe_safe.sql"
?? db/audit/493_494_audit_suspicious_no_match_resolves.sql
?? db/audit/493_audit_remaining_no_match_groups.sql
?? db/audit/496_c_export_team_not_mapped_alias_candidates.sql
?? db/fix/493_audit_remaining_no_match_groups.sql
?? db/sql/496_k_find_last_4_canonical_targets.sql
?? db/sql/496_l_find_last_4_via_maps.sql
?? db/sql/496_m_seed_final_normalized_aliases.sql
?? db/sql/496_n_audit_pair_missing_detail.sql
?? db/sql/496_o_find_ambiguous_aliases.sql
?? db/sql/496_p_bundesliga_duplicate_teams.sql
?? db/sql/496_s_merge_union_berlin_safe_v2.sql
?? db/sql/496_t_fc_st_pauli_duplicate_check.sql
?? db/sql/496_u_merge_fc_st_pauli_safe.sql
?? db/sql/496_v_ligue1_duplicate_check.sql
?? db/sql/496_w_merge_lyon_safe.sql
?? db/sql/496_x_merge_nice_safe.sql
?? db/sql/496_y_merge_strasbourg_safe_v2.sql
?? db/sql/496_z_auxerre_profile_check.sql
?? db/sql/497_a_merge_auxerre_safe.sql
?? db/sql/497_b_merge_nantes_safe.sql
?? db/sql/497_c_merge_angers_safe.sql
?? db/sql/497_d_merge_rennes_safe.sql
?? db/sql/497_e_merge_burnley_safe.sql
?? db/sql/497_f_merge_crystal_palace_safe.sql
?? db/sql/497_g_merge_newcastle_safe.sql
?? db/sql/497_h_merge_bournemouth_safe.sql
?? db/sql/497_i_merge_brighton_safe.sql
?? db/sql/497_j_merge_leeds_safe.sql
?? db/sql/497_k_merge_manchester_united_safe.sql
?? db/sql/497_m_merge_cagliari_safe.sql
?? db/sql/497_n_merge_psv_safe.sql
?? db/sql/497_o_merge_barcelona_safe.sql
?? db/sql/497_p_merge_nacional_safe.sql
?? db/sql/497_q_merge_utrecht_safe.sql
?? db/sql/497_r_merge_az_alkmaar_safe.sql
?? db/sql/497_s_merge_como_safe.sql
?? db/sql/497_u_merge_nec_safe.sql
?? db/sql/497_v_merge_udinese_safe.sql
?? db/sql/497_w_merge_sevilla_safe.sql
?? db/sql/501_inspect_odds_table.sql
?? db/sql/502_find_theodds_raw_tables.sql
?? db/sql/504_inspect_matches_columns.sql
?? db/sql/505_debug_theodds_match_linking.sql
?? db/sql/506_inspect_api_raw_payloads_theodds.sql
?? db/sql/508_debug_theodds_valid_match_linking.sql
?? db/sql/509_debug_real_madrid_and_sporting_arsenal.sql
?? db/sql/510_merge_real_madrid_safe.sql
?? db/sql/511_batch_merge_remaining_duplicates.sql
?? db/sql/511_merge_arsenal_safe.sql
?? db/sql/512_a_merge_psg_safe.sql
?? db/sql/512_b_merge_atletico_safe.sql
?? db/sql/512_c_merge_valencia_safe.sql
?? db/sql/512_d_merge_real_sociedad_safe.sql
?? db/sql/512_e_merge_alaves_safe.sql
?? db/sql/512_f_merge_rayo_safe.sql
?? db/sql/512_g_merge_mallorca_safe.sql
?? db/sql/512_h_merge_real_madrid_safe.sql
?? db/sql/512_i_merge_villarreal_safe.sql
?? db/sql/512_j_merge_getafe_safe.sql
?? "docs/komunikace s chatGPT/04_2026/20260402/MATCHMATRIX \342\200\223 STAV PROJEKTU .md"
?? reports/audit/2026-04-02/469_audit/494_audit_2.txt
?? reports/audit/2026-04-02/469_audit/494_audit_3.txt
?? reports/audit/2026-04-02/469_audit/496_n_audit_3.txt
?? reports/audit/2026-04-02/469_audit/496_o_audit_1.txt
?? reports/audit/2026-04-02/469_audit/508_audit.txt
?? reports/audit/system_tree_2026-04-02_235719.txt
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2986
  - matches: 105603
  - players: 1490
  - teams: 5399
- OPS counts:
  - ingest_planner: 3084
  - job_runs: 469
  - provider_jobs: 140
  - scheduler_queue: 6
- Player pipeline:
  - player_match_statistics: 0
  - players_import: 1546
  - public_players: 1490
  - stg_provider_players: 1465
- API budget:
  - 2026-03-10 | american_football | used=0 | limit=100 | remaining=100
  - 2026-03-10 | baseball | used=0 | limit=100 | remaining=100
  - 2026-03-10 | basketball | used=0 | limit=40 | remaining=40
  - 2026-03-10 | cricket | used=0 | limit=100 | remaining=100
  - 2026-03-10 | esports | used=0 | limit=100 | remaining=100
  - 2026-03-10 | field_hockey | used=0 | limit=100 | remaining=100
  - 2026-03-10 | football | used=0 | limit=20 | remaining=20
  - 2026-03-10 | handball | used=0 | limit=100 | remaining=100
  - 2026-03-10 | hockey | used=0 | limit=40 | remaining=40
  - 2026-03-10 | mma | used=0 | limit=100 | remaining=100
  - 2026-03-10 | rugby | used=0 | limit=100 | remaining=100
  - 2026-03-10 | tennis | used=0 | limit=100 | remaining=100
  - 2026-03-10 | volleyball | used=0 | limit=100 | remaining=100

## Navigator
- Projekt root: FOUND | C:\MatchMatrix-platform
- Workers: FOUND | C:\MatchMatrix-platform\workers
- Ingest: FOUND | C:\MatchMatrix-platform\ingest
- API-Football: FOUND | C:\MatchMatrix-platform\ingest\API-Football
- DB: FOUND | C:\MatchMatrix-platform\db
- Reports: FOUND | C:\MatchMatrix-platform\reports
- OPS Admin: FOUND | C:\MatchMatrix-platform\ops_admin
- Frontend root: FOUND | C:\MatchMatrix-platform\fronted
- MatchMatrix web: FOUND | C:\MatchMatrix-platform\fronted\matchmatrix-web
- Docs: FOUND | C:\MatchMatrix-platform\docs
- Dump: FOUND | C:\MatchMatrix-platform\MatchMatrix-platform\Dump
- Scripts: FOUND | C:\MatchMatrix-platform\MatchMatrix-platform\Scripts