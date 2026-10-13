ANALYZE modelo_ia;
ANALYZE treinamento;
ANALYZE predicao;

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT m.id_modelo,m.nome,m.tipo,m.algoritmo
FROM modelo_ia m JOIN usuario u ON u.id_usuario=m.id_usuario
WHERE u.email='ana.silva@example.com'
ORDER BY m.id_modelo DESC
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT t.id_treinamento,t.data_inicio,t.data_fim,t.status
FROM treinamento t
WHERE t.id_modelo=(
  SELECT m.id_modelo FROM modelo_ia m
  WHERE m.nome='Classificador de imagens'
  ORDER BY m.id_modelo LIMIT 1
)
AND t.status='concluido'
ORDER BY t.data_inicio DESC
LIMIT 20;
