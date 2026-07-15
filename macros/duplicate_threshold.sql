{% test duplicate_threshold(model, column_name, max_duplicates) %}

select count(*) as duplicate_count
from (
    select {{ column_name }}
    from {{ model }}
    group by {{ column_name }}
    having count(*) > 1
) t
having count(*) > {{ max_duplicates }}

{% endtest %}