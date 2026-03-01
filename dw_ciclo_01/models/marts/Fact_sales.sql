
{{
  config(
    materialized='incremental',
    unique_key='ordem_id'
  )
}}

WITH stg_sales AS (
    SELECT
        *
    FROM {{source('Staging', 'venda')}}

    {% if is_incremental() %}
    WHERE data > (SELECT MAX(data) FROM {{ this }})
    {% endif %}
),
table_sales AS (
    SELECT
        data,
        desconto,
        isbn,
        ordem_id
    FROM stg_sales
)
select * from table_sales