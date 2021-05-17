import UIKit

enum Scene {
    case login
    case home
    case update(UpdateNoteViewModel.Kind)
    case user
}

extension Scene {
    func build(in navigationController: UINavigationController) -> UIViewController {
        switch self {
        case .login:
            return LoginSceneBuilder()
                .withUsecase(DefaultLoginUsecase())
                .withNavigator(DefaultLoginNavigator(navigationController: navigationController))
                .build()
        case .home:
            return HomeSceneBuilder()
                .withUsecase(DefaultHomeUsecase())
                .withNavigator(DefaultHomeNavigator(navigationController: navigationController))
                .build()
        case .update(let kind):
            return UpdateNoteSceneBuilder()
                .withKind(kind)
                .withUsecase(DefaultUpdateNoteUsecase())
                .withNavigator(
                    DefaultUpdateNoteNavigator(navigationController: navigationController))
                .build()
        case .user:
            return UserSceneBuilder()
                .withUsecase(DefaultUserUsecase())
                .withNavigator(DefaultUserNavigator(navigationController: navigationController))
                .build()
        }
    }
 }
