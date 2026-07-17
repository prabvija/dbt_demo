-- CONCEPT: ref() links models. dbt uses these to build the DAG.
-- Here we depend on the source-based model above.

select
    id,
    count(*) as country_count
from {{ ref('first_model') }}
group by id
