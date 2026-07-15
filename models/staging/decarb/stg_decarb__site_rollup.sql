with source as (

    select *
    from {{ source('raw_decarb', 'site_rollup') }}

)

select

    UPLOADED_AT,
    _LOADED_AT,
    _SOURCE_FILE_NAME,
    _FILE_ROW_NUMBER,
    SITE_NAME,
    SITE_CODE,
    COUNTRY_NAME,
    BUSINESS_AREA_LONG_NAME,
    BUSINESS_UNIT_NAME,
    BUSINESS_AREA_SHORT_NAME,
    SKF_REGION_NAME,
    PARENT_NAME,
    DIVISION_NAME,
    PRIMARY_EMAIL,
    SECONDARY_EMAIL,
    BACKUP_EMAIL,
    REMAIN_NEWCO,
    DECARBONIZED_SITE

from source