import pandas as pd
import pyodbc
from sqlalchemy import create_engine
import urllib
import os
from dotenv import load_dotenv

load_dotenv()


user_oltp = os.getenv('USER_OLTP')
pass_oltp = os.getenv('PASSWORD_OLTP')
user_dw = os.getenv('USER_DW')
pass_dw = os.getenv('PASSWORD_DW')

origem_str = (
    f"Driver={{ODBC Driver 18 for SQL Server}};"
    f"Server=localhost,1433;"
    f"Database=OLTP;"
    f"UID={user_oltp};"
    f"PWD={pass_oltp};"
    "Encrypt=no;"
    "TrustServerCertificate=yes;"
)
destino_str = (
    f"Driver={{ODBC Driver 18 for SQL Server}};"
    f"Server=localhost,1434;"
    f"Database=DW;"
    f"UID={user_dw};"
    f"PWD={pass_dw};"
    "Encrypt=no;"
    "TrustServerCertificate=yes;"
)

TABELAS_PARA_INGESTAO = {
    'edicao': 'edicao',
    'livro': 'livro',
    'autor': 'autor',
    'venda': 'venda',
    'conquista': 'conquista'
}

def executar_pipeline():
    
    quoted_destino = urllib.parse.quote_plus(destino_str)
    engine_dw = create_engine(f"mssql+pyodbc:///?odbc_connect={quoted_destino}")
    
    
    with pyodbc.connect(origem_str) as conn_oltp:
        for tabela_origem, tabela_destino in TABELAS_PARA_INGESTAO.items():
            try:
                print(f"--- Ingerindo {tabela_origem} -> {tabela_destino} ---")
                
                
                query = f"SELECT * FROM dbo.{tabela_origem}"
                df = pd.read_sql(query, conn_oltp)
                
                
                df.to_sql(
                    name=tabela_destino, 
                    con=engine_dw, 
                    schema='StgO', 
                    if_exists='replace', 
                    index=False
                )
                print(f"Sucesso! {len(df)} linhas carregadas.")
                
            except Exception as e:
                print(f"Erro ao processar a tabela {tabela_origem}: {e}")

if __name__ == "__main__":
    executar_pipeline()