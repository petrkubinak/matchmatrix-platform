SELECT
    ext_source,
    COUNT(*) AS cnt
FROM public.matches
GROUP BY ext_source
ORDER BY cnt DESC, ext_source;