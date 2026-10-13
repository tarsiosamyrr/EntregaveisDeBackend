# 🏥 Sistema Hospitalar - Banco de Dados

## 1. Descrição do domínio

O projeto representa um sistema hospitalar para controlar pacientes, médicos, especialidades, convênios, unidades hospitalares, quartos, leitos, consultas, diagnósticos, receitas, medicamentos, internações e pagamentos.

O banco permite acompanhar o atendimento desde o cadastro do paciente e do médico até a consulta, diagnóstico, prescrição, internação e pagamento.

**SGBD utilizado:** PostgreSQL.

## 2. Modelo lógico

O modelo foi ampliado a partir das entidades originais, preservando **PACIENTE, MEDICO, CONSULTA, DIAGNOSTICO e RECEITA** e adicionando entidades necessárias para representar melhor o domínio.

### Tabelas e principais relacionamentos

- **PACIENTE**: PK `cpf`.
- **MEDICO**: PK `crm`.
- **ESPECIALIDADE**: PK `id_especialidade`.
- **CONVENIO**: PK `id_convenio`.
- **UNIDADE**: PK `id_unidade`.
- **QUARTO**: PK `id_quarto`, FK `id_unidade`.
- **LEITO**: PK `id_leito`, FK `id_quarto`.
- **MEDICAMENTO**: PK `id_medicamento`.
- **CONSULTA**: PK `id_consulta`, FKs `cpf_paciente`, `crm_medico` e `id_convenio`.
- **DIAGNOSTICO**: PK `id_diagnostico`, FK `id_consulta`.
- **RECEITA**: PK `id_receita`, FKs `id_consulta` e `id_medicamento`.
- **INTERNACAO**: PK `id_internacao`, FKs `cpf_paciente`, `id_leito` e `crm_medico_responsavel`.
- **PAGAMENTO**: PK `id_pagamento`, FK `id_consulta`.

### Cardinalidades principais

- PACIENTE 1:N CONSULTA
- MEDICO 1:N CONSULTA
- CONVENIO 1:N CONSULTA
- CONSULTA 1:N DIAGNOSTICO
- CONSULTA 1:N RECEITA
- MEDICAMENTO 1:N RECEITA
- UNIDADE 1:N QUARTO
- QUARTO 1:N LEITO
- PACIENTE 1:N INTERNACAO
- LEITO 1:N INTERNACAO
- MEDICO 1:N INTERNACAO
- CONSULTA 1:1 PAGAMENTO

## 3. Modelo físico e restrições

O arquivo `01_ddl.sql` possui **14 tabelas**, superando o mínimo de 10.

Foram utilizados:

- **PK:** identificação única de cada registro.
- **FK:** integridade referencial entre as entidades.
- **NOT NULL:** campos obrigatórios.
- **UNIQUE:** usuários, nomes de entidades e combinações que não podem se repetir.
- **CHECK:** validação de preços, estoque, percentuais, status, sexo e datas.
- **DEFAULT:** valores automáticos para campos como ativo, status e datas.
- **Colunas geradas:** `imposto` e `total` da consulta são calculados automaticamente a partir do preço.

O arquivo `02_inserts.sql` contém **15 registros em cada uma das 14 tabelas**, totalizando 210 registros.

## 4. Justificativa das escolhas

A separação das entidades evita concentrar informações diferentes em uma única tabela e reduz redundância.

- **Paciente e médico** mantêm dados cadastrais.
- **Consulta** registra o atendimento e relaciona paciente, médico e convênio.
- **Diagnóstico e receita** ficam separados porque uma consulta pode gerar mais de um registro clínico ou prescrição.
- **Medicamento** permite reutilização do cadastro de medicamentos em várias receitas.
- **Unidade, quarto e leito** representam a estrutura física hospitalar.
- **Internação** registra o uso dos leitos e o médico responsável.
- **Pagamento** separa o controle financeiro do atendimento.
- **Índices** foram criados principalmente em FKs e colunas usadas em filtros, JOINs e consultas de agrupamento.

## 5. Índices criados

Arquivo: `03_indices.sql`.

1. `idx_consulta_paciente`: acelera consultas e JOINs por paciente.
2. `idx_consulta_medico_data`: auxilia filtros por médico e ordenação por data.
3. `idx_consulta_status`: auxilia filtros por situação da consulta.
4. `idx_diagnostico_consulta`: acelera busca de diagnósticos por consulta.
5. `idx_receita_consulta`: acelera busca de receitas por consulta.
6. `idx_internacao_paciente_status`: auxilia busca de internações ativas de pacientes.
7. `idx_internacao_leito`: auxilia consultas sobre ocupação de leitos.
8. `idx_pagamento_data_status`: auxilia filtros financeiros por data e situação.
9. `idx_medicamento_principio`: auxilia pesquisas pelo princípio ativo.
10. `idx_quarto_unidade`: acelera a relação entre quartos e unidades.

## 6. Consultas SQL

Arquivo: `04_consultas.sql`.

Foram implementadas **15 consultas**, incluindo:

1. JOIN entre consultas, pacientes e médicos.
2. JOIN entre diagnósticos, consultas, pacientes e médicos.
3. GROUP BY para quantidade de consultas por médico.
4. GROUP BY para faturamento por forma de pagamento.
5. GROUP BY + HAVING para médicos com consultas.
6. Subconsulta para pacientes que possuem consultas.
7. Subconsulta para médicos acima do preço médio.
8. Subconsulta para medicamentos prescritos.
9. GROUP BY para quantidade de receitas por medicamento.
10. GROUP BY para situação dos leitos.
11. JOIN múltiplo para internações.
12. Funções de agregação para valores de consultas.
13. Subconsulta para consultas acima da média.
14. JOIN com filtro para receitas.
15. GROUP BY para status das consultas.

Assim, o requisito de 10 ou mais consultas é atendido, com uso de **JOIN, GROUP BY, HAVING, subconsultas e agregações**.

## 7. Transações

Arquivo: `05_transacoes.sql`.

### Transação 1 - COMMIT

Registra o pagamento da consulta e reduz uma unidade do estoque do medicamento. Ao executar `COMMIT`, as alterações são confirmadas.

### Transação 2 - ROLLBACK

Altera temporariamente o status de uma consulta para `Cancelada`. Em seguida, `ROLLBACK` desfaz a alteração. A consulta final verifica que o valor anterior foi preservado.

O projeto demonstra os comandos `BEGIN`, `COMMIT` e `ROLLBACK`.

## 8. Usuários, GRANT, REVOKE e segurança

Arquivo: `06_permissoes.sql`.

A segurança foi organizada em quatro papéis: 

- **hospital_superuser:** administrador real do PostgreSQL, com `SUPERUSER`, `CREATEDB` e `CREATEROLE`. Deve ser usado somente para administração e não pela aplicação.
- **hospital_manager:** gerente do sistema, sem `SUPERUSER` e sem `CREATEDB`, com permissões para consultar, inserir, alterar e excluir dados.
- **medico_user:** pode acessar, inserir, alterar e excluir os dados do sistema, conforme a regra de negócio definida.
- **paciente_user:** pode visualizar informações do atendimento, enviar exames e realizar pagamentos. Não pode alterar ou excluir dados existentes nem administrar cadastros hospitalares.

O paciente tem `INSERT` somente em `exame` e `pagamento`, além de `SELECT` nas informações necessárias. O médico possui `SELECT, INSERT, UPDATE, DELETE` nas tabelas do sistema.

O arquivo também usa `REVOKE` para retirar permissões de escrita e exclusão do paciente.

### Observação de segurança

O `hospital_superuser` é deliberadamente um superusuário real do PostgreSQL porque o requisito solicita essa categoria. Em um ambiente real, a aplicação nunca deveria usar essa conta. Os arquivos versionados não contêm senhas: depois de criar os papéis, defina-as com `\password` no `psql`.

## 9. EXPLAIN (ANALYZE)

Arquivo: `07_explain.sql`.

Foram preparadas três análises com `EXPLAIN (ANALYZE)`.

A análise deve observar:

- `Index Scan` ou `Bitmap Index Scan`, quando o otimizador considerar o índice vantajoso;
- `Seq Scan`, que pode ser escolhido quando a tabela possui poucos registros;
- `actual time`, `rows` e `loops`;
- diferença entre o custo estimado e o tempo real.

Como o projeto possui apenas 15 registros por tabela, é possível que o PostgreSQL prefira `Seq Scan` em algumas consultas. Isso não significa que o índice esteja incorreto. Com volume maior de dados, os índices tendem a se tornar mais relevantes para os filtros e JOINs definidos.

## 10. Organização dos arquivos

A estrutura da Sprint 5 foi mantida e a Sprint 6 acrescenta os itens marcados com ➕.

```text
01_ddl.sql                          -> criação das 14 tabelas e restrições
02_inserts.sql                      -> 15 registros por tabela (210 registros)
03_indices.sql                      -> índices e justificativas
04_consultas.sql                    -> 15 consultas SQL
05_transacoes.sql                   -> transações COMMIT e ROLLBACK
06_criacao_usuarios_postgresql.sql  -> criação dos 4 papéis (sem senhas)
06_permissoes.sql                   -> GRANT e REVOKE
07_explain.sql                      -> EXPLAIN (ANALYZE)
07_explain_postgresql.sql           -> variação do EXPLAIN para PostgreSQL
08_backup.sh                        ➕ backup lógico com pg_dump -Fc
09_cron_backup.txt                  ➕ agendamento diário às 02:00
docs/10_teste_restauracao.md        ➕ restauração em banco de teste + evidências
mongodb/01_modelo_e_dados.js        ➕ banco, 2 collections e 11 documentos
mongodb/02_consultas_indices_explain.js ➕ consultas, índices e explain()
diagrama inicial.png                -> diagrama do modelo
README.md                           -> documentação do projeto
```

## 11. Atendimento aos requisitos

| Requisito | Atendimento |
|---|---|
| Modelo lógico | Sim, documentado no README |
| Modelo físico | Sim |
| 10+ tabelas | **14 tabelas** |
| PK | Sim |
| FK | Sim |
| NOT NULL | Sim |
| UNIQUE | Sim |
| CHECK | Sim |
| DEFAULT | Sim |
| 15 registros por tabela | **Sim, 210 registros** |
| Índices justificados | **10 índices** |
| 10+ consultas | **15 consultas** |
| JOIN | Sim |
| GROUP BY | Sim |
| Subconsultas | Sim |
| 2+ transações | **2 transações** |
| BEGIN | Sim |
| COMMIT | Sim |
| ROLLBACK | Sim |
| 2+ usuários | **2 usuários** |
| GRANT | Sim |
| REVOKE | Sim |
| EXPLAIN (ANALYZE) | **3 análises** |
| README completo | Sim |


### Cadastro de CPF e CRM
O `cpf` do paciente e o `crm` do médico são informados no cadastro. Eles são chaves primárias (`PRIMARY KEY`) e não utilizam `GENERATED AS IDENTITY`. O banco apenas valida o formato e garante a unicidade.

A tabela **EXAME** permite que o paciente envie seus exames, relacionando o arquivo ao próprio CPF e, quando aplicável, à consulta. O paciente também pode registrar pagamentos, enquanto o médico pode acessar e alterar os dados do sistema.


## Comentários nos arquivos SQL
Todos os arquivos SQL possuem comentários explicando a função dos principais comandos utilizados, como CREATE TABLE, INSERT, CREATE INDEX, SELECT, JOIN, GROUP BY, HAVING, subconsultas, START TRANSACTION, COMMIT e ROLLBACK, GRANT, REVOKE e EXPLAIN (ANALYZE).


### Compatibilidade no DBeaver

Os arquivos foram preparados para PostgreSQL. No DBeaver, a conexão deve ser PostgreSQL e o dialeto SQL do editor deve estar configurado como PostgreSQL. `EXPLAIN (ANALYZE)`, `CREATE USER`, `GRANT`, `REVOKE` e transações são comandos suportados pelo PostgreSQL.

No DDL, a validação de CPF/CRM usa `CHECK` com `length()` para evitar o operador de expressão regular `~`, que alguns validadores genéricos do DBeaver não reconhecem. CPF e CRM continuam sendo informados manualmente pelo cadastro.

## Execução das permissões no PostgreSQL

O arquivo `06_permissoes.sql` contém somente GRANT/REVOKE. Antes dele, em uma conexão PostgreSQL administrativa, execute `06_criacao_usuarios_postgresql.sql` para criar os quatro usuários.

O arquivo `07_explain.sql` contém `EXPLAIN ANALYZE`, que é requisito do trabalho e é sintaxe específica do PostgreSQL.

Se o DBeaver sublinhar `CREATE USER` ou `EXPLAIN ANALYZE` como erro antes da execução, configure o SQL dialect da conexão/arquivo para PostgreSQL. Esses comandos não são comandos SQL genéricos e não podem ser tornados simultaneamente compatíveis com todos os bancos sem deixar de cumprir o requisito de PostgreSQL.

---

# Sprint 6 — Backup, restauração e introdução ao MongoDB

## 12. Backup lógico automatizado e restauração (PostgreSQL)

### 12.1 O script `08_backup.sh`

O script executa `pg_dump` no **formato customizado (`-Fc`)**, que é comprimido e permite restaurar tabelas isoladamente com `pg_restore`.

| Recurso | Como foi feito |
|---|---|
| Nome com data | `<banco>_AAAAMMDD_HHMMSS.dump` |
| Tratamento de erros | `set -Eeuo pipefail`; variáveis obrigatórias validadas; verificação da existência do `pg_dump`; código de saída diferente de zero em falha |
| Sem backup corrompido | O dump é gravado em `.partial` e só vira `.dump` depois de sucesso; em falha o parcial é apagado (`trap`) |
| Retenção de 30 dias | `find ... -name "<banco>_*.dump" -mtime +30 -delete` (configurável em `RETENTION_DAYS`) — só apaga dumps do próprio banco |
| Segurança | `umask 077` (dump legível só pelo dono); sem senha no script (use `~/.pgpass` ou `PGPASSFILE`, permissão `0600`) |

```bash
chmod +x 08_backup.sh
export PGDATABASE=hospitalar PGUSER=usuario_backup BACKUP_DIR="$HOME/backups/hospitalar"
./08_backup.sh
```

### 12.2 Agendamento com cron

Arquivo `09_cron_backup.txt`. Expressão: **`0 2 * * *`** (minuto 0, hora 2, todo dia, todo mês, qualquer dia da semana = todos os dias às 02:00).

```cron
0 2 * * * /bin/bash -c 'set -a; . "$HOME/.hospitalar_backup.env"; set +a; /caminho/absoluto/08_backup.sh' >> "$HOME/backup-hospitalar.log" 2>&1
```

O cron roda com um ambiente mínimo, por isso as variáveis ficam em um arquivo fora do repositório (`~/.hospitalar_backup.env`, permissão `600`) e o caminho do script é absoluto. A saída (inclusive erros) vai para um log que deve ser monitorado.

### 12.3 Regra 3-2-1

| Regra | Aplicação neste projeto | Situação |
|---|---|---|
| **3** cópias dos dados | Banco em produção + dump local do dia + cópia replicada do dump | O script cobre o dump local; a replicação deve ser configurada |
| **2** tipos de mídia | Disco do servidor de banco e outro meio independente (NAS, disco externo ou armazenamento em nuvem) | A configurar na infraestrutura |
| **1** cópia fora do local | Cópia **criptografada** em outro local físico ou conta de nuvem, com acesso restrito | A configurar na infraestrutura |

O script cobre apenas a primeira cópia. A replicação (por exemplo `rsync` ou `rclone` após o `pg_dump`), a criptografia, o monitoramento e os alertas precisam ser configurados fora dele. Em dados hospitalares, a cópia externa precisa de criptografia e controle de acesso. Um backup só é confiável depois de restaurado com sucesso.

### 12.4 Teste de restauração

O procedimento completo está em [`docs/10_teste_restauracao.md`](docs/10_teste_restauracao.md). Resumo:

```bash
createdb hospitalar_restore_teste
pg_restore --no-owner --no-acl --exit-on-error --dbname=hospitalar_restore_teste ./backups/hospitalar_AAAAMMDD_HHMMSS.dump
```

**Resultado do teste executado (13/10/2026, PostgreSQL 16.15):** o `pg_restore` terminou sem erros e as **14 tabelas** têm a mesma contagem na origem e no banco restaurado (15 linhas cada, **210 no total**). Também coincidiram 36 índices, 14 chaves estrangeiras, 23 constraints `CHECK` e o MD5 do conteúdo da tabela `consulta`. A tabela por tabela está no documento. Os cenários de falha (banco inexistente) e de retenção (31, 5 e 40 dias) do script também foram testados.

## 13. Introdução ao MongoDB

### 13.1 Modelo

Banco `sistema_hospitalar_nosql`, com duas collections relacionadas:

- **`pacientes`** (5 documentos): cadastro do paciente.
- **`consultas`** (6 documentos): atendimentos, ligados ao paciente por `pacienteId`.

Total de **11 documentos**, inseridos por `mongodb/01_modelo_e_dados.js` com dados fictícios. A **flexibilidade de esquema** aparece nos próprios dados: nem todo paciente tem `alergias`, `email` ou `observacaoCadastro`; consultas canceladas têm `motivoCancelamento` e não têm `triagem`; uma consulta tem `anexos`; a triagem da consulta pediátrica registra peso e altura e as demais não. Nada disso exigiu alterar a collection.

```js
// consultas (Referencing + Embedding)
{
  pacienteId: ObjectId("650000000000000000000001"),          // REFERENCING -> pacientes._id
  medico: { crm: "CRM12345", nome: "Ana Souza", especialidade: "Cardiologia" }, // EMBEDDING
  data: ISODate("2026-09-01T12:30:00Z"), status: "realizada",
  diagnosticos: ["hipertensão"],                              // EMBEDDING (array pequeno)
  triagem: { pressao: "130/85", temperaturaC: 36.7 }          // EMBEDDING
}
```

### 13.2 Embedding vs. Referencing

Regra aplicada: **modelar pelo padrão de acesso**. Se os dados são lidos juntos, embutir; se são lidos separadamente ou crescem sem limite, referenciar.

| Dado | Escolha | Justificativa |
|---|---|---|
| `triagem` na consulta | **Embedding** | Pertence a uma única consulta, é pequena, só faz sentido junto dela e tem campos que variam. Uma leitura traz tudo. |
| `diagnosticos` na consulta | **Embedding** | Lista curta e limitada, sempre exibida com a consulta. |
| `medico` na consulta | **Embedding** (cópia dos campos usados) | A tela da consulta precisa de nome e especialidade; evita uma segunda busca. O custo é a duplicação: se o médico mudar de nome, as consultas antigas mantêm o valor da época, o que é desejável como histórico do atendimento. |
| `pacienteId` na consulta | **Referencing** | O paciente é uma entidade com ciclo de vida próprio, acessada sozinha (cadastro) e reutilizada em muitas consultas. Embutir o paciente em cada consulta duplicaria dados pessoais e dificultaria atualizar telefone ou alergias. |
| Consultas dentro de `pacientes` | **Não embutir** | O histórico de consultas cresce sem limite, e um documento tem teto de 16 MB; seria também lido inteiro sem necessidade. |

Quando a escolha deve mudar: se `anexos` passarem a guardar muitos itens ou arquivos grandes, passam para uma collection própria referenciada por `consultaId`. Se o médico passar a ter dados editados com frequência e que precisem refletir em todas as consultas, referenciar `crm`.

### 13.3 Consultas, índices e `explain()`

Execução (com `mongosh` instalado):

```bash
mongosh "mongodb://localhost:27017" mongodb/01_modelo_e_dados.js
mongosh "mongodb://localhost:27017" mongodb/02_consultas_indices_explain.js | tee docs/saida_mongodb.txt
```

`02_consultas_indices_explain.js` contém:

- **Filtros (`find`)**: por prefixo de nome com `$regex`, por campo embutido (`medico.especialidade`) e com operadores (`$exists`, `$not`, `$size`).
- **Ordenação (`sort`)** por data e por nome.
- **Projeção** de campos, incluindo campos aninhados (`"contato.telefone"`, `"medico.nome"`) e exclusão de `_id`.
- **Dois índices**: simples `{ pacienteId: 1 }` e composto `{ status: 1, data: -1 }` (igualdade primeiro, depois ordenação).
- **`explain("executionStats")`** antes e depois dos índices, com um resumo de estágios, `nReturned`, `totalKeysExamined` e `totalDocsExamined`.

Como interpretar: antes dos índices, espera-se `COLLSCAN` (lê todos os documentos). Depois, espera-se `IXSCAN`, e na consulta ordenada o índice composto deve dispensar o estágio `SORT` em memória. Com 6 consultas a diferença de tempo é irrelevante; o que importa é a mudança de plano e de `totalDocsExamined`.

> **Atenção:** os scripts MongoDB tiveram a sintaxe verificada, mas **não foram executados** no ambiente em que este documento foi preparado (não havia `mongod` disponível). Rode-os e guarde a saída em `docs/saida_mongodb.txt` como evidência, conferindo se o plano mudou de `COLLSCAN` para `IXSCAN`.

## 14. PostgreSQL x MongoDB neste domínio

| Necessidade hospitalar | Mais adequado | Motivo |
|---|---|---|
| Consultas, pagamentos, convênios e internações com várias relações | **PostgreSQL** | Chaves estrangeiras, `CHECK` e transações ACID garantem integridade entre entidades; um pagamento não pode existir sem consulta, e o estoque de medicamento deve baixar junto com a receita. |
| Relatórios que cruzam paciente, médico, consulta e pagamento | **PostgreSQL** | JOINs, agregações e `GROUP BY` são o ponto forte do SQL. |
| Controle de acesso por papel (médico, paciente, gerente) sobre tabelas | **PostgreSQL** | `GRANT`/`REVOKE` por tabela, como feito em `06_permissoes.sql`. |
| Triagem e prontuário com campos opcionais e variáveis por especialidade | **MongoDB** | Documentos aceitam campos diferentes sem migração (`ALTER TABLE`) e sem colunas quase sempre nulas. |
| Leitura de uma consulta com seus dados contextuais em uma só operação | **MongoDB** | Com embedding, uma leitura traz o conjunto, sem JOIN. |
| Metadados de anexos, logs de eventos e protótipos de formulários clínicos | **MongoDB** | Estrutura muda com frequência e o volume cresce rápido. |

Para este sistema, o **PostgreSQL deve ser a base principal** (dados cadastrais, financeiros e de internação, onde a integridade é crítica). O MongoDB aparece como complemento para dados clínicos semiestruturados. A escolha não é absoluta: o PostgreSQL também suporta dados semiestruturados com `JSONB`, e o MongoDB também oferece transações multi-documento. A decisão depende dos padrões de acesso e das garantias exigidas. Em ambos, dados clínicos exigem privacidade, auditoria, autorização e retenção adequadas (no Brasil, LGPD).

## 15. Atendimento aos requisitos da Sprint 6

| Requisito | Atendimento | Onde |
|---|---|---|
| Script de backup `08_backup.sh` com `pg_dump -Fc` | Sim | `08_backup.sh` |
| Nome com data, tratamento de erros, retenção de 30 dias | Sim (testado) | `08_backup.sh`, seção 12.1 |
| Agendamento cron diário (2h) | Sim (`0 2 * * *`, testado com ambiente mínimo) | `09_cron_backup.txt`, seção 12.2 |
| Teste de restauração com contagem de registros | Sim, executado: 14 tabelas, 210 registros | `docs/10_teste_restauracao.md`, seção 12.4 |
| Regra 3-2-1 explicada | Sim | Seção 12.3 |
| Banco MongoDB com 2+ collections relacionadas | `pacientes` e `consultas` | `mongodb/01_modelo_e_dados.js` |
| 10+ documentos com flexibilidade de esquema | 11 documentos | Seção 13.1 |
| Embedding e Referencing justificados | Sim | Seção 13.2 |
| `find`, `sort` e projeção | Sim | `mongodb/02_consultas_indices_explain.js` |
| 2+ índices e `explain()` | 2 índices, explain antes e depois | Seção 13.3 (scripts ainda a executar) |
| README com domínio, modelagem, backup/restauração e comparação | Sim | Seções 1–2, 12, 13 e 14 |

> **Antes de entregar:** confirme que o repositório está público (ou com acesso de leitura liberado) e que não há dados pessoais reais nem senhas nos arquivos. Os dados são fictícios.
