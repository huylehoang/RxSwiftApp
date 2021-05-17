import UIKit

struct UpdateNoteSceneBuilder: SceneBuilderType {
    var kind: UpdateNoteViewModel.Kind?
    var usecase: UpdateNoteUsecase?
    var navigator: UpdateNoteNavigator?

    func withKind(_ kind: UpdateNoteViewModel.Kind) -> UpdateNoteSceneBuilder {
        return updated { $0.kind = kind }
    }

    func build() -> UIViewController {
        guard let kind = kind, let usecase = usecase, let navigator = navigator else {
            return getEmptyScene()
        }
        let viewModel = UpdateNoteViewModel(kind: kind, usecase: usecase, navigator: navigator)
        let scene = UpdateNoteScene(viewModel: viewModel)
        return scene
    }
}
