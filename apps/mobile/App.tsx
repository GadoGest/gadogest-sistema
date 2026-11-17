import { PowerSyncContext, useQuery, useStatus } from '@powersync/react-native';
import { StatusBar } from 'expo-status-bar';
import { useEffect, useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { banco, registrarAnimalDeTeste } from './src/banco/banco';
import type { TesteAnimal } from './src/banco/esquema';

// Tela provisória da prova técnica (Etapa 0): grava no SQLite local e mostra
// quantos registros ainda não foram enviados ao servidor.
function TelaDeTeste() {
  const status = useStatus();
  const [erro, setErro] = useState<string | null>(null);
  const { data: animais } = useQuery<TesteAnimal>(
    'SELECT * FROM teste_animais ORDER BY criado_em DESC',
  );
  const [pendentes, setPendentes] = useState(0);

  // A fila de envio muda a cada gravação; recalcula quando a lista muda.
  useEffect(() => {
    banco
      .getUploadQueueStats()
      .then((fila) => setPendentes(fila.count))
      .catch((e: unknown) => setErro(String(e)));
  }, [animais]);

  async function aoRegistrar() {
    try {
      setErro(null);
      await registrarAnimalDeTeste();
    } catch (e) {
      setErro(String(e));
    }
  }

  return (
    <View style={styles.container}>
      <Text style={styles.titulo}>GadoGest</Text>
      <Text style={styles.texto}>Prova técnica — banco local</Text>

      <View style={styles.cartao}>
        <Text style={styles.cartaoTexto}>
          Servidor: {status.connected ? 'conectado' : 'sem conexão'}
        </Text>
        <Text style={styles.cartaoTexto}>Animais no aparelho: {animais.length}</Text>
        <Text style={styles.cartaoTexto}>Pendentes de envio: {pendentes}</Text>
      </View>

      <Pressable style={styles.botao} onPress={aoRegistrar}>
        <Text style={styles.botaoTexto}>Registrar animal de teste</Text>
      </Pressable>

      {erro ? <Text style={styles.erro}>Erro: {erro}</Text> : null}

      <FlatList
        style={styles.lista}
        data={animais}
        keyExtractor={(animal) => animal.id}
        renderItem={({ item }) => (
          <View style={styles.linha}>
            <Text style={styles.linhaTitulo}>{item.brinco}</Text>
            <Text style={styles.linhaId}>{item.id}</Text>
          </View>
        )}
      />
      <StatusBar style="light" />
    </View>
  );
}

export default function App() {
  return (
    <PowerSyncContext.Provider value={banco}>
      <TelaDeTeste />
    </PowerSyncContext.Provider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#14532d',
    paddingTop: 72,
    paddingHorizontal: 20,
    gap: 12,
  },
  titulo: { color: '#ffffff', fontSize: 32, fontWeight: '700' },
  texto: { color: '#dcfce7', fontSize: 18 },
  cartao: { backgroundColor: '#166534', borderRadius: 12, padding: 16, gap: 6 },
  cartaoTexto: { color: '#ffffff', fontSize: 18 },
  botao: {
    backgroundColor: '#22c55e',
    borderRadius: 12,
    paddingVertical: 20,
    alignItems: 'center',
  },
  botaoTexto: { color: '#052e16', fontSize: 20, fontWeight: '700' },
  erro: { color: '#fecaca', fontSize: 16 },
  lista: { flex: 1 },
  linha: { borderBottomColor: '#166534', borderBottomWidth: 1, paddingVertical: 10 },
  linhaTitulo: { color: '#ffffff', fontSize: 18, fontWeight: '600' },
  linhaId: { color: '#bbf7d0', fontSize: 12 },
});
