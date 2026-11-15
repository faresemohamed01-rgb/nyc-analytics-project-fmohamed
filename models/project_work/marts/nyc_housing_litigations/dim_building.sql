WITH stg_litigation AS (

    SELECT *
    FROM {{ ref('stg_nyc_housing_litigations') }}

),

distinct_buildings AS (

    SELECT DISTINCT
    building_id, streetname, zip
    FROM stg_311
    WHERE building_id IS NOT NULL

),

enriched AS (

    SELECT
        building_id, 
        zip

        -- Derived category, based on keywords appearing in descriptor
        -- Order matters due to CASE WHEN structure (worth considering)
        -- Match is case insensitive

        CASE
            WHEN LOWER(descriptor) LIKE '%sidewalk%' THEN 'sidewalk'
            WHEN LOWER(descriptor) LIKE '%street%'   THEN 'street'
            WHEN LOWER(descriptor) LIKE '%bike%'     THEN 'bike'
            WHEN LOWER(descriptor) LIKE '%highway%'  THEN 'highway'
            ELSE 'other'
        END AS complaint_category

    FROM distinct_complaint_types

),

dim_complaint_type AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'building_id', 'streetname', 'zip'
        ]) }} AS buidling_key,

        complaint_type,
        descriptor,
        complaint_category

    FROM enriched

)

SELECT * FROM dim_complaint_type