import type {
  AbstractPowerSyncDatabase,
  PowerSyncBackendConnector,
  PowerSyncCredentials,
} from '@powersync/react-native';
import { supabase } from './supabase';

const urlPowerSync = process.env.EXPO_PUBLIC_POWERSYNC_URL;

if (!urlPowerSync) {
  throw new Error('Falta EXPO_PUBLIC_POWERSYNC_URL no apps/mobile/.env (ver .env.example).');
}

/** Resposta da função `sincronizar_teste_animal` (contrato da D-36). */
type RespostaEnvio = {
  resultado: 'aplicado' | 'ja_aplicado' | 'conflito' | 'rejeitado';
  motivo?: string;
  id?: string;
};

/**
 * Liga o banco local ao servidor:
 * - leitura (servidor → aparelho) pelo PowerSync, com o login do Supabase;
 * - envio (aparelho → servidor) pela função do Supabase, um item da fila por vez.
 */
export class ConectorSupabase implements PowerSyncBackendConnector {
  async fetchCredentials(): Promise<PowerSyncCredentials | null> {
    const { data, error } = await supabase.auth.getSession();
    // Erro temporário (ex.: sem internet): lança para o PowerSync tentar de novo depois.
    if (error) throw error;
    if (!data.session) return null;

    return {
      endpoint: urlPowerSync!,
      token: data.session.access_token,
      expiresAt: data.session.expires_at ? new Date(data.session.expires_at * 1000) : undefined,
    };
  }

  async uploadData(banco: AbstractPowerSyncDatabase): Promise<void> {
    const transacao = await banco.getNextCrudTransaction();
    if (!transacao) return;

    for (const op of transacao.crud) {
      if (op.table !== 'teste_animais') {
        // Só existe esta tabela na prova técnica. Erro aqui mantém o item na fila
        // (nada é perdido) até o app saber enviá-lo.
        throw new Error(`Envio ainda não implementado para a tabela ${op.table}.`);
      }

      const { data, error } = await supabase.rpc('sincronizar_teste_animal', {
        p_operacao: op.op,
        p_id: op.id,
        p_dados: op.opData ?? {},
      });

      // Falha de rede ou de login: NÃO completa a transação; o PowerSync tenta de novo.
      // Reenviar o que já foi aceito é seguro: o servidor responde "ja_aplicado" (D-36).
      if (error) throw error;

      const resposta = data as RespostaEnvio;
      if (resposta.resultado === 'conflito' || resposta.resultado === 'rejeitado') {
        // O servidor guardou o caso em pendencias_sincronizacao para o gestor decidir.
        console.warn(
          `Envio de ${op.id}: ${resposta.resultado}${resposta.motivo ? ` (${resposta.motivo})` : ''}`,
        );
      }
    }

    // Qualquer resultado da função significa "processado": o item sai da fila.
    await transacao.complete();
  }
}

export const conector = new ConectorSupabase();
