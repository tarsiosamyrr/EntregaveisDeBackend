# Sprint 4 — Modelagem Física adaptada à Sprint 3

## Cenário
Sistema de gerenciamento de modelos de Inteligência Artificial, com usuários, modelos, datasets, treinamentos, métricas, implantações, predições, feedbacks e permissões.

## Arquivos
- `sql/01_verificar_estrutura.sql`: consulta os metadados.
- `sql/02_indexes.sql`: índices adicionais.
- `sql/03_seed.sql`: dados de demonstração.
- `sql/04_transactions.sql`: transações com `BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT` e `RETURNING`.
- `sql/05_explain_analyze.sql`: consultas de análise.
- `sql/06_security.sql`: exemplo de roles, usuários, `GRANT` e `REVOKE`.

## Colunas confirmadas
- `usuario`: `id_usuario`, `nome`, `email`.
- `modelo_ia`: `id_modelo`, `nome`, `tipo`, `algoritmo`, `id_usuario`.
- `dataset`: `id_dataset`, `nome`, `descricao`, `tamanho_mb`, `id_modelo`.
- `treinamento`: `id_treinamento`, `data_inicio`, `data_fim`, `status`, `id_modelo`, `id_dataset`.
- `metrica`: `id_metrica`, `nome`, `valor`, `data_avaliacao`, `id_treinamento`.
- `predicao`: `id_predicao`, `data_hora`, `entrada`, `resultado`, `id_modelo`.
- `feedback`: `id_feedback`, `descricao`, `nota`, `data_feedback`, `id_predicao`, `id_usuario`.
- `permissao`: `id_permissao`, `tipo`, `id_usuario`, `id_modelo`.

As colunas de `deploy` ainda não foram confirmadas completamente. O script de índices não presume colunas de deploy.

## Indexação
Os índices apoiam buscas por proprietário, datasets de um modelo, histórico de treinamentos, métricas por treinamento, predições por modelo e feedbacks por usuário/predição. Índices têm custo de armazenamento e escrita; valide com consultas reais. PKs e restrições `UNIQUE` já criam índices automaticamente.

## Transações
A transação 1 cria usuário, modelo, dataset e treinamento e passa IDs por `RETURNING`. A transação 2 cria uma predição e seu feedback, usando `SAVEPOINT` e `ROLLBACK TO SAVEPOINT` para desfazer uma alteração temporária. A transação 3 demonstra `ROLLBACK` integral. Execute em ambiente de teste.

## EXPLAIN ANALYZE
Execute `05_explain_analyze.sql` e observe `Index Scan`, `Bitmap Index Scan` ou `Seq Scan`, estimativas, linhas reais e buffers. `Seq Scan` pode ser a opção correta para tabelas pequenas. Não afirme que o índice foi utilizado sem verificar a saída.

## Controle de acesso
O script `06_security.sql` contém marcadores de banco e senhas. Substitua-os e execute com conta administradora. Teste os privilégios conectando-se com cada usuário. O script é um modelo inicial e deve ser revisado conforme as permissões exigidas pela aplicação.

## Ordem sugerida
1. Verificar estrutura.
2. Criar índices.
3. Inserir dados de demonstração.
4. Executar transações.
5. Executar `EXPLAIN ANALYZE`.
6. Revisar e executar o script de segurança.

Os scripts foram adaptados às colunas confirmadas nas conversas. Execute-os no PostgreSQL e registre evidências reais antes da entrega.
