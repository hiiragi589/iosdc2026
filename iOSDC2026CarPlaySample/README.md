# iOSDC2026CarPlaySample

iOSDC Japan 2026 パンフレット記事 **「CarPlay未経験から始める車載UI入門: 車載アプリ開発の制約と面白さ」** のサンプルアプリです。

CarPlay の Audio カテゴリを題材に、システム定義テンプレートを1本の体験としてつなげます。

```text
Home            Episode Detail          Now Playing
CPListTemplate → CPListTemplate        → CPNowPlayingTemplate
(root)           (push)                  (shared)
```

このサンプルの目的は、音声アプリを完成させることではありません。CarPlay Scene、Interface Controller、Template、Now Playing が1本につながる感覚を作ることです。

このサンプルは Audio カテゴリで使えるシステム定義 Template を題材にしています。利用可能な Template や API はアプリカテゴリと OS バージョンで異なるため、ほかのカテゴリへ広げるときは [CarPlay framework documentation](https://developer.apple.com/documentation/carplay) と現行の WWDC セッションを確認してください。

## CarPlay 利用時の操作

CarPlay が有効な間の主な操作は、車載ディスプレイと車両側の入力で完結させます。ログイン、詳細な設定、長文の確認のような操作は CarPlay に持ち込まず、必要であれば接続・走行前に iPhone 側で済ませます。CarPlay を iPhone 入力待ちで利用不能にしないことも重要です。詳しくは [Human Interface Guidelines: CarPlay](https://developer.apple.com/design/human-interface-guidelines/carplay) を参照してください。

## 動作環境

- 検証環境: macOS、Xcode 26、iOS 26 Simulator の **I/O > External Displays > CarPlay**
- このREADMEで動作確認したのは iOS Simulator の CarPlay ディスプレイだけです
- Apple は CarPlay Simulator を Additional Tools for Xcode から利用できるものとして案内しています。WWDC26では Device Hub での提供も案内されていますが、本サンプルではその経路を検証していません
- 紙面のフローを試すだけなら実車は不要です
  - テンプレートの表示
  - push / pop による画面遷移
  - Now Playing の表示と基本操作
- オーディオ状態の同期や実際の車載入力は、実機環境で最終確認してください

## 動かし方

1. Xcode で `iOSDC2026CarPlaySample.xcodeproj` を開く
2. iPhone Simulator を選んで Run する(iPhone 側にエピソード一覧が表示されます)
3. Simulator のメニューから **I/O > External Displays > CarPlay** を選び、CarPlay ディスプレイを表示する
4. CarPlay ホームに出た **iOSDC2026CarPlaySample** のアイコンをタップする
5. **Home(一覧) → 詳細(メタデータ一覧) → 再生 → Now Playing** と遷移する

Now Playing 画面では、再生・一時停止と再生速度ボタン(1.0x → 1.25x → 1.5x → 2.0x)が使えます。iPhone 側の画面、ロック画面、コントロールセンター、CarPlay は、同じ `AudioPlayer` の状態を `MPNowPlayingInfoCenter` と `MPRemoteCommandCenter` 経由で共有します。

サンプルで全エピソード共通に再生される機械的な音声は、再生機能を確認するために Python で生成した短いダミー音源であり、実際のポッドキャスト音声を想定したものではありません。

## プロジェクト構成

CarPlay 固有のコードは思ったより少なく、大半は普段の iOS 開発と同じ Swift です。責務は次の4つに分けています。

| ファイル | 役割 |
| --- | --- |
| `CarPlay/CarPlaySceneDelegate.swift` | 接続・切断を受ける。接続時に Root Template を置く |
| `CarPlay/CarPlayAudioCoordinator.swift` | テンプレート生成と遷移(push / pop / root) |
| `AudioPlayer.swift` | 再生状態の管理 |
| `NowPlayingController.swift` | Now Playing 情報の反映と Remote Command の受け付け |

補助的なファイル:

- `Episode.swift` — 一覧・詳細・Now Playing で使うメタデータ(ダミーの5エピソード)
- `AppServices.swift` — iPhone 側と CarPlay Scene で共有する再生系インスタンス
- `Info.plist` — CarPlay 用 Scene(`CPTemplateApplicationScene`)の宣言
- `iOSDC2026CarPlaySample.entitlements` — `com.apple.developer.carplay-audio`

## Entitlement について

CarPlay 対応には、カテゴリに応じた Entitlement が必要です。このサンプル(Audio)では次のキーを使っています。

```xml
<key>com.apple.developer.carplay-audio</key>
<true/>
```

- このサンプルには Audio カテゴリの Entitlement キーを設定しており、この構成で iOS Simulator の表示・遷移を確認しています
- CarPlay の画面にアプリを表示するには、アプリのカテゴリに対応する Entitlement が必要です
- 実機や App Store 配布では、[CarPlay の Entitlement リクエスト](https://developer.apple.com/contact/carplay/) を行い、承認後に App ID と Provisioning Profile を更新します
- Simulator での確認は Entitlement の承認や実機での利用可能性を示すものではありません
- このリポジトリの動作確認は iOS Simulator の External Display を使ったもので、Additional Tools の CarPlay Simulator アプリは未検証です

## Simulator でできること・できないこと

| できる | できない |
| --- | --- |
| テンプレートの表示・push/pop 遷移 | 車種ごとの画面サイズ・解像度の差 |
| Now Playing の表示と基本操作(状態表示の同期には制限あり) | ロータリーノブ・タッチパッド操作 |
| CarPlay Scene の接続・切断の確認 | 走行中の機能制限(Driver Distraction 対策)の挙動 |

筆者の検証環境では、iOS Simulator の CarPlay ウィンドウで Now Playing を開いた直後に、再生状態、再生速度、プログレスバーがアプリ側の状態と一致しない場合がありました。過去にも同種の症状が [Apple Developer Forums](https://developer.apple.com/forums/thread/96104) と [別のスレッド](https://developer.apple.com/forums/thread/107641) で報告されていますが、現在の環境に同じ原因が当てはまるとは限りません。この表示だけでアプリの状態管理が誤っていると判断せず、実機環境でも切り分けてください。

Apple は [Using the CarPlay Simulator](https://developer.apple.com/documentation/carplay/using-the-carplay-simulator) で、Simulator を唯一のテスト手段にせず、実車またはアフターマーケット機器でもテストするよう案内しています。ロック中の挙動、Siri、オーディオ動作は Simulator だけでは確認できません。

[Apple の CarPlay 開発者ページ](https://developer.apple.com/carplay/)は、[Additional Tools for Xcode](https://developer.apple.com/download/all/?q=Additional%20Tools%20for%20Xcode) から CarPlay Simulator を利用する案内を掲載しています。また、[WWDC26](https://developer.apple.com/videos/play/wwdc2026/212/)では Device Hub での提供も案内されています。本サンプルでは、これらの経路では動作確認していません。実車またはアフターマーケット機器での最終確認は、いずれの Simulator でも置き換えられません。

## ハマりどころ

- **CarPlay ホームにアプリのアイコンが出ない**
  - CarPlay Entitlement がターゲットに設定されているか確認してください(`CODE_SIGN_ENTITLEMENTS`)。Entitlement のないアプリは Simulator でも CarPlay ホームに表示されません
  - アプリを一度 Simulator にインストール(Run)してから CarPlay ディスプレイを開いてください
- **CarPlay Scene が起動しない**
  - `Info.plist` の `UISceneDelegateClassName` にはモジュール名が必要です(`$(PRODUCT_MODULE_NAME).CarPlaySceneDelegate`)。クラス名だけ書くと解決されず、無言で失敗します
- **Now Playing に何も表示されない**
  - `CPNowPlayingTemplate` を push するだけでは表示されません。`MPNowPlayingInfoCenter` への情報設定と、オーディオセッション(`.playback`)の有効化・実際の再生が必要です
- **再生中なのに再生ボタン、または倍速表示が一致しない**
  - `MPNowPlayingInfoPropertyPlaybackRate` は再生中の速度(一時停止中は `0`)を、`MPNowPlayingInfoPropertyDefaultPlaybackRate` は選択中の通常再生速度を渡します。`MPRemoteCommandCenter` の play / pause はコンテンツがある間は両方有効のままにして、状態の表現は `PlaybackRate` に一本化します(状態ごとにコマンドを無効化すると、反映タイミングのずれで表示が逆転することがあります)。`CPNowPlayingTemplate.shared` は表示先であり、再生状態そのものを保持する場所ではありません。ボタン状態を直接設定する API はなく、システムが Now Playing 情報から描画します
- **Simulator と CarPlay で音量を分けたい**
  - できません。Simulator の CarPlay ディスプレイは独立したオーディオ出力ではなく、iOS Simulator のシステム出力を共有します。`AVAudioSession.outputVolume` はユーザーが設定するシステム全体の音量なので、Simulator 側で下げると CarPlay の Now Playing 再生音も下がります。実車では車載機側の音量制御・オーディオルートに従います
- **`Provided status bar edge is invalid`、`AddInstanceForFactory`、`LoudnessManager` のログが出る**
  - いずれも Simulator / macOS の表示・音響サービスから出る警告で、このサンプルの Swift コードが原因のクラッシュではありません。テンプレート例外、`Fatal error`、またはアプリのスタックトレースが伴う場合だけ、該当箇所を別途確認してください
- **`CPNowPlayingTemplate` は生成しない**
  - ほかのテンプレートと違い、`init` せず共有インスタンス `CPNowPlayingTemplate.shared` を使います
- **Audio カテゴリでは `CPInformationTemplate` を使えない**
  - `CPInformationTemplate` は Audio Entitlement のアプリではサポートされません。このサンプルでは詳細画面も `CPListTemplate` で構成し、メタデータ表示と再生アクションを同じ流れで学べるようにしています
- **一覧の件数上限**
  - 表示件数の上限はシステム側が決めます。`CPListTemplate.maximumItemCount` を確認し、超える分は渡す前に絞ります

## このサンプルが簡略化していること

- 再生位置は `AudioPlayer` 内の論理的な時計で管理しています(ループ音源の再生位置とは独立)
- エラー処理・永続化・ネットワークは扱いません。主題はテンプレートと Now Playing のつながりです

## 参考リンク

- [Human Interface Guidelines: CarPlay](https://developer.apple.com/design/human-interface-guidelines/carplay)
- [CarPlay Framework](https://developer.apple.com/documentation/carplay)
- [CarPlay App Programming Guide (PDF)](https://developer.apple.com/carplay/documentation/CarPlay-App-Programming-Guide.pdf)
- [Using the CarPlay Simulator](https://developer.apple.com/documentation/carplay/using-the-carplay-simulator)
- [CarPlay Entitlement のリクエスト](https://developer.apple.com/contact/carplay/)
- [MPNowPlayingInfoCenter](https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfocenter)
- [MPRemoteCommandCenter](https://developer.apple.com/documentation/mediaplayer/mpremotecommandcenter)

## 関連

- パンフレット原稿の組版ワークスペース: [`../iosdc-2026-carplay-pamphlet`](../iosdc-2026-carplay-pamphlet)

## ライセンス

このディレクトリの著者作成コードとサンプル用素材は [MIT License](LICENSE) です。アプリアイコンの来歴と第三者の権利に関する注意は [NOTICE.md](NOTICE.md) を参照してください。
