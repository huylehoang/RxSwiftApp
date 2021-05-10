import UIKit

struct UserSceneBuilder: SceneBuilderType {
    var usecase: UserUsecase
    var navigator: UserNavigator

    init(usecase: UserUsecase = DefaultUserUsecase(), navigator: UserNavigator) {
        self.usecase = usecase
        self.navigator = navigator
    }

    init(navigationController: UINavigationController) {
        usecase = DefaultUserUsecase()
        navigator = DefaultUserNavigator(navigationController: navigationController)
    }

    func build() -> UIViewController {
        let viewModel = UserViewModel(usecase: usecase, navigator: navigator)
        let scene = UserScene(viewModel: viewModel)
        return scene
    }
}
