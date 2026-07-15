with source as (

    select *
    from {{ source('raw_decarb', 'site_data') }}

)

select

    _UPLOADED_AT,
    _LOADED_AT,
    _SOURCE_FILE_NAME,
    _FILE_ROW_NUMBER,
    SITE,
    YEAR,
    ASPECT,
    UNIT_OF_MEASUREMENT,
    VALUE,
    IS_CALCULATED,
    INTEGER_VALUE,
    DECIMAL_VALUE

from source