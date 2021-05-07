import UIKit

protocol UserNavigator: NavigatorType {
    func toLogin()
}

struct DefaultUserNavigator: UserNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toLogin() {
        navigationController.popViewController(animated: true)
    }
}
