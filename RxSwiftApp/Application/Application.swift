import UIKit
import FirebaseAuth

final class Application {
    static let shared = Application()

    private init() {}

    func confirgureMainInterface(in window: UIWindow) {
        let navigationController = UINavigationController()
        let userUsercase = UserUsecase()
        let loginUsecase = LoginUsecase()
        let loginNavigator = LoginNavigator(navigationController: navigationController)
        let loginViewModel = LoginViewModel(
            loginUsecase: loginUsecase,
            userUsecase: userUsercase,
            navigator: loginNavigator)
        let loginScene = LoginScene(viewModel: loginViewModel)
        var scenes: [UIViewController] = [loginScene]

        if userUsercase.getUser() != nil {
            let userNavigator = UserNavigator(navigationController: navigationController)
            let userViewModel = UserViewModel(usecase: userUsercase, navigator: userNavigator)
            let userScene = UserScene(viewModel: userViewModel)
            scenes.append(userScene)
        }

        navigationController.setViewControllers(scenes, animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
