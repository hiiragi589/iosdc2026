<h2 class="sample-flow-heading">Template で作る最小フロー</h2>

<div class="sample-screenshot-flow" aria-label="CarPlayの画面遷移を表す説明用イメージ">
  <figure class="sample-screenshot">
    <img src="../../assets/examples/flow-1-example.png" alt="一覧から再生中までのフローを表す説明用イメージ" />
    <figcaption>説明用イメージ</figcaption>
  </figure>
  <figure class="sample-screenshot">
    <img src="../../assets/examples/flow-2-example.png" alt="一覧から再生中までのフローを表す説明用イメージ" />
    <figcaption>説明用イメージ</figcaption>
  </figure>
  <figure class="sample-screenshot">
    <img src="../../assets/examples/flow-3-example.png" alt="一覧から再生中までのフローを表す説明用イメージ" />
    <figcaption>説明用イメージ</figcaption>
  </figure>
  <figure class="sample-screenshot">
    <img src="../../assets/examples/flow-4-example.png" alt="一覧から再生中までのフローを表す説明用イメージ" />
    <figcaption>説明用イメージ</figcaption>
  </figure>
</div>

<p class="keep-paragraph">上の図は画面遷移を説明するための抽象的なイメージであり、CarPlay の実際の UI スクリーンショットではありません。</p>

最初に触る CarPlay UI として分かりやすいのは、一覧から詳細へ進む流れです。ここでは、ポッドキャスト風の音声アプリを題材に、2つの `CPListTemplate` と `CPNowPlayingTemplate` を1本の体験としてつなげます。

| サンプル画面 | 使うAPI | 題材での用途 |
| --- | --- | --- |
| エピソード一覧（ルート） | `CPListTemplate` | エピソードの一覧を表示する |
| 詳細 | `CPListTemplate` | 長さや更新日を見せ、再生を起動する |
| 再生中 | `CPNowPlayingTemplate` | 運転中のメディア操作を受ける |
| 遷移 | `CPInterfaceController` | 画面の push / pop を管理する |

### Root Templateを置く

前ページで接続時に起動した Coordinator は、`makeHomeTemplate()` で Root Template を作ります。表示したいデータを `CPListItem` に変換し、セクションにまとめて `CPListTemplate` に渡します。

```swift
private func makeHomeTemplate() -> CPListTemplate {
    let episodes = Episode.samples.prefix(
        CPListTemplate.maximumItemCount)
    let items = episodes.map { episode in
        let item = CPListItem(
            text: episode.title,
            detailText: episode.subtitle)
        item.handler = { [weak self] _, completion in
            self?.showDetail(of: episode)
            completion()
        }
        return item
    }
    return CPListTemplate(
        title: "Audio Sample",
        sections: [CPListSection(items: items)])
}
```

項目がタップされたことは `handler` クロージャに伝えられます。`handler` では「次の画面へ進む」処理を実行し、最後に `completion` を呼んでタップ処理の完了を OS に伝えます。`handler` はメインキューで実行されるため、ネットワーク取得のような時間のかかる処理は別のキューへ移し、処理が終わってから `completion` を呼びます。

### 一覧は選ぶ場所

<p class="keep-paragraph">iPhone 側なら、ランキング、検索、履歴、バナー、設定を置きたくなるかもしれません。CarPlay 側では、最初の判断を少なくします。一覧は「詳しく読む場所」ではなく、表示された選択肢から次に行う操作を選ぶ場所と考えます。</p>

表示件数にも上限があります。上限はシステム側が決めるため、`CPListTemplate.maximumItemCount` で確認し、超える分は渡す前に絞ります。「全部見せる」から「今選べる分だけ見せる」への切り替えが、CarPlay の一覧設計です。

### 詳細は行動の直前に絞る

候補を選んだら、もう1つの `CPListTemplate` を push します。詳細画面といっても、長い説明や複雑な編集は置きません。「このエピソードを再生してよいか」を判断できるだけの情報と、次のアクションを残します。

```swift
private func showDetail(of episode: Episode) {
    let playItem = CPListItem(
        text: "再生",
        detailText: "Now Playing を開く")
    playItem.handler = { [weak self] _, completion in
        self?.startPlayback(of: episode)
        completion()
    }
    let detail = CPListTemplate(
        title: episode.title,
        sections: [
            CPListSection(
                items: metadataItems,
                header: "エピソード情報",
                sectionIndexTitle: nil),
            CPListSection(
                items: [playItem],
                header: "アクション",
                sectionIndexTitle: nil),
        ])
    interfaceController.pushTemplate(
        detail, animated: true, completion: nil)
}
```

`metadataItems` には、長さ、更新日、作者を表示する `CPListItem` を渡します。Audio カテゴリで利用できる Template に合わせながら、情報とアクションをセクションで分けています。コード全体は記事末尾の QR コードから確認できます。

ここまでで一覧から詳細までがつながりました。振り返ると CarPlay 固有のコードは思ったより少なく、大半は普段の iOS 開発と同じ Swift です。
