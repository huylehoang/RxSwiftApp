import UIKit
import Firebase

enum Application {
    static func confirgureMainInterface(in window: UIWindow) {
        let navigationController = MasterNavigationController()
        let loginScene = Scene.login.build(in: navigationController)
        var scenes: [UIViewController] = [loginScene]

        if Auth.auth().currentUser != nil {
            let homeScene = Scene.home.build(in: navigationController)
            scenes.append(homeScene)
        }

        navigationController.setViewControllers(scenes, animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    static func setupLibs() {
        FirebaseApp.configure()
    }
}
