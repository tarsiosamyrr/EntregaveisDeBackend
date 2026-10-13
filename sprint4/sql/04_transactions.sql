BEGIN;
WITH novo_usuario AS (
  INSERT INTO usuario (nome,email)
  VALUES ('Carla Mendes','carla.mendes.sprint4@example.com')
  RETURNING id_usuario
),
novo_modelo AS (
  INSERT INTO modelo_ia (nome,tipo,algoritmo,id_usuario)
  SELECT 'Detector de anomalias Sprint4','Detecção de anomalias','Isolation Forest',id_usuario
  FROM novo_usuario
  RETURNING id_modelo
),
novo_dataset AS (
  INSERT INTO dataset (nome,descricao,tamanho_mb,id_modelo)
  SELECT 'Dataset de anomalias Sprint4','Dataset criado pela transação de demonstração',25.50,id_modelo
  FROM novo_modelo
  RETURNING id_dataset,id_modelo
)
INSERT INTO treinamento (data_inicio,data_fim,status,id_modelo,id_dataset)
SELECT CURRENT_TIMESTAMP,NULL,'na_fila',id_modelo,id_dataset
FROM novo_dataset
RETURNING id_treinamento,id_modelo,id_dataset;
COMMIT;

BEGIN;
WITH modelo_alvo AS (
  SELECT m.id_modelo,m.id_usuario
  FROM modelo_ia m JOIN usuario u ON u.id_usuario=m.id_usuario
  WHERE u.email='ana.silva@example.com' AND m.nome='Classificador de imagens'
  ORDER BY m.id_modelo LIMIT 1
),
nova_predicao AS (
  INSERT INTO predicao (data_hora,entrada,resultado,id_modelo)
  SELECT CURRENT_TIMESTAMP,
         '{"arquivo":"imagem_demo_001.png"}',
         '{"classe":"gato","confianca":0.94}',
         id_modelo
  FROM modelo_alvo
  RETURNING id_predicao,id_modelo
)
INSERT INTO feedback (descricao,nota,data_feedback,id_predicao,id_usuario)
SELECT 'Feedback de demonstração da Sprint 4',5,CURRENT_TIMESTAMP,p.id_predicao,m.id_usuario
FROM nova_predicao p JOIN modelo_alvo m ON m.id_modelo=p.id_modelo
RETURNING id_feedback,id_predicao,id_usuario;

SAVEPOINT antes_alteracao_feedback;
UPDATE feedback
SET descricao='ALTERAÇÃO TEMPORÁRIA - será desfeita'
WHERE descricao='Feedback de demonstração da Sprint 4';
ROLLBACK TO SAVEPOINT antes_alteracao_feedback;
RELEASE SAVEPOINT antes_alteracao_feedback;
COMMIT;

BEGIN;
UPDATE treinamento SET status='cancelado'
WHERE id_treinamento=(
  SELECT t.id_treinamento FROM treinamento t
  JOIN modelo_ia m ON m.id_modelo=t.id_modelo
  WHERE m.nome='Detector de anomalias Sprint4'
  ORDER BY t.id_treinamento DESC LIMIT 1
);
ROLLBACK;
