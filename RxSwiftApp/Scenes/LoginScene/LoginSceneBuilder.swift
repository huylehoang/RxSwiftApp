import UIKit

struct LoginSceneBuilder: SceneBuilderType {
    var usecase: LoginUsecase
    var navigator: LoginNavigator

    init(usecase: LoginUsecase = DefaultLoginUsecase(), navigator: LoginNavigator) {
        self.usecase = usecase
        self.navigator = navigator
    }

    init(navigationController: UINavigationController) {
        usecase = DefaultLoginUsecase()
        navigator = DefaultLoginNavigator(navigationController: navigationController)
    }

    func build() -> UIViewController {
        let viewModel = LoginViewModel(usecase: usecase, navigator: navigator)
        let scene = LoginScene(viewModel: viewModel)
        return scene
    }
}
