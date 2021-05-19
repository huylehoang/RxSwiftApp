import UIKit

protocol UpdateNoteNavigator {
    func toHome()
}

struct DefaultUpdateNoteNavigator: UpdateNoteNavigator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toHome() {
        guard let navigationController = navigationController else { return }
        navigationController.popViewController(animated: true)
    }
}
