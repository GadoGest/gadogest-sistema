// ESLint dos pacotes em packages/. O app mobile tem a própria configuração
// (apps/mobile/eslint.config.js), baseada na da Expo.
import js from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  { ignores: ['**/node_modules/**', '**/dist/**', 'apps/**'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
);
