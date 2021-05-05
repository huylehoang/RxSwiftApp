import UIKit

protocol LoginNavigator {
    func toUser()
}

final class DefaultLoginNavigator: LoginNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toUser() {
        let usecase = DefaultUserUsecase()
        let userNavigator = DefaultUserNavigator(navigationController: navigationController)
        let userViewModel = UserViewModel(usecase: usecase, navigator: userNavigator)
        let userScene = UserScene(viewModel: userViewModel)
        navigationController.pushViewController(userScene, animated: true)
    }
}
