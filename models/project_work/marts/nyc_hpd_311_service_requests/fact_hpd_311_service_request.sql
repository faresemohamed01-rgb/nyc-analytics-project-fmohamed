--fact table for hpd 311 service request
--status info for nyc hpd 311 service request

WITH stg_311 AS (
    SELECT * FROM {{ ref('stg_nyc_hpd_311_service_requests') }}

),

dim_channel AS (
    SELECT channel_key FROM {{ ref('dim_channel') }}
),

dim_date AS (
    SELECT date_key FROM {{ ref('dim_date') }}
),

dim_location AS (
    SELECT location_key FROM {{ ref('dim_location') }}
),

dim_problem AS (
    SELECT problem_key FROM {{ ref('dim_problem') }}
),

dim_status AS (
    SELECT status_key FROM {{ ref('dim_status') }}
),

dim_time AS (
    SELECT time_key FROM {{ ref('dim_time') }}
),


fact_311_hpd_services AS (

    SELECT
    channel_key 
    FROM dim_channel

),

enriched AS (

    SELECT
        status, 
        
        CASE
            WHEN status LIKE '%CLOSED%' THEN 'TRUE'
            WHEN status LIKE '%OPEN%' THEN 'FALSE'
            ELSE 'other'
        END AS is_closed

    FROM distinct_status

),

dim_status AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'status', 'is_closed'
        ]) }} AS status_key,

        status, is_closed

    FROM enriched

)

SELECT * FROM dim_status

