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
        boro_name, council_district, incident_zip
    FROM stg_311
    WHERE boro_name IS NOT NULL
       OR council_district IS NOT NULL
       OR incident_zip IS NOT NULL

    UNION DISTINCT

    SELECT DISTINCT
        boro_name, council_district, incident_zip
    FROM stg_litigation
    WHERE boro_name IS NOT NULL
       OR council_district IS NOT NULL
       OR incident_zip IS NOT NULL

),

location_dimension AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'boro_name', 'council_district', 'incident_zip'
        ]) }} AS location_key,

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
        CAST(NULL AS STRING) AS boro_name,
        CAST(NULL AS STRING) AS council_district,
        CAST(NULL AS STRING) AS incident_zip, 
        CAST(NULL AS STRING) AS incident_address,
        CAST(NULL AS STRING) AS bbl,
        CAST(NULL AS STRING) AS community_board, 
        CAST(NULL AS FLOAT) AS latitude, 
        CAST(NULL AS STRING) AS longitude, 

)

SELECT * FROM location_dimension
UNION ALL
SELECT * FROM null_placeholder
