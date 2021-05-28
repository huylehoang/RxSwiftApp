import UIKit
import Domain

public struct ProfileSceneBuilder: SceneBuilderType {
    public var usecase: ProfileUsecase?
    public var navigator: ProfileNavigator?

    public init() {}

    public func build() -> UIViewController {
        guard let usecase = usecase, let navigator = navigator else { return getEmptyScene() }
        let viewModel = ProfileViewModel(usecase: usecase, navigator: navigator)
        let scene = ProfileScene(viewModel: viewModel)
        return scene
    }
}
