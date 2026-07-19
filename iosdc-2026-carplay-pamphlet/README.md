# iOSDC 2026 CarPlay Pamphlet

`iosdc-2026-carplay-pamphlet/` は、iOSDC 2026 向け CarPlay パンフレット原稿の組版ワークスペースです。  
このディレクトリでは、公開用に選別した原稿と組版ソースを、Vivliostyle CLI の公式ドキュメントに合わせて管理します。

## 前提

- Node.js 22.12.0 以上
- npm
- `pdfinfo`
- Docker
  - `npm run press` に利用します
- Ghostscript (`gs`)
  - `npm run press-local` に利用します

このプロジェクトでは `@vivliostyle/cli` と `@vivliostyle/vfm` をローカル依存関係として使います。

## セットアップ

```bash
npm ci
```

`package-lock.json` を正本として、CI とローカル環境の両方で同じ依存グラフを復元します。依存関係を更新する場合だけ `npm install` を実行し、変更された lockfile を確認してください。

## 使い方

プレビュー:

```bash
npm run preview
```

PDF生成:

```bash
npm run build
```

入稿向け PDF 生成:

```bash
npm run press
```

ローカル preflight での入稿向け PDF 生成:

```bash
npm run press-local
```

生成 PDF の基本確認:

```bash
npm run check
```

原稿の校正:

```bash
npm run lint
```

出力先:

- `dist/iosdc-2026-carplay-pamphlet.pdf`
- `dist/iosdc-2026-carplay-pamphlet-press.pdf`

## 原稿運用

- `manuscript/page-1.md` 〜 `manuscript/page-4.md`
  - 紙面用の正本です。
  - この4ファイルだけがビルド対象です。
- `manuscript/draft/chapter-*.md`
  - 長文草案、調査メモ、圧縮前の素材置き場です。
  - ビルドには自動では入りません。

`npm run prepare:manuscript` は、4つの `page-*.md` を HTML に変換し、見開き2面の入力ファイル `.vivliostyle/generated/spreads.html` を生成します。  
その後 `vivliostyle build` / `vivliostyle preview` が同ファイルを入力として使います。

## レイアウト方針

- 見開き `420mm × 297mm` を基本とする
- 4ページ記事は「見開き2面の PDF 2ページ」として出力する
- 2段組、下部メタ情報領域、ノド側安全余白を先に固定する
- 塗り足しはまだ入れず、背景を断ち切りたくなった段階で拡張する

## 校正と入稿用ビルド

- `npm run lint`
  - `manuscript/` 配下の Markdown を textlint で確認します
- `npm run press`
  - Docker 上の `press-ready` preflight を使って入稿向け PDF を生成します
- `npm run press-local`
  - ローカルの Ghostscript を使って同じ出力を生成します

現在の `lint` は、まず草稿と紙面原稿の文章を崩しすぎないように、比較的軽めの日本語技術文書ルールで設定しています。

## サンプルアプリ

紙面(page-2〜page-4)が参照するサンプルアプリは [`../iOSDC2026CarPlaySample`](../iOSDC2026CarPlaySample) にあります。

- `CPListTemplate` → `CPListTemplate` → `CPNowPlayingTemplate` の最小フローを実装しています
- 紙面から README に逃がした実践情報(動作環境、Entitlement、Simulator 手順、ハマりどころ、公式リンク)は [`../iOSDC2026CarPlaySample/README.md`](../iOSDC2026CarPlaySample/README.md) にまとめています
- page-4 末尾の QR コード(`assets/qr/github-repo.png`)は、GitHub 上のサンプルアプリディレクトリへ遷移します
- page-4 の「筆者について」で使うプロフィール画像は `assets/author/MyIcon.JPG` に置いています

## 参考

- [Vivliostyle CLI: Getting Started](https://docs.vivliostyle.org/en/cli/getting-started/)
- [Vivliostyle CLI: Using Config File](https://docs.vivliostyle.org/en/cli/using-config-file/)
- [Vivliostyle CLI: Themes and CSS](https://docs.vivliostyle.org/en/cli/themes-and-css/)
