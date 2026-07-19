# CarPlay未経験から始める車載UI入門

iOSDC Japan 2026 のパンフレット記事「CarPlay未経験から始める車載UI入門」の公開用リポジトリです。

CarPlay の Audio カテゴリを題材に、CarPlay Scene、`CPListTemplate`、画面遷移、Now Playing を最小構成で試せるサンプルアプリと、パンフレットの組版ソースを収録しています。

## サンプルアプリを動かす

詳しい動作環境、Entitlement、Simulator 手順、よくあるつまずきは、[サンプルアプリの README](iOSDC2026CarPlaySample/README.md) を参照してください。

```text
Home            Episode Detail          Now Playing
CPListTemplate → CPListTemplate        → CPNowPlayingTemplate
```

## リポジトリ構成

- `iOSDC2026CarPlaySample/`: Xcode プロジェクトと実行手順
- `iosdc-2026-carplay-pamphlet/`: Vivliostyle によるパンフレットの原稿・組版ソース

`dist/` 以下のビルド出力、執筆途中の草稿、企画・調査・レビュー資料、ローカル設定は公開対象から除外しています。
一方、提出成果物の PDF は [`iosdc-2026-carplay-pamphlet/iosdc-2026-carplay-pamphlet.pdf`](iosdc-2026-carplay-pamphlet/iosdc-2026-carplay-pamphlet.pdf) に固定配置して追跡しています。

## ライセンスと権利表示

このリポジトリ全体には単一のオープンソースライセンスを適用していません。

- [`iOSDC2026CarPlaySample/`](iOSDC2026CarPlaySample/) の著者作成コードとサンプル用素材は [MIT License](iOSDC2026CarPlaySample/LICENSE) です。アプリアイコンを含む素材の来歴と留意点は [権利表示](iOSDC2026CarPlaySample/NOTICE.md) を参照してください。
- [`iosdc-2026-carplay-pamphlet/`](iosdc-2026-carplay-pamphlet/) の原稿、組版ソース、提出成果物 PDF、説明用イメージは MIT License の対象外です。説明用イメージは CarPlay または iOS の実際の UI スクリーンショットではありません。利用条件と画像の来歴は [権利表示](iosdc-2026-carplay-pamphlet/NOTICE.md) を参照してください。

Apple および CarPlay は Apple Inc. の商標です。本リポジトリは Apple による推奨、後援、または提携を示すものではありません。

## パンフレット原稿のビルド

```bash
cd iosdc-2026-carplay-pamphlet
npm ci
npm run build
```

## 参考

- [CarPlay Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/carplay)
- [CarPlay framework documentation](https://developer.apple.com/documentation/carplay)
- [WWDC26: Rev up your CarPlay app](https://developer.apple.com/videos/play/wwdc2026/212/)
