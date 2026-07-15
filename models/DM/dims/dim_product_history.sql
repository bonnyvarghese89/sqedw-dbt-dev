{{
    config(
        materialized='table'
    )
}}

SELECT

    {{ dbt_utils.generate_surrogate_key([
        'ITEM_NUMBER',
        'DBT_VALID_FROM'
    ]) }} AS PRODUCT_HISTORY_KEY,

    ITEM_NUMBER,
    ITEM_DESCRIPTION,
    STANDARD_COST,
    ITEM_WEIGHT,
    ITEM_SIZE,
    ITEM_OUTER_DIAMETER,
    ITEM_WIDTH,
    COMMODITY_CODE_MM,

    DBT_VALID_FROM,
    DBT_VALID_TO,

    CASE
        WHEN DBT_VALID_TO IS NULL
        THEN 'Y'
        ELSE 'N'
    END AS CURRENT_FLAG

FROM {{ ref('snap_product') }}