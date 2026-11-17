// Mostra no terminal os avisos abertos de AVISOS.md.
// Roda sozinho depois de todo `git pull` (hooks em .githooks/) e com `npm run avisos`.
// Mostra o passo a passo completo dos avisos de quem está usando o Git
// (pelo `git config user.name`) e só o título dos avisos do outro.
// Nunca falha: um erro aqui não pode atrapalhar o `git pull`.
import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const PESSOAS = {
  'kadu-cell': 'Kadu',
  'pedro-m-vilela': 'Pedro',
};

function usuarioAtual() {
  try {
    const nome = execFileSync('git', ['config', 'user.name'], { encoding: 'utf8' }).trim();
    return PESSOAS[nome.toLowerCase()] ?? null;
  } catch {
    return null;
  }
}

function lerAvisos(texto) {
  const linhas = texto.split(/\r?\n/);
  const avisos = [];
  let naSecaoAbertos = false;
  let atual = null;

  for (const linha of linhas) {
    if (linha.startsWith('## ')) {
      naSecaoAbertos = linha.trim().toLowerCase() === '## avisos abertos';
      atual = null;
      continue;
    }
    if (!naSecaoAbertos) continue;

    const cabecalho = linha.match(/^### (A-\d+) · Para: ([^·]+) · (.+)$/);
    if (cabecalho) {
      atual = {
        id: cabecalho[1],
        para: cabecalho[2].trim(),
        titulo: cabecalho[3].trim(),
        corpo: [],
      };
      avisos.push(atual);
      continue;
    }
    if (atual && linha.trim()) atual.corpo.push(linha);
  }
  return avisos;
}

function ehPara(aviso, pessoa) {
  const para = aviso.para.toLowerCase();
  return para.includes('todos') || (pessoa !== null && para.includes(pessoa.toLowerCase()));
}

function principal() {
  const arquivo = join(process.cwd(), 'AVISOS.md');
  if (!existsSync(arquivo)) return;

  const avisos = lerAvisos(readFileSync(arquivo, 'utf8'));
  if (avisos.length === 0) return;

  const pessoa = usuarioAtual();
  const meus = avisos.filter((a) => pessoa === null || ehPara(a, pessoa));
  const dosOutros = avisos.filter((a) => !meus.includes(a));

  const linha = '='.repeat(70);
  const saida = [
    '',
    linha,
    ` GadoGest — avisos abertos (AVISOS.md)${pessoa ? ` · você: ${pessoa}` : ''}`,
    linha,
  ];

  if (meus.length > 0) {
    saida.push('', pessoa ? `PARA VOCÊ (${meus.length}):` : `TODOS OS AVISOS (${meus.length}):`);
    for (const a of meus) {
      saida.push('', `▶ ${a.id} · ${a.titulo}  [para: ${a.para}]`);
      for (const l of a.corpo) saida.push(`   ${l}`);
    }
  } else {
    saida.push('', 'Nenhum aviso aberto para você.');
  }

  if (dosOutros.length > 0) {
    saida.push('', `Para os outros (${dosOutros.length}):`);
    for (const a of dosOutros) saida.push(`  • ${a.id} · ${a.titulo}  [para: ${a.para}]`);
  }

  saida.push(
    '',
    'Terminou um aviso? Mova para "Avisos resolvidos" em AVISOS.md, num PR.',
    linha,
    '',
  );
  console.log(saida.join('\n'));
}

try {
  principal();
} catch (erro) {
  console.log(`(Não foi possível mostrar os avisos de AVISOS.md: ${erro.message})`);
}
