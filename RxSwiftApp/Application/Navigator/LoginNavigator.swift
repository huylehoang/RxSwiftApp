import UIKit
import Application

struct LoginNavigator: Application.LoginNavigator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toHome() {
        guard let navigationController = navigationController else { return }
        let homeScene = Scene.home.build(in: navigationController)
        navigationController.pushViewController(homeScene, animated: true)
    }
}
