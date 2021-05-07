import UIKit
import FirebaseAuth

enum Application {
    static func confirgureMainInterface(in window: UIWindow) {
        let navigationController = UINavigationController()
        let loginScene = LoginSceneBuilder(navigationController: navigationController).build()

        if Auth.auth().currentUser != nil {
            let userScene = UserSceneBuilder(navigationController: navigationController).build()
            navigationController.setViewControllers([loginScene, userScene], animated: false)
        } else {
            navigationController.setViewControllers([loginScene], animated: false)
        }

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
