import { column, Schema, Table } from '@powersync/react-native';

// Tabela provisória da prova técnica (Etapa 0). O "id" (UUID gerado no aparelho)
// é criado automaticamente pelo PowerSync e não é declarado aqui.
// As colunas precisam espelhar a tabela que o back criar no Postgres.
const teste_animais = new Table({
  fazenda_id: column.text,
  brinco: column.text,
  nome: column.text,
  versao: column.integer,
  criado_em: column.text,
  atualizado_em: column.text,
  apagado_em: column.text,
});

export const esquema = new Schema({ teste_animais });

export type TesteAnimal = (typeof esquema)['types']['teste_animais'];
