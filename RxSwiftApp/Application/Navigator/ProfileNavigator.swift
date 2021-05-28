import UIKit
import Application

struct ProfileNavigator: Application.ProfileNavigator {
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
