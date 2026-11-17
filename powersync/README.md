# powersync/ — sincronização (área do back-end, D-29)

| Arquivo | Conteúdo |
|---|---|
| `sync-config.yaml` | Sync Streams: quais dados cada usuário recebe no aparelho. |
| `service.yaml` | Configuração da instância (conexão com o Supabase, login). Gerado por `powersync init cloud`. |
| `cli.yaml` | Liga a pasta à instância. Gerado por `powersync link`. |

Senhas e tokens **nunca** ficam nesses arquivos: entram por variável de ambiente (`!env`).

## Como funciona

- **Leitura (servidor → aparelho):** o PowerSync lê o Postgres do `gadogest-dev` pelo usuário `powersync_role` (só leitura) e pela publicação `powersync`, criados na migration `supabase/migrations/20261117165858_prova_offline.sql`.
- **Escrita (aparelho → servidor):** não passa pelo PowerSync. O app chama a função `sincronizar_teste_animal` do Supabase para cada item da fila (contrato na D-36 em `docs/DECISOES.md`).

## Comandos (CLI via `npx`)

```bash
npx powersync@0.9.0 login             # token pessoal do PowerSync, uma vez por máquina
npx powersync@0.9.0 validate          # confere as regras
npx powersync@0.9.0 deploy --dry-run  # mostra o que vai mudar
npx powersync@0.9.0 deploy            # publica na instância
```
