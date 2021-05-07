import UIKit

protocol SceneBuilderType {
    associatedtype Usecase = UsecaseType
    associatedtype Navigator = NavigatorType

    var usecase: Usecase { get }
    var navigator: Navigator { get }

    mutating func withUsecase(_ usecase: Usecase) -> Self
    mutating func withNavigator(_ navigator: Navigator) -> Self
    func build() -> UIViewController
}
