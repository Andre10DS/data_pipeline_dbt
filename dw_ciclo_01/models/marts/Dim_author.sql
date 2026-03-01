WITH stg_author AS (
   
    SELECT * FROM {{ source('Staging', 'autor') }} 
),
table_author AS(
    SELECT
        {{dbt_utils.generate_surrogate_key(['autor_id', 'nome', 'sobrenome'])}} AS sk_author,
        autor_id,
        nome,
        sobrenome,
        data_nascimento,
        pais_de_residencia,
        CURRENT_TIMESTAMP AS data_carga
    FROM stg_author
)
SELECT * FROM table_author