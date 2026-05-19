# merge_media_articles_to_public_v1.py
# MATCHMATRIX MEDIA MERGE V3
#
# Canonical merge:
# staging.stg_media_articles
# ->
# public.articles
#
# QUALITY FILTER:
# pouze clean články
#
# staging = RAW + dirty + rejected
# public  = canonical clean media layer

import re
from urllib.parse import urlparse

import psycopg


DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)


def make_slug(title: str | None, url: str) -> str:
    """
    Vytvoří jednoduchý slug.
    Pokud title není dostupný, použije poslední část URL.
    """

    base = title or url.rstrip("/").split("/")[-1] or "article"

    base = base.lower()
    base = re.sub(r"[^a-z0-9]+", "-", base)
    base = base.strip("-")

    if not base:
        parsed = urlparse(url)
        base = parsed.netloc.replace(".", "-")

    return base[:250]


def load_pending_articles(conn):

    sql = """
    SELECT
        id,
        provider,
        source_name,
        source_type,
        title,
        url,
        summary,
        raw_html,
        raw_text,
        author_name,
        published_at,
        language_code,
        payload_hash,
        thumbnail_url,
        video_url,
        duration_seconds,
        is_video,
        article_quality_score,
        article_quality_reason,
        is_filtered,
        filter_reason
    FROM staging.stg_media_articles
    WHERE
        parse_status IN ('pending', 'parsed')
        AND COALESCE(is_filtered, false) = false
    ORDER BY id
    """

    return conn.execute(sql).fetchall()


def resolve_content_source_id(conn, source_name: str, source_type: str):

    sql = """
    SELECT id
    FROM public.content_sources
    WHERE name = %s
      AND source_type = %s
    ORDER BY id
    LIMIT 1
    """

    row = conn.execute(sql, (source_name, source_type)).fetchone()

    if row:
        return row[0]

    return None


def insert_public_article(conn, row):

    staging_id = row[0]
    source_name = row[2]
    source_type = row[3]

    title = row[4]
    url = row[5]
    summary = row[6]
    raw_html = row[7]
    raw_text = row[8]
    author_name = row[9]
    published_at = row[10]
    language_code = row[11]

    thumbnail_url = row[13]
    video_url = row[14]
    duration_seconds = row[15]
    is_video = row[16]

    article_quality_score = row[17]
    article_quality_reason = row[18]

    content_source_id = resolve_content_source_id(
        conn,
        source_name=source_name,
        source_type=source_type,
    )

    if content_source_id is None:
        return "missing_source"

    slug = make_slug(title, url)

    content_type = "video" if is_video else "article"

    sql = """
    INSERT INTO public.articles
    (
        content_source_id,
        title,
        slug,
        summary,
        url,
        author_name,
        published_at,
        language_code,
        content_type,
        raw_html_path,
        raw_text,
        ai_summary,
        thumbnail_url,
        video_url,
        duration_seconds,
        is_video,
        article_quality_score,
        article_quality_reason,
        created_at,
        updated_at
    )
    VALUES
    (
        %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s,
        %s, %s, %s,
        now(),
        now()
    )
    ON CONFLICT (content_source_id, url)
    DO UPDATE SET
        title = COALESCE(EXCLUDED.title, public.articles.title),
        slug = COALESCE(EXCLUDED.slug, public.articles.slug),
        summary = COALESCE(EXCLUDED.summary, public.articles.summary),
        author_name = COALESCE(EXCLUDED.author_name, public.articles.author_name),
        published_at = COALESCE(EXCLUDED.published_at, public.articles.published_at),
        language_code = COALESCE(EXCLUDED.language_code, public.articles.language_code),
        raw_text = COALESCE(EXCLUDED.raw_text, public.articles.raw_text),
        thumbnail_url = COALESCE(EXCLUDED.thumbnail_url, public.articles.thumbnail_url),
        video_url = COALESCE(EXCLUDED.video_url, public.articles.video_url),
        duration_seconds = COALESCE(EXCLUDED.duration_seconds, public.articles.duration_seconds),
        is_video = COALESCE(EXCLUDED.is_video, public.articles.is_video),
        article_quality_score = COALESCE(
            EXCLUDED.article_quality_score,
            public.articles.article_quality_score
        ),
        article_quality_reason = COALESCE(
            EXCLUDED.article_quality_reason,
            public.articles.article_quality_reason
        ),
        updated_at = now()
    """

    result = conn.execute(
        sql,
        (
            content_source_id,
            title,
            slug,
            summary,
            url,
            author_name,
            published_at,
            language_code,
            content_type,
            None,
            raw_text,
            None,
            thumbnail_url,
            video_url,
            duration_seconds,
            is_video,
            article_quality_score,
            article_quality_reason,
        ),
    )

    if result.rowcount == 1:
        return "upserted"

    return "skipped"


def mark_as_merged(conn, staging_id):

    sql = """
    UPDATE staging.stg_media_articles
    SET
        parse_status = 'merged',
        updated_at = now()
    WHERE id = %s
    """

    conn.execute(sql, (staging_id,))


def mark_as_error(conn, staging_id, error_text: str):

    sql = """
    UPDATE staging.stg_media_articles
    SET
        parse_status = 'error',
        error_message = %s,
        updated_at = now()
    WHERE id = %s
    """

    conn.execute(sql, (error_text[:1000], staging_id))


def main():

    conn = psycopg.connect(DB_DSN)
    conn.autocommit = True

    rows = load_pending_articles(conn)

    print("=" * 80)
    print("MATCHMATRIX MEDIA MERGE V3")
    print("=" * 80)
    print("TARGET: public.articles")
    print("QUALITY FILTER: ENABLED")
    print(f"PENDING CLEAN ROWS: {len(rows)}")
    print("=" * 80)

    merged = 0
    upserted = 0
    missing_source = 0
    errors = 0

    for row in rows:

        staging_id = row[0]
        provider = row[1]
        source_name = row[2]
        source_type = row[3]
        url = row[5]

        article_quality_score = row[17]

        try:

            result = insert_public_article(conn, row)

            if result == "upserted":

                upserted += 1

                mark_as_merged(conn, staging_id)

                merged += 1

                print(
                    f"UPSERTED: {source_name} | "
                    f"quality={article_quality_score} | "
                    f"{url}"
                )

            elif result == "missing_source":

                missing_source += 1

                mark_as_error(
                    conn,
                    staging_id,
                    f"Missing content_source for "
                    f"source_name={source_name}, "
                    f"source_type={source_type}",
                )

                errors += 1

                print(
                    f"MISSING SOURCE: "
                    f"{source_name} | "
                    f"{source_type} | "
                    f"{url}"
                )

            else:

                mark_as_merged(conn, staging_id)

                merged += 1

                print(
                    f"SKIPPED: {provider} | {url}"
                )

        except Exception as e:

            errors += 1

            error_text = str(e)

            mark_as_error(conn, staging_id, error_text)

            print(f"ERROR: {provider} | {url}")
            print(error_text)

    print("\n" + "=" * 80)
    print("DONE")
    print("=" * 80)
    print(f"MERGED        : {merged}")
    print(f"UPSERTED      : {upserted}")
    print(f"MISSING SOURCE: {missing_source}")
    print(f"ERRORS        : {errors}")
    print("=" * 80)

    conn.close()


if __name__ == "__main__":
    main()