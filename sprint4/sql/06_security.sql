CREATE ROLE lia_leitura NOLOGIN;
CREATE ROLE app_ia LOGIN PASSWORD 'SUBSTITUA_POR_SENHA_FORTE_APP';
GRANT CONNECT ON DATABASE nome_do_banco TO app_ia;
GRANT USAGE ON SCHEMA public TO app_ia;
GRANT SELECT,INSERT,UPDATE ON modelo_ia,dataset,treinamento,metrica,deploy,predicao,feedback TO app_ia;
GRANT SELECT ON usuario,permissao TO app_ia;

CREATE ROLE analista_ia LOGIN PASSWORD 'SUBSTITUA_POR_SENHA_FORTE_ANALISTA';
GRANT CONNECT ON DATABASE nome_do_banco TO analista_ia;
GRANT USAGE ON SCHEMA public TO analista_ia;
GRANT SELECT ON usuario,modelo_ia,dataset,treinamento,metrica,deploy,predicao,feedback,permissao TO lia_leitura;
GRANT lia_leitura TO analista_ia;
REVOKE INSERT,UPDATE,DELETE ON usuario,modelo_ia,dataset,treinamento,metrica,deploy,predicao,feedback,permissao FROM analista_ia;
