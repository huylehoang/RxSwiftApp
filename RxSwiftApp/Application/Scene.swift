import UIKit
import Application

enum Scene {
    case login
    case home
    case update(UpdateNoteViewModel.Kind)
    case profile
}

extension Scene {
    func build(in navigationController: UINavigationController) -> UIViewController {
        switch self {
        case .login:
            return LoginSceneBuilder()
                .withUsecase(App.services.makeLoginUsecase())
                .withNavigator(LoginNavigator(navigationController: navigationController))
                .build()
        case .home:
            return HomeSceneBuilder()
                .withUsecase(App.services.makeHomeUsecase())
                .withNavigator(HomeNavigator(navigationController: navigationController))
                .build()
        case .update(let kind):
            return UpdateNoteSceneBuilder()
                .withKind(kind)
                .withUsecase(App.services.makeUpdateNoteUsecase())
                .withNavigator(UpdateNoteNavigator(navigationController: navigationController))
                .build()
        case .profile:
            return ProfileSceneBuilder()
                .withUsecase(App.services.makeProfileUsecase())
                .withNavigator(ProfileNavigator(navigationController: navigationController))
                .build()
        }
    }
}
