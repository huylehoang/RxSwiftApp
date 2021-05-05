import UIKit
import FirebaseAuth

final class Application {
    static let shared = Application()

    private init() {}

    func confirgureMainInterface(in window: UIWindow) {
        let navigationController = UINavigationController()
        let loginUsecase = DefaultLoginUsecase()
        let loginNavigator = DefaultLoginNavigator(navigationController: navigationController)
        let loginViewModel = LoginViewModel(usecase: loginUsecase, navigator: loginNavigator)
        let loginScene = LoginScene(viewModel: loginViewModel)
        var scenes: [UIViewController] = [loginScene]

        let authService = DefaultAuthService()
        if authService.getUser() != nil {
            let userUsecase = DefaultUserUsecase()
            let userNavigator = DefaultUserNavigator(navigationController: navigationController)
            let userViewModel = UserViewModel(usecase: userUsecase, navigator: userNavigator)
            let userScene = UserScene(viewModel: userViewModel)
            scenes.append(userScene)
        }

        navigationController.setViewControllers(scenes, animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
