//
//  CarPlaySceneDelegate.swift
//  iOSDC2026CarPlaySample
//

import CarPlay

/// CarPlay の接続・切断を受けるクラス。
///
/// Info.plist の CPTemplateApplicationSceneSessionRoleApplication で
/// このクラスを宣言しておくと、CarPlay 接続時にシステムが直接インスタンス化します。
/// 接続時に受け取る CPInterfaceController が、CarPlay 側の画面遷移を握る
/// オブジェクト(UIKit でいう UINavigationController に近い役割)です。
final class CarPlaySceneDelegate: UIResponder,
    CPTemplateApplicationSceneDelegate {

    private var coordinator: CarPlayAudioCoordinator?

    func templateApplicationScene(
        _ scene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        let coordinator = CarPlayAudioCoordinator(
            interfaceController: interfaceController,
            player: AppServices.player,
            nowPlayingController: AppServices.nowPlayingController)
        self.coordinator = coordinator
        coordinator.start()
    }

    func templateApplicationScene(
        _ scene: CPTemplateApplicationScene,
        didDisconnectInterfaceController interfaceController: CPInterfaceController
    ) {
        // 切断されたら CPInterfaceController への参照ごと手放す
        coordinator = nil
    }
}
