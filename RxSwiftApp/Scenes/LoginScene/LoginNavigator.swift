import UIKit

final class LoginNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toUser() {
        let userUsecase = UserUsecase()
        let userNavigator = UserNavigator(navigationController: navigationController)
        let userViewModel = UserViewModel(usecase: userUsecase, navigator: userNavigator)
        let userScene = UserScene(viewModel: userViewModel)
        navigationController.pushViewController(userScene, animated: true)
    }
}
