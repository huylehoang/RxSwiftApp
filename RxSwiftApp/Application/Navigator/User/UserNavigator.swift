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
        presentedScene.dismiss(animated: true)
        navigationController.popToRootViewController(animated: false)
    }
}
