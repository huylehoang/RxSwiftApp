import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: LoginScene.ValidationTextField {
    var text: ControlProperty<String> {
        return ControlProperty(
            values: base.currentText.asObservable(),
            valueSink: base.currentText.asObserver())
    }

    var error: Binder<String> {
        return Binder(base) { view, error in
            view.errorLabel.text = error
            let isHidden = error.isEmpty
            guard view.errorLabel.isHidden != isHidden else { return }
            UIView.animate(withDuration: 0.25) {
                view.errorLabel.isHidden = isHidden
                view.layoutIfNeeded()
            }
        }
    }

    var animatedHiddden: Binder<Bool> {
        return Binder(base) { view, hidden in
            guard view.isHidden != hidden else { return }
            UIView.animate(withDuration: 0.25) {
                view.isHidden = hidden
                view.alpha = hidden ? 0 : 1
                view.superview?.layoutIfNeeded()
            }
        }
    }
}

extension LoginScene {
    final class ValidationTextField: UIStackView {
        fileprivate lazy var textField: UITextField = {
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

        private lazy var separator: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        var placeholder: String = "" {
            didSet {
                textField.placeholder = placeholder
            }
        }

        var isSecrectTextEntry: Bool = false {
            didSet {
                textField.isSecureTextEntry = isSecrectTextEntry
            }
        }

        fileprivate let currentText = BehaviorSubject(value: "")

        private let disposeBag = DisposeBag()

        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }

        required init(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
    }
}

private extension LoginScene.ValidationTextField {
    func commonInit() {
        setupView()
        setupBinding()
    }

    func setupView() {
        axis = .vertical
        distribution = .fill
        spacing = 8
        addArrangedSubview(textField)
        addArrangedSubview(separator)
        addArrangedSubview(errorLabel)
        setCustomSpacing(16, after: separator)
        Constraint.activate(separator.height.equalTo(1))
    }

    func setupBinding() {
        Observable.merge(
            textField.rx.controlEvent(.editingChanged).asObservable(),
            textField.rx.deleteBackward.asObservable())
            .withUnretained(textField)
            .compactMap { textField, _ in textField.text }
            .bind(to: currentText)
            .disposed(by: disposeBag)

        currentText
            .map(getSeparatorColor)
            .bind(to: separator.rx.backgroundColor)
            .disposed(by: disposeBag)

        currentText
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
    }

    func getSeparatorColor(with text: String) -> UIColor {
        return text.isEmpty ? .lightGray.withAlphaComponent(0.7) : .systemBlue
    }
}
