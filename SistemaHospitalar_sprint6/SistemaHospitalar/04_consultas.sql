SELECT c.id_consulta, p.nome AS paciente, m.nome AS medico, c.data_consulta, c.status
FROM consulta c
JOIN paciente p ON p.cpf = c.cpf_paciente
JOIN medico m ON m.crm = c.crm_medico
ORDER BY c.data_consulta;

SELECT p.nome AS paciente, m.nome AS medico, d.descricao, d.gravidade
FROM diagnostico d
JOIN consulta c ON c.id_consulta = d.id_consulta
JOIN paciente p ON p.cpf = c.cpf_paciente
JOIN medico m ON m.crm = c.crm_medico;

SELECT m.crm, m.nome, COUNT(c.id_consulta) AS total_consultas
FROM medico m
LEFT JOIN consulta c ON c.crm_medico = m.crm
GROUP BY m.crm, m.nome
ORDER BY total_consultas DESC;

SELECT forma_pagamento, COUNT(*) AS quantidade, SUM(valor) AS faturamento
FROM pagamento
GROUP BY forma_pagamento
ORDER BY faturamento DESC;

SELECT m.crm, m.nome, COUNT(c.id_consulta) AS total
FROM medico m
JOIN consulta c ON c.crm_medico = m.crm
GROUP BY m.crm, m.nome
HAVING COUNT(c.id_consulta) >= 1;

SELECT nome
FROM paciente
WHERE cpf IN (SELECT cpf_paciente FROM consulta);

SELECT nome, preco_consulta
FROM medico m
WHERE preco_consulta > (SELECT AVG(m2.preco_consulta) FROM medico m2);

SELECT nome, principio_ativo, estoque
FROM medicamento
WHERE id_medicamento IN (SELECT id_medicamento FROM receita);

SELECT med.nome, COUNT(r.id_receita) AS total_receitas
FROM medicamento med
LEFT JOIN receita r ON r.id_medicamento = med.id_medicamento
GROUP BY med.id_medicamento, med.nome
ORDER BY total_receitas DESC;


SELECT l.status, COUNT(*) AS quantidade
FROM leito l
GROUP BY l.status;

SELECT p.nome AS paciente, u.nome AS unidade, q.numero AS quarto,
       l.numero AS leito, i.data_entrada, i.status
FROM internacao i
JOIN paciente p ON p.cpf = i.cpf_paciente
JOIN leito l ON l.id_leito = i.id_leito
JOIN quarto q ON q.id_quarto = l.id_quarto
JOIN unidade u ON u.id_unidade = q.id_unidade;

SELECT ROUND(AVG(preco),2) AS media,
       MIN(preco) AS menor,
       MAX(preco) AS maior
FROM consulta;

SELECT id_consulta, preco, total
FROM consulta
WHERE preco > (SELECT AVG(preco) FROM consulta)
ORDER BY preco DESC;

SELECT r.id_receita, p.nome AS paciente, med.nome AS medicamento,
       r.dosagem, r.quantidade
FROM receita r
JOIN consulta c ON c.id_consulta = r.id_consulta
JOIN paciente p ON p.cpf = c.cpf_paciente
JOIN medicamento med ON med.id_medicamento = r.id_medicamento
WHERE r.quantidade >= 2;

SELECT status, COUNT(*) AS quantidade
FROM consulta
GROUP BY status
ORDER BY quantidade DESC;
