--Para realizar a coleta dos dados apresentados na tabela3, a seguinte consulta SQL foi executada:

SELECT NOMEMOTORISTA,
  ZONA,
  MEDIAKM
FROM
  (SELECT M.NOME AS NOMEMOTORISTA,
      Z.ZONA,
      AVG(F.KMIN) AS MEDIAKM,
      COUNT(*) AS CONTAGEMOCORRENCIAS
    FROM MOTORISTA M
    JOIN TAXI T ON M.PLACA = T.PLACA
    JOIN CORRIDA R ON T.PLACA = R.PLACA
    JOIN CLIENTE C ON R.CLIID = C.CLIID
    JOIN FILA F ON M.CNH = F.CNH
    JOIN ZONA Z ON F.ZONA = Z.ZONA
    GROUP BY M.NOME,
      Z.ZONA
    HAVING COUNT(*) > 1) AS SUBCONSULTA
WHERE MEDIAKM % 2 = 0;

--A consulta SQL acima é utilizada para retornar o apenas o nome do motorista, a zona onde a corrida ocorreu e a média de quilômetros percorridos por cada motorista em cada zona 
--apenas para os motoristas que tiveram mais de uma ocorrência de corrida e que possua a média de quilometragem sendo um número par. Com base nesses dados, foram criado os índices:
--Indice Hash no campo CNH da tabela Motorista
CREATE INDEX IDX_HASH_MOTORISTA_CNH ON MOTORISTA USING HASH(CNH);
--Indice Btree no campo Zona 
CREATE INDEX IDX_BTREE_ZONA_ZONA ON ZONA USING BTREE(ZONA);
--Indice multi colunas nos campos CliId e Placa na tabela Corrida
CREATE INDEX IDX_CLIID_PLACA ON CORRIDA(CLIID, PLACA);
--Indice BRIN no campo Placa da tabela Motorista
CREATE INDEX IDX_BRIN_PLACA ON MOTORISTA USING BRIN (PLACA);
--Indice GIN + Essa extensão pg_trgm define a classe de operadores necessária para índices GIN em strings.
CREATE EXTENSION IF NOT EXISTS PG_TRGM;
CREATE INDEX IDX_GIN_PLACA ON CORRIDA USING GIN (PLACA GIN_TRGM_OPS);

