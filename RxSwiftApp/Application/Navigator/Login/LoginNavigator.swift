import UIKit

protocol LoginNavigator: NavigatorType {
    func toHome()
}

struct DefaultLoginNavigator: LoginNavigator {
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
