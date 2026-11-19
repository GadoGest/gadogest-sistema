import { PowerSyncContext, useQuery, useStatus } from '@powersync/react-native';
import type { Session } from '@supabase/supabase-js';
import { StatusBar } from 'expo-status-bar';
import { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  FlatList,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { banco, editarAnimalDeTeste, registrarAnimalDeTeste } from './src/banco/banco';
import type { TesteAnimal } from './src/banco/esquema';
import { conector } from './src/servidor/conector';
import { supabase } from './src/servidor/supabase';

// Login provisório da prova técnica (Etapa 0): e-mail e senha pelo Supabase Auth (D-02).
// O primeiro login precisa de internet; depois a sessão fica guardada no aparelho.
function TelaDeLogin() {
  const [email, setEmail] = useState('');
  const [senha, setSenha] = useState('');
  const [entrando, setEntrando] = useState(false);
  const [erro, setErro] = useState<string | null>(null);

  async function aoEntrar() {
    setErro(null);
    setEntrando(true);
    const { error } = await supabase.auth.signInWithPassword({
      email: email.trim(),
      password: senha,
    });
    setEntrando(false);
    if (error) {
      setErro(
        error.message === 'Invalid login credentials'
          ? 'E-mail ou senha incorretos.'
          : `Não foi possível entrar: ${error.message}`,
      );
    }
  }

  return (
    <View style={styles.container}>
      <Text style={styles.titulo}>GadoGest</Text>
      <Text style={styles.texto}>Entre com seu e-mail e senha</Text>

      <TextInput
        style={styles.campo}
        placeholder="E-mail"
        placeholderTextColor="#6b7280"
        autoCapitalize="none"
        autoComplete="email"
        keyboardType="email-address"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        style={styles.campo}
        placeholder="Senha"
        placeholderTextColor="#6b7280"
        secureTextEntry
        autoComplete="password"
        value={senha}
        onChangeText={setSenha}
      />

      <Pressable
        style={[styles.botao, entrando && styles.botaoDesativado]}
        onPress={aoEntrar}
        disabled={entrando || !email || !senha}
      >
        {entrando ? (
          <ActivityIndicator color="#052e16" />
        ) : (
          <Text style={styles.botaoTexto}>Entrar</Text>
        )}
      </Pressable>

      {erro ? <Text style={styles.erro}>{erro}</Text> : null}
      <StatusBar style="light" />
    </View>
  );
}

// Tela provisória da prova técnica (Etapa 0): grava no SQLite local, mostra quantos
// registros ainda não foram enviados e envia ao servidor quando há internet.
function TelaDeTeste({ email }: { email: string }) {
  const status = useStatus();
  const [erro, setErro] = useState<string | null>(null);
  const { data: animais } = useQuery<TesteAnimal>(
    'SELECT * FROM teste_animais ORDER BY criado_em DESC',
  );
  const [pendentes, setPendentes] = useState(0);

  // A fila muda a cada gravação e a cada envio; recalcula nos dois casos.
  useEffect(() => {
    banco
      .getUploadQueueStats()
      .then((fila) => setPendentes(fila.count))
      .catch((e: unknown) => setErro(String(e)));
  }, [animais, status]);

  async function executar(acao: () => Promise<void>) {
    try {
      setErro(null);
      await acao();
    } catch (e) {
      setErro(String(e));
    }
  }

  return (
    <View style={styles.container}>
      <Text style={styles.titulo}>GadoGest</Text>
      <Text style={styles.texto}>Prova técnica — {email}</Text>

      <View style={styles.cartao}>
        <Text style={styles.cartaoTexto}>
          Servidor: {status.connected ? 'conectado' : 'sem conexão'}
          {status.dataFlowStatus.uploading ? ' (enviando…)' : ''}
        </Text>
        <Text style={styles.cartaoTexto}>Animais no aparelho: {animais.length}</Text>
        <Text style={styles.cartaoTexto}>Pendentes de envio: {pendentes}</Text>
      </View>

      <Pressable style={styles.botao} onPress={() => executar(registrarAnimalDeTeste)}>
        <Text style={styles.botaoTexto}>Registrar animal de teste</Text>
      </Pressable>

      {erro ? <Text style={styles.erro}>Erro: {erro}</Text> : null}

      <Text style={styles.dica}>Toque num animal para editar o nome.</Text>
      <FlatList
        style={styles.lista}
        data={animais}
        keyExtractor={(animal) => animal.id}
        renderItem={({ item }) => (
          <Pressable
            style={styles.linha}
            onPress={() => executar(() => editarAnimalDeTeste(item.id))}
          >
            <Text style={styles.linhaTitulo}>
              {item.brinco} · {item.nome}
            </Text>
            <Text style={styles.linhaId}>
              versão {item.versao} · {item.id}
            </Text>
          </Pressable>
        )}
      />

      <Pressable
        style={styles.botaoSair}
        onPress={() =>
          executar(async () => {
            await supabase.auth.signOut();
          })
        }
      >
        <Text style={styles.botaoSairTexto}>Sair</Text>
      </Pressable>
      <StatusBar style="light" />
    </View>
  );
}

export default function App() {
  // undefined = ainda lendo a sessão guardada no aparelho.
  const [sessao, setSessao] = useState<Session | null | undefined>(undefined);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => setSessao(data.session));
    const { data } = supabase.auth.onAuthStateChange((_evento, novaSessao) => {
      setSessao(novaSessao);
    });
    return () => data.subscription.unsubscribe();
  }, []);

  const logado = !!sessao;

  // Com login, liga o banco local ao servidor. Ao sair, só desliga: os dados e a
  // fila de pendentes continuam no aparelho (nada é perdido).
  useEffect(() => {
    if (logado) {
      void banco.connect(conector);
    } else {
      void banco.disconnect();
    }
  }, [logado]);

  if (sessao === undefined) {
    return (
      <View style={[styles.container, styles.centro]}>
        <ActivityIndicator color="#ffffff" size="large" />
      </View>
    );
  }

  return (
    <PowerSyncContext.Provider value={banco}>
      {sessao ? <TelaDeTeste email={sessao.user.email ?? ''} /> : <TelaDeLogin />}
    </PowerSyncContext.Provider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#14532d',
    paddingTop: 72,
    paddingHorizontal: 20,
    paddingBottom: 24,
    gap: 12,
  },
  centro: { justifyContent: 'center', alignItems: 'center' },
  titulo: { color: '#ffffff', fontSize: 32, fontWeight: '700' },
  texto: { color: '#dcfce7', fontSize: 18 },
  dica: { color: '#bbf7d0', fontSize: 14 },
  campo: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 16,
    fontSize: 18,
    color: '#052e16',
  },
  cartao: { backgroundColor: '#166534', borderRadius: 12, padding: 16, gap: 6 },
  cartaoTexto: { color: '#ffffff', fontSize: 18 },
  botao: {
    backgroundColor: '#22c55e',
    borderRadius: 12,
    paddingVertical: 20,
    alignItems: 'center',
  },
  botaoDesativado: { opacity: 0.6 },
  botaoTexto: { color: '#052e16', fontSize: 20, fontWeight: '700' },
  botaoSair: {
    borderColor: '#bbf7d0',
    borderWidth: 1,
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
  },
  botaoSairTexto: { color: '#dcfce7', fontSize: 18, fontWeight: '600' },
  erro: { color: '#fecaca', fontSize: 16 },
  lista: { flex: 1 },
  linha: { borderBottomColor: '#166534', borderBottomWidth: 1, paddingVertical: 10 },
  linhaTitulo: { color: '#ffffff', fontSize: 18, fontWeight: '600' },
  linhaId: { color: '#bbf7d0', fontSize: 12 },
});
