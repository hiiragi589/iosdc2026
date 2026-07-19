//
//  NowPlayingController.swift
//  iOSDC2026CarPlaySample
//

import MediaPlayer

/// Now Playing 情報の反映を担当するクラス。
///
/// CPNowPlayingTemplate に表示される曲名・再生位置は、テンプレート自身にではなく
/// MPNowPlayingInfoCenter 経由でシステムに渡します。車側やシステム UI から来る
/// 再生・停止の操作は MPRemoteCommandCenter で受けます。どちらもロック画面や
/// AirPods の操作と同じ、普段の iOS 開発でおなじみの仕組みです。
final class NowPlayingController {
    private let player: AudioPlayer

    init(player: AudioPlayer) {
        self.player = player
        configureRemoteCommands()
        player.onStateChange = { [weak self] in
            self?.refresh()
        }
        // CarPlay 接続前に iPhone 側で再生が始まっていた場合も、接続時に
        // 現在の状態を公開できるようにする。
        refresh()
    }

    func refresh() {
        let infoCenter = MPNowPlayingInfoCenter.default()
        guard let episode = player.currentEpisode else {
            infoCenter.nowPlayingInfo = nil
            updateRemoteCommandAvailability()
            return
        }

        // 再生速度とデフォルト速度の両方を渡すことで、CarPlay の倍速ボタンが
        // 早送り状態ではなく、選択中の通常再生速度として表示される。
        infoCenter.nowPlayingInfo = [
            MPNowPlayingInfoPropertyMediaType:
                MPNowPlayingInfoMediaType.audio.rawValue,
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
        updateRemoteCommandAvailability()
    }

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        // play / pause は常時有効にしているため、表示の反映が遅れた瞬間に
        // すでにその状態へのコマンドが届くことがある。望みの状態なら成功扱いにする。
        center.playCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            if self.player.isPlaying { return .success }
            return self.player.resume() ? .success : .commandFailed
        }
        center.pauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            if !self.player.isPlaying { return .success }
            return self.player.pause() ? .success : .commandFailed
        }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            let didChange = self.player.isPlaying ?
                self.player.pause() : self.player.resume()
            return didChange ? .success : .commandFailed
        }
        center.changePlaybackRateCommand.supportedPlaybackRates =
            player.supportedPlaybackRates.map { NSNumber(value: $0) }
        center.changePlaybackRateCommand.addTarget { [weak self] event in
            guard let self,
                  let event = event as? MPChangePlaybackRateCommandEvent,
                  self.player.setPlaybackRate(event.playbackRate)
            else {
                return .commandFailed
            }
            return .success
        }
        updateRemoteCommandAvailability()
    }

    private func updateRemoteCommandAvailability() {
        let center = MPRemoteCommandCenter.shared()
        let hasEpisode = player.currentEpisode != nil
        // play / pause は再生状態で切り替えず、エピソードがある間は両方有効のままにする。
        // CarPlay の再生/一時停止ボタンはコマンドの有効状態も見てアイコンを決めるため、
        // 状態ごとに無効化すると nowPlayingInfo の反映タイミングとずれて表示が逆転する。
        // どちらの状態を表示するかは PlaybackRate(再生中: rate / 停止中: 0)だけで伝える。
        center.playCommand.isEnabled = hasEpisode
        center.pauseCommand.isEnabled = hasEpisode
        center.togglePlayPauseCommand.isEnabled = hasEpisode
        center.changePlaybackRateCommand.isEnabled = hasEpisode
    }
}
