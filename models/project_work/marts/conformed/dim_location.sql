-- Shared location dimension.
-- Grain: one row per distinct borough, council district, and ZIP.

WITH all_locations AS (
    SELECT
        borough,
        council_district,
        zip
    FROM {{ ref('stg_nyc_hpd_311_service_requests') }}

    UNION DISTINCT

    SELECT
        borough,
        council_district,
        zip
    FROM {{ ref('stg_nyc_housing_litigations') }}
),

location_dimension AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'borough',
            'council_district',
            'zip'
        ]) }} AS location_key,
        borough,
        council_district,
        zip
    FROM all_locations
    WHERE borough IS NOT NULL
       OR council_district IS NOT NULL
       OR zip IS NOT NULL
),

null_placeholder AS (
    SELECT
        '-1' AS location_key,
        CAST(NULL AS STRING) AS borough,
        CAST(NULL AS STRING) AS council_district,
        CAST(NULL AS STRING) AS zip
)

SELECT * FROM location_dimension
UNION ALL
SELECT * FROM null_placeholder
