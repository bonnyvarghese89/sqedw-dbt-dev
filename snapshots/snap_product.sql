{% snapshot snap_product %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='ITEM_NUMBER',
        strategy='check',
        check_cols=[
            'ITEM_DESCRIPTION',
            'STANDARD_COST',
            'ITEM_WEIGHT',
            'ITEM_SIZE',
            'ITEM_OUTER_DIAMETER',
            'ITEM_WIDTH',
            'COMMODITY_CODE_MM'
        ]
    )
}}

select *
from {{ ref('stg_sievo__material_master') }}

{% endsnapshot %}