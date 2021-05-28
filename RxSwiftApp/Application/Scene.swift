import UIKit
import Application
import FirebasePlatform

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
                .withUsecase(LoginUsecase())
                .withNavigator(LoginNavigator(navigationController: navigationController))
                .build()
        case .home:
            return HomeSceneBuilder()
                .withUsecase(HomeUsecase())
                .withNavigator(HomeNavigator(navigationController: navigationController))
                .build()
        case .update(let kind):
            return UpdateNoteSceneBuilder()
                .withKind(kind)
                .withUsecase(UpdateNoteUsecase())
                .withNavigator(UpdateNoteNavigator(navigationController: navigationController))
                .build()
        case .user:
            return ProfileSceneBuilder()
                .withUsecase(ProfileUsecase())
                .withNavigator(ProfileNavigator(navigationController: navigationController))
                .build()
        }
    }
}
