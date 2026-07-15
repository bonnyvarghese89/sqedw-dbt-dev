{% snapshot snap_vendor %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='VENDOR_ID',
        strategy='check',
        check_cols=[
            'ERP_SUPPLIER_DESC',
            'VENDOR_INTERNATIONAL_NAME',
            'CITY',
            'STATE',
            'COUNTRY',
            'REGION',
            'IS_ACTIVE',
            'SAP_VENDOR_NO',
            'SAP_VENDOR_NAME'
        ]
    )
}}

select *
from {{ ref('stg_sievo__vendor_master_v2') }}

{% endsnapshot %}