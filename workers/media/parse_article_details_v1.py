# ============================================================
# parse_article_details_v1.py
# MATCHMATRIX ARTICLE DETAIL PARSER V2 + QUALITY FILTER V1
# ============================================================

from __future__ import annotations

import re

import psycopg
import requests
from bs4 import BeautifulSoup

# =========================================================
# MEDIA QUALITY FILTER V1
# =========================================================

LOW_QUALITY_PATTERNS = [
    "newsletter",
    "fantasy",
    "pressroom",
    "/tag/",
    "/tags/",
    "/category/",
    "/categories/",
    "/topics/",
    "/topic/",
    "/hub/",
    "/login",
    "/sign-up",
    "/signup",
    "/register",
    "/shop",
    "/documents/",
    "/publications/",
    "/mediaservices/",
    "/news-media/",
]

HIGH_QUALITY_HINTS = [
    "/news/",
    "/article/",
    "/articles/",
    "/stories/",
    "/story/",
    "/match/",
    "/player/",
]

DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)

HEADERS = {
    "User-Agent": "MatchMatrixBot/1.0"
}


def clean_text(text: str | None) -> str | None:
    if not text:
        return None
    text = re.sub(r"\s+", " ", text).strip()
    return text or None


def extract_title(soup: BeautifulSoup) -> str | None:
    og = soup.find("meta", property="og:title")
    if og and og.get("content"):
        return clean_text(og["content"])

    if soup.title:
        return clean_text(soup.title.text)

    h1 = soup.find("h1")
    if h1:
        return clean_text(h1.get_text())

    return None


def extract_summary(soup: BeautifulSoup) -> str | None:
    meta = soup.find("meta", attrs={"name": "description"})
    if meta and meta.get("content"):
        return clean_text(meta["content"])

    og = soup.find("meta", property="og:description")
    if og and og.get("content"):
        return clean_text(og["content"])

    return None


def extract_author(soup: BeautifulSoup) -> str | None:
    meta = soup.find("meta", attrs={"name": "author"})
    if meta and meta.get("content"):
        return clean_text(meta["content"])

    return None


def extract_thumbnail_url(soup: BeautifulSoup) -> str | None:
    patterns = [
        ("meta", {"property": "og:image"}),
        ("meta", {"name": "og:image"}),
        ("meta", {"property": "twitter:image"}),
        ("meta", {"name": "twitter:image"}),
    ]

    for tag_name, attrs in patterns:
        tag = soup.find(tag_name, attrs=attrs)
        if tag and tag.get("content"):
            return clean_text(tag["content"])

    return None


def extract_raw_text(soup: BeautifulSoup) -> str | None:
    paragraphs = soup.find_all("p")
    parts = []

    for p in paragraphs:
        text = clean_text(p.get_text())
        if not text:
            continue
        if len(text) < 30:
            continue
        parts.append(text)

    if not parts:
        return None

    return "\n\n".join(parts)[:200000]


def detect_video(title: str | None, url: str | None) -> bool:
    haystack = f"{title or ''} {url or ''}".lower()

    video_patterns = [
        "highlight",
        "highlights",
        "playback",
        "top plays",
        "prime video",
        "live-updates",
        "video:",
        "recap:",
    ]

    return any(pattern in haystack for pattern in video_patterns)


def evaluate_article_quality(
    title: str | None,
    url: str | None,
    raw_text: str | None,
) -> tuple[int, str, bool, str | None]:
    quality_score = 100
    quality_reason = []
    is_filtered = False
    filter_reason = None

    url_lower = (url or "").lower()
    title_lower = (title or "").lower()
    raw_text_clean = raw_text or ""

    for pattern in LOW_QUALITY_PATTERNS:
        if pattern in url_lower or pattern in title_lower:
            quality_score -= 40
            quality_reason.append(f"low_quality_pattern:{pattern}")

    for pattern in HIGH_QUALITY_HINTS:
        if pattern in url_lower:
            quality_score += 10
            quality_reason.append(f"high_quality_hint:{pattern}")

    if not title:
        quality_score -= 30
        quality_reason.append("missing_title")

    if not raw_text_clean or len(raw_text_clean) < 250:
        quality_score -= 30
        quality_reason.append("short_or_missing_text")

    quality_score = max(0, min(100, quality_score))

    if quality_score < 50:
        is_filtered = True
        filter_reason = "low_quality_content"

    quality_reason_text = " | ".join(quality_reason) if quality_reason else "quality_ok"

    return quality_score, quality_reason_text, is_filtered, filter_reason


def load_pending_articles(conn):
    sql = """
    SELECT
        id,
        provider,
        source_name,
        url
    FROM staging.stg_media_articles
    WHERE parse_status = 'pending'
    ORDER BY
        CASE
            WHEN source_name IN (
                'Premier League',
                'LaLiga',
                'Bundesliga',
                'Serie A',
                'Ligue 1',
                'UEFA',
                'FIFA'
            ) THEN 0
            ELSE 1
        END,
        id
    LIMIT 50
    """
    return conn.execute(sql).fetchall()


def update_staging_article(
    conn,
    staging_id,
    title,
    summary,
    raw_text,
    raw_html,
    author_name,
    content_type,
    thumbnail_url,
    is_video,
    article_quality_score,
    article_quality_reason,
    is_filtered,
    filter_reason,
):
    sql = """
    UPDATE staging.stg_media_articles
    SET
        title = COALESCE(%s, title),
        summary = COALESCE(%s, summary),
        raw_text = COALESCE(%s, raw_text),
        raw_html = COALESCE(%s, raw_html),
        author_name = COALESCE(%s, author_name),
        content_type = COALESCE(%s, content_type),
        thumbnail_url = COALESCE(%s, thumbnail_url),
        is_video = %s,
        article_quality_score = %s,
        article_quality_reason = %s,
        is_filtered = %s,
        filter_reason = %s,
        parse_status = 'parsed',
        parse_message = 'detail parsed',
        updated_at = now()
    WHERE id = %s
    """

    conn.execute(
        sql,
        (
            title,
            summary,
            raw_text,
            raw_html,
            author_name,
            content_type,
            thumbnail_url,
            is_video,
            article_quality_score,
            article_quality_reason,
            is_filtered,
            filter_reason,
            staging_id,
        ),
    )


def update_public_article_by_url(
    conn,
    url,
    thumbnail_url,
    is_video,
):
    content_type = "video" if is_video else "article"

    sql = """
    UPDATE public.articles
    SET
        thumbnail_url = COALESCE(%s, thumbnail_url),
        is_video = %s,
        content_type = %s,
        updated_at = now()
    WHERE url = %s
    """

    conn.execute(
        sql,
        (
            thumbnail_url,
            is_video,
            content_type,
            url,
        ),
    )


def mark_error(conn, staging_id, error_text):
    sql = """
    UPDATE staging.stg_media_articles
    SET
        parse_status = 'error',
        parse_message = %s,
        updated_at = now()
    WHERE id = %s
    """

    conn.execute(
        sql,
        (
            error_text[:1000],
            staging_id,
        ),
    )


def main():
    conn = psycopg.connect(DB_DSN)
    conn.autocommit = True

    rows = load_pending_articles(conn)

    print("=" * 80)
    print("MATCHMATRIX ARTICLE DETAIL PARSER V2 + QUALITY FILTER V1")
    print("=" * 80)
    print(f"PENDING: {len(rows)}")
    print("=" * 80)

    parsed = 0
    errors = 0
    thumbnails = 0
    videos = 0
    filtered = 0

    for row in rows:
        staging_id = row[0]
        source_name = row[2]
        url = row[3]

        print(f"\nURL: {url}")

        try:
            response = requests.get(
                url,
                headers=HEADERS,
                timeout=30,
                allow_redirects=True,
            )

            response.raise_for_status()

            raw_html = response.text[:500000]
            soup = BeautifulSoup(response.text, "html.parser")

            title = extract_title(soup)
            summary = extract_summary(soup)
            author_name = extract_author(soup)
            raw_text = extract_raw_text(soup)
            thumbnail_url = extract_thumbnail_url(soup)

            is_video = detect_video(title, url)
            content_type = "video" if is_video else "article"

            (
                article_quality_score,
                article_quality_reason,
                is_filtered,
                filter_reason,
            ) = evaluate_article_quality(
                title=title,
                url=url,
                raw_text=raw_text,
            )

            update_staging_article(
                conn=conn,
                staging_id=staging_id,
                title=title,
                summary=summary,
                raw_text=raw_text,
                raw_html=raw_html,
                author_name=author_name,
                content_type=content_type,
                thumbnail_url=thumbnail_url,
                is_video=is_video,
                article_quality_score=article_quality_score,
                article_quality_reason=article_quality_reason,
                is_filtered=is_filtered,
                filter_reason=filter_reason,
            )

            update_public_article_by_url(
                conn=conn,
                url=url,
                thumbnail_url=thumbnail_url,
                is_video=is_video,
            )

            parsed += 1

            if thumbnail_url:
                thumbnails += 1

            if is_video:
                videos += 1

            if is_filtered:
                filtered += 1

            print(
                f"PARSED: {source_name} | "
                f"video={is_video} | "
                f"thumbnail={bool(thumbnail_url)} | "
                f"quality={article_quality_score} | "
                f"filtered={is_filtered}"
            )

        except Exception as e:
            errors += 1
            mark_error(conn, staging_id, str(e))
            print(f"ERROR: {e}")

    print("\n" + "=" * 80)
    print("DONE")
    print("=" * 80)
    print(f"PARSED: {parsed}")
    print(f"ERRORS: {errors}")
    print(f"THUMBNAILS: {thumbnails}")
    print(f"VIDEOS: {videos}")
    print(f"FILTERED: {filtered}")
    print("=" * 80)

    conn.close()


if __name__ == "__main__":
    main()