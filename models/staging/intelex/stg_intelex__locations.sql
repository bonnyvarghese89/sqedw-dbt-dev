with source as (

    select *
    from {{ source('intelex', 'locations') }}

)

select

    ID              as id,
    NAME            as name,
    DESCRIPTION     as description,
    POSTALCODE      as postal_code,
    PHONE           as phone,
    FAX             as fax,
    LICENSE         as license,
    PARENTID        as parent_id,
    DATECREATED     as date_created,
    DATEMODIFIED    as date_modified,
    PATH            as path,
    REGION          as region,
    COUNTRYID       as country_id,
    CITY            as city,
    STATE           as state,
    LOCATIONCODE    as location_code,
    SKFSITEID       as skf_site_id,
    DIVISION        as division,
    PRODUCTGROUP    as product_group,
    BUSINESSUNITS   as business_units,
    COMPANYNAME     as company_name,
    DATA_LOADDATE   as data_load_date,
    DATA_ENV        as data_env

from source