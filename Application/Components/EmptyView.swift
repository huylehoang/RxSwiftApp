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

    fileprivate lazy var actionButton: UIButton = {
        let view = UIButton()
        view.isHidden = true
        view.setTitleColor(.link, for: .normal)
        view.setTitleColor(.link.withAlphaComponent(0.7), for: .highlighted)
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
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

    var actionTitle: Binder<String> {
        return Binder(base) { base, title in
            base.actionButton.isHidden = title.isEmpty
            base.actionButton.setTitle(title, for: .normal)
        }
    }

    var action: ControlEvent<Void> {
        return base.actionButton.rx.tap
    }
}

private extension EmptyView {
    func setupView() {
        backgroundColor = .clear
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 8
        addSubview(stackView)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(actionButton)
        Constraint.activate(
            stackView.leading.equalTo(leading).constant(24),
            stackView.trailing.equalTo(trailing).constant(-24),
            stackView.centerY.equalTo(centerY))
    }
}
