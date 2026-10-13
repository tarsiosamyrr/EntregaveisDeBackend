INSERT INTO usuario (nome,email)
SELECT 'Ana Silva','ana.silva@example.com'
WHERE NOT EXISTS (SELECT 1 FROM usuario WHERE email='ana.silva@example.com');

INSERT INTO usuario (nome,email)
SELECT 'Bruno Costa','bruno.costa@example.com'
WHERE NOT EXISTS (SELECT 1 FROM usuario WHERE email='bruno.costa@example.com');

INSERT INTO modelo_ia (nome,tipo,algoritmo,id_usuario)
SELECT 'Classificador de imagens','Visão Computacional','CNN',u.id_usuario
FROM usuario u
WHERE u.email='ana.silva@example.com'
AND NOT EXISTS (SELECT 1 FROM modelo_ia m WHERE m.nome='Classificador de imagens' AND m.id_usuario=u.id_usuario);

INSERT INTO dataset (nome,descricao,tamanho_mb,id_modelo)
SELECT 'Dataset inicial','Conjunto demonstrativo para classificação de imagens',120.00,m.id_modelo
FROM modelo_ia m JOIN usuario u ON u.id_usuario=m.id_usuario
WHERE u.email='ana.silva@example.com' AND m.nome='Classificador de imagens'
AND NOT EXISTS (SELECT 1 FROM dataset d WHERE d.nome='Dataset inicial' AND d.id_modelo=m.id_modelo);

INSERT INTO treinamento (data_inicio,data_fim,status,id_modelo,id_dataset)
SELECT CURRENT_TIMESTAMP-INTERVAL '1 hour',CURRENT_TIMESTAMP,'concluido',m.id_modelo,d.id_dataset
FROM modelo_ia m JOIN usuario u ON u.id_usuario=m.id_usuario
JOIN dataset d ON d.id_modelo=m.id_modelo
WHERE u.email='ana.silva@example.com' AND m.nome='Classificador de imagens' AND d.nome='Dataset inicial'
AND NOT EXISTS (SELECT 1 FROM treinamento t WHERE t.id_modelo=m.id_modelo AND t.id_dataset=d.id_dataset AND t.status='concluido');

ANALYZE usuario;
ANALYZE modelo_ia;
ANALYZE dataset;
ANALYZE treinamento;
