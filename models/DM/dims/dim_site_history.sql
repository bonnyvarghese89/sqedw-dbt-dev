{{
    config(
        materialized='table'
    )
}}

SELECT

    {{ dbt_utils.generate_surrogate_key([
        'SITE_ID',
        'DBT_VALID_FROM'
    ]) }} AS SITE_HISTORY_KEY,

    SITE_ID,
    SITE_DESCRIPTION,
    BUSINESS_AREA,
    BUSINESS_UNIT,
    COUNTRY,
    STATE,
    CITY,
    SITE_TYPE,

    DBT_VALID_FROM,
    DBT_VALID_TO,

    CASE
        WHEN DBT_VALID_TO IS NULL
        THEN 'Y'
        ELSE 'N'
    END AS CURRENT_FLAG

FROM {{ ref('snap_site') }}