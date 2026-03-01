with stg_book AS (
    SELECT  *
    FROM {{source('Staging', 'livro')}}
),
table_book AS (
    SELECT
        {{dbt_utils.generate_surrogate_key(['livro_id','titulo','autor_id'])}} AS sk_livro,
        livro_id,
        titulo,
        autor_id,
        CURRENT_TIMESTAMP AS data_carga
    FROM stg_book
)
select * FROM table_book