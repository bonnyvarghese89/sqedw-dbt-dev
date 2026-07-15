{% macro add_audit_columns() %}

    CURRENT_TIMESTAMP() AS DW_CREATED_TS,
    CURRENT_TIMESTAMP() AS DW_UPDATED_TS,
    '{{ invocation_id }}' AS DW_RUN_ID,
    '{{ target.name | upper }}' AS DW_ENVIRONMENT,
    '{{ this.identifier }}' AS DW_MODEL_NAME

{% endmacro %}