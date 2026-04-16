# TicketMatrixPlatform – technický audit

Datum a čas: 2026-04-15 20:21:07
Project root: C:\MatchMatrix-platform

## Vybrané části projektu
- Celý projekt

## Souhrn souborů
- Celkem souborů: 2396
- NEW: 8
- MODIFIED: 4
- DELETED: 0

## Nejvýznamnější změny
- MODIFIED: db\scripts\.112_runtime_audit_export_V2.ps1.txt
- MODIFIED: ingest\API-American-Football\pull_api_american_football_fixtures.ps1
- MODIFIED: ingest\providers\generic_api_sport_provider.py
- MODIFIED: reports\614_worker_file_scan_v2.csv
- NEW: data\raw\api_american_football\fixtures\api_american_football_fixtures_league_NFL_season_2024_20260413_160710.json
- NEW: docs\komunikace s chatGPT\04_2026\20260412\MATCHMATRIX – ZÁPIS (dnešní stav).md
- NEW: docs\komunikace s chatGPT\04_2026\20260415\# MATCHMATRIX – ZÁPIS.md
- NEW: logs\api_football_backfill_status_2026-04-13_162113.txt
- NEW: logs\api_football_backfill_status_2026-04-15_202032.txt
- NEW: MatchMatrix-platform\Scripts\18_stahování_dat_z_API\18_3_players\Script.sql
- NEW: reports\runtime_audit_20260413_162109.txt
- NEW: reports\runtime_audit_20260415_202029.txt

## Git
- Branch: main
- Last commit: 8b03f52 | 2026-04-06 21:54:00 +0200 | update players pipeline
```
M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
 M MatchMatrix-platform/.dbeaver/project-metadata.json
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/467_audit_api_football_cleanup_overview.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/468_disable_api_football_leagues.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/470_create_canonical_mapping_tables.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/471_seed_canonical_league_team_mapping.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/473_audit_manual_team_mapping_candidates.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/474_audit_unmapped_top_league_teams_side_by_side.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/475_seed_manual_team_mapping_review.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/476_cleanup_wrong_manual_team_mapping_review.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/477_audit_review_batch2_candidates.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/478_seed_manual_team_mapping_confirmed.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/479_create_canonical_team_resolve_view.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/480_create_canonical_match_lookup_view.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/481_audit_theodds_against_canonical_match_lookup.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/482_create_preferred_team_name_lookup_view.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/483_audit_theodds_against_preferred_team_name_lookup.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/484_audit_suspicious_team_aliases.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/485_cleanup_wrong_team_aliases.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/486_rerun_audit_483_after_alias_cleanup.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/487_extract_missing_teams_from_theodds.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/488_audit_missing_theodds_team_candidates.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/489_seed_missing_theodds_aliases.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/490_insert_missing_theodds_teams.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/491_cleanup_duplicate_theodds_teams.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/492_final_theodds_match_test.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/493_494_audit_suspicious_no_match_resolves.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/493_audit_remaining_no_match_groups.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/495_fix_team_alias_blacklist_youth.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_audit_missing_fixture_coverage.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_b_audit_no_match_id_coverage.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_c_export_team_not_mapped_alias_candidates.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_d_seed_missing_team_aliases_FIX2.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_e_export_remaining_team_not_mapped.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_f_find_canonical_targets_for_remaining_aliases.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_g_seed_remaining_clear_aliases.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_i_export_last_6_team_not_mapped.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_j_seed_last_clear_aliases.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_k_find_last_4_canonical_targets.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_l_find_last_4_via_maps.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_m_seed_final_normalized_aliases.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_n_audit_pair_missing_detail.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_o_find_ambiguous_aliases.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_p_bundesliga_duplicate_teams.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_q_merge_union_berlin.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_r_merge_union_berlin_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_s_merge_union_berlin_safe_v2.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_t_fc_st_pauli_duplicate_check.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_u_merge_fc_st_pauli_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_v_ligue1_duplicate_check.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_w_merge_lyon_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_x_merge_nice_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_y_merge_strasbourg_safe_v2.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/496_z_auxerre_profile_check.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_a_merge_auxerre_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_b_merge_nantes_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_c_merge_angers_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_d_merge_rennes_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_e_merge_burnley_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_f_merge_crystal_palace_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_g_merge_newcastle_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_h_merge_bournemouth_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_i_merge_brighton_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_j_merge_leeds_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_k_merge_manchester_united_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_l_top_problem_teams.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_m_merge_cagliari_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_n_merge_psv_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_o_merge_barcelona_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_p_merge_nacional_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_q_merge_utrecht_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_r_merge_az_alkmaar_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_s_merge_como_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_t_merge_feyenoord_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_u_merge_nec_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_v_merge_udinese_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/497_w_merge_sevilla_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/501_inspect_odds_table.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/502_find_theodds_raw_tables.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/503_debug_theodds_from_raw.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/504_inspect_matches_columns.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/505_debug_theodds_match_linking.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/506_inspect_api_raw_payloads_theodds.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/508_a_debug_theodds_valid_match_linking.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/508_b_debug_theodds_valid_match_linking.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/508_c_debug_theodds_valid_match_linking.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/508_d_debug_theodds_valid_match_linking.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/508_debug_theodds_valid_match_linking.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/509_debug_real_madrid_and_sporting_arsenal.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/510_merge_real_madrid_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/511_batch_merge_remaining_duplicates.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/511_merge_arsenal_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_a_merge_psg_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_b_merge_atletico_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_c_merge_valencia_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_d_merge_real_sociedad_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_e_merge_alaves_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_f_merge_rayo_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_g_merge_mallorca_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_h_merge_real_madrid_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_i_merge_villarreal_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_j_merge_getafe_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_k_merge_gil_vicente_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_l_merge_santa_clara_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_m_merge_fc_porto_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_n_merge_famalicao_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_o_merge_benfica_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_p_merge_casa_pia_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_q_merge_arouca_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_r_merge_estoril_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_s_merge_celta_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_t_merge_real_betis_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_u_merge_espanyol_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_v_merge_girona_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/512_w_merge_sc_telstar_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/513_a_merge_groningen_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/513_b_merge_auxerre_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/515_bulk_merge_eredivisie_fk_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/516_a_check_az_fortuna_match.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/516_merge_fortuna_sittard_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/517_next_eredivisie_safe_merges.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/519_ligue1_safe_merges_real.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/520_serie_a_safe_merges.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/521_bundesliga_safe_merges.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/521_bundesliga_st.pauli_safe_merges.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/522_epl_safe_merges_verified.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/523_epl_finish_safe_merges.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/524_efl_champ_safe_merges.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/524_efl_champ_southampton_safe_merges.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/525_copa_libertadores_safe_merges.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/526_copa_libertadores_more_safe_merges.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/527_world_cup_Congo_safe_merges.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/527_world_cup_safe_merges.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/528_repoint_universidad_catolica_aliases_to_team_603.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/529_repoint_universidad_catolica_aliases_conflict_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/530_merge_universidad_catolica_10979_into_603_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/531_repoint_universidad_catolica_league_standings.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/532_repoint_nacional_de_montevideo_alias_to_35243.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/533_repoint_nacional_de_montevideo_conflict_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/534_repoint_lanus_alias_to_35245.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/536_repoint_estudiantes_la_plata_alias_to_35247.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/537_repoint_ucvfc_and_libertad_asuncion_aliases.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/540_repoint_ucv_league_standings_27876_to_35254.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/541_delete_duplicate_ucv_alias_on_27876.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/542_repoint_platense_alias_to_35258.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/543_repoint_penarol_montevideo_alias_to_35261.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/545_a_inspect_unmatched_theodds_columns.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/545_b_epl_6_cases_detail.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/546_epl_team_branch_time_detail_FIX.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/547_inspect_leeds_brighton_duplicate_branches.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/548_e_merge_leeds_brighton_final_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/549_verify_epl_after_leeds_brighton_merge.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/550_epl_remaining_2_cases_detail.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/551_merge_newcastle_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/552_verify_epl_after_all_merges.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/555_bundesliga_remaining_1_detail.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/556_heidenheim_alias_target_check.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/557_fix_heidenheim_alias_on_gladbach.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/558_primeira_remaining_1_detail.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/559_today_cleanup_notes_2026-04-06.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/560_brasileirao_remaining_2_detail.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/561_brasileirao_exact_pair_check.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/562_libertadores_remaining_2_detail.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/563_linker_backlog_summary.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/564_linker_rules_proposal.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/565_audit_exact_pair_no_fixture_found.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/566_audit_exact_pair_no_fixture_found_with_time.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/567_audit_football_data_missing_team_ids.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/568_audit_missing_pairs_in_football_data_raw.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/569_classify_unmatched_fixture_backlog.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/570_top_problem_teams.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/571_top4_team_identity_detail.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/572_remaining_unmatched_after_cleanup.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/573_final_backlog_classification.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/574_attach_now_linker_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/575_attach_now_update_safe.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/576_remaining_after_safe_attach.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/577_finalize_remaining_backlog.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/578_mapping_gap_candidates.sql"
 D "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/579_fix_mapping_gap_senior_preference.sql"
 D "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/575_create_v_harvest_e2e_control.sql"
 D MatchMatrix-platform/Scripts/99_reports/Script-3.sql
 D MatchMatrix-platform/Scripts/99_reports/Script-4.sql
 D "docs/komunikace s chatGPT/20260329/467_audit_1.txt"
 D ingest/API-Sport/pull_api_basketball_players.ps1
 M ingest/API-Sport/pull_api_sport_teams.ps1
 M ingest/TheOdds/theodds_parse_multi_V3.py
 M ingest/providers/generic_api_sport_provider.py
 M ingest/run_unified_ingest_batch_v1.py
 M ingest/run_unified_ingest_v1.py
 M reports/audit/latest_audit_report.md
 M reports/audit/latest_progress_report.md
 M reports/audit/latest_snapshot.txt
 M reports/audit/latest_system_tree.txt
 D reports/audit/system_tree_2026-04-01_103734.txt
 D reports/audit/system_tree_2026-04-01_205300.txt
 D reports/audit/system_tree_2026-04-02_074300.txt
 D reports/audit/system_tree_2026-04-02_112803.txt
 D reports/audit/system_tree_2026-04-02_235719.txt
 D reports/audit/system_tree_2026-04-04_090424.txt
 D reports/audit/system_tree_2026-04-04_235058.txt
 D reports/audit/system_tree_2026-04-05_231123.txt
 D reports/audit/system_tree_2026-04-06_120927.txt
 D reports/audit/system_tree_2026-04-06_191203.txt
 D reports/audit/system_tree_2026-04-06_211837.txt
 D reports/audit/system_tree_2026-04-06_215252.txt
?? "MATCHMATRIX \342\200\223 popis ORCHESTRACE INGESTU.md"
?? "MatchMatrix-platform/Scripts/16_ticket_vyhodnocen\303\255/496_o_find_ambiguous_aliases.sql"
?? "MatchMatrix-platform/Scripts/16_ticket_vyhodnocen\303\255/496_p_bundesliga_duplicate_teams.sql"
?? "MatchMatrix-platform/Scripts/16_ticket_vyhodnocen\303\255/496_q_merge_union_berlin.sql"
?? "MatchMatrix-platform/Scripts/16_ticket_vyhodnocen\303\255/496_r_merge_union_berlin_safe.sql"
?? "MatchMatrix-platform/Scripts/16_ticket_vyhodnocen\303\255/496_s_merge_union_berlin_safe_v2.sql"
?? "MatchMatrix-platform/Scripts/16_ticket_vyhodnocen\303\255/496_t_fc_st_pauli_duplicate_check.sql"
?? "MatchMatrix-platform/Scripts/16_ticket_vyhodnocen\303\255/496_u_merge_fc_st_pauli_safe.sql"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/17_4--_/"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/17_5--_/"
?? "MatchMatrix-platform/Scripts/17_\304\215i\305\241t\304\233n\303\255_DB/17_7--_/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_0_p\305\231ehled_cel\303\251_DB/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_1_audity_po_sportech/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_2_coaches/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_3_players/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_4_kontrola_runn\305\257_/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_5_pipeline_full/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/18_6_sporty_cel\303\251_postupy/"
?? "MatchMatrix-platform/Scripts/18_stahov\303\241n\303\255_dat_z_API/Script.sql"
?? MatchMatrix-platform/Scripts/99_reports/99_1_ops_tables_columns_overview.sql
?? MatchMatrix-platform/Scripts/99_reports/99_2_staging_tables_columns_overview.sql
?? data/
?? db/audit/601_reuse_audit_ops_core_status.sql
?? db/audit/602_harvest_final_classification.sql
?? db/audit/603_wave_planner_input.sql
?? db/audit/604_planner_seed_candidates.sql
?? db/audit/605_planner_seed_insert_preview.sql
?? db/audit/606_wave1_core_filter_preview.sql
?? db/audit/607_planner_seed_insert_core_preview.sql
?? db/audit/608_planner_seed_core_stage.sql
?? db/audit/610_provider_sport_entity_matrix.sql
?? db/audit/612_normalized_structure_matrix.sql
?? db/audit/613_runtime_build_backlog.sql
?? db/audit/616_hk_teams_public_merge_check_v2.sql
?? db/audit/701_audit_fb_players_ready_definition.sql
?? db/audit/702_audit_fb_players_pro_harvest_ready.sql
?? db/audit/706_audit_fb_players_wave1_coverage.sql
?? db/audit/99_1_ops_tables_columns_overview.sql
?? db/audit/99_2_staging_tables_columns_overview.sql
?? db/checks/110_seed_runtime_entity_audit_known_state.sql
?? db/checks/112_runtime_audit_master_quickcheck_v2.sql
?? db/checks/113_hk_fixtures_after_run_check_v2.sql
?? db/checks/115_update_runtime_entity_audit_hk_fixtures_stage_confirmed.sql
?? db/checks/116_preview_hk_provider_fixtures.sql
?? db/checks/117_bk_teams_after_run_check_v2.sql
?? db/checks/119_update_runtime_entity_audit_bk_teams_payload_only.sql
?? db/checks/120_bk_fixtures_after_run_check.sql
?? db/checks/121_update_runtime_entity_audit_bk_fixtures_stage_confirmed.sql
?? db/checks/122_find_bk_teams_parser_state.sql
?? db/checks/123_update_runtime_entity_audit_vb_fixtures_partial.sql
?? db/checks/124_insert_runtime_entity_audit_vb_leagues.sql
?? db/checks/124_update_runtime_entity_audit_vb_leagues_partial.sql
?? db/checks/125_insert_runtime_entity_audit_vb_odds.sql
?? db/checks/126_update_runtime_entity_audit_vb_teams_partial.sql
?? db/checks/127_update_or_insert_runtime_entity_audit_bk_teams_confirmed.sql
?? db/checks/128_update_or_insert_runtime_entity_audit_bk_fixtures_confirmed.sql
?? db/checks/129_update_or_insert_sport_completion_audit_bk_fixtures_core_done.sql
?? db/checks/130_update_or_insert_sport_completion_audit_bk_teams_core_done.sql
?? db/checks/131_update_or_insert_runtime_entity_audit_bk_leagues_confirmed.sql
?? db/checks/132_update_runtime_entity_audit_bk_fixtures_batch_ok.sql
?? db/checks/135_update_or_insert_runtime_entity_audit_vb_fixtures_confirmed.sq.sql
?? db/checks/136_update_or_insert_runtime_entity_audit_vb_teams_confirmed.sql
?? db/checks/137_update_or_insert_runtime_entity_audit_vb_leagues_confirmed.sql
?? db/checks/138_update_or_insert_sport_completion_audit_vb_fixtures_core_done.s
?? db/checks/139_update_or_insert_sport_completion_audit_vb_teams_core_done.sql
?? db/checks/576_inspect_fb_entity_audit.sql
?? db/checks/577_fb_execution_flow_snapshot.sql
?? db/checks/578_fb_runtime_job_flow.sql
?? db/checks/580_fb_provider_reality.sql
?? db/checks/581_fb_entity_audit_table.sql
?? db/checks/582_fb_entity_audit_seed_core.sql
?? db/checks/583_fb_entity_audit_seed_extended.sql
?? db/checks/584_hk_audit_start.sql
?? db/checks/585_bk_audit_start.sql
?? db/checks/586_vb_audit_start.sql
?? db/checks/589_create_ops_provider_people_audit.sql
?? "db/checks/590_inspect_people_provider_candidates.sql (FINAL FOR YOUR DB).sql"
?? db/checks/592_seed_missing_people_audit_rows.sql
?? db/checks/593_coaches_reality_matrix.sql
?? db/checks/594_seed_coaches_runtime_checklist.sql
?? db/checks/595_apply_coaches_runtime_result_template.sql
?? db/checks/596_create_ops_sport_completion_audit.sql
?? db/checks/597_seed_sport_completion_audit.sql
?? db/checks/598_create_v_sport_completion_summary.sql
?? db/checks/599_fb_completion_tasks.sql
?? db/checks/600_fb_coaches_mapping_gap_check.sql
?? db/checks/601_fb_coaches_mapping_data_gap.sql
?? db/checks/602_fb_coaches_ingest_gap_check.sql
?? db/checks/603_fix_fb_coaches_completion_note.sql
?? db/checks/604A_fb_coaches_jobs_structure.sql
?? db/checks/604B_fb_coaches_job_binding_check.sql
?? db/checks/604_fb_coaches_worker_path_check.sql
?? db/checks/605_fb_coaches_ingest_binding_note.sql
?? db/checks/606_find_fb_coaches_worker_binding.ps1
?? db/checks/606_find_fb_coaches_worker_binding_output.txt
?? db/checks/607_cleanup_bad_fb_coaches_stage_rows.sql
?? db/checks/608_fb_coaches_team_mapping_check.sql
?? db/checks/609_fb_missing_team_provider_map_check.sql
?? db/checks/610_insert_missing_fb_coaches_team_provider_map.sql
?? db/checks/611_fb_coaches_to_public.sql
?? db/checks/612_fb_team_coach_history.sql
?? db/checks/613_update_fb_coaches_completion_after_runtime.sql
?? db/checks/614_fb_players_runtime_gap_check.sql
?? db/checks/615_hk_teams_after_pull_check_v3.sql
?? db/checks/704_upsert_runtime_entity_audit_afb_teams.sql
?? db/checks/707_upsert_runtime_entity_audit_afb_fixtures.sql
?? db/checks/708_upsert_runtime_entity_audit_afb_leagues.sql
?? db/checks/709_upsert_sport_completion_audit_afb_fix2.sql
?? db/checks/710_ops_key_tables_columns_overview.sql
?? db/migrations/109_create_ops_runtime_entity_audit.sql
?? db/ops/703_build_fb_players_pro_priority_buckets.sql
?? db/ops/704_select_fb_players_wave_0.sql
?? db/ops/705_select_fb_players_wave_1.sql
?? db/scripts/.112_runtime_audit_export_V2.ps1.txt
?? db/scripts/112_runtime_audit_export_V2.ps1
?? db/scripts/614_worker_file_scan.ps1
?? db/scripts/614_worker_file_scan_v2.ps1
?? db/scripts/701_missing_team_provider_map_analysis.sql
?? db/scripts/702_missing_team_provider_map_detail.sql
?? db/scripts/703_missing_team_provider_map_team_ids.sql
?? db/scripts/704_missing_team_identity_lookup.sql
?? db/scripts/705_verify_existing_api_football_team_map.sql
?? db/scripts/706_audit_api_football_name_collisions.sql
?? db/scripts/707_global_team_identity_audit_all_sports.sql
?? db/scripts/707_split_same_vs_cross_sport_collisions.sql
?? db/scripts/708_split_same_vs_cross_sport_collisions.sql
?? db/scripts/709_same_sport_merge_plan.sql
?? db/scripts/710_audit_api_football_reset_scope.sql
?? db/scripts/710_fix_league_standings_before_merge.sql
?? db/scripts/711_audit_fk_references_to_public_matches.sql
?? db/scripts/711_safe_merge_same_sport_batch.sql
?? db/scripts/711_verify_post_merge_fk_cleanup.sql
?? db/scripts/712_audit_dependent_tables_for_api_football_matches.sql
?? db/scripts/712_audit_fk_references_to_public_teams.sql
?? db/scripts/713_merge_team_full_fk_update.sql
?? db/scripts/714_next_same_sport_merge_candidates.sql
?? db/scripts/714_next_same_sport_merge_candidates_from_audit.sql
?? db/scripts/714_safe_reset_api_football_with_match_features.sql
?? db/scripts/715_verify_api_football_reset.sql
?? db/scripts/717_verify_api_football_staging_after_rebuild.sql
?? db/scripts/718_verify_api_football_league_duplicates.sql
?? db/scripts/719_verify_api_football_league_identity_conflicts.sql
?? db/scripts/720_verify_api_football_leagues_by_run.sql
?? "db/scripts/spou\305\241t\304\233n\303\255 ulo\305\276en\303\255 report\305\257.txt"
?? db/sql/133_bk_full_pipeline.sql
?? db/sql/134_vb_full_pipeline.sql
?? db/sql/135_afb_full_pipeline.sql
?? db/sql/136_bsb_teams_provider_map.sql
?? db/sql/136_update_runtime_entity_audit_bsb_teams.sql
?? db/sql/700_bk_team_provider_map.sql
?? db/sql/701_afb_readiness_audit.sql
?? db/sql/701_bk_team_provider_map_fix.sql
?? db/sql/702_bk_team_provider_map_manual_fix.sql
?? db/sql/702_create_stg_api_american_football_teams.sql
?? db/sql/703_bk_fixtures_merge.sql
?? db/sql/703_merge_api_american_football_teams_to_public.sql
?? db/sql/704_bk_league_mapping.sql
?? db/sql/704_update_runtime_entity_audit_afb_teams.sql
?? db/sql/705_create_stg_api_american_football_fixtures.sql
?? db/sql/706_merge_api_american_football_fixtures_to_public_matches.sql
?? db/views/109_create_v_runtime_entity_audit_summary.sql
?? db/views/111_view_z_runtime_entity_audit_summary.sql
?? "docs/komunikace s chatGPT/03_2026/20260329/467_audit_1.txt"
?? "docs/komunikace s chatGPT/04_2026/20260406/Z\303\201PIS NA DNE\305\240EK \342\200\223 P\305\230\303\215PRAVA NA Z\303\215T\305\230E.md"
?? "docs/komunikace s chatGPT/04_2026/20260407/"
?? "docs/komunikace s chatGPT/04_2026/20260408/"
?? "docs/komunikace s chatGPT/04_2026/20260409/"
?? "docs/komunikace s chatGPT/04_2026/20260410/"
?? "docs/komunikace s chatGPT/04_2026/20260412/"
?? "docs/komunikace s chatGPT/04_2026/20260415/"
?? ingest/API-American-Football/
?? ingest/API-Basketball/
?? ingest/API-Sport/parse_api_baseball_teams_to_staging.py
?? ingest/providers/generic_api_sport_provider_V1.py
?? ingest/providers/generic_api_sport_provider_V2.py
?? logs/api_football_backfill_status_2026-04-11_100113.txt
?? logs/api_football_backfill_status_2026-04-12_213847.txt
?? logs/api_football_backfill_status_2026-04-13_162113.txt
?? logs/api_football_backfill_status_2026-04-15_202032.txt
?? reports/audit/2026-04-07/
?? reports/audit/2026-04-08/
?? reports/audit/2026-04-09/
?? reports/audit/2026-04-10/
?? reports/audit/2026-04-11/
?? reports/audit/2026-04-12/
?? reports/audit/2026-04-13/
?? reports/audit/system_tree_2026-04-11_095512.txt
?? reports/audit/system_tree_2026-04-12_214012.txt
?? reports/audit/system_tree_2026-04-12_233321.txt
?? reports/audit/system_tree_2026-04-15_202105.txt
?? "reports/p\305\231ehled_sloupc\305\257_tabulek_OPS/"
?? "reports/p\305\231ehled_sloupc\305\257_tabulek_staging/"
?? reports/reports_runner/112_runtime_audit_export.txt
?? unmatched_theodds_195.csv
?? unmatched_theodds_195.sql
?? workers/run_api_football_coaches_ingest_v1.py
?? workers/run_fb_players_wave1_pro.ps1
?? workers/run_players_pipeline_merge_only_v1.ps1
```

## Databáze
- Připojení: OK
- Core counts:
  - leagues: 2988
  - matches: 31675
  - players: 2429
  - teams: 5450
- OPS counts:
  - ingest_planner: 3084
  - job_runs: 517
  - provider_jobs: 140
  - scheduler_queue: 6
- Player pipeline:
  - player_match_statistics: 0
  - players_import: 2506
  - public_players: 2429
  - stg_provider_players: 2410
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