with source as (

    select *
    from {{ source('intelex', 'monthly_batch_loading') }}

)

select

    "Record No."      as record_no,
    "Site"            as site,
    "Operating Unit"  as operating_unit,
    "Year"            as year,
    "Month"           as month,
    "Incident Type"   as incident_type,
    "bp8cck"          as bp8cck,
    "Nb of Incidents" as number_of_incidents

from source