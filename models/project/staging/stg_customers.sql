-- STAGING: light cleanup of one source table.
-- Rules of thumb:
--   • 1 staging model per source table
--   • rename columns, cast types, no joins, no business logic
--   • materialized as a view (see dbt_project.yml)

with source as (
    select * from {{ source('raw', 'raw_customers') }}
),

renamed as (
    select
        customer_id,
        first_name,
        last_name,
        lower(email)                as email,
        cast(signup_date as date)   as signup_date,
        country
    from source
)

select * from renamed
