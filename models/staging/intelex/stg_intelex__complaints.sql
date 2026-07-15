with source as (

    select *
    from {{ source('intelex', 'complaints') }}

)

select

    "SOURCESYSTEM"     as source_system,
    "DATECREATED"      as date_created,
    "STATUS"           as status,
    "COMPLAINTCATEGORY" as complaint_category,
    "CUSTOMERNUMBER"   as customer_number,
    "CUSTOMER"         as customer,
    "COUNTRY"          as country,
    "RECORDNO"         as record_no,
    "CAPTION"          as caption,
    "SEVERITY"         as severity

from source