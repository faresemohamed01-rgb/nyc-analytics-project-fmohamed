-- One row per distinct building ID and address combination.

WITH distinct_buildings AS (
    SELECT DISTINCT
        building_id AS buildingid,
        street_name AS streetname,
        zip,
        REGEXP_EXTRACT(
            incident_address, r'^\S*\d+'
        ) AS housenumber
    FROM {{ ref('stg_nyc_housing_litigations') }}
    WHERE building_id IS NOT NULL
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'buildingid',
        'streetname',
        'zip',
        'housenumber'
    ]) }} AS building_key,
    buildingid,
    streetname,
    zip,
    housenumber
FROM distinct_buildings
