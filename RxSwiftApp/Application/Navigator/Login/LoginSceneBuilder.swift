import UIKit

struct LoginSceneBuilder: SceneBuilderType {
    var usecase: LoginUsecase?
    var navigator: LoginNavigator?

    func build() -> UIViewController {
        guard let usecase = usecase, let navigator = navigator else { return getEmptyScene() }
        let viewModel = LoginViewModel(usecase: usecase, navigator: navigator)
        let scene = LoginScene(viewModel: viewModel)
        return scene
    }
}
