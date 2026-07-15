{{
    config(
        materialized='table'
    )
}}

SELECT

    {{ dbt_utils.generate_surrogate_key([
        'VENDOR_ID',
        'DBT_VALID_FROM'
    ]) }} AS VENDOR_HISTORY_KEY,

    VENDOR_ID,
    ERP_SUPPLIER_DESC,
    VENDOR_INTERNATIONAL_NAME,
    CITY,
    STATE,
    COUNTRY,
    REGION,
    IS_ACTIVE,
    SAP_VENDOR_NO,
    SAP_VENDOR_NAME,

    DBT_VALID_FROM,
    DBT_VALID_TO,

    CASE
        WHEN DBT_VALID_TO IS NULL
        THEN 'Y'
        ELSE 'N'
    END AS CURRENT_FLAG

FROM {{ ref('snap_vendor') }}