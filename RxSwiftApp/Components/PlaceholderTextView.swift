import RxSwift

final class PlaceholderTextView: UITextView {
    private lazy var placeholderLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.textColor = UIColor.lightGray.withAlphaComponent(0.7)
        return view
    }()

    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    override var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }

    private let disposeBag = DisposeBag()

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

private extension PlaceholderTextView {
    func setupView() {
        addSubview(placeholderLabel)
        let topConstant: CGFloat = 5
        let halfFontPointSize = font?.pointSize ?? topConstant / 2
        Constraint.activate(
            placeholderLabel.leading.equalTo(leading).constant(5),
            placeholderLabel.trailing.equalTo(trailing).constant(-5),
            placeholderLabel.top.equalTo(top).constant(topConstant + halfFontPointSize))

        rx.text.orEmpty
            .map { !$0.isEmpty }
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
