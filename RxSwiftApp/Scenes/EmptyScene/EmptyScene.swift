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
        view.backgroundColor = .white
        let emptyView = EmptyView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emptyView)
        Constraint.activate(
            emptyView.leading.equalTo(contentView.leading),
            emptyView.trailing.equalTo(contentView.trailing),
            emptyView.top.equalTo(contentView.top),
            emptyView.bottom.equalTo(contentView.bottom))
        emptyView.rx.message.onNext(message)
    }
}
