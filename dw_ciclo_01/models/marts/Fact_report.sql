WITH stg_sales AS (
    SELECT
        *
    FROM {{ref('Fact_sales')}}
),
table_sales AS (
    SELECT
        d.date_key,
        e.sk_edicao,
        l.sk_livro,
        a.sk_author,
        c.sk_conquista,
        v.ordem_id,
        v.isbn,
        v.desconto,
        e.preco as preco_unitario,
        (e.preco - v.desconto) as valor_liquido
    FROM stg_sales v
    left join {{ref('Dim_date' ) }} d on v.data = d.full_date
    left join {{ref('Dim_edition')}} e on v.isbn = e.isbn and v.data >= e.data_inicio and (v.data < e.data_fim or e.data_fim is null)
    left join {{ref('Dim_book') }} l on e.livro_id = l.livro_id
    left join {{ref('Dim_author') }} a on l.autor_id = a.autor_id
    left join {{ref('Dim_conquest') }} c on l.livro_id = c.livro_id
)
select * from table_sales