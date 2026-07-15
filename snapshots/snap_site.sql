{% snapshot snap_site %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='SITE_ID',
        strategy='check',
        check_cols=[
            'SITE_DESCRIPTION',
            'BUSINESS_AREA',
            'BUSINESS_UNIT',
            'COUNTRY',
            'STATE',
            'CITY',
            'SITE_TYPE'
        ]
    )
}}

select *
from {{ ref('stg_bpc__site') }}

{% endsnapshot %}