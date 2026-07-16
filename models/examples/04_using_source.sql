-- CONCEPT: source() points to a raw table NOT built by dbt.
-- The source is declared in _sources.yml (see this folder).

select
    country,
    continent
from {{ source('examples_raw', 'example_countries') }}
