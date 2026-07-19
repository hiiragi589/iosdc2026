# CarPlay未経験から始める車載UI入門

<p class="subtitle">車載アプリ開発の制約と面白さ</p>

<p class="author-name">西滉平 / Kohei Nishi / @hiiragi589</p>

<p class="lead">CarPlay は、iPhone アプリをそのまま車載ディスプレイに映す仕組みではありません。「運転中に利用したい機能」という目的に対して、車内でユーザーに示す情報を設計する開発領域です。この記事では、番組一覧からエピソードを選んで再生し、車側から再生や一時停止を操作できる、ポッドキャスト風の音声アプリを題材にします。このサンプルアプリを通して、一覧の表示、画面遷移、Now Playing、システムとの再生状態の共有という CarPlay 開発の基本を、小さな構成でひと続きに確認できます。</p>

### CarPlay はアプリのミラーリングではない

CarPlay は、iPhone の画面をそのまま車に映す仕組みではありません。「運転中に利用したい機能」という目的を先に決め、その目的に合わせて「ユーザーに示す情報」を設計します。アプリ側は CarPlay Framework の提供する Template やメディア情報を使い、この設計を車載ディスプレイ向けの体験として別に組み立てます。

通常の iOS アプリなら、画面を自由に作り、ラベルやボタンを好きなところに配置できます。しかし車内でユーザーが集中すべきなのは、アプリの機能を使うことではなく運転することです。CarPlay では、便利そうな機能を足すよりも、運転中または停車中の文脈で本当に必要な情報だけを残すことが出発点になります。

<div class="diagram">
  <div class="diagram-box">
    <h4>iPhone App</h4>
    <ul>
      <li>ログイン・検索</li>
      <li>詳細な設定</li>
      <li>長文の確認</li>
      <li>複雑な入力</li>
    </ul>
  </div>
  <div class="diagram-arrow">→</div>
  <div class="diagram-box">
    <h4>CarPlay</h4>
    <ul>
      <li>一覧から選ぶ</li>
      <li>必要な情報だけ見る</li>
      <li>再生・案内を始める</li>
      <li>短い操作で戻る</li>
    </ul>
  </div>
</div>

複雑な操作は iPhone 側に残し、運転中に短い操作で完了できるタスクだけを CarPlay 側に渡します。この分担が決まると、後で出てくる Template の制約は「不自由」ではなく「設計の前提」として読めるようになります。

### 最初に捨てるもの

CarPlay 開発で最初に捨てるべきなのは、iPhone アプリと同じ感覚で UI を作ることです。CarPlay にはシステム定義の Template に従って描画する制約があり、iPhone と同じ画面は作れません。一方で、CarPlay 側を「劣化版の iPhone UI」と捉えるのも違います。本当に必要な情報だけを強調する場所として見ることが大切です。

Apple の Human Interface Guidelines(CarPlay)でも、アプリ種別に応じたシステム定義の Template を使うことが前提として説明されています。車種によってはロータリーノブやタッチパッドで操作されることも忘れてはいけません。「車種や入力方法が変わっても、短い操作で目的を達成できるか」が判断基準になります。

| 観点 | CarPlayでの扱い |
| --- | --- |
| 画面の役割 | 長い説明 ❌ 要点だけを確認する ⭕️ |
| 入力 | 細かな設定・検索条件は iPhone 側に残す |
| レイアウト | 自由な配置 ❌ システム定義の Template を使う ⭕️ |
| ハードウェア | 画面サイズ・入力方法が車ごとに違う前提で設計する |
| 情報量 | 「便利そう」ではなく「今必要か」で選ぶ |

実車がなくても、iOS Simulator の「External Displays」機能を使って、CarPlay Template の表示や画面遷移を確認できます。

ただし、Apple は iOS Simulator だけでテストを完結させないよう案内しています。
iOS Simulator では、iPhone のロック中の動作、Siri との連携、オーディオの振る舞いを確認できません。
これらは、実機の iPhone を Mac へ接続して使うスタンドアロン版の CarPlay Simulator、または CarPlay 対応車や後付け車載機で確認します。

この記事では、iOS Simulator の「External Displays」機能で確認できる、CarPlay Template の表示と基本的な画面遷移に範囲を絞ります。

<div class="column-box page-bottom">
  <p class="column-box-label">💡 なぜ今CarPlayなの？</p>
  <p>WWDC25では、iOS 26でwidgetsとLive ActivitiesがCarPlayに対応し、CarPlay専用アプリを持たないアプリにも車載画面へ情報を届ける入口が広がりました。
  WWDC26では、iOS 27でvoice-based conversational appsがサポートされ、対応車両で停車中に動画を探して再生できるvideo appsも加わりました。
  一方で、日本語で「未経験から最初の一歩」を扱う資料はまだ少なく、Template 中心という独特の設計思想が入口のハードルになっています。
  最初に押さえたいのは、運転中の利用を前提に情報を絞ることと、アプリのカテゴリに合う Template を選ぶことです。
  画面の接続にはScene、再生中コンテンツの情報やリモート操作の連携にはMediaPlayerなど、通常のiOS開発で使う知識を引き続き活かせます。</p>
</div>
