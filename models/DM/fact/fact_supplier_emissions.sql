{{
    config(
        materialized='incremental',
        unique_key='supplier_emission_key'
    )
}}

select

    {{ dbt_utils.generate_surrogate_key([
        'pcf.supplier_id',
        'pcf.product_id',
        'pcf.reporting_period'
    ]) }} as supplier_emission_key,

    pcf.reporting_period,

    ds.supplier_key,
    dp.product_key,

    pcf.supplier_id,
    pcf.product_id,

    pcf.pcf_kg_co2e,
    pcf.transport_emissions,
    pcf.material_emissions,
    pcf.manufacturing_emissions,
    pcf.total_emissions,

    current_timestamp() as load_ts

from {{ ref('stg_chaintraced__pcf') }} pcf

left join {{ ref('dim_supplier') }} ds
    on pcf.supplier_id = ds.sap_vendor_no

left join {{ ref('dim_product') }} dp
    on pcf.product_id = dp.item_number