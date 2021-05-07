import UIKit

protocol LoginNavigator: NavigatorType {
    func toUser()
}

struct DefaultLoginNavigator: LoginNavigator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toUser() {
        guard let navigationController = navigationController else { return }
        let userScene = UserSceneBuilder(navigationController: navigationController).build()
        navigationController.pushViewController(userScene, animated: true)
    }
}
