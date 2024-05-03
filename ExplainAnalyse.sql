CREATE OR REPLACE FUNCTION get_explain_analyze_result_JSON(query_text TEXT)
RETURNS JSON AS $$
DECLARE
    result_text JSON;
BEGIN
--Executa o EXPLAIN ANALYZE
    EXECUTE 'EXPLAIN (ANALYZE, format json) ' || query_text INTO result_text;
--Retorna o resultado
    RETURN result_text;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
  V_SQL TEXT; --Variável que vai armazenar a SQL de consulta
  V_RESULT_JSON JSON; --Resultado do explain analyse
  V_TIME FLOAT; --Tempo de execução da consulta
  V_COST FLOAT; --Custo de recursos para executar a consulta
BEGIN
--Coloca a consulta na variável pra executar
  V_SQL := 'consulta'
     
--executar 100x    
  for i in 1..100 loop    
    SELECT get_explain_analyze_result_JSON(V_SQL) into V_RESULT_JSON;
    V_TIME := CAST(((V_RESULT_JSON::jsonb)-> 0 -> 'Execution Time') AS FLOAT);
    V_COST := CAST(((V_RESULT_JSON::jsonb)-> 0 -> 'Plan' -> 'Total Cost') AS FLOAT);
   
    INSERT INTO tbl_time_consult1 VALUES(i, V_TIME, V_COST); 
--insere o tempo e o custo na tbl_time_consult1
  END LOOP;
END $$;
