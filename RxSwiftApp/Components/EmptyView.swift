import RxSwift
import RxCocoa

final class EmptyView: UIView {
    fileprivate lazy var messageLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 36, weight: .bold)
        view.textAlignment = .center
        view.numberOfLines = 0
        view.shadowColor = .black
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

extension Reactive where Base: EmptyView {
    var message: Binder<String?> {
        return base.messageLabel.rx.text
    }
}

private extension EmptyView {
    func setupView() {
        addSubview(messageLabel)
        Constraint.activate(
            messageLabel.leading.equalTo(leading).constant(24),
            messageLabel.trailing.equalTo(trailing).constant(-24),
            messageLabel.centerY.equalTo(centerY))
    }
}
