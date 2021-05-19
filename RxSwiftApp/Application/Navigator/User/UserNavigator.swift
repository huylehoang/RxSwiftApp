import UIKit

protocol UserNavigator: NavigatorType {
    func toLogin()
}

struct DefaultUserNavigator: UserNavigator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toLogin() {
        guard
            let navigationController = navigationController,
            let presentedScene = navigationController.presentedViewController
        else { return }
        navigationController.popToRootViewController(animated: true)
        presentedScene.dismiss(animated: true)
    }
}
