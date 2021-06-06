import UIKit
import Application
import FirebasePlatform

enum App {
    static let services = UsecaseProvider()

    static func confirgureMainInterface(in window: UIWindow) {
        let navigationController = MasterNavigationController()
        let loginScene = Scene.login.build(in: navigationController)
        var scenes: [UIViewController] = [loginScene]

        if FirebaseService.isSignedIn() {
            let homeScene = Scene.home.build(in: navigationController)
            scenes.append(homeScene)
        }

        navigationController.setViewControllers(scenes, animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    static func setupLibs() {
        FirebaseService.setup()
    }
}
