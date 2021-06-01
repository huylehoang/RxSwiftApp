import UIKit
import Domain

public struct UpdateNoteSceneBuilder: SceneBuilderType {
    private var kind: UpdateNoteViewModel.Kind?
    public var usecase: UpdateNoteUsecase?
    public var navigator: UpdateNoteNavigator?

    public init() {}

    public func withKind(_ kind: UpdateNoteViewModel.Kind) -> UpdateNoteSceneBuilder {
        return updated { $0.kind = kind }
    }

    public func build() -> UIViewController {
        guard let kind = kind, let usecase = usecase, let navigator = navigator else {
            return getEmptyScene()
        }
        let viewModel = UpdateNoteViewModel(kind: kind, usecase: usecase, navigator: navigator)
        let scene = UpdateNoteScene(viewModel: viewModel)
        return scene
    }
}
