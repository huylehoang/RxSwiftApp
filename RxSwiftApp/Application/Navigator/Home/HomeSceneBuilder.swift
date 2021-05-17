import UIKit

struct HomeSceneBuilder: SceneBuilderType {
    var usecase: HomeUsecase?
    var navigator: HomeNavigator?

    func build() -> UIViewController {
        guard let usecase = usecase, let navigator = navigator else { return getEmptyScene() }
        let viewModel = HomeViewModel(usecase: usecase, navigator: navigator)
        let scene = HomeScene(viewModel: viewModel)
        return scene
    }
}
