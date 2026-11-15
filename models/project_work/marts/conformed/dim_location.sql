-- Location dimension shared by NYC HPD 311 Service Requests
-- and NYC Housing Litigations

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
        borough, council_district, zip,
        longitude
    FROM stg_311
    WHERE borough IS NOT NULL
       OR council_district IS NOT NULL
       OR zip IS NOT NULL

    UNION DISTINCT

    SELECT DISTINCT
        borough, council_district, zip, 
    FROM stg_litigation
    WHERE borough IS NOT NULL
       OR council_district IS NOT NULL
       OR zip IS NOT NULL

),

location_dimension AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'borough', 'council_district', 'zip'
        ]) }} AS location_key,

        borough, 
        council_district, 
        zip, 
        incident_address,
        bbl,
        community_board, 
        latitude, 
        longitude

    FROM all_locations

),

-- Null placeholder row to handle NULL values.

null_placeholder AS (

    SELECT
        '-1' AS location_key,
        CAST(NULL AS STRING) AS borough,
        CAST(NULL AS STRING) AS council_district,
        CAST(NULL AS STRING) AS zip, 
        CAST(NULL AS STRING) AS incident_address,
        CAST(NULL AS STRING) AS bbl,
        CAST(NULL AS STRING) AS community_board, 
        CAST(NULL AS DECIMAL) AS latitude, 
        CAST(NULL AS DECIMAL) AS longitude, 

)

SELECT * FROM location_dimension
UNION ALL
SELECT * FROM null_placeholder
