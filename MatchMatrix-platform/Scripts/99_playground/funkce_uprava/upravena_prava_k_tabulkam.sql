GRANT SELECT, INSERT, UPDATE, DELETE ON mm_match_ratings TO mm_ingest;
GRANT SELECT, INSERT, UPDATE, DELETE ON mm_team_ratings TO mm_ingest;

-- pokud chceš, aby šel i TRUNCATE:
GRANT TRUNCATE ON mm_match_ratings TO mm_ingest;
GRANT TRUNCATE ON mm_team_ratings TO mm_ingest;
