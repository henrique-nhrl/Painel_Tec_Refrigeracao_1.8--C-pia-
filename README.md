# Projeto Vite com Supabase

Este projeto utiliza Vite com TypeScript e Supabase como banco de dados. Abaixo estão as instruções para configurar e executar a aplicação.

## Estrutura do Projeto

- `docker-compose.yml`: Configuração do Docker Compose para os serviços da aplicação.
- `Dockerfile`: Dockerfile para a aplicação principal.
- `Dockerfile.migration`: Dockerfile para o serviço de migrações.
- `scripts/run-migration.js`: Script para executar as migrações no banco de dados Supabase.
- `supabase/migrations`: Diretório contendo os arquivos de migração SQL.

## Variáveis de Ambiente

Certifique-se de definir as seguintes variáveis de ambiente no seu arquivo `.env`:

```
SUPABASE_URL=
SUPABASE_KEY=
VITE_SUPABASE_ANON_KEY=
VITE_API_BASE_URL=
VITE_SUPPORT_API_KEY=
SUPABASE_DB_HOST=
SUPABASE_DB_NAME=
SUPABASE_DB_PASSWORD=
SUPABASE_DB_PORT=5432
SUPABASE_DB_USER=
```

## Executando a Aplicação

1. **Construir e iniciar os serviços**:
   ```bash
   docker-compose up --build
   ```

2. **Executar migrações**:
   As migrações serão aplicadas automaticamente ao iniciar o serviço de migrações. Para executar manualmente, você pode usar:
   ```bash
   docker-compose run migrations
   ```

## Controle de Migrações

As migrações são registradas na tabela `migracoes_do_sistema`, que contém as seguintes colunas:

- `ID`: Identificador único da migração.
- `Timestamp`: Data e hora da migração.
- `Titulo`: Título da migração (extraído do nome do arquivo).
- `Data_aplicacao`: Data em que a migração foi aplicada.

## Contribuições

Sinta-se à vontade para contribuir com melhorias ou correções. Para isso, faça um fork do repositório e envie um pull request.

## Licença

Este projeto está licenciado sob a MIT License.
