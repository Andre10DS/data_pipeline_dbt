

![dbt](https://raw.githubusercontent.com/Andre10DS/data_pipeline_dbt/main/img/capa.png)


## Projeto: Data Warehouse de Vendas de Livros com dbt + SQL Server + Docker

Este projeto tem como objetivo demonstrar a aplicação prática de Analytics Engineering com dbt, utilizando modelagem dimensional (Kimball) para construção de um Data Warehouse (DW) a partir de um banco transacional (OLTP).



# 1. Problema de negócio.

Os dados de vendas de livros estão armazenados em um sistema transacional (OLTP), estruturado para operações do dia a dia e não para análises estratégicas. Essa estrutura dificulta a consolidação de métricas, análises históricas e o acompanhamento de mudanças relevantes, como variações de preço nas edições.

Surge, portanto, a necessidade de construir um Data Warehouse dimensional, capaz de organizar, historizar e disponibilizar os dados de forma confiável e analítica para suporte à tomada de decisão.

# 2. Arquitetura da Solução.

A arquitetura contempla:

 - Dois bancos SQL Server em containers Docker

 - Processo de ingestão via Python

 - Transformações com dbt

 - Modelagem dimensional (Dimensões + Fato)

 - Snapshot para controle de mudanças

 - Geração de documentação automática



![Arquitetura](https://raw.githubusercontent.com/Andre10DS/data_pipeline_dbt/main/img/Arquitetura.png)

# 3. Infraestrutura com Docker.

Foram criados dois containers:

 - sqlserver_oltp

 - sqlserver_dw

Cada um com sua base isolada:

 | Ambiente | Finalidade                        |
| -------- | --------------------------------- |
| OLTP     | Simulação do sistema transacional |
| DW       | Armazenamento analítico           |


# 4. Processo de Ingestão (Python)

Para captura dos dados do banco OLTP e realizar a ingestão no banco DW foi utilizado o arquivo raw_ingestion.py:

![python](https://raw.githubusercontent.com/Andre10DS/data_pipeline_dbt/main/img/python.png)

Responsável por:

 - Conectar ao OLTP
 - Extrair dados
 - Carregar no DW
 - Popular camada RAW/Staging inicial

## 5. Estrutura do Projeto dbt


![projeto_dbt](https://raw.githubusercontent.com/Andre10DS/data_pipeline_dbt/main/img/projeto_dbt.png)

    
## 6. Snapshot – Controle de Mudança (SCD)

Na tabela edição, a coluna preco pode sobrer alterações constantemente fazendo necessário a cosntrução de snapshot para guardar o histórico dos preços. Desta forma, fui utilizado o arquivo sn_edicao para realizar a construção da tabela snapshot.

![sn_edicao](https://raw.githubusercontent.com/Andre10DS/data_pipeline_dbt/main/img/sn_edicao.png)


Tipo implementado:

Slowly Changing Dimension (SCD Type 2)

Isso permite:

  - Histórico de preços
  - Análise temporal
  - Auditoria de mudanças

## 7. Construção das Dimensões

Dimensões criadas:

 - Dim_author
 - Dim_book
 - Dim_conquest
 - Dim_date
 - Dim_edition

🔑 Estratégia

  - Criação de Surrogate Keys (SK)
  - Controle de integridade
  - Estrutura orientada a análise

## 8. Construção da Fato

Fato criada:

Fonte:

 - Tabela de vendas (staging)
 - Junção com todas as dimensões

Objetivo:

 - Inserir Surrogate Keys
 - Consolidar métricas de negócio


![sql_server](https://raw.githubusercontent.com/Andre10DS/data_pipeline_dbt/main/img/view_dim.png)

## 9. Sources.yml

O arquivo de Sources é onde você declara para o dbt quais tabelas já existem no seu banco de dados (no seu caso, as tabelas que o script Python inseriu no schema StgO) antes do dbt entrar em ação.

Arquivo responsável por:

 - Declarar origem dos dados
 - Documentar tabelas externas
 - Permitir rastreabilidade

Exemplo:

![Sources](https://raw.githubusercontent.com/Andre10DS/data_pipeline_dbt/main/img/sources.png)


## 10. schema.yml

O schema é o dicionário de dados e o motor de testes dos modelos. Define descrições detalhadas para tabelas e colunas, além de aplicar testes de integridade (como unique e not_null), garantindo que os dados transformados estejam corretos antes de chegarem ao usuário final.

Responsável por:

 - Documentar colunas
 - Criar testes
 - Garantir qualidade


![schema](https://raw.githubusercontent.com/Andre10DS/data_pipeline_dbt/main/img/schema.png)



## 11. Exposures.yml

O arquivo Exposures permite mapear os consumidores dos produtos finais do dbt. Documenta quais dashboards, relatórios ou ferramentas de BI dependem de cada tabela. Isso permite realizar análises de impacto, identificando quais entregáveis de negócio serão afetados caso ocorra uma alteração no pipeline.


Exemplo:

![Exposures](https://raw.githubusercontent.com/Andre10DS/data_pipeline_dbt/main/img/exposure.png)


## 12. Documentação

A etapa de documentação é fundamental em projetos de Analytics Engineering, pois garante transparência, rastreabilidade, governança e entendimento do fluxo de dados por parte de times técnicos e de negócio. No contexto de um Data Warehouse, documentar não é apenas descrever tabelas — é tornar explícitas as dependências, regras de negócio, testes aplicados e o fluxo completo da transformação dos dados.

O dbt possui um sistema nativo de documentação automatizada, que é gerado a partir dos próprios artefatos do projeto.

Para que o dbt consiga gerar a documentação completa, alguns arquivos são fundamentais:

 - sources.yml → Declara e documenta as origens dos dados.
 - schema.yml → Documenta modelos, colunas e testes aplicados.
 - exposures.yml → Define os destinos finais e consumidores dos dados.
 - Modelos .sql com uso de ref() e source() → Permitem ao dbt construir o grafo de dependências (DAG).

Esses arquivos funcionam como insumos estruturados que alimentam a documentação automática.

A documentação é gerada com o comando:

  *** dbt docs generate ***

Esse comando cria artefatos internos como manifest.json, catalog.json e index.html.

Esses arquivos contêm:

 - Metadados dos modelos
 - Estrutura de colunas
 - Testes aplicados
 - Dependências entre objetos
 - Informações de materialização

Após a geração, a documentação pode ser visualizada localmente com:

  *** dbt docs serve ***

O comando cria um servidor web local que disponibiliza uma interface interativa contendo:

  - DAG (Data Lineage Graph)
  - Descrição de modelos e colunas
  - Testes aplicados
  - Filtros de navegação
  - Dependências entre fontes, dimensões, fatos e relatórios

![Lineage](https://raw.githubusercontent.com/Andre10DS/data_pipeline_dbt/main/img/Lineage.gif)

## 13. Testes e Qualidade de Dados

Foram implementados testes para:

 - Unicidade de chaves
 - Integridade referencial
 - Campos obrigatórios

Isso garante que o DW mantenha consistência analítica.


## 14. Conclusão

Este projeto demonstra uma arquitetura completa de Engenharia de Dados e Analytics Engineering, partindo de um sistema transacional até a construção de um Data Warehouse analítico, utilizando boas práticas de modelagem dimensional e governança com dbt.

## 15. Próximos passos

 - Implementação de camada int_
 - Orquestração com Airflow
 - Deploy em cloud (Azure / AWS / GCP)
 - Integração com Power BI


