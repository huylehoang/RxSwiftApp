import UIKit

protocol SceneBuilderType {
    associatedtype Usecase = UsecaseType
    associatedtype Navigator = NavigatorType

    var usecase: Usecase { get set }
    var navigator: Navigator { get set }

    func withUsecase(_ usecase: Usecase) -> Self
    func withNavigator(_ navigator: Navigator) -> Self
    func build() -> UIViewController
}

// MARK: Default Implementation
extension SceneBuilderType {
    func withUsecase(_ usecase: Usecase) -> Self {
        return updated { $0.usecase = usecase }
    }

    func withNavigator(_ navigator: Navigator) -> Self {
        return updated { $0.navigator = navigator }
    }

    func updated(by changed: (inout Self) -> Void) -> Self {
        var builder = self
        changed(&builder)
        return builder
    }
}
