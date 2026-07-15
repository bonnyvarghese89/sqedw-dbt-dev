{{
    config(
        materialized='table'
    )
}}

with entity_master as (

    select distinct
        entity_id,
        entity_description,
        entity,
        active,
        country,
        country_code,
        currency_code,
        currency_zone,
        currency_scale,
        geo_area_code,
        site_id,
        entity_type,
        entity_id_legal,
        parent_entity_id_operational_h1,
        parent_entity_id_legal_h2,
        parent_entity_id_country_h3,
        parent_entity_id_press_h4,
        entity_level
    from {{ ref('stg_bpc__entity') }}

),

entity_activity as (

    select distinct
        entity_id
    from {{ ref('int_bpc__consolidated_impact') }}
    where entity_id is not null

)

select

    {{ dbt_utils.generate_surrogate_key([
        'e.entity_id'
    ]) }} as entity_key,

    e.entity_id,
    e.entity_description,
    e.entity,

    e.active as is_active,

    e.entity_type,
    e.entity_level,

    e.site_id,

    e.country,
    e.country_code,

    e.currency_code,
    e.currency_zone,
    e.currency_scale,

    e.geo_area_code,

    e.entity_id_legal,

    e.parent_entity_id_operational_h1,
    e.parent_entity_id_legal_h2,
    e.parent_entity_id_country_h3,
    e.parent_entity_id_press_h4,

    case
        when a.entity_id is not null then 'Y'
        else 'N'
    end as has_esg_activity

from entity_master e
left join entity_activity a
    on e.entity_id = a.entity_id