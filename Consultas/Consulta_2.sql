--Para realizar a coleta dos dados apresentados na tabela 2, a seguinte consulta SQL foi executada:
SELECT
  C.NOME AS NOMECLIENTE,
  COUNT(*) AS TOTALCORRIDAS
FROM
  CLIENTE C
  JOIN CORRIDA R ON C.CLIID = R.CLIID
  JOIN TAXI T ON R.PLACA = T.PLACA
  JOIN MOTORISTA M ON T.PLACA = M.PLACA
  JOIN FILA F ON M.CNH = F.CNH
  JOIN ZONA Z ON F.ZONA = Z.ZONA
WHERE
  R.datapedido BETWEEN '1/1/2000' AND '1/1/2023'
GROUP BY
  C.CLIID
HAVING
  COUNT(*) > 1;

--A consulta SQL acima é utilizada para retornar o apenas o nome de cada cliente que possuir o total de corridas maior que 1 e entre '1/1/2000' a '1/1/2023'. Com base nesses dados, foram criado os índices:
--Indice Hash no campo CliId da tabela Corrida
CREATE INDEX IDX_HASH_CORRIDA_CLIID ON CORRIDA USING HASH (CLIID);

--Indice Btree no campo Nome da tabela Cliente
CREATE INDEX IDX_BTREE_CLIENTE_NOME ON CLIENTE USING BTREE (NOME);

--Indice multi colunas nos campos CliId e Placa na tabela Corrida
CREATE INDEX IDX_CLIID_PLACA ON CORRIDA (CLIID, PLACA);

--Indice BRIN no campo DataPedido da tabela Corrida
CREATE INDEX IDX_BRIN_DATA_PEDIDO ON CORRIDA USING BRIN (DATAPEDIDO);

--Indice GIN + Extensão pg_trgm define a classe de operadores necessária para indices GIN em strings.
CREATE EXTENSION IF NOT EXISTS PG_TRGM;

CREATE INDEX IDX_GIN_PLACA ON CORRIDA USING GIN (PLACA GIN_TRGM_OPS);

CREATE EXTENSION IF NOT EXISTS PG_TRGM;

CREATE INDEX IDX_GIN_DATA_PEDIDO ON CORRIDA USING GIN (PLACA GIN_TRGM_OPS);