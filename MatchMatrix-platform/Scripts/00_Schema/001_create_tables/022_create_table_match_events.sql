INSERT INTO public.languages (language_code, language_name, native_name, is_active, is_default)
VALUES
('en', 'English', 'English', true, true),
('cs', 'Czech', 'Čeština', true, false),
('de', 'German', 'Deutsch', true, false),
('es', 'Spanish', 'Español', true, false),
('fr', 'French', 'Français', true, false),
('it', 'Italian', 'Italiano', true, false),
('pl', 'Polish', 'Polski', true, false),
('pt', 'Portuguese', 'Português', true, false),
('tr', 'Turkish', 'Türkçe', true, false)
ON CONFLICT DO NOTHING;