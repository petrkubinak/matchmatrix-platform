-- =====================================================
-- MatchMatrix
-- Global language seed
-- =====================================================

INSERT INTO public.languages
(
    language_code,
    language_name,
    native_name,
    is_active,
    is_default
)
VALUES

-- GLOBAL
('en','English','English',true,true),

-- EUROPE
('cs','Czech','Čeština',true,false),
('sk','Slovak','Slovenčina',true,false),
('de','German','Deutsch',true,false),
('fr','French','Français',true,false),
('es','Spanish','Español',true,false),
('it','Italian','Italiano',true,false),
('pl','Polish','Polski',true,false),
('pt','Portuguese','Português',true,false),
('nl','Dutch','Nederlands',true,false),
('sv','Swedish','Svenska',true,false),
('da','Danish','Dansk',true,false),
('fi','Finnish','Suomi',true,false),
('no','Norwegian','Norsk',true,false),
('hu','Hungarian','Magyar',true,false),
('ro','Romanian','Română',true,false),
('tr','Turkish','Türkçe',true,false),
('el','Greek','Ελληνικά',true,false),
('uk','Ukrainian','Українська',true,false),
('ru','Russian','Русский',true,false),

-- ASIA
('zh','Chinese','中文',true,false),
('ja','Japanese','日本語',true,false),
('ko','Korean','한국어',true,false),
('hi','Hindi','हिन्दी',true,false),
('id','Indonesian','Bahasa Indonesia',true,false),
('th','Thai','ไทย',true,false),
('vi','Vietnamese','Tiếng Việt',true,false),

-- MIDDLE EAST
('ar','Arabic','العربية',true,false),
('fa','Persian','فارسی',true,false),
('he','Hebrew','עברית',true,false),

-- AFRICA
('sw','Swahili','Kiswahili',true,false)

ON CONFLICT (language_code) DO UPDATE
SET
language_name = EXCLUDED.language_name,
native_name = EXCLUDED.native_name,
is_active = EXCLUDED.is_active,
updated_at = now();