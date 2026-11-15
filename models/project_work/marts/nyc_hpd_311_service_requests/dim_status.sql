--status info for nyc hpd 311 service request

WITH stg_311 AS (
    SELECT * FROM {{ ref('stg_nyc_hpd_311_service_requests') }}
),

distinct_status AS (

    SELECT DISTINCT
    status, service_request_id
    FROM stg_311
    WHERE service_request_id IS NOT NULL

),

enriched AS (

    SELECT
        status, 
        service_request_id,
        
        CASE
            WHEN status LIKE '%CLOSED%' THEN 'TRUE'
        END AS is_closed

    FROM distinct_status

),

dim_status AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'status', 'service_request_id','is_closed'
        ]) }} AS status_key,

        status, is_closed, service_request_id

    FROM enriched

)

SELECT * FROM dim_status