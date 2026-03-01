WITH snapshot_edition AS (
    SELECT *
    FROM {{ref('sn_edicao')}}
),
table_edition AS (
    SELECT
        {{dbt_utils.generate_surrogate_key(['isbn', 'dbt_valid_from'])}} AS sk_edicao,
        isbn,
        livro_id,
        pub_id,
        data_publicacao,
        qtd_paginas,
        amostra_tamanho_k,
        preco,
        dbt_valid_from as data_inicio,
        dbt_valid_to as data_fim
    from snapshot_edition
)
SELECT * FROM table_edition