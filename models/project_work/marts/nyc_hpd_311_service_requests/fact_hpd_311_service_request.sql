--fact table for hpd 311 service request

WITH stg_311 AS (
    SELECT * FROM {{ ref('stg_nyc_hpd_311_service_requests') }}
),

distinct_building AS (

    SELECT DISTINCT
    building_id as buildingid, street_name as streetname, zip, incident_address
    FROM stg_litigation
    WHERE building_id IS NOT NULL

),

enriched AS (

    SELECT
        buildingid, streetname, zip, 
        REGEXP_EXTRACT(incident_address, r'^\S*\d+') AS housenumber

    FROM distinct_building

),

dim_building AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'buildingid', 'streetname', 'zip', 'housenumber'
        ]) }} AS building_key,

        buildingid, streetname, zip, housenumber

    FROM enriched

)

SELECT * FROM dim_building