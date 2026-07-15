with source as (

    select *
    from {{ source('codemaster', 'legal_tree') }}

)

select

    change_date,
    legal_unit_code,
    bpc_id,
    legal_unit_name,
    legal_parent_code,
    legal_parent_name,
    country_name,
    currency_code,
    status,
    status_change_date,
    legal_type,
    is_active,
    entity_type,
    financial_system,
    legal_entity_code

from source