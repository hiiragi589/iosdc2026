//
//  Episode.swift
//  iOSDC2026CarPlaySample
//

import Foundation

/// CarPlay と iPhone の両方の画面で扱う、音声コンテンツ1件分のメタデータ。
struct Episode: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let author: String
    /// 詳細画面(CPListTemplate)のメタデータ行に表示する文字列
    let length: String
    /// 詳細画面(CPListTemplate)のメタデータ行に表示する文字列
    let updated: String
    /// Now Playing に渡す再生時間(秒)
    let duration: TimeInterval
}

extension Episode {
    static let samples: [Episode] = [
        Episode(
            id: "ep-01",
            title: "CarPlayはミラーリングではない",
            subtitle: "車載UIの前提を整理する",
            author: "iOSDC 2026 Audio Sample",
            length: "12分",
            updated: "2026/07/04",
            duration: 12 * 60),
        Episode(
            id: "ep-02",
            title: "CarPlayアプリを構成する4つの要素",
            subtitle: "Category / Entitlement / Scene / Template",
            author: "iOSDC 2026 Audio Sample",
            length: "18分",
            updated: "2026/07/05",
            duration: 18 * 60),
        Episode(
            id: "ep-03",
            title: "テンプレートで作る最小フロー",
            subtitle: "一覧から詳細へ、そして再生へ",
            author: "iOSDC 2026 Audio Sample",
            length: "15分",
            updated: "2026/07/06",
            duration: 15 * 60),
        Episode(
            id: "ep-04",
            title: "Now Playingと次の一歩",
            subtitle: "再生状態はシステムに渡す",
            author: "iOSDC 2026 Audio Sample",
            length: "10分",
            updated: "2026/07/07",
            duration: 10 * 60),
        Episode(
            id: "ep-05",
            title: "Simulatorでどこまで確認できる?",
            subtitle: "実車がなくても始められる範囲",
            author: "iOSDC 2026 Audio Sample",
            length: "8分",
            updated: "2026/07/08",
            duration: 8 * 60),
    ]
}
