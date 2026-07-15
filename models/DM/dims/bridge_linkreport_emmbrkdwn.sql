{{ config(
    materialized='incremental',
    on_schema_change='fail'
) }}

WITH bridge AS (

    SELECT DISTINCT

        {{ dbt_utils.generate_surrogate_key([
            'product_id'
        ]) }} AS FK_PRODUCT,

        {{ dbt_utils.generate_surrogate_key([
            'supplier_id'
        ]) }} AS FK_SUPPLIER,

        {{ dbt_utils.generate_surrogate_key([
            'plant_id'
        ]) }} AS FK_PLANT

    FROM {{ ref('stg_chaintraced__pcf') }}

    WHERE product_id IS NOT NULL
      AND supplier_id IS NOT NULL
      AND plant_id IS NOT NULL

)

SELECT *
FROM bridge