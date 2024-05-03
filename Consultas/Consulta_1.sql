--Para realizar a coleta dos dados apresentados na tabela 1, a seguinte consulta SQL foi executada:

SELECT C.NOME AS NOMECLIENTE,
  T.MARCA,
  T.MODELO,
  Z.ZONA,
  R.DATAPEDIDO
FROM CLIENTE C
JOIN CORRIDA R ON C.CLIID = R.CLIID
JOIN TAXI T ON R.PLACA = T.PLACA
JOIN MOTORISTA M ON T.PLACA = M.PLACA
JOIN FILA F ON M.CNH = F.CNH
JOIN ZONA Z ON F.ZONA = Z.ZONA
WHERE R.DATAPEDIDO BETWEEN
    (SELECT R.DATAPEDIDO
      FROM CLIENTE C
      JOIN CORRIDA R ON C.CLIID = R.CLIID
      JOIN TAXI T ON R.PLACA = T.PLACA
      JOIN MOTORISTA M ON T.PLACA = M.PLACA
      JOIN FILA F ON M.CNH = F.CNH
      JOIN ZONA Z ON F.ZONA = Z.ZONA
      ORDER BY R.DATAPEDIDO ASC
      LIMIT 1) AND NOW()
  AND T.MODELO like '%i%';

--A consulta SQL acima é utilizada para retornar o nome do cliente, marca e modelo do táxi, a zona onde a corrida ocorreu e a data da corrida. Com base nesses dados, foram criado os índices:
	--Indice Hash no campo zona
CREATE INDEX IDX_HASH_ZONA ON ZONA USING HASH(ZONA);


--Indice Btree no campo CPF da tabela Cliente
CREATE INDEX IDX_BTREE_CLIENTE_CPF ON CLIENTE USING BTREE(CPF);


--Indice multi colunas nos campos CliId e Placa da tabela Corrida
CREATE INDEX IDX_CLIID_PLACA ON CORRIDA(CLIID, PLACA);


--Indice BRIN no campo DataPedido da tabela corrida
CREATE INDEX IDX_BRIN_DATA_PEDIDO ON CORRIDA USING BRIN(DATAPEDIDO);


--Indice GIN + Extensão pg_trgm, define a classe de operadores necessária para índices GIN em strings.
CREATE EXTENSION IF NOT EXISTS PG_TRGM;
CREATE INDEX IDX_GIN_DATA_PEDIDO ON CORRIDA USING GIN (PLACA GIN_TRGM_OPS);