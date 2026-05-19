ALTER TABLE public.articles
ADD COLUMN IF NOT EXISTS is_breaking_news boolean DEFAULT false;

ALTER TABLE public.articles
ADD COLUMN IF NOT EXISTS breaking_score numeric DEFAULT 0;

ALTER TABLE public.articles
ADD COLUMN IF NOT EXISTS hot_score numeric DEFAULT 0;

ALTER TABLE public.articles
ADD COLUMN IF NOT EXISTS velocity_score numeric DEFAULT 0;