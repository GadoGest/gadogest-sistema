// Liga os hooks do repositório (.githooks/) — roda sozinho no `npm install` (script "prepare").
// Com isso, os avisos de AVISOS.md aparecem depois de todo `git pull`.
// Nunca falha: fora de um repositório Git (ex.: build), só não faz nada.
import { execFileSync } from 'node:child_process';

try {
  execFileSync('git', ['config', 'core.hooksPath', '.githooks'], { stdio: 'ignore' });
} catch {
  // sem Git disponível: ignora
}
