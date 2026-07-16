-- CONCEPT: Materialized as a TABLE — physical CREATE TABLE AS.
-- Overrides the folder default (view) for this one model.

{{ config(materialized='table') }}

select
    'table'   as materialization,
    'stored physically, fast reads' as behaviour
