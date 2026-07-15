-- stg_bpc__energy.sql
-- BPC Energy staging view

with source_data as (

    select
        PERIOD_DATE,
        SITE_ID,
        ACCOUNT_ID,
        CATEGORY,
        ENERGY_KWH
    from {{ source('bpc', 'energy') }}

)

select
    PERIOD_DATE,
    SITE_ID,
    ACCOUNT_ID,
    CATEGORY,
    ENERGY_KWH

from source_data