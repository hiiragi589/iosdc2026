//
//  iOSDC2026CarPlaySampleApp.swift
//  iOSDC2026CarPlaySample
//
//  Created by Kohei Nishi on 2026/07/05.
//

import SwiftUI

@main
struct iOSDC2026CarPlaySampleApp: App {
    // iPhone 側の Scene は SwiftUI に任せる。
    // CarPlay 側の Scene(CPTemplateApplicationScene)は Info.plist の
    // UIApplicationSceneManifest で宣言していて、接続時にシステムが
    // CarPlaySceneDelegate を直接インスタンス化する。
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
