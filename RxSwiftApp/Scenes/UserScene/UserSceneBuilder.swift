import UIKit

struct UserSceneBuilder: SceneBuilderType {
    private(set) var usecase: UserUsecase
    private(set) var navigator: UserNavigator

    init(usecase: UserUsecase = DefaultUserUsecase(), navigator: UserNavigator) {
        self.usecase = usecase
        self.navigator = navigator
    }

    init(navigationController: UINavigationController) {
        usecase = DefaultUserUsecase()
        navigator = DefaultUserNavigator(navigationController: navigationController)
    }

    mutating func withUsecase(_ usecase: UserUsecase) -> UserSceneBuilder {
        self.usecase = usecase
        return self
    }

    mutating func withNavigator(_ navigator: UserNavigator) -> UserSceneBuilder {
        self.navigator = navigator
        return self
    }

    func build() -> UIViewController {
        let viewModel = UserViewModel(usecase: usecase, navigator: navigator)
        let scene = UserScene(viewModel: viewModel)
        return scene
    }
}
