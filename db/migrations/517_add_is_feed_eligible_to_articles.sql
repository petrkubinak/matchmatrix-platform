ALTER TABLE public.articles
ADD COLUMN IF NOT EXISTS is_feed_eligible boolean DEFAULT true;