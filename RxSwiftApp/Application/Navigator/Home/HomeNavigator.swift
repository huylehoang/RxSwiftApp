import UIKit

protocol HomeNavigator: NavigatorType {
    func toUser()
    func toAddNote()
    func toEditNote(_ note: Note)
}

struct DefaultHomeNavigator: HomeNavigator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
        navigationController.pushViewController(addNoteScene, animated: true)
    }

    func toEditNote(_ note: Note) {
        guard let navigationController = navigationController else { return }
        let editNoteScene = Scene.update(.edit(note)).build(in: navigationController)
        navigationController.pushViewController(editNoteScene, animated: true)
    }
}