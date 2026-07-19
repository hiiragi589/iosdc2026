//
//  AudioPlayer.swift
//  iOSDC2026CarPlaySample
//

import AVFoundation
import Observation

/// 再生状態の管理を担当するクラス。
///
/// このサンプルの主題はテンプレートと Now Playing のつながりなので、
/// 実際の音は同梱の短いループ音源(SampleAudio.m4a)を鳴らし続けるだけにして、
/// エピソードの再生位置は論理的な時計(anchor 方式)で管理します。
@Observable
final class AudioPlayer {
    private(set) var currentEpisode: Episode?
    private(set) var isPlaying = false
    private(set) var rate: Float = 1.0

    /// 再生状態が変わったときに呼ばれるフック。NowPlayingController が購読します。
    var onStateChange: (() -> Void)?

    private static let rates: [Float] = [1.0, 1.25, 1.5, 2.0]

    /// CarPlay と Remote Command に公開する再生速度の候補。
    var supportedPlaybackRates: [Float] {
        Self.rates
    }

    private var loopPlayer: AVAudioPlayer?
    /// 一時停止・レート変更時点までに確定した再生位置(秒)
    private var anchorTime: TimeInterval = 0
    /// 再生中なら、その再生区間が始まった時刻。停止中は nil
    private var anchorDate: Date?

    var currentTime: TimeInterval {
        guard let anchorDate else { return anchorTime }
        let elapsed = Date().timeIntervalSince(anchorDate) * Double(rate)
        return min(anchorTime + elapsed, currentEpisode?.duration ?? .infinity)
    }

    @discardableResult
    func play(_ episode: Episode) -> Bool {
        currentEpisode = episode
        anchorTime = 0
        rate = 1.0
        let didStart = startLoopAudio()
        anchorDate = didStart ? Date() : nil
        isPlaying = didStart
        onStateChange?()
        return didStart
    }

    @discardableResult
    func pause() -> Bool {
        guard isPlaying else { return false }
        anchorTime = currentTime
        anchorDate = nil
        loopPlayer?.pause()
        isPlaying = false
        onStateChange?()
        return true
    }

    @discardableResult
    func resume() -> Bool {
        guard !isPlaying, currentEpisode != nil, let loopPlayer else {
            return false
        }
        let didResume = loopPlayer.play()
        anchorDate = didResume ? Date() : nil
        isPlaying = didResume
        onStateChange?()
        return didResume
    }

    func cycleRate() {
        let index = Self.rates.firstIndex(of: rate) ?? 0
        setPlaybackRate(Self.rates[(index + 1) % Self.rates.count])
    }

    /// CarPlay / ロック画面など、アプリ外の操作からも同じ候補だけを受け付ける。
    @discardableResult
    func setPlaybackRate(_ newRate: Float) -> Bool {
        guard Self.rates.contains(newRate) else { return false }

        // レートを変える前に、旧レートでの再生位置を確定させる
        anchorTime = currentTime
        anchorDate = isPlaying ? Date() : nil
        rate = newRate
        loopPlayer?.rate = newRate
        onStateChange?()
        return true
    }

    private func startLoopAudio() -> Bool {
        guard configureAudioSession() else { return false }
        if loopPlayer == nil {
            guard let url = Bundle.main.url(
                forResource: "SampleAudio", withExtension: "m4a"),
                let player = try? AVAudioPlayer(contentsOf: url)
            else {
                return false
            }
            loopPlayer = player
            loopPlayer?.numberOfLoops = -1
            loopPlayer?.enableRate = true
        }
        guard let loopPlayer else { return false }
        loopPlayer.currentTime = 0
        loopPlayer.rate = rate
        return loopPlayer.play()
    }

    private func configureAudioSession() -> Bool {
        // オーディオセッションを .playback で有効化しておかないと、
        // 自分のアプリが Now Playing の対象として扱われない
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .spokenAudio)
            try session.setActive(true)
            return true
        } catch {
            return false
        }
    }
}
