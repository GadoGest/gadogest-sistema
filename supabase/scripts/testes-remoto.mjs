// Roda os testes pgTAP de supabase/tests/ no projeto vinculado (gadogest-dev)
// SEM Docker. O `supabase test db --remote` precisa de Docker para o pg_prove;
// este script transforma cada arquivo de teste num único bloco DO que termina
// com RAISE EXCEPTION levando o resultado. A exceção desfaz TUDO o que o teste
// gravou (rollback garantido), então nenhum dado de teste fica no banco.
//
// Uso (na raiz do repositório):
//   node supabase/scripts/testes-remoto.mjs                 -> todos os testes
//   node supabase/scripts/testes-remoto.mjs fundacao_test   -> só os que contêm o nome
import { execFileSync } from 'node:child_process';
import { mkdtempSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const CLI = ['--yes', 'supabase@3.2.0'];
const pastaTestes = join('supabase', 'tests');
const filtro = process.argv[2] ?? '';
const arquivos = readdirSync(pastaTestes)
  .filter((f) => f.endsWith('.sql') && f.includes(filtro))
  .sort();

function converter(sql) {
  const texto = sql
    .split('\n')
    .filter((l) => !/^\s*--/.test(l))
    .join('\n');

  // Separa as instruções por ';' fora de blocos $$ ... $$.
  const instrucoes = [];
  let atual = '';
  let dentroDolar = false;
  for (let i = 0; i < texto.length; i++) {
    if (texto.startsWith('$$', i)) {
      dentroDolar = !dentroDolar;
      atual += '$$';
      i++;
      continue;
    }
    if (texto[i] === ';' && !dentroDolar) {
      if (atual.trim()) instrucoes.push(atual.trim());
      atual = '';
      continue;
    }
    atual += texto[i];
  }
  if (atual.trim()) instrucoes.push(atual.trim());

  const corpo = [];
  for (const s of instrucoes) {
    if (/^(begin|rollback)$/i.test(s)) continue;
    if (/^select \* from finish\(\)$/i.test(s)) {
      corpo.push("saida := saida || coalesce((select string_agg(f, E'\\n') from finish() f), '') || E'\\n';");
    } else if (/^select (plan|is|isnt|ok|lives_ok|throws_ok|results_eq)\(/i.test(s)) {
      corpo.push(`saida := saida || coalesce((${s}), '') || E'\\n';`);
    } else if (/^select set_config\(/i.test(s)) {
      corpo.push('perform ' + s.slice(7) + ';');
    } else if (/^(set local|create extension)/i.test(s)) {
      corpo.push(`execute '${s.replace(/'/g, "''")}';`);
    } else {
      corpo.push(s + ';');
    }
  }

  return `do $runner$
declare saida text := '';
begin
${corpo.join('\n')}
raise exception using message = 'TAP ok=' ||
  (select count(*) from regexp_split_to_table(saida, E'\\n') l where l ~ '^ok ') ||
  ' falhas=' || (select count(*) from regexp_split_to_table(saida, E'\\n') l where l ~ '^not ok ') || E'\\n' ||
  coalesce((select string_agg(l, E'\\n') from regexp_split_to_table(saida, E'\\n') l where l !~ '^ok '), '');
end
$runner$;
`;
}

const pastaTemp = mkdtempSync(join(tmpdir(), 'gadogest-testes-'));
let falhou = false;

for (const arquivo of arquivos) {
  const destino = join(pastaTemp, arquivo);
  writeFileSync(destino, converter(readFileSync(join(pastaTestes, arquivo), 'utf8')));

  let saida = '';
  try {
    saida = execFileSync('npx', [...CLI, 'db', 'query', '--remote', '--yes', '-f', destino], {
      encoding: 'utf8',
      shell: process.platform === 'win32',
      stdio: ['ignore', 'pipe', 'pipe'],
    });
  } catch (e) {
    // O RAISE EXCEPTION final sempre "falha" a consulta: é assim que o resultado volta.
    saida = `${e.stdout ?? ''}${e.stderr ?? ''}`;
  }

  const bruto = saida.replace(/\\\\n/g, '\n').replace(/\\n/g, '\n').replace(/\\"/g, '"');
  const resumo = bruto.match(/TAP ok=(\d+) falhas=(\d+)/);
  if (!resumo) {
    falhou = true;
    console.log(`✗ ${arquivo}: não terminou (erro antes do fim do teste)\n${bruto}`);
    continue;
  }
  const [, ok, falhas] = resumo;
  const plano = bruto.match(/1\.\.(\d+)/)?.[1];
  const detalhes = bruto
    .slice(bruto.indexOf(resumo[0]) + resumo[0].length)
    .split('\n')
    .filter((l) => /^(not ok|#)/.test(l))
    .join('\n');
  const passou = falhas === '0' && plano === ok;
  if (!passou) falhou = true;
  console.log(`${passou ? '✓' : '✗'} ${arquivo}: ${ok} ok, ${falhas} falhas (plano: ${plano ?? '?'})`);
  if (detalhes) console.log(detalhes);
}

process.exit(falhou ? 1 : 0);
