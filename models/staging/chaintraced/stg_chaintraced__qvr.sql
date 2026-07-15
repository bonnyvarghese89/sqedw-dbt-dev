-- stg_chaintraced__qvr.sql

with source_data as (

    select
        SUPPLIER_ID,
        SUPPLIER_NAME,
        COUNTRY,
        MATERIAL_ID,
        MATERIAL_DESCRIPTION,
        TRACEABILITY_STATUS,
        CERTIFICATION_STATUS,
        RISK_LEVEL,
        REPORTING_PERIOD,
        LOAD_TS
    from {{ source('chaintraced', 'FCT_CHAINTRACED_QVR') }}

)

select
    {{ dbt_utils.generate_surrogate_key([
        'SUPPLIER_ID',
        'MATERIAL_ID',
        'REPORTING_PERIOD'
    ]) }} as qvr_key,

    SUPPLIER_ID,
    SUPPLIER_NAME,
    COUNTRY,
    MATERIAL_ID,
    MATERIAL_DESCRIPTION,
    TRACEABILITY_STATUS,
    CERTIFICATION_STATUS,
    RISK_LEVEL,
    REPORTING_PERIOD,
    LOAD_TS

from source_data