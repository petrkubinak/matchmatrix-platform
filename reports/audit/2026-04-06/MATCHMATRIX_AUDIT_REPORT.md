# TicketMatrixPlatform – technický audit

Datum a čas: 2026-04-06 21:52:53
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 2069
- NEW: 3
- MODIFIED: 0
- DELETED: 0

## Nejvýznamnější změny
- NEW: db\checks\575_create_v_harvest_e2e_control.sql
- NEW: docs\komunikace s chatGPT\04_2026\20260406\MATCHMATRIX – ZÁPIS A PLÁN auditu.md
- NEW: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\575_create_v_harvest_e2e_control.sql

## Git
- Branch: main
- Last commit: a5d20ae | 2026-04-02 11:37:42 +0200 | %1
```
M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
 M MatchMatrix-platform/.dbeaver/project-metadata.json
 M db/sql/Script.sql
 M ingest/TheOdds/theodds_parse_multi_V3.py
 M reports/audit/2026-04-02/MATCHMATRIX_AUDIT_REPORT.md
 M reports/audit/2026-04-02/MATCHMATRIX_PROGRESS.md
 M reports/audit/latest_audit_report.md
 M reports/audit/latest_progress_report.md
 M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
 M tools/matchmatrix_control_panel_V11.py
 M unmatched_theodds_165.sql
 M workers/theodds_matching_v3.py
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
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_l_top_problem_teams.sql"
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
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/508_a_debug_theodds_valid_match_linking.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/508_b_debug_theodds_valid_match_linking.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/508_c_debug_theodds_valid_match_linking.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/508_d_debug_theodds_valid_match_linking.sql"
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
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_k_merge_gil_vicente_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_l_merge_santa_clara_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_m_merge_fc_porto_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_n_merge_famalicao_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_o_merge_benfica_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_p_merge_casa_pia_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_q_merge_arouca_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_r_merge_estoril_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_s_merge_celta_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_t_merge_real_betis_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_u_merge_espanyol_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_v_merge_girona_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_w_merge_sc_telstar_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/513_a_merge_groningen_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/513_b_merge_auxerre_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/515_bulk_merge_eredivisie_fk_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/516_a_check_az_fortuna_match.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/516_merge_fortuna_sittard_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/517_next_eredivisie_safe_merges.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/519_ligue1_safe_merges_real.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/520_serie_a_safe_merges.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/521_bundesliga_safe_merges.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/521_bundesliga_st.pauli_safe_merges.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/522_epl_safe_merges_verified.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/523_epl_finish_safe_merges.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/524_efl_champ_safe_merges.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/524_efl_champ_southampton_safe_merges.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/525_copa_libertadores_safe_merges.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/526_copa_libertadores_more_safe_merges.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/527_world_cup_Congo_safe_merges.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/527_world_cup_safe_merges.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/528_repoint_universidad_catolica_aliases_to_team_603.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/529_repoint_universidad_catolica_aliases_conflict_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/530_merge_universidad_catolica_10979_into_603_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/531_repoint_universidad_catolica_league_standings.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/532_repoint_nacional_de_montevideo_alias_to_35243.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/533_repoint_nacional_de_montevideo_conflict_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/534_repoint_lanus_alias_to_35245.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/536_repoint_estudiantes_la_plata_alias_to_35247.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/537_repoint_ucvfc_and_libertad_asuncion_aliases.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/540_repoint_ucv_league_standings_27876_to_35254.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/541_delete_duplicate_ucv_alias_on_27876.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/542_repoint_platense_alias_to_35258.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/543_repoint_penarol_montevideo_alias_to_35261.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/545_a_inspect_unmatched_theodds_columns.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/545_b_epl_6_cases_detail.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/546_epl_team_branch_time_detail_FIX.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/547_inspect_leeds_brighton_duplicate_branches.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/548_e_merge_leeds_brighton_final_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/549_verify_epl_after_leeds_brighton_merge.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/550_epl_remaining_2_cases_detail.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/551_merge_newcastle_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/552_verify_epl_after_all_merges.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/555_bundesliga_remaining_1_detail.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/556_heidenheim_alias_target_check.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/557_fix_heidenheim_alias_on_gladbach.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/558_primeira_remaining_1_detail.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/559_today_cleanup_notes_2026-04-06.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/560_brasileirao_remaining_2_detail.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/561_brasileirao_exact_pair_check.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/562_libertadores_remaining_2_detail.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/563_linker_backlog_summary.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/564_linker_rules_proposal.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/565_audit_exact_pair_no_fixture_found.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/566_audit_exact_pair_no_fixture_found_with_time.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/567_audit_football_data_missing_team_ids.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/568_audit_missing_pairs_in_football_data_raw.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/569_classify_unmatched_fixture_backlog.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/570_top_problem_teams.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/571_top4_team_identity_detail.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/572_remaining_unmatched_after_cleanup.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/573_final_backlog_classification.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/574_attach_now_linker_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/575_attach_now_update_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/576_remaining_after_safe_attach.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/577_finalize_remaining_backlog.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/578_mapping_gap_candidates.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/579_fix_mapping_gap_senior_preference.sql"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/"
?? db/audit/493_494_audit_suspicious_no_match_resolves.sql
?? db/audit/493_audit_remaining_no_match_groups.sql
?? db/audit/496_c_export_team_not_mapped_alias_candidates.sql
?? db/audit/528_repoint_universidad_catolica_aliases_to_team_603.sql
?? db/audit/529_repoint_universidad_catolica_aliases_conflict_safe.sql
?? db/audit/530_merge_universidad_catolica_10979_into_603_safe.sql
?? db/audit/531_repoint_universidad_catolica_league_standings.sql
?? db/audit/532_repoint_nacional_de_montevideo_alias_to_35243.sql
?? db/audit/533_repoint_nacional_de_montevideo_conflict_safe.sql
?? db/audit/534_repoint_lanus_alias_to_35245.sql
?? db/audit/536_repoint_estudiantes_la_plata_alias_to_35247.sql
?? db/audit/537_repoint_ucvfc_and_libertad_asuncion_aliases.sql
?? db/audit/540_repoint_ucv_league_standings_27876_to_35254.sql
?? db/audit/541_delete_duplicate_ucv_alias_on_27876.sql
?? db/audit/542_repoint_platense_alias_to_35258.sql
?? db/audit/543_repoint_penarol_montevideo_alias_to_35261.sql
?? db/audit/545_a_inspect_unmatched_theodds_columns.sql
?? db/audit/545_b_epl_6_cases_detail.sql
?? db/audit/546_epl_team_branch_time_detail_FIX.sql
?? db/audit/547_inspect_leeds_brighton_duplicate_branches.sql
?? db/audit/548_e_merge_leeds_brighton_final_safe.sql
?? db/audit/549_verify_epl_after_leeds_brighton_merge.sql
?? db/audit/550_epl_remaining_2_cases_detail.sql
?? db/audit/551_merge_newcastle_safe.sql
?? db/audit/552_verify_epl_after_all_merges.sql
?? db/audit/555_bundesliga_remaining_1_detail.sql
?? db/audit/556_heidenheim_alias_target_check.sql
?? db/audit/557_fix_heidenheim_alias_on_gladbach.sql
?? db/audit/558_primeira_remaining_1_detail.sql
?? db/audit/559_today_cleanup_notes_2026-04-06.sql
?? db/audit/560_brasileirao_remaining_2_detail.sql
?? db/audit/561_brasileirao_exact_pair_check.sql
?? db/audit/562_libertadores_remaining_2_detail.sql
?? db/audit/563_linker_backlog_summary.sql
?? db/audit/564_linker_rules_proposal.sql
?? db/audit/565_audit_exact_pair_no_fixture_found.sql
?? db/audit/566_audit_exact_pair_no_fixture_found_with_time.sql
?? db/audit/567_audit_football_data_missing_team_ids.sql
?? db/audit/568_audit_missing_pairs_in_football_data_raw.sql
?? db/audit/569_classify_unmatched_fixture_backlog.sql
?? db/audit/570_top_problem_teams.sql
?? db/audit/571_top4_team_identity_detail.sql
?? db/audit/572_remaining_unmatched_after_cleanup.sql
?? db/audit/573_final_backlog_classification.sql
?? db/audit/574_attach_now_linker_safe.sql
?? db/audit/575_attach_now_update_safe.sql
?? db/audit/576_remaining_after_safe_attach.sql
?? db/audit/577_finalize_remaining_backlog.sql
?? db/audit/578_mapping_gap_candidates.sql
?? db/audit/579_fix_mapping_gap_senior_preference.sql
?? db/checks/575_create_v_harvest_e2e_control.sql
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
?? db/sql/497_l_top_problem_teams.sql
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
?? db/sql/512_k_merge_gil_vicente_safe.sql
?? db/sql/512_l_merge_santa_clara_safe.sql
?? db/sql/512_m_merge_fc_porto_safe.sql
?? db/sql/512_n_merge_famalicao_safe.sql
?? db/sql/512_o_merge_benfica_safe.sql
?? db/sql/512_p_merge_casa_pia_safe.sql
?? db/sql/512_q_merge_arouca_safe.sql
?? db/sql/512_r_merge_estoril_safe.sql
?? db/sql/512_s_merge_celta_safe.sql
?? db/sql/512_t_merge_real_betis_safe.sql
?? db/sql/512_u_merge_espanyol_safe.sql
?? db/sql/512_v_merge_girona_safe.sql
?? db/sql/512_w_merge_sc_telstar_safe.sql
?? db/sql/513_a_merge_groningen_safe.sql
?? db/sql/513_b_merge_auxerre_safe.sql
?? db/sql/515_bulk_merge_eredivisie_fk_safe.sql
?? db/sql/516_a_check_az_fortuna_match.sql
?? db/sql/516_merge_fortuna_sittard_safe.sql
?? db/sql/517_next_eredivisie_safe_merges.sql
?? db/sql/519_ligue1_safe_merges_real.sql
?? db/sql/520_serie_a_safe_merges.sql
?? db/sql/521_bundesliga_safe_merges.sql
?? db/sql/521_bundesliga_st.pauli_safe_merges.sql
?? db/sql/522_epl_safe_merges_verified.sql
?? db/sql/523_epl_finish_safe_merges.sql
?? db/sql/524_efl_champ_safe_merges.sql
?? db/sql/524_efl_champ_southhampton_safe_merges.sql
?? db/sql/525_copa_libertadores_safe_merges.sql
?? db/sql/526_copa_libertadores_more_safe_merges.sql
?? db/sql/527_world_cup_Congo_safe_merges.sql
?? db/sql/527_world_cup_safe_merges.sql
?? "docs/komunikace s chatGPT/04_2026/20260402/MATCHMATRIX \342\200\223 STAV PROJEKTU .md"
?? "docs/komunikace s chatGPT/04_2026/20260403/"
?? "docs/komunikace s chatGPT/04_2026/20260404/"
?? "docs/komunikace s chatGPT/04_2026/20260405/"
?? "docs/komunikace s chatGPT/04_2026/20260406/"
?? launchers/run_matchmatrix_ticket_studio_v3.vbs
?? legacy/ingest/theodds_parse_multi_V3.py
?? reports/audit/2026-04-02/469_audit/494_audit_2.txt
?? reports/audit/2026-04-02/469_audit/494_audit_3.txt
?? reports/audit/2026-04-02/469_audit/496_n_audit_3.txt
?? reports/audit/2026-04-02/469_audit/496_o_audit_1.txt
?? reports/audit/2026-04-02/469_audit/508_audit-1775467065586.txt
?? reports/audit/2026-04-02/469_audit/508_audit.txt
?? reports/audit/2026-04-04/
?? reports/audit/2026-04-05/
?? reports/audit/2026-04-06/
?? reports/audit/system_tree_2026-04-02_235719.txt
?? reports/audit/system_tree_2026-04-04_090424.txt
?? reports/audit/system_tree_2026-04-04_235058.txt
?? reports/audit/system_tree_2026-04-05_231123.txt
?? reports/audit/system_tree_2026-04-06_120927.txt
?? reports/audit/system_tree_2026-04-06_191203.txt
?? reports/audit/system_tree_2026-04-06_211837.txt
?? reports/audit/system_tree_2026-04-06_215252.txt
?? unmatched_theodds_168.csv
?? unmatched_theodds_168.sql
?? unmatched_theodds_169.csv
?? unmatched_theodds_169.sql
?? unmatched_theodds_170.csv
?? unmatched_theodds_170.sql
?? unmatched_theodds_171.csv
?? unmatched_theodds_171.sql
?? unmatched_theodds_172.csv
?? unmatched_theodds_172.sql
?? unmatched_theodds_174.csv
?? unmatched_theodds_174.sql
?? unmatched_theodds_175.csv
?? unmatched_theodds_175.sql
?? unmatched_theodds_176.csv
?? unmatched_theodds_176.sql
?? unmatched_theodds_177.csv
?? unmatched_theodds_177.sql
?? unmatched_theodds_178.csv
?? unmatched_theodds_178.sql
?? unmatched_theodds_179.csv
?? unmatched_theodds_179.sql
?? unmatched_theodds_180.csv
?? unmatched_theodds_180.sql
?? unmatched_theodds_181.csv
?? unmatched_theodds_181.sql
?? unmatched_theodds_182.csv
?? unmatched_theodds_182.sql
?? unmatched_theodds_183.csv
?? unmatched_theodds_183.sql
?? unmatched_theodds_184.csv
?? unmatched_theodds_184.sql
?? unmatched_theodds_185.csv
?? unmatched_theodds_185.sql
?? unmatched_theodds_186.csv
?? unmatched_theodds_186.sql
?? unmatched_theodds_188.csv
?? unmatched_theodds_188.sql
?? unmatched_theodds_189.csv
?? unmatched_theodds_189.sql
?? unmatched_theodds_191.csv
?? unmatched_theodds_191.sql
?? unmatched_theodds_193.csv
?? unmatched_theodds_193.sql
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2986
  - matches: 105603
  - players: 1490
  - teams: 5306
- OPS counts:
  - ingest_planner: 3084
  - job_runs: 470
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