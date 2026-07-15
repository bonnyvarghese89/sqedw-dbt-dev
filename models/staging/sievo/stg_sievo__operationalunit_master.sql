with source as (

    select *
    from {{ source('sievo', 'operationalunit_master') }}

)

select

    "MD_OperationalUnitNoId"    as operational_unit_id,
    "ReportingCurrencyDesc"     as reporting_currency,
    "BusinessLineDirector"      as business_line_director,
    "BusinessLineManager"       as business_line_manager,
    "MD_OperationalUnitDesc"    as operational_unit_desc

from source