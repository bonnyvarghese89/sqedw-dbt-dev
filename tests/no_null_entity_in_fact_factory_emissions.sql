select *
from {{ ref('fact_factory_emissions') }}
where entity_id is null