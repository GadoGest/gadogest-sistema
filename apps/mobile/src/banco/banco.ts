import { PowerSyncDatabase } from '@powersync/react-native';
import { esquema } from './esquema';

// Banco SQLite local do aparelho. Tudo é gravado primeiro aqui e fica na fila
// de envio; o envio ao servidor acontece quando há login e internet
// (ver src/servidor/conector.ts).
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

/**
 * Edita o nome de um animal de teste. Toda edição sobe `versao` em 1 no mesmo
 * UPDATE (D-36): é assim que o servidor detecta edição feita em dois aparelhos.
 */
export async function editarAnimalDeTeste(id: string): Promise<void> {
  const agora = new Date().toISOString();
  const hora = new Date().toLocaleTimeString('pt-BR');
  await banco.execute(
    `UPDATE teste_animais
       SET nome = ?, versao = versao + 1, atualizado_em = ?
     WHERE id = ?`,
    [`Editado às ${hora}`, agora, id],
  );
}
