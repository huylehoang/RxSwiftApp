import UIKit
import Domain

public protocol SceneBuilderType: MutableType {
    associatedtype Usecase = UsecaseType
    associatedtype Navigator = NavigatorType

    var usecase: Usecase? { get set }
    var navigator: Navigator? { get set }

    func withUsecase(_ usecase: Usecase) -> Self
    func withNavigator(_ navigator: Navigator) -> Self
    func build() -> UIViewController
}

// MARK: Default Implementation
public extension SceneBuilderType {
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

enum SceneBuidlerError {
    case missingUsecaseNavigator
}

extension SceneBuidlerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingUsecaseNavigator: return "Missing\nUsecase & Navigator"
        }
    }
}
