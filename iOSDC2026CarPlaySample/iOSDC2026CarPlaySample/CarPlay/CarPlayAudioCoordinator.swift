//
//  CarPlayAudioCoordinator.swift
//  iOSDC2026CarPlaySample
//

import CarPlay

/// テンプレートの生成と遷移を担当するクラス。
///
/// 画面フロー:
///   Home            Episode Detail          Now Playing
///   CPListTemplate → CPListTemplate        → CPNowPlayingTemplate
///   (root)           (push)                  (shared)
final class CarPlayAudioCoordinator {
    private let interfaceController: CPInterfaceController
    private let player: AudioPlayer
    private let nowPlayingController: NowPlayingController

    init(
        interfaceController: CPInterfaceController,
        player: AudioPlayer,
        nowPlayingController: NowPlayingController
    ) {
        self.interfaceController = interfaceController
        self.player = player
        self.nowPlayingController = nowPlayingController
    }

    func start() {
        interfaceController.setRootTemplate(
            makeHomeTemplate(), animated: false,
            completion: nil)
        configureNowPlayingButtons()
    }

    // MARK: - Home (CPListTemplate)

    private func makeHomeTemplate() -> CPListTemplate {
        // 表示件数の上限はシステム側が決める。超える分は渡す前に絞る
        let episodes = Episode.samples.prefix(CPListTemplate.maximumItemCount)
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

    // MARK: - Episode Detail (CPListTemplate)

    private func showDetail(of episode: Episode) {
        let metadataItems = [
            CPListItem(
                text: "長さ",
                detailText: episode.length),
            CPListItem(
                text: "更新",
                detailText: episode.updated),
            CPListItem(
                text: "作者",
                detailText: episode.author),
        ]
        // 情報表示のみの行。handler を設定しないままタップされると
        // 完了通知が返らずスピナーが出続けるので、即座に completion を
        // 呼んで「タップしても何も起きない行」として扱う。
        for item in metadataItems {
            item.handler = { _, completion in
                completion()
            }
        }
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

    // MARK: - Now Playing (CPNowPlayingTemplate)

    private func startPlayback(of episode: Episode) {
        player.play(episode)
        // CPNowPlayingTemplate は自分でインスタンスを作らず shared を使う。
        // 再生/一時停止ボタンの状態を直接設定する API はなく、
        // MPNowPlayingInfoCenter に公開した PlaybackRate からシステムが描画する。
        interfaceController.pushTemplate(
            CPNowPlayingTemplate.shared,
            animated: true, completion: nil)
    }

    private func configureNowPlayingButtons() {
        // 車内で本当に使う操作だけに絞る。ここでは再生速度のみ
        CPNowPlayingTemplate.shared.updateNowPlayingButtons([
            CPNowPlayingPlaybackRateButton { [weak self] _ in
                self?.player.cycleRate()
            },
        ])
    }
}
