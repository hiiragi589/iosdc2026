## Now Playingで再生体験をつなぐ

一覧でエピソードを選び、再生を始め、車側の操作と再生状態を同期するところまで進みます。ここで Template の表示と音声再生の仕組みをつなぐのが `CPNowPlayingTemplate` です。

`CPListTemplate` は必要に応じて生成しますが、`CPNowPlayingTemplate` は自分で生成せず、Apple が提供する共有インスタンス `shared` を使います。生成コードに別の初期化方法が現れた場合は、公式ドキュメントに示された使用方法を優先します。

```swift
private func startPlayback(of episode: Episode) {
    player.play(episode)
    interfaceController.pushTemplate(
        CPNowPlayingTemplate.shared,
        animated: true, completion: nil)
}
```

### 再生状態はシステムに渡す

`CPNowPlayingTemplate` は再生 UI の表示先です。画面に出るエピソード名、再生位置、再生状態は自動では入らないため、`MPNowPlayingInfoCenter` 経由でシステムに伝えます。

```swift
func refresh() {
    guard let episode =
        player.currentEpisode
    else { return }
    let center = MPNowPlayingInfoCenter.default()
    center.nowPlayingInfo = [
        MPMediaItemPropertyTitle: episode.title,
        MPMediaItemPropertyArtist: episode.author,
        MPMediaItemPropertyPlaybackDuration:
            episode.duration,
        MPNowPlayingInfoPropertyElapsedPlaybackTime:
            player.currentTime,
        MPNowPlayingInfoPropertyPlaybackRate:
            player.isPlaying ? Double(player.rate) : 0,
        MPNowPlayingInfoPropertyDefaultPlaybackRate:
            Double(player.rate),
    ]
}
```

`PlaybackRate` は現在の状態を、`DefaultPlaybackRate` は選択中の通常再生速度を表します。サンプルでは再生開始、一時停止、再開、速度変更のたびに `refresh()` を呼び、システムへ最新値を渡します。

<p>車側やシステム UI からの操作は、<code>MPRemoteCommandCenter</code> にコマンドとして届きます。再生は <code>playCommand</code>、一時停止は <code>pauseCommand</code> で受け取り、その中でプレイヤーを動かします。ロック画面や AirPods の操作と同じ、普段の iOS 開発でおなじみの仕組みです。</p>

```swift
let center = MPRemoteCommandCenter.shared()
center.playCommand.addTarget { [weak self] _ in
    self?.player.resume()
    return .success
}
center.pauseCommand.addTarget { [weak self] _ in
    self?.player.pause()
    return .success
}
```

再生速度の変更など、対応する操作の分だけ同じ形でコマンドを登録します。Remote Command を含むコード全体は、記事末尾の QR コードから GitHub リポジトリを開いて確認できます。

### ボタンは絞る

CarPlay 側に出すボタンも、置けるから置くのではありません。再生速度、次に再生、ライブラリ追加など、車内で本当に使う操作に絞ります。

```swift
CPNowPlayingTemplate.shared.updateNowPlayingButtons([
    CPNowPlayingPlaybackRateButton { [weak self] _ in
        self?.player.cycleRate()
    },
])
```

判断基準はここでも同じです。iPhone 側で豊かに管理し、CarPlay 側では短い操作にする。

### まとめ

何を表示しないかを先に決め、Scene で接続を受け、必要な Template だけを組み合わせる。制約を前提に設計すれば、CarPlay は今日から学び始められます。

### 動くサンプルコードをGitHubで公開

紙面で扱った一覧、詳細、Now Playing のフローを実装したサンプルアプリを GitHub で公開しています。README では、動作環境、Entitlement、Simulator 手順、ハマりどころ、公式リンクも確認できます。

<div class="sample-cta">
  <img class="sample-cta-qr" src="../../assets/qr/github-repo.png" alt="GitHub repository QR code" />
  <div class="sample-cta-copy">
    <p class="sample-cta-title">サンプルコード・README</p>
    <p><code>CPListTemplate</code> から Now Playing まで、実際に動かして確認できます。</p>
    <p>再生される機械的な音声は、再生機能の確認用に生成したダミー音源です。</p>
  </div>
</div>

<section class="author-profile page-bottom" aria-labelledby="author-profile-name">
  <img class="author-profile-image" src="../../assets/author/MyIcon.JPG" alt="hiiragi589のプロフィール写真" />
  <div class="author-profile-heading">
    <p class="author-profile-label">筆者について</p>
    <p id="author-profile-name" class="author-profile-name">hiiragi589</p>
  </div>
  <p class="author-profile-description">2001年、和歌山生まれ。高校でC言語に出会う。大学・大学院では競技プログラミング、XR制作、ロボットアーム制御を経験。仕事では、バックエンドとAndroidを経てiOS開発へ。</p>
</section>
