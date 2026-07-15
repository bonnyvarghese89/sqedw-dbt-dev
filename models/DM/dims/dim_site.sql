{{
    config(
        materialized='table'
    )
}}

with site_master as (

    select
        site_id,
        site_description,
        is_active,
        business_area,
        business_unit,
        country,
        state,
        city,
        currency_code,
        site_type
    from {{ ref('stg_bpc__site') }}

),

site_usage as (

    select distinct
        site_id
    from {{ ref('int_bpc__consolidated_impact') }}
    where site_id is not null

),

final as (

    select

        {{ dbt_utils.generate_surrogate_key([
            's.site_id'
        ]) }} as site_key,

        s.site_id,
        s.site_description,

        s.business_area,
        s.business_unit,

        s.country,
        s.state,
        s.city,

        s.currency_code,
        s.site_type,

        s.is_active,

        case
            when u.site_id is not null then 'Y'
            else 'N'
        end as has_esg_activity

    from site_master s
    left join site_usage u
        on s.site_id = u.site_id

)

select *
from final