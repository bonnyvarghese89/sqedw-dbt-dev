-- stg_bpc__site.sql

with source_data as (

    select
        SITE_ID,
        SITE_DESCRIPTION,
        IS_ACTIVE,
        BUSINESS_AREA,
        BUSINESS_UNIT,
        COUNTRY,
        STATE,
        CITY,
        CURRENCY_CODE,
        SITE_TYPE
    from {{ source('bpc','sqe_site') }}

)

select
    {{ dbt_utils.generate_surrogate_key(['SITE_ID']) }} as site_key,

    SITE_ID,
    SITE_DESCRIPTION,
    IS_ACTIVE,
    BUSINESS_AREA,
    BUSINESS_UNIT,
    COUNTRY,
    STATE,
    CITY,
    CURRENCY_CODE,
    SITE_TYPE

from source_data