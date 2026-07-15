{{
    config(
        materialized='table'
    )
}}

select distinct

    {{ dbt_utils.generate_surrogate_key([
        'sap_vendor_no'
    ]) }} as supplier_key,

    sap_vendor_no,
    sap_vendor_name,

    counterparty_name,
    counterparty_supplier_city,

    counterparty_is_supplier

from {{ ref('int_sievo__co2_factory_emissions') }}

where sap_vendor_no is not null
