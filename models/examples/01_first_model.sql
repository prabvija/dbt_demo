-- CONCEPT: A model is just one SELECT statement.
-- dbt wraps it in CREATE VIEW / CREATE TABLE for you.

select
    1        as id,
    'hello'  as message
