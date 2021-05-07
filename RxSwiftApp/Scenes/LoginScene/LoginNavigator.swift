import UIKit

protocol LoginNavigator: NavigatorType {
    func toUser()
}

struct DefaultLoginNavigator: LoginNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toUser() {
        let userScene = UserSceneBuilder(navigationController: navigationController).build()
        navigationController.pushViewController(userScene, animated: true)
    }
}
