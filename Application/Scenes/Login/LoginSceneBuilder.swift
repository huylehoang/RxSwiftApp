import UIKit
import Domain

public struct LoginSceneBuilder: SceneBuilderType {
    public var usecase: LoginUsecase?
    public var navigator: LoginNavigator?

    public init() {}

    public func build() -> UIViewController {
        guard let usecase = usecase, let navigator = navigator else { return getEmptyScene() }
        let viewModel = LoginViewModel(usecase: usecase, navigator: navigator)
        let scene = LoginScene(viewModel: viewModel)
        return scene
    }
}
