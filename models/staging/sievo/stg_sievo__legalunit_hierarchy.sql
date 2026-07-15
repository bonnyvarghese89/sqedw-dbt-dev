with source as (

    select *
    from {{ source('sievo', 'legalunit_hierarchy') }}

)

select

    "LegalUnitId"        as legal_unit_id,
    "Company Country"    as company_country,
    "Legal Unit"         as legal_unit

from source