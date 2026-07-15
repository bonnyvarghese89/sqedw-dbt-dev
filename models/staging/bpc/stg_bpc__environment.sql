-- stg_bpc__environment.sql

with source_data as (

    select
        PERIOD_DATE,
        SITE_ID,
        ACCOUNT_ID,
        CATEGORY,
        AMOUNT,

        case 
            when ACCOUNT_ID = 'ENV_ARSE' then 'SQUARE METERS'
            when ACCOUNT_ID in (
                'ENV_META','ENV_RUBB','ENV_SOLV','ENV_GREA','ENV_GRSW',
                'ENV_GRSR','ENV_GRRU','ENV_GRIW','ENV_GRIO','ENV_GRLF',
                'ENV_ORRR','ENV_ORIW','ENV_ORIO','ENV_ORLF','ENV_MESC',
                'ENV_MSRE','ENV_PMET','ENV_PMSC','ENV_RUSC','ENV_RURE',
                'ENV_WAST','ENV_VOCT','ENV_VOCE','ENV_OILT'
            ) then 'METRIC TONS'
            when ACCOUNT_ID in (
                'ENV_ODMA','ENV_ODMB','ENV_ODMC',
                'ENV_ODNA','ENV_ODNB','ENV_ODNC','ENV_ODSA'
            ) then 'KILOGRAMS'
            when ACCOUNT_ID in ('ENV_WATE','ENV_WATM','ENV_WATO') then '1000 N CUBIC METERS'
            else null
        end as UOM

    from {{ source('bpc', 'environment') }}

)

select
    {{ dbt_utils.generate_surrogate_key([
        'PERIOD_DATE',
        'SITE_ID',
        'ACCOUNT_ID'
    ]) }} as environment_key,

    PERIOD_DATE,
    SITE_ID,
    ACCOUNT_ID,
    CATEGORY,
    AMOUNT,
    UOM

from source_data