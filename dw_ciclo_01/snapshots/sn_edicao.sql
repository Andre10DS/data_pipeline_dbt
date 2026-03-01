{% snapshot sn_edicao %}

{{
    config(
        target_schema='snapshots',
        unique_key='isbn',
        strategy='check',
        check_cols=['preco'],
    )
}}
select
    isbn,
    livro_id,
    pub_id,
    data_publicacao,
    qtd_paginas,
    amostra_tamanho_k,
    preco
from {{source('Staging', 'edicao')}}
{% endsnapshot %}