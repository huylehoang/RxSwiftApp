import UIKit

struct LoginSceneBuilder: SceneBuilderType {
    private(set) var usecase: LoginUsecase
    private(set) var navigator: LoginNavigator

    init(usecase: LoginUsecase = DefaultLoginUsecase(), navigator: LoginNavigator) {
        self.usecase = usecase
        self.navigator = navigator
    }

    init(navigationController: UINavigationController) {
        usecase = DefaultLoginUsecase()
        navigator = DefaultLoginNavigator(navigationController: navigationController)
    }

    mutating func withUsecase(_ usecase: LoginUsecase) -> LoginSceneBuilder {
        self.usecase = usecase
        return self
    }

    mutating func withNavigator(_ navigator: LoginNavigator) -> LoginSceneBuilder {
        self.navigator = navigator
        return self
    }

    func build() -> UIViewController {
        let viewModel = LoginViewModel(usecase: usecase, navigator: navigator)
        let scene = LoginScene(viewModel: viewModel)
        return scene
    }
}
