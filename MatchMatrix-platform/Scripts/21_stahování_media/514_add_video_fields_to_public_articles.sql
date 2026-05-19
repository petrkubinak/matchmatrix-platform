ALTER TABLE public.articles
ADD COLUMN IF NOT EXISTS video_url text;

ALTER TABLE public.articles
ADD COLUMN IF NOT EXISTS thumbnail_url text;

ALTER TABLE public.articles
ADD COLUMN IF NOT EXISTS duration_seconds integer;

ALTER TABLE public.articles
ADD COLUMN IF NOT EXISTS is_video boolean DEFAULT false;