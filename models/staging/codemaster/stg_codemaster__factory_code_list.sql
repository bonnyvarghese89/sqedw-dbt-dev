with source as (

    select *
    from {{ source('codemaster', 'factory_code_list') }}

)

select

    change_date,
    site_one_letter,
    country_name,
    is_factory,
    skf_country_code,
    country_code_iso2,
    site_name,
    site_code,
    is_d8_relevant,
    is_d10_relevant,
    active,
    incident_number,
    comment

from source