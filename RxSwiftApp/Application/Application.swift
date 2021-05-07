import UIKit
import FirebaseAuth

final class Application {
    static let shared = Application()

    private init() {}

    func confirgureMainInterface(in window: UIWindow) {
        let navigationController = UINavigationController()
        let loginScene = LoginSceneBuilder(navigationController: navigationController).build()
        var scenes: [UIViewController] = [loginScene]

        if Auth.auth().currentUser != nil {
            let userScene = UserSceneBuilder(navigationController: navigationController).build()
            scenes.append(userScene)
        }

        navigationController.setViewControllers(scenes, animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
