import UIKit
import Domain

public struct HomeSceneBuilder: SceneBuilderType {
    public var usecase: HomeUsecase?
    public var navigator: HomeNavigator?

    public init() {}

    public func build() -> UIViewController {
        guard let usecase = usecase, let navigator = navigator else { return getEmptyScene() }
        let viewModel = HomeViewModel(usecase: usecase, navigator: navigator)
        let scene = HomeScene(viewModel: viewModel)
        return scene
    }
}
