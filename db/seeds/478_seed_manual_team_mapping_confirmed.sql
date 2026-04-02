-- 478_seed_manual_team_mapping_confirmed.sql
-- potvrzené mapování z audit 477

INSERT INTO public.canonical_team_map (
    canonical_team_id,
    provider,
    provider_team_id,
    status,
    note
)
VALUES

-- England Premier League
(48, 'api_football', 11910, 'confirmed', 'Arsenal FC ↔ Arsenal'),
(50, 'api_football', 11915, 'confirmed', 'Chelsea FC ↔ Chelsea'),
(53, 'api_football', 11908, 'confirmed', 'Liverpool FC ↔ Liverpool'),
(54, 'api_football', 11916, 'confirmed', 'Manchester City FC ↔ Manchester City'),
(56, 'api_football', 11904, 'confirmed', 'Newcastle United FC ↔ Newcastle'),
(58, 'api_football', 11913, 'confirmed', 'Tottenham Hotspur FC ↔ Tottenham'),
(66, 'api_football', 11914, 'confirmed', 'West Ham United FC ↔ West Ham'),

-- England Championship (výběr)
(32, 'api_football', 13359, 'confirmed', 'Birmingham City FC ↔ Birmingham'),
(24, 'api_football', 12194, 'confirmed', 'Blackburn Rovers FC ↔ Blackburn'),
(43, 'api_football', 12187, 'confirmed', 'Bristol City FC ↔ Bristol City'),
(60, 'api_football', 12186, 'confirmed', 'Burnley FC ↔ Burnley'),
(45, 'api_football', 12204, 'confirmed', 'Coventry City FC ↔ Coventry'),
(35, 'api_football', 12195, 'confirmed', 'Derby County FC ↔ Derby'),
(30, 'api_football', 12193, 'confirmed', 'Hull City AFC ↔ Hull City'),
(61, 'api_football', 12192, 'confirmed', 'Leeds United FC ↔ Leeds'),
(33, 'api_football', 11912, 'confirmed', 'Leicester City FC ↔ Leicester'),
(36, 'api_football', 12196, 'confirmed', 'Middlesbrough FC ↔ Middlesbrough'),
(42, 'api_football', 12188, 'confirmed', 'Millwall FC ↔ Millwall'),

-- France
(90, 'api_football', 12110, 'confirmed', 'AS Monaco FC ↔ Monaco'),
(504, 'api_football', 12103, 'confirmed', 'Lille OSC ↔ Lille'),
(505, 'api_football', 12108, 'confirmed', 'OGC Nice ↔ Nice'),
(88, 'api_football', 12105, 'confirmed', 'Olympique de Marseille ↔ Marseille'),
(506, 'api_football', 12104, 'confirmed', 'Olympique Lyonnais ↔ Lyon'),

-- Germany
(68, 'api_football', 12071, 'confirmed', 'Bayer 04 Leverkusen ↔ Leverkusen'),
(70, 'api_football', 12070, 'confirmed', 'FC Bayern München ↔ Bayern Munich'),
(526, 'api_football', 12066, 'confirmed', 'SV Werder Bremen ↔ Werder Bremen'),
(519, 'api_football', 12070, 'confirmed', 'TSG 1899 Hoffenheim ↔ Hoffenheim'),

-- Italy
(83, 'api_football', 12129, 'confirmed', 'Atalanta BC ↔ Atalanta'),
(85, 'api_football', 12127, 'confirmed', 'Juventus FC ↔ Juventus'),
(86, 'api_football', 12124, 'confirmed', 'SSC Napoli ↔ Napoli'),
(545, 'api_football', 12121, 'confirmed', 'SS Lazio ↔ Lazio'),
(553, 'api_football', 12132, 'confirmed', 'Torino FC ↔ Torino'),

-- Netherlands
(95, 'api_football', 12161, 'confirmed', 'AFC Ajax ↔ Ajax'),
(562, 'api_football', 12171, 'confirmed', 'FC Utrecht ↔ Utrecht'),

-- Portugal
(99, 'api_football', 12141, 'confirmed', 'Sport Lisboa e Benfica ↔ Benfica'),
(587, 'api_football', 12144, 'confirmed', 'Sporting Clube de Braga ↔ Braga')

ON CONFLICT (canonical_team_id, provider, provider_team_id) DO NOTHING;