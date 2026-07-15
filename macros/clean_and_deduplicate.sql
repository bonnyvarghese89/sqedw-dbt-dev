{% macro clean_and_deduplicate(
        source_relation,
        dedup_columns=[],
        order_by=None
    ) %}

{% set cols = adapter.get_columns_in_relation(source_relation) %}

SELECT

{% for col in cols %}

    {% if col.data_type.upper() in ['VARCHAR', 'TEXT', 'STRING'] %}

        TRIM(
            REGEXP_REPLACE(
                {{ adapter.quote(col.name) }},
                '\\s+',
                ' '
            )
        ) AS {{ adapter.quote(col.name) }}

    {% else %}

        {{ adapter.quote(col.name) }}

    {% endif %}

    {% if not loop.last %},{% endif %}

{% endfor %}

FROM {{ source_relation }}

{% if dedup_columns | length > 0 %}

QUALIFY
ROW_NUMBER() OVER (
    PARTITION BY
        {% for col in dedup_columns %}
            {{ col }}
            {% if not loop.last %}, {% endif %}
        {% endfor %}

    {% if order_by %}
        ORDER BY {{ order_by }}
    {% endif %}
) = 1

{% endif %}

{% endmacro %}