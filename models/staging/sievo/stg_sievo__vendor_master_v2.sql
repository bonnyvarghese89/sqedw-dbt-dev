with source as (

    select *
    from {{ source('sievo', 'vendor_master_v2') }}

)

select

    "MD_VendorNoId"                 as vendor_id,
    "ERP supplier no"               as erp_supplier_no,
    "Original supplier no"          as original_supplier_no,
    "ERP supplier desc"             as erp_supplier_desc,
    "MD_HarmonizedVendorNoId"       as harmonized_vendor_id,
    "MD_VendorInternationalName"    as vendor_international_name,
    "Supplier address"              as supplier_address,
    "MD_VendorPostalCode"          as postal_code,
    "Supplier city"                as city,
    "MD_VendorState"               as state,
    "MD_VendorPaymentTermDesc"     as payment_terms,
    "MD_VendorGroupDesc"           as vendor_group,
    "MD_VendorType"                as vendor_type,
    "MD_NameCountry"               as country,
    "MD_RegionSKF"                 as region,
    "MD_ActiveVendor"              as is_active,
    "SAPVendorNo"                  as sap_vendor_no,
    "SAPVendorName"                as sap_vendor_name

from source