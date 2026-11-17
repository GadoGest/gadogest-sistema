# supabase/ — back-end do GadoGest

Área do back-end (Pedro). Projeto de desenvolvimento: **`gadogest-dev`** (região São Paulo, `sa-east-1`). Ver D-14 e D-15 em `docs/DECISOES.md`.

| Pasta | Conteúdo |
|---|---|
| `migrations/` | Toda mudança de esquema, em ordem. Nunca editar uma migration já aplicada; criar outra. |
| `tests/` | Testes pgTAP (isolamento entre fazendas, papéis, exclusão lógica). |
| `config.toml` | Configuração do Supabase CLI (ambiente local). |

## Comandos (CLI via `npx`, sem instalar nada global)

```bash
npx supabase@3.2.0 login                     # uma vez por máquina
npx supabase@3.2.0 link                      # escolher o gadogest-dev
npx supabase@3.2.0 migration new <nome>      # nova migration
npx supabase@3.2.0 db push --remote --dry-run  # ver o que será aplicado
npx supabase@3.2.0 db push --remote          # aplicar no gadogest-dev
npx supabase@3.2.0 test db --remote          # rodar os testes (precisa de Docker)
npx supabase@3.2.0 gen types typescript --remote --schema public > packages/shared/src/database.types.ts
```

Depois de toda migration: regerar `packages/shared/src/database.types.ts` (nunca editar à mão) e mandar migration + tipos no mesmo PR.
