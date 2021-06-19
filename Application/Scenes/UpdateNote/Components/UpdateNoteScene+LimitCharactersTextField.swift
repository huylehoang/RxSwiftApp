import RxSwift
import RxCocoa

extension UpdateNoteScene {
    final class LimitCharactersTextField: UIStackView {
        fileprivate lazy var textField: UITextField = {
            let view = PaddingTextField()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = .systemFont(ofSize: 16, weight: .regular)
            view.borderStyle = .none
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 8
            view.textColor = .darkText
            view.autocapitalizationType = .none
            view.autocorrectionType = .no
            view.borderStyle = .none
            return view
        }()

        private lazy var counterLabel: UILabel = {
            let view = UILabel()
            view.font = .systemFont(ofSize: 11)
            view.textAlignment = .left
            view.minimumScaleFactor = 0.5
            return view
        }()

        var placeholder: String? {
            didSet {
                textField.placeholder = placeholder
            }
        }

        fileprivate let currentText = BehaviorSubject(value: "")

        private let disposeBag = DisposeBag()

        private let limitCharacters: Int

        init(limit: Int) {
            limitCharacters = limit
            super.init(frame: .zero)
            commonInit()
        }

        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension Reactive where Base: UpdateNoteScene.LimitCharactersTextField {
    var text: ControlProperty<String> {
        return ControlProperty(
            values: base.currentText.asObservable(),
            valueSink: base.currentText.asObserver())
    }

    var endEditing: ControlEvent<Void> {
        return base.textField.rx.controlEvent(.editingDidEnd)
    }
}

private extension UpdateNoteScene.LimitCharactersTextField {
    func commonInit() {
        setupView()
        setupBinding()
    }

    func setupView() {
        axis = .vertical
        alignment = .trailing
        distribution = .fill
        spacing = 8
        addArrangedSubview(textField)
        addArrangedSubview(counterLabel)
        Constraint.activate(
            textField.width.equalTo(width),
            textField.height.equalTo(height, multiplier: 2/3))
    }

    func setupBinding() {
        Observable.merge(
            textField.rx.controlEvent(.editingChanged).asObservable(),
            textField.rx.deleteBackward.asObservable())
            .withUnretained(textField)
            .compactMap { textField, _ in textField.text }
            .map(getLimitedText)
            .bind(to: currentText)
            .disposed(by: disposeBag)

        currentText
            .map(getCounterString)
            .bind(to: counterLabel.rx.text)
            .disposed(by: disposeBag)

        currentText
            .map(getCounterLabelColor)
            .bind(to: counterLabel.rx.textColor)
            .disposed(by: disposeBag)

        currentText
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
    }

    func getLimitedText(from text: String) -> String {
        return String(text.prefix(limitCharacters))
    }

    func getCounterString(from text: String) -> String {
        return text.count.description + "/" + limitCharacters.description
    }

    func getCounterLabelColor(from text: String) -> UIColor {
        return text.count == limitCharacters ? .systemRed : .darkText
    }
}
