--Para realizar a coleta dos dados apresentados na tabela 5, a seguinte consulta SQL foi executada:

SELECT C.NOME AS NOMECLIENTE,
  C.CPF,
  CO.DATAPEDIDO,
  T.PLACA,
  T.MARCA AS MARCATAXI,
  T.MODELO AS MODELOTAXI,
  T.ANOFAB AS ANOFABRICACAO,
  M.CNH,
  M.NOME AS NOMEMOTORISTA,
  Z.ZONA AS ZONAINICIOCORRIDA,
  F.DATAHORAIN AS HORAINICIOCORRIDA,
  F.DATAHORAOUT AS HORAFIMCORRIDA,
  F.KMIN
FROM CORRIDA CO
JOIN CLIENTE C ON CO.CLIID = C.CLIID
JOIN TAXI T ON CO.PLACA = T.PLACA
JOIN MOTORISTA M ON T.PLACA = M.PLACA
JOIN FILA F ON M.CNH = F.CNH
JOIN ZONA Z ON F.ZONA = Z.ZONA
WHERE C.NOME LIKE '%i%'
  AND M.CNH IN
    (SELECT CNH
      FROM MOTORISTA
      WHERE CNHVALID = 1)
  AND F.DATAHORAIN BETWEEN '01-01-1999' AND '31-12-2023'
  AND CO.DATAPEDIDO > CURRENT_DATE - INTERVAL '12 month'
ORDER BY F.DATAHORAIN DESC;

--A consulta SQL acima é utilizada para retornar dados de todas as tabelas filtrando por nomes de clientes que contenham 'i', 
--motoristas que possuam CNH valida, data do pedido entre '01-01-1999' e '31-12-2023' e também que a data o pedido tenha sido feita nos últimos 12 meses.. Com base nesses dados, foram criado os índices:

--Indice Hash no campo CliId da tabela Corrida
CREATE INDEX idx_hash_corrida_cliid ON Corrida USING hash(CliId);
--Indice Btree no campo Placa da tabela taxi
CREATE INDEX idx_btree_taxi_placa ON Taxi USING BTREE(Placa);
--Indice multi colunas nos campos CliId e Placa da tabela corrida
create index idx_cliId_placa on corrida(cliId, placa);
--Indice BRIN no campo DataHoraIn da tabela Fila
create index idx_brin_datahora on fila using brin(DataHoraIn)
--Indice GIN + extensão pg_trgm define a classe de operadores necessária para índices GIN em strings.
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_gin_placa ON corrida USING gin (placa gin_trgm_ops);
