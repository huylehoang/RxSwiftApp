import UIKit

struct UserSceneBuilder: SceneBuilderType {
    var usecase: UserUsecase?
    var navigator: UserNavigator?

    func build() -> UIViewController {
        guard let usecase = usecase, let navigator = navigator else { return getEmptyScene() }
        let viewModel = UserViewModel(usecase: usecase, navigator: navigator)
        let scene = UserScene(viewModel: viewModel)
        return scene
    }
}
