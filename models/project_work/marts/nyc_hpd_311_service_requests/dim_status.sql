-- One row per distinct HPD 311 request status.

WITH distinct_status AS (
    SELECT DISTINCT status
    FROM {{ ref('stg_nyc_hpd_311_service_requests') }}
    WHERE status IS NOT NULL
),

enriched AS (
    SELECT
        status,
        CASE
            WHEN status = 'CLOSED' THEN TRUE
            WHEN status IN ('OPEN', 'REOPENED') THEN FALSE
            ELSE CAST(NULL AS BOOL)
        END AS is_closed
    FROM distinct_status
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['status']) }} AS status_key,
    status,
    is_closed
FROM enriched
