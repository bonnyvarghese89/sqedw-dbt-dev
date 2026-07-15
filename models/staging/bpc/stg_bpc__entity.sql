-- stg_bpc__entity.sql
-- BPC Entity staging view

with source_data as (

    select
        ENTITY_ID,
        ENTITY_DESCRIPTION,
        ENTITY,
        ACTIVE,
        COUNTRY,
        COUNTRY_CODE,
        CURRENCY_CODE,
        CURRENCY_ZONE,
        CURRENCY_SCALE,
        GEO_AREA_CODE,
        SITE_ID,
        ENTITY_TYPE,
        ENTITY_ID_LEGAL,
        PARENT_ENTITY_ID_OPERATIONAL_H1,
        PARENT_ENTITY_ID_LEGAL_H2,
        PARENT_ENTITY_ID_COUNTRY_H3,
        PARENT_ENTITY_ID_PRESS_H4,
        ENTITY_LEVEL
    from {{ source('bpc','sqe_entity') }}

)

select
    ENTITY_ID,
    ENTITY_DESCRIPTION,
    ENTITY,
    ACTIVE,
    COUNTRY,
    COUNTRY_CODE,
    CURRENCY_CODE,
    CURRENCY_ZONE,
    CURRENCY_SCALE,
    GEO_AREA_CODE,
    SITE_ID,
    ENTITY_TYPE,
    ENTITY_ID_LEGAL,
    PARENT_ENTITY_ID_OPERATIONAL_H1,
    PARENT_ENTITY_ID_LEGAL_H2,
    PARENT_ENTITY_ID_COUNTRY_H3,
    PARENT_ENTITY_ID_PRESS_H4,
    ENTITY_LEVEL

from source_data