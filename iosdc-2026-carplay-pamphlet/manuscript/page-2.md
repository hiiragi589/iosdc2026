## CarPlayアプリを構成する4要素

CarPlay を調べ始めると、`Entitlement`、`Scene`、`CPInterfaceController`、`CPListTemplate` などの言葉が一気に出てきます。最初は個別の API を追うより、次の4つで捉えると見通しがよくなります。

### 1. App Category

カテゴリは単なる分類名ではなく、「車内でどのタスクを担うか」を決めます。使える Template もカテゴリで変わります。

| 代表的なカテゴリ | 車内での主なタスク |
| --- | --- |
| Audio | 音声コンテンツの選択と再生 |
| Communication / Voice | 通話、メッセージ、音声応答 |
| Navigation / Driving task | 経路案内と運転情報 |
| Parking / Charging / Fueling | 周辺施設の検索と選択 |
| Quick ordering / Public safety | 注文と安全情報の確認 |
| Video | 停車中の動画再生 |

CarPlay Framework でアプリ画面を提供するには、Apple が定めるカテゴリに該当し、対応する Entitlement を取得します。表は代表例であり、利用できる Template もカテゴリごとに異なります。なお、CarPlay 専用アプリに該当しなくても、widget や Live Activity を表示できる場合があります。このサンプルでは、一覧から Now Playing までを試せる Audio カテゴリを選びます。

### 2. Entitlement

Audio カテゴリのこのサンプルでは、entitlements ファイルに次のキーを設定します。

```xml
<!-- Sample.entitlements -->
<key>com.apple.developer.carplay-audio</key>
<true/>
```

このキーは設定済みなので、Apple への Entitlement 申請前でも、Simulator で一覧から Now Playing までのフローを試せます。

実機での検証や App Store での配布には、Apple へ Audio カテゴリの Entitlement を申請します。
この申請は App Store Review とは別で、Apple が所定の基準に基づいて審査します。
承認後は、App ID の Capability と Provisioning Profile を設定します。

### 3. CarPlay Scene

CarPlay では、iPhone 側の通常画面とは別に、CarPlay 接続時の Scene を扱います。入口は `CPTemplateApplicationScene` です。

```xml
<!-- Info.plist: CarPlay 用 Scene を宣言 -->
<key>UISceneClassName</key>
<string>CPTemplateApplicationScene</string>
<key>UISceneDelegateClassName</key>
<string>$(PRODUCT_MODULE_NAME).CarPlaySceneDelegate</string>
```

Scene が接続されたら `CPInterfaceController` を受け取ります。サンプルでは、Template の生成と画面遷移を担う `CarPlayAudioCoordinator` にこのオブジェクトを渡します。

```swift
func templateApplicationScene(
    _ scene: CPTemplateApplicationScene,
    didConnect interfaceController:
        CPInterfaceController
) {
    let coordinator = CarPlayAudioCoordinator(
        interfaceController: interfaceController,
        player: AppServices.player,
        nowPlayingController:
            AppServices.nowPlayingController)
    self.coordinator = coordinator
    coordinator.start()
}
```

`CPInterfaceController` は CarPlay 側の画面遷移を管理し、UIKit の `UINavigationController` に近い役割を持ちます。`coordinator.start()` は `setRootTemplate` で最初の Template を置きます。切断時は `didDisconnectInterfaceController` で Coordinator を手放します。CarPlay Scene は iPhone 側の画面状態に依存させません。

### 4. Template

CarPlay UI は、システム定義の Template を選んで構成します。View を自作するのではなく、Template に情報とアクションを渡します。

| Template | 用途 |
| --- | --- |
| `CPListTemplate` | 候補を一覧する |
| `CPInformationTemplate` | 駐車・充電などの詳細情報を見せる |
| `CPNowPlayingTemplate` | 再生中の状態を見せる |
| `CPTabBarTemplate` | 複数セクションを切り替える |
| `CPGridTemplate` | アイコンで選ばせる |

`CPInformationTemplate` のように、カテゴリによって利用対象が限られる Template もあります。この Audio サンプルの詳細画面には `CPListTemplate` を使います。

アプリが内容と操作を渡し、システムが車載画面へ描画します。画面サイズや入力方式が違っても、システムが車載環境に合わせて表示し、操作を短く保てるのが Template の役割です。

<div class="column-box column-box-compact page-bottom">
  <p class="column-box-label">💡 AI生成コードを公式資料と照合する</p>
  <p>生成コードが動いても、カテゴリごとの Template 制約から外れていることがあります。CarPlay の Human Interface Guidelines、Framework の公式ドキュメント、近年の WWDC セッションで確認します。筆者はこの3つのリンクを AGENTS.md に置き、実装前に一次情報を確認しています。4ページ目では、Now Playing の生成方法を例に確認します。</p>
</div>
