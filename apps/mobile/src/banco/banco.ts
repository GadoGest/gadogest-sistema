import { PowerSyncDatabase } from '@powersync/react-native';
import { esquema } from './esquema';

// Banco SQLite local do aparelho. Ainda sem conexão com o servidor:
// nesta fase tudo é gravado só no celular e fica na fila de envio.
export const banco = new PowerSyncDatabase({
  schema: esquema,
  database: { dbFilename: 'gadogest.db' },
});

// Fazenda fictícia usada só na prova técnica.
export const FAZENDA_DE_TESTE = '00000000-0000-4000-8000-000000000001';

/** Grava um animal de teste. O UUID é gerado no próprio aparelho. */
export async function registrarAnimalDeTeste(): Promise<void> {
  const agora = new Date().toISOString();
  const brinco = `T-${Date.now().toString().slice(-6)}`;
  await banco.execute(
    `INSERT INTO teste_animais (id, fazenda_id, brinco, nome, versao, criado_em, atualizado_em)
     VALUES (uuid(), ?, ?, ?, 1, ?, ?)`,
    [FAZENDA_DE_TESTE, brinco, `Animal ${brinco}`, agora, agora],
  );
}
