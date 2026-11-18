
-- Time dimension shared by HPD 311 service requests
-- Used for created and closed time in fact_311_housing_request

-- Build initial CTE for Jinja syntax to reference staging model

WITH stg_311 AS (

    SELECT *
    FROM {{ ref('stg_nyc_hpd_311_service_requests') }}

),

-- Collect all hours from the staging data
-- Including both created and closed times

all_times AS (

    -- 311 service requests: created time
    SELECT DISTINCT
        EXTRACT(HOUR FROM created_date) AS hour
    FROM stg_311
    WHERE created_date IS NOT NULL

    UNION DISTINCT

    -- 311 service requests: closed time
    SELECT DISTINCT
        EXTRACT(HOUR FROM closed_date) AS hour
    FROM stg_311
    WHERE closed_date IS NOT NULL

),

-- Time dimension with time-of-day categories
-- Business hours defined as 9 AM to 5 PM

time_dimension AS (

    SELECT

        hour AS time_key,

        hour,

        CASE
            WHEN hour >= 5 AND hour < 12
                THEN 'Morning'
            WHEN hour >= 12 AND hour < 17
                THEN 'Afternoon'
            WHEN hour >= 17 AND hour < 21
                THEN 'Evening'
            ELSE 'Night'
        END AS time_of_day,

        CASE
            WHEN hour >= 9 AND hour < 17
                THEN TRUE
            ELSE FALSE
        END AS is_business_hours

    FROM all_times

),

-- Null placeholder row to handle NULL values
-- Fact tables should COALESCE missing time keys to -1
-- Keeps fact and dimension joins consistent

null_placeholder AS (

    SELECT

        CAST(-1 AS INT64) AS time_key,

        CAST(NULL AS INT64) AS hour,

        CAST(NULL AS STRING) AS time_of_day,

        CAST(NULL AS BOOLEAN) AS is_business_hours

)

-- Make sure BigQuery knows the column types

SELECT * FROM time_dimension

UNION ALL

SELECT * FROM null_placeholder
