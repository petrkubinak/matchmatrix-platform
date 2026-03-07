-- =====================================================
-- MatchMatrix
-- Seed file: content_sources
-- Purpose: definice zdrojů obsahu / providerů
-- =====================================================

INSERT INTO public.content_sources (source_code, source_name, is_active)
VALUES
('manual', 'Manual Entry', true),
('api_football', 'API-Football', true),
('transfermarkt', 'Transfermarkt', true),
('internal', 'Internal System', true)
ON CONFLICT (source_code) DO NOTHING;