import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';
import { AppState } from 'react-native';

const url = process.env.EXPO_PUBLIC_SUPABASE_URL;
const chave = process.env.EXPO_PUBLIC_SUPABASE_KEY;

if (!url || !chave) {
  throw new Error(
    'Faltam EXPO_PUBLIC_SUPABASE_URL e EXPO_PUBLIC_SUPABASE_KEY no apps/mobile/.env (ver .env.example).',
  );
}

// Cliente do Supabase (login e envio da fila). A sessão fica guardada no
// aparelho para o usuário continuar logado sem internet (offline-first).
export const supabase = createClient(url, chave, {
  auth: {
    storage: AsyncStorage,
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: false,
  },
});

// No celular, a renovação automática do login só roda com o app em primeiro plano.
AppState.addEventListener('change', (estado) => {
  if (estado === 'active') {
    void supabase.auth.startAutoRefresh();
  } else {
    void supabase.auth.stopAutoRefresh();
  }
});
