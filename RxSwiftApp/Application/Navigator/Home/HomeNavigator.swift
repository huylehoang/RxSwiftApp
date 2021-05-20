import UIKit

protocol HomeNavigator: NavigatorType {
    func toLogin()
    func toUser()
    func toAddNote()
    func toEditNote(_ note: Note)
}

struct DefaultHomeNavigator: HomeNavigator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toLogin() {
        guard let navigationController = navigationController else { return }
        navigationController.popToRootViewController(animated: true)
    }

    func toUser() {
        guard let navigationController = navigationController else { return }
        let userScene = Scene.user.build(in: navigationController)
        let sideMenuScene = SideMenuScene(embeddedScene: userScene)
        navigationController.present(sideMenuScene, animated: true)
    }

    func toAddNote() {
        guard let navigationController = navigationController else { return }
        let addNoteScene = Scene.update(.add).build(in: navigationController)
        addNoteScene.modalPresentationStyle = .overFullScreen
        navigationController.pushViewController(addNoteScene, animated: true)
    }

    func toEditNote(_ note: Note) {
        guard let navigationController = navigationController else { return }
        let editNoteScene = Scene.update(.edit(note)).build(in: navigationController)
        editNoteScene.modalPresentationStyle = .overFullScreen
        navigationController.pushViewController(editNoteScene, animated: true)
    }
}
