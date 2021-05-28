import UIKit

final class EmptyScene: BaseViewController {
    private let message: String

    init(message: String) {
        self.message = message
        super.init()
    }

    override func loadView() {
        super.loadView()
        setupView()
    }
}

private extension EmptyScene {
    func setupView() {
        contentView.backgroundColor = .white
        let emptyView = EmptyView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emptyView)
        Constraint.activateGroup(emptyView.equalToEdges(of: contentView))
        emptyView.rx.message.onNext(message)
    }
}
