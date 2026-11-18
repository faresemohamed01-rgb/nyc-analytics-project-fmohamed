-- Grain: one row per unique HPD 311 service request.

WITH requests AS (
    SELECT
        *,
        COALESCE(
            NULLIF(UPPER(TRIM(open_data_channel_type)), ''),
            'UNKNOWN'
        ) AS cleaned_channel
    FROM {{ ref('stg_nyc_hpd_311_service_requests') }}
)

SELECT
    -- Request identifier and fact surrogate key
    {{ dbt_utils.generate_surrogate_key([
        'r.service_request_id'
    ]) }} AS request_fact_key,
    r.service_request_id AS unique_key,

    -- Created and closed dates
    COALESCE(created_date_dim.date_key, -1) AS created_date_key,
    COALESCE(closed_date_dim.date_key, -1) AS closed_date_key,

    -- Created and closed hours
    COALESCE(created_time_dim.time_key, -1) AS created_time_key,
    COALESCE(closed_time_dim.time_key, -1) AS closed_time_key,

    -- Other dimension keys
    location.location_key,
    problem.problem_key,
    channel.channel_key,
    request_status.status_key,

    -- Full timestamps retained for duration calculations
    r.created_date AS created_datetime,
    r.closed_date AS closed_datetime,

    -- Measures
    1 AS request_count,
    CASE
        WHEN r.closed_date >= r.created_date THEN
            CAST(
                TIMESTAMP_DIFF(r.closed_date, r.created_date, SECOND)
                AS NUMERIC
            ) / 3600
    END AS resolution_hours

FROM requests AS r

LEFT JOIN {{ ref('dim_date') }} AS created_date_dim
    ON CAST(r.created_date AS DATE) = created_date_dim.full_date

LEFT JOIN {{ ref('dim_date') }} AS closed_date_dim
    ON CAST(r.closed_date AS DATE) = closed_date_dim.full_date

LEFT JOIN {{ ref('dim_time') }} AS created_time_dim
    ON EXTRACT(HOUR FROM r.created_date) = created_time_dim.hour

LEFT JOIN {{ ref('dim_time') }} AS closed_time_dim
    ON EXTRACT(HOUR FROM r.closed_date) = closed_time_dim.hour

LEFT JOIN {{ ref('dim_location') }} AS location
    ON r.borough IS NOT DISTINCT FROM location.borough
    AND r.council_district IS NOT DISTINCT FROM location.council_district
    AND r.zip IS NOT DISTINCT FROM location.zip

LEFT JOIN {{ ref('dim_problem') }} AS problem
    ON r.complaint_type IS NOT DISTINCT FROM problem.problem_name
    AND r.descriptor IS NOT DISTINCT FROM problem.problem_detail
    AND r.descriptor_2 IS NOT DISTINCT FROM problem.additional_detail

LEFT JOIN {{ ref('dim_channel') }} AS channel
    ON r.cleaned_channel = channel.channel_name

LEFT JOIN {{ ref('dim_status') }} AS request_status
    ON r.status = request_status.status

    
