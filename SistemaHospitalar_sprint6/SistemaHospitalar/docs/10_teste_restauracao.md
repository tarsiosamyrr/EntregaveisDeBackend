# Teste de restauração PostgreSQL

> Execute sempre em ambiente de teste. O processo abaixo cria um banco **separado** (`hospitalar_restore_teste`) e nunca deve apontar para produção.

## 1. Pré-requisitos

- Cliente PostgreSQL instalado (`createdb`, `pg_restore`, `psql`).
- Um arquivo `.dump` criado por `08_backup.sh` (formato customizado `-Fc`).
- Permissão para criar banco de teste.

## 2. Procedimento

```bash
# 1) Gerar o backup (banco de origem: hospitalar)
export PGDATABASE=hospitalar PGUSER=postgres BACKUP_DIR=./backups
./08_backup.sh

# 2) Criar o banco de teste e restaurar
createdb hospitalar_restore_teste
pg_restore --verbose --no-owner --no-acl --exit-on-error \
  --dbname=hospitalar_restore_teste \
  ./backups/hospitalar_AAAAMMDD_HHMMSS.dump
```

Observações:

- Como o dump usa `-Fc`, a restauração é feita com `pg_restore`. O `psql` só serve para dumps em SQL texto (`pg_dump -Fp`).
- `--exit-on-error` faz o `pg_restore` parar no primeiro erro, em vez de concluir uma restauração parcial sem avisar.
- Se o banco de teste já existir, use outro nome ou remova-o somente após confirmar que não contém dados necessários.

## 3. Validação de integridade

Consulta usada nos dois bancos (origem e restaurado) para contar as linhas de todas as tabelas do schema `public`:

```sql
SELECT t.table_name,
       (xpath('/row/c/text()',
              query_to_xml(format('select count(*) as c from public.%I', t.table_name), false, true, '')))[1]::text::int AS linhas
FROM information_schema.tables t
WHERE t.table_schema = 'public' AND t.table_type = 'BASE TABLE'
ORDER BY 1;
```

Uma verificação de conteúdo (não só de contagem) para a tabela `consulta`:

```sql
SELECT md5(string_agg(t::text, '|' ORDER BY t::text)) FROM consulta t;
```

## 4. Evidências da execução

Teste executado em **13/10/2026** com **PostgreSQL 16.15** (Ubuntu), a partir dos arquivos `01_ddl.sql`, `02_inserts.sql` e `03_indices.sql` do projeto.

- Dump gerado por `08_backup.sh`: `hospitalar_20261013_173605.dump` (42 179 bytes, permissão `600`).
- `pg_restore --no-owner --no-acl --exit-on-error` terminou com **código de saída 0**, sem erros.

| Tabela | Origem | Restaurado | Resultado |
|---|---:|---:|---|
| `consulta` | 15 | 15 | OK |
| `convenio` | 15 | 15 | OK |
| `diagnostico` | 15 | 15 | OK |
| `especialidade` | 15 | 15 | OK |
| `exame` | 15 | 15 | OK |
| `internacao` | 15 | 15 | OK |
| `leito` | 15 | 15 | OK |
| `medicamento` | 15 | 15 | OK |
| `medico` | 15 | 15 | OK |
| `paciente` | 15 | 15 | OK |
| `pagamento` | 15 | 15 | OK |
| `quarto` | 15 | 15 | OK |
| `receita` | 15 | 15 | OK |
| `unidade` | 15 | 15 | OK |
| **Total** | **210** | **210** | **OK** |

Verificações adicionais, todas idênticas entre origem e restauração:

| Verificação | Origem | Restaurado |
|---|---:|---:|
| Índices no schema `public` | 36 | 36 |
| Chaves estrangeiras | 14 | 14 |
| Constraints `CHECK` | 23 | 23 |
| MD5 do conteúdo de `consulta` | `381fd800fef8a5805fb0a94cf0d4b166` | `381fd800fef8a5805fb0a94cf0d4b166` |

## 5. Testes do próprio script de backup

| Cenário | Resultado esperado | Resultado obtido |
|---|---|---|
| Backup normal | Arquivo `hospitalar_<data>_<hora>.dump`, código de saída 0 | OK |
| Banco inexistente (`PGDATABASE=nao_existe`) | Mensagem de erro, código de saída 1, nenhum arquivo `.dump` ou `.partial` deixado | OK (exit 1, sem arquivo parcial) |
| Retenção: dump do mesmo banco com 31 dias | Removido | OK |
| Retenção: dump do mesmo banco com 5 dias | Mantido | OK |
| Retenção: dump de **outro** banco com 40 dias | Mantido (a limpeza só atinge `<PGDATABASE>_*.dump`) | OK |

## 6. Repetindo o teste

Faça este teste periodicamente (por exemplo, mensalmente) e sempre que alterar o esquema. Registre data, nome do dump, versão do PostgreSQL e o resultado da comparação. Ao terminar, remova o banco de teste:

```bash
dropdb hospitalar_restore_teste
```
