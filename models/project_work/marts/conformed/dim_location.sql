WITH stg_311 AS (

    SELECT *
    FROM {{ ref('stg_nyc_hpd_311_service_requests') }}

),

stg_litigation AS (

    SELECT *
    FROM {{ ref('stg_nyc_housing_litigations') }}

),

all_locations AS (

    SELECT DISTINCT
        borough, council_district, zipcode
    FROM stg_311
    WHERE borough IS NOT NULL
       OR council_district IS NOT NULL
       OR zipcode IS NOT NULL

    UNION DISTINCT

    SELECT DISTINCT
        borough, council_district, zipcode
    FROM stg_dob
    WHERE borough IS NOT NULL
       OR council_district IS NOT NULL
       OR zipcode IS NOT NULL

),

location_dimension AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'borough', 'council_district', 'zipcode'
        ]) }} AS location_key,

        borough,
        council_district,
        zipcode

    FROM all_locations

),

-- Null placeholder row to handle NULL values.

null_placeholder AS (

    SELECT
        '-1' AS location_key,
        CAST(NULL AS STRING) AS borough,
        CAST(NULL AS STRING) AS council_district,
        CAST(NULL AS STRING) AS zipcode

)

SELECT * FROM location_dimension
UNION ALL
SELECT * FROM null_placeholder
)