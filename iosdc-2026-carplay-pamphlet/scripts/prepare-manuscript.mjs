import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { stringify } from '@vivliostyle/vfm';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rootDir = path.resolve(__dirname, '..');
const manuscriptDir = path.join(rootDir, 'manuscript');
const generatedDir = path.join(rootDir, '.vivliostyle', 'generated');
const outputPath = path.join(generatedDir, 'spreads.html');

// 入稿テンプレート(2ページ以上)に合わせ、見開きH297×W420mm単位で出力する。
// 下部17mmはページ番号・著者名・タイトルが主催側で入るため、原稿側では何も描画しない。
const spreadDefinitions = [
  {
    pages: [
      { source: 'page-1.md', pageNumber: 1, side: 'left' },
      { source: 'page-2.md', pageNumber: 2, side: 'right' },
    ],
  },
  {
    pages: [
      { source: 'page-3.md', pageNumber: 3, side: 'left' },
      { source: 'page-4.md', pageNumber: 4, side: 'right' },
    ],
  },
];

async function renderPage({ source, pageNumber, side }) {
  const filePath = path.join(manuscriptDir, source);
  const markdown = await readFile(filePath, 'utf8');
  const html = stringify(markdown, {
    partial: true,
    language: 'ja',
  });

  return `
      <article class="pamphlet-page ${side}-page" data-page-number="${pageNumber}">
        <div class="page-content">
${html}
        </div>
      </article>`;
}

async function renderSpread({ pages }, index) {
  const renderedPages = await Promise.all(pages.map(renderPage));
  return `
    <section class="spread" data-spread-number="${index + 1}">
${renderedPages.join('\n')}
    </section>`;
}

async function main() {
  await mkdir(generatedDir, { recursive: true });
  const renderedSpreads = await Promise.all(
    spreadDefinitions.map(renderSpread),
  );

  const html = `<!doctype html>
<html lang="ja">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>iOSDC 2026 CarPlay Pamphlet</title>
  </head>
  <body>
    <main class="pamphlet-document">
${renderedSpreads.join('\n')}
    </main>
  </body>
</html>
`;

  await writeFile(outputPath, html, 'utf8');
  console.log(`Generated ${path.relative(rootDir, outputPath)}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
