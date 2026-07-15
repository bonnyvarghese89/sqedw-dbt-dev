with source as (

    select *
    from {{ source('intelex', 'investigations') }}

)

select

    *

from source