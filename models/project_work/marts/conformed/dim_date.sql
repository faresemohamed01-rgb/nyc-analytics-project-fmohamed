
-- Date dimension shared by NYC HPD 311 Service Requests
-- and NYC Housing Litigations

WITH stg_311 AS (

    SELECT *
    FROM {{ ref('stg_nyc_hpd_311_service_requests') }}

),

stg_litigation AS (

    SELECT *
    FROM {{ ref('stg_nyc_housing_litigations') }}

),

-- Collect dates from both staging models

all_dates AS (

    -- HPD 311: Request Created Date
    SELECT DISTINCT
        CAST(created_date AS DATE) AS full_date
    FROM stg_311
    WHERE created_date IS NOT NULL

    UNION DISTINCT

    -- HPD 311: Request Closed Date
    SELECT DISTINCT
        CAST(closed_date AS DATE) AS full_date
    FROM stg_311
    WHERE closed_date IS NOT NULL

    UNION DISTINCT

    -- Housing Litigation: Case Open Date
    -- Renamed to created_date in staging
    SELECT DISTINCT
        CAST(created_date AS DATE) AS full_date
    FROM stg_litigation
    WHERE created_date IS NOT NULL

    UNION DISTINCT

    -- Housing Litigation: Harassment Finding Date
    SELECT DISTINCT
        CAST(harassment_finding_date AS DATE) AS full_date
    FROM stg_litigation
    WHERE harassment_finding_date IS NOT NULL

),
-- Generate date attributes

date_dimension AS (

    SELECT

        CAST(
            FORMAT_DATE('%Y%m%d', full_date)
            AS INT64
        ) AS date_key,

        full_date,

        EXTRACT(YEAR FROM full_date) AS year,

        EXTRACT(QUARTER FROM full_date) AS quarter,

        EXTRACT(MONTH FROM full_date) AS month_number,

        FORMAT_DATE('%B', full_date) AS month_name,

        EXTRACT(DAY FROM full_date) AS day_of_month,

        EXTRACT(DAYOFWEEK FROM full_date)
            AS day_of_week_number,

        FORMAT_DATE('%A', full_date)
            AS day_of_week_name,

        EXTRACT(WEEK FROM full_date) AS week_of_year,

        EXTRACT(DAYOFWEEK FROM full_date)
            IN (1, 7) AS is_weekend

    FROM all_dates

),

-- Placeholder for missing dates

null_placeholder AS (

    SELECT
        CAST(-1 AS INT64) AS date_key,
        CAST(NULL AS DATE) AS full_date,
        CAST(NULL AS INT64) AS year,
        CAST(NULL AS INT64) AS quarter,
        CAST(NULL AS INT64) AS month_number,
        CAST(NULL AS STRING) AS month_name,
        CAST(NULL AS INT64) AS day_of_month,
        CAST(NULL AS INT64) AS day_of_week_number,
        CAST(NULL AS STRING) AS day_of_week_name,
        CAST(NULL AS INT64) AS week_of_year,
        CAST(NULL AS BOOLEAN) AS is_weekend

)

SELECT * FROM date_dimension

UNION ALL

SELECT * FROM null_placeholder
