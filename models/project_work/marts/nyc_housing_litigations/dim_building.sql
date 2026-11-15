--building_info for the litigation data

WITH stg_litigation AS (
    SELECT * FROM {{ ref('stg_nyc_housing_litigations') }}
),

distinct_building AS (

    SELECT DISTINCT
    building_id, incident_address as street_name, zip, incident_address
    FROM stg_litigation
    WHERE building_id IS NOT NULL

),

enriched AS (

    SELECT
        building_id, street_name, zip, 
        regexp_extract(incident_address , r'\d+') AS house_number

    FROM distinct_building

),

dim_complaint_type AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'building_id', 'street_name', 'zip'
        ]) }} AS building_key,

        building_id, street_name, zip, house_number

    FROM enriched

)

SELECT * FROM dim_building