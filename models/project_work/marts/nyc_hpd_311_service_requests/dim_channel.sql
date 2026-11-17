-- One row per distinct HPD 311 reporting channel.
WITH distinct_channels AS (
    SELECT DISTINCT
        COALESCE(
            NULLIF(UPPER(TRIM(open_data_channel_type)), ''),
            'UNKNOWN'
        ) AS channel_name
    FROM {{ ref('stg_nyc_hpd_311_service_requests') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['channel_name']) }} AS channel_key,
    channel_name
FROM distinct_channels