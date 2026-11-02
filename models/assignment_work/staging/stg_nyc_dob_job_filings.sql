-- Clean and standardize NYC DOB jobs apps dataset
-- One row per DOB job

WITH source AS (
   SELECT * FROM {{ source('raw', 'source_nyc_dob_job_apps') }}
), -- Easier to refer to the dbt reference to a long name table this way

cleaned AS (
   SELECT
       -- Get all columns from source, except ones we're transforming below
       -- To do cleaning on them or explicitly cast them as types just in case
       * EXCEPT (
        --Identifier
           job_filing_number,
        --Date
           filing_date,
           current_status_date, 
           approved_date, 
           signoff_date,
           first_permit_date
        --applicant_info and job_description
           applicant_license,
           applicant_first_name,
           applicant_last_name,
           job_description,
        --Location
           borough,
           house_no,
           street_name,
           postcode,
           latitude,
           longitude
        
       ),

       -- Identifiers
       CAST(job_filing_number AS STRING) AS job_filing_number,

       -- Date/Time
       CAST(filing_date AS TIMESTAMP) AS filing_date,
       CAST(current_status_date AS TIMESTAMP) AS status_date,
       CAST(approved_date AS TIMESTAMP) AS approved_date,
       CAST(signoff_date AS TIMESTAMP) AS signoff_date,
       CAST(first_permit_date AS TIMESTAMP) AS first_permit_date,


       -- Request details
       CAST(applicant_license AS STRING) AS applicant_license,
       CAST(applicant_first_name AS STRING) AS applicant_first_name,
       CAST(applicant_last_name AS STRING) AS applicant_last_name,
       CAST(job_description AS STRING) AS job_description,

       -- Location - clean zip code, handling several common zip code data problems
       CASE
           WHEN UPPER(TRIM(CAST(postcode AS STRING))) IN ('N/A', 'NA') THEN NULL
           WHEN UPPER(TRIM(CAST(postcode AS STRING))) = 'ANONYMOUS' THEN 'Anonymous'
           WHEN LENGTH(CAST(postcode AS STRING)) = 5 THEN CAST(postcode AS STRING)
           WHEN LENGTH(CAST(postcode AS STRING)) = 9 THEN CAST(postcode AS STRING)
           WHEN LENGTH(CAST(postcode AS STRING)) = 10
               AND REGEXP_CONTAINS(CAST(postcode AS STRING), r'^\d{5}-\d{4}')
           THEN CAST(postcode AS STRING)
           ELSE NULL
       END AS zipcode,

       -- Location - standardized borough, just in case
       CASE
           WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
           WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
           WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
           WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
           WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
           ELSE 'UNKNOWN or CITYWIDE'
       END AS borough,

       CAST(house_no AS STRING) AS  house_no,
       CAST(street_name AS STRING) AS street_name,
       CAST(latitude AS DECIMAL) AS latitude,
       CAST(longitude AS DECIMAL) AS longitude,

       -- Metadata
       CURRENT_TIMESTAMP() AS _stg_loaded_at

   FROM source

   -- Filters
   WHERE job_filing_number IS NOT NULL
   AND filing_date IS NOT NULL
   AND CAST(filing_date AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 YEAR)
   AND borough IS NOT NULL

   -- Deduplicate
   QUALIFY ROW_NUMBER() OVER (PARTITION BY job_filing_number ORDER BY filing_date DESC) = 1
)

SELECT * FROM cleaned
-- All should be part of this table after running: stg_nyc_dob_job_filings
