-- ==========================================
-- Název: 000_create_schema_migrations.sql
-- Umístění: C:\MATCHMATRIX-PLATFORM\db\migrations\
-- Účel: evidence aplikovaných migrací
-- Spuštění: docker exec -i matchmatrix_postgres psql ...
-- ==========================================

CREATE TABLE IF NOT EXISTS ops.schema_migrations (
  id bigserial PRIMARY KEY,
  filename text NOT NULL UNIQUE,
  applied_at timestamptz NOT NULL DEFAULT now()
);