--Para realizar a coleta dos dados apresentados na tabela4, a seguinte consulta SQL foi executada:
SELECT
  T.PLACA,
  T.MARCA,
  T.MODELO,
  M.NOME AS NOMEMOTORISTA,
  M.CNH
FROM
  TAXI T
  JOIN CORRIDA R ON T.PLACA = R.PLACA
  JOIN MOTORISTA M ON T.PLACA = M.PLACA
WHERE
  EXISTS (
    SELECT
      1
    FROM
      FILA F
    WHERE
      F.CNH = M.CNH
      AND F.ZONA = 'Unicamp'
  )
  AND M.CNHVALID = 1;

--A consulta SQL acima é utilizada para retornar placa, marca e modelo do táxi, juntamente com o nome e CNH do motorista, 
--para os táxis que realizaram corridas na zona 'Unicamp' e foram conduzidos por motoristas com licença válida. Com base nesses dados, foram criados os índices:
--Indice Hash no campo CNH da tabela Motorista
CREATE INDEX IDX_HASH_MOTORISTA_CNH ON MOTORISTA USING HASH (CNH);

--Indice Btree no campo Placa da tabela Taxi
CREATE INDEX IDX_BTREE_TAXI_PLACA ON TAXI USING BTREE (PLACA);

--Indice multi colunas nos campos CliId e Placa da tabela Corrida
CREATE INDEX IDX_CLIID_PLACA ON CORRIDA (CLIID, PLACA);

--Indice BRIN nos campos CNH e Zona da tabela Fila
CREATE INDEX IDX_BRIN_CNH_ZONA ON FILA USING BRIN (CNH, ZONA);

--Indice GIN + Extensão pg_trgm define a classe de operadores necessária para índices GIN em strings.
CREATE EXTENSION IF NOT EXISTS PG_TRGM;

CREATE INDEX IDX_GIN_PLACA ON CORRIDA USING GIN (PLACA GIN_TRGM_OPS);