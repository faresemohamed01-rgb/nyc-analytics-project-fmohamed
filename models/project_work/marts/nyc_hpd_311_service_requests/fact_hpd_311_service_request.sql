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
    c.channel_key,
    p.problem_key,
    s.status_key, 
    COALESCE(l.location_key, '-1') AS location_key,
    COALESCE(open_d.date_key, -1) AS caseopendate_key,
    COALESCE(finding_d.date_key, -1) AS findingdate_key,
    FROM dim_channel

),

SELECT * FROM fact_hpd_311_service_request

