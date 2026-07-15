{% snapshot snap_entity %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='ENTITY_ID',
        strategy='check',
        check_cols=[
            'ENTITY_DESCRIPTION',
            'ENTITY',
            'ENTITY_TYPE',
            'ENTITY_LEVEL'
        ]
    )
}}

select *
from {{ ref('stg_bpc__entity') }}

{% endsnapshot %}