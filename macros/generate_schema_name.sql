{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema.lower() -%}

    {%- if custom_schema_name is none -%}

        {{ default_schema | trim }}

    {%- elif "dbt_cloud_pr" in default_schema -%}

        {{ default_schema }}_{{ custom_schema_name | lower | trim }}

    {%- else -%}

        {{ custom_schema_name | lower | trim }}

    {%- endif -%}

{%- endmacro %}