/**
 * Formata um peso em kg para exibição: uma casa decimal e vírgula (padrão brasileiro).
 * Ex.: 412.34 -> "412,3 kg". Convenção do projeto (CLAUDE.md §8).
 */
export function formatarPesoKg(pesoKg: number): string {
  if (!Number.isFinite(pesoKg)) {
    throw new RangeError('Peso inválido');
  }
  return `${pesoKg.toFixed(1).replace('.', ',')} kg`;
}
