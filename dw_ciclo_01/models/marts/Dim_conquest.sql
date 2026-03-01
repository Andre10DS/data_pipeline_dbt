WITH stg_conquistas AS (
    SELECT 
        livro_id,
        premio_name
    FROM {{source('Staging', 'conquista')}}
),

pivotado AS (
    SELECT
        livro_id,
        {{ dbt_utils.pivot(
            column='premio_name',
            values=dbt_utils.get_column_values(source('Staging', 'conquista'), 'premio_name'),
            then_value='1',
            else_value='0',
            agg='max',
            prefix='tem_premio_'
        ) }}
    FROM stg_conquistas
    GROUP BY livro_id
),

table_conquest AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['livro_id']) }} AS sk_conquista,
        *
    FROM pivotado
)

SELECT * FROM table_conquest