-- One row per unique combination of 311 complaint type and descriptors.
WITH distinct_problems AS (
    SELECT DISTINCT
        complaint_type AS problem_name,
        descriptor AS problem_detail,
        descriptor_2 AS additional_detail
    FROM {{ ref('stg_nyc_hpd_311_service_requests') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'problem_name',
        'problem_detail',
        'additional_detail'
    ]) }} AS problem_key,
    problem_name,
    problem_detail,
    additional_detail
FROM distinct_problems