import UIKit
import RxSwift
import RxCocoa

final class ValidationTextfield: UIStackView {
    fileprivate lazy var textfield: UITextField = {
        let view = UITextField()
        view.font = .systemFont(ofSize: 16, weight: .regular)
        view.textColor = .darkText
        view.autocapitalizationType = .none
        view.autocorrectionType = .no
        view.borderStyle = .none
        view.isSecureTextEntry = false
        return view
    }()

    fileprivate lazy var errorLabel: UILabel = {
        let view = UILabel()
        view.isHidden = true
        view.numberOfLines = 0
        view.textColor = .systemRed
        view.font = .systemFont(ofSize: 16, weight: .regular)
        return view
    }()

    var placeholder: String = "" {
        didSet {
            textfield.placeholder = placeholder
        }
    }

    var isSecrectTextEntry: Bool = false {
        didSet {
            textfield.isSecureTextEntry = isSecrectTextEntry
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

extension Reactive where Base: ValidationTextfield {
    var text: ControlProperty<String> {
        return base.textfield.rx.text.orEmpty
    }

    var error: Binder<String> {
        return Binder(base) { view, error in
            view.errorLabel.text = error
            UIView.animate(withDuration: 0.25) {
                view.errorLabel.isHidden = error.isEmpty
                view.superview?.layoutIfNeeded()
            }
        }
    }
}

private extension ValidationTextfield {
    func setupView() {
        axis = .vertical
        distribution = .fill
        spacing = 8
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .systemBlue
        addArrangedSubview(textfield)
        addArrangedSubview(separator)
        addArrangedSubview(errorLabel)
        setCustomSpacing(16, after: separator)
        let constraints = [
            separator.heightAnchor.constraint(equalToConstant: 1)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
