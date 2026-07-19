import { defineConfig } from '@vivliostyle/cli';

export default defineConfig({
  title: 'iOSDC 2026 CarPlay Pamphlet',
  author: 'hiiragi589',
  language: 'ja',
  entry: ['.vivliostyle/generated/spreads.html'],
  output: ['dist/iosdc-2026-carplay-pamphlet.pdf'],
  theme: [
    './styles/base.css',
    './styles/layout.css',
    './styles/print.css',
  ],
  workspaceDir: '.vivliostyle/workspace',
});
