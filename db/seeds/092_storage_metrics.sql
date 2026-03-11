CREATE TABLE storage_metrics
(
    id BIGSERIAL PRIMARY KEY,
    metric_day DATE DEFAULT CURRENT_DATE,

    postgres_size_gb NUMERIC,
    raw_storage_gb NUMERIC,
    content_storage_gb NUMERIC,

    created_at TIMESTAMP DEFAULT now()
);