import { formatarPesoKg } from '@gadogest/shared';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View } from 'react-native';

// Tela provisória da Etapa 0: só confirma que o app abre e que o pacote
// compartilhado (packages/shared) é encontrado. Será substituída na prova técnica.
export default function App() {
  return (
    <View style={styles.container}>
      <Text style={styles.titulo}>GadoGest</Text>
      <Text style={styles.texto}>Etapa 0 — base do app</Text>
      <Text style={styles.texto}>Peso de exemplo: {formatarPesoKg(412.34)}</Text>
      <StatusBar style="light" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#14532d',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  titulo: {
    color: '#ffffff',
    fontSize: 32,
    fontWeight: '700',
  },
  texto: {
    color: '#dcfce7',
    fontSize: 18,
  },
});
