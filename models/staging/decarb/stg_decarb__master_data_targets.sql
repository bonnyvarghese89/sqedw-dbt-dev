with source as (

    select *
    from {{ source('raw_decarb', 'master_data_targets') }}

)

select

    _UPLOADED_AT,
    _LOADED_AT,
    _SOURCE_FILE_NAME,
    _FILE_ROW_NUMBER,
    COUNTRY,
    SITE_NAME,
    SITE_CODE,
    DECARB_SCOPE,
    DECARB_SITE_TARGET_T_CO2E,
    DECARBONIZED_SITES_TARGET_YEAR,
    ROADMAP_MATURITY_SCOPE_BASED_ON_COMPLETENESS_EVALUATION

from source