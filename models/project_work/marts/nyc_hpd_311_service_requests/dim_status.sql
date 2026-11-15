--status info for nyc hpd 311 service request

WITH stg_311 AS (
    SELECT * FROM {{ ref('stg_nyc_hpd_311_service_requests') }}
),

distinct_status AS (

    SELECT DISTINCT
    status
    FROM stg_311
    WHERE status IS NOT NULL

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