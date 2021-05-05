import UIKit

final class UserNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toLogin() {
        navigationController.popViewController(animated: true)
    }
}
