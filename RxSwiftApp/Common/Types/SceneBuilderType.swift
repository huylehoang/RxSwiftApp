import UIKit

protocol SceneBuilderType: MutableType {
    associatedtype Usecase = UsecaseType
    associatedtype Navigator = NavigatorType

    var usecase: Usecase? { get set }
    var navigator: Navigator? { get set }

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

    func getEmptyScene() -> UIViewController {
        return EmptyScene(message: SceneBuidlerError.missingUsecaseNavigator.localizedDescription)
    }
}
