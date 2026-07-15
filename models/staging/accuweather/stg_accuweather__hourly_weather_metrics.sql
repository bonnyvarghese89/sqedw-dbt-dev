with source as (

    select *
    from {{ source('accuweather', 'hourly_weather_metrics') }}

),

final as (

    select

        {{ dbt_utils.generate_surrogate_key([
            'location_code',
            'datetime'
        ]) }} as location_datetime_key,

        location_code,
        location_name,
        latitude,
        longitude,
        datetime,
        offset_gmt,
        cloud_cover_total,
        humidity_relative,
        minutes_of_precipitation,
        minutes_of_snow,
        has_precipitation,
        precipitation_lwe,
        precipitation_lwe_rate,
        precipitation_type,
        precipitation_type_desc,
        pressure,
        has_snow,
        snow,
        snow_lwe,
        snow_lwe_rate,
        temperature,
        temperature_dew_point,
        visibility,
        wind_direction,
        wind_gust,
        wind_speed,

        {{ add_audit_columns() }}

    from source

)

select *
from final