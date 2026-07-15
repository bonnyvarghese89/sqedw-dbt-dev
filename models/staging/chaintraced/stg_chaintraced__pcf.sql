-- stg_chaintraced__pcf.sql

with source_data as (

    select
        PRODUCT_ID,
        PRODUCT_DESCRIPTION,
        SUPPLIER_ID,
        SUPPLIER_NAME,
        PLANT_ID,
        REPORTING_PERIOD,
        PCF_KG_CO2E,
        PCF_UNIT,
        TRANSPORT_EMISSIONS,
        MATERIAL_EMISSIONS,
        MANUFACTURING_EMISSIONS,
        TOTAL_EMISSIONS,
        LOAD_TS
    from {{ source('chaintraced', 'FCT_CHAINTRACED_PCF') }}

)

select
    {{ dbt_utils.generate_surrogate_key([
        'PRODUCT_ID',
        'SUPPLIER_ID',
        'PLANT_ID',
        'REPORTING_PERIOD'
    ]) }} as pcf_key,

    PRODUCT_ID,
    PRODUCT_DESCRIPTION,
    SUPPLIER_ID,
    SUPPLIER_NAME,
    PLANT_ID,
    REPORTING_PERIOD,
    PCF_KG_CO2E,
    PCF_UNIT,
    TRANSPORT_EMISSIONS,
    MATERIAL_EMISSIONS,
    MANUFACTURING_EMISSIONS,
    TOTAL_EMISSIONS,
    LOAD_TS

from source_data