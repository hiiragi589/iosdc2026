//
//  AppServices.swift
//  iOSDC2026CarPlaySample
//

/// iPhone 側の画面と CarPlay Scene の両方から使う共有インスタンス。
/// CarPlay Scene は iPhone の画面状態に依存させないため、
/// どちらの Scene からも参照できる場所に再生系の実体を置きます。
enum AppServices {
    static let player = AudioPlayer()
    static let nowPlayingController = NowPlayingController(player: player)
}
