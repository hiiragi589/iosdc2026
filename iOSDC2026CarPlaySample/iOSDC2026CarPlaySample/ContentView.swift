//
//  ContentView.swift
//  iOSDC2026CarPlaySample
//
//  Created by Kohei Nishi on 2026/07/05.
//

import SwiftUI

/// iPhone 側の画面。
/// このサンプルの主役は CarPlay 側なので、iPhone 側はエピソード一覧と
/// 最小限の再生コントロールだけを置いています。
struct ContentView: View {
    private let player = AppServices.player
    private let nowPlayingController = AppServices.nowPlayingController

    var body: some View {
        NavigationStack {
            List(Episode.samples) { episode in
                Button {
                    play(episode)
                } label: {
                    row(for: episode)
                }
                .foregroundStyle(.primary)
            }
            .navigationTitle("Audio Sample")
            .safeAreaInset(edge: .bottom) {
                if player.currentEpisode != nil {
                    playbackBar
                }
            }
        }
        .onAppear {
            // NowPlayingController を初期化し、リモート操作の受け付けを開始する。
            nowPlayingController.refresh()
        }
    }

    private func row(for episode: Episode) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(episode.title)
                    .font(.headline)
                Text(episode.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(episode.length)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }

    private var playbackBar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(player.currentEpisode?.title ?? "")
                    .font(.subheadline)
                    .lineLimit(1)
                Text(player.isPlaying ? "再生中" : "一時停止中")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                player.cycleRate()
            } label: {
                Text("\(player.rate.formatted())x")
                    .font(.caption.bold())
                    .monospacedDigit()
            }
            .buttonStyle(.bordered)
            Button {
                if player.isPlaying {
                    player.pause()
                } else {
                    player.resume()
                }
            } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
            }
        }
        .padding()
        .background(.bar)
    }

    private func play(_ episode: Episode) {
        player.play(episode)
    }
}

#Preview {
    ContentView()
}
