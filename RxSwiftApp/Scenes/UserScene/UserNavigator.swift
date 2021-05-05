import UIKit

protocol UserNavigator {
    func toLogin()
}

final class DefaultUserNavigator: UserNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toLogin() {
        navigationController.popViewController(animated: true)
    }
}
