-- CONCEPT: ref() links models. dbt uses these to build the DAG.
-- Here we depend on the source-based model above.

select
    continent,
    count(*) as country_count
from {{ ref('04_using_source') }}
group by continent
