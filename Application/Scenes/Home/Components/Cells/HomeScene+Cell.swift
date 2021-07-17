import Domain
import RxSwift
import RxCocoa

extension Reactive where Base: HomeScene.Cell {
    var isSelecting: Binder<Bool> {
        return Binder(base) { base, isSelecting in
            base.selectionStyle = isSelecting ? .none : .default
            guard base.radioButton.isHidden != !isSelecting else { return }
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseInOut,
                animations: {
                    base.radioButton.isHidden = !isSelecting
                    base.radioButton.alpha = isSelecting ? 1 : 0
                    base.radioButton.superview?.layoutIfNeeded()
                })
        }
    }
}

extension HomeScene {
    final class Cell: RxTableViewCell {
        private lazy var titleLabel: UILabel = {
            let view = UILabel()
            view.font = .systemFont(ofSize: 18)
            view.textColor = .darkText
            view.textAlignment = .left
            view.numberOfLines = 3
            view.lineBreakMode = .byTruncatingTail
            return view
        }()

        fileprivate lazy var radioButton: RadioButton = {
            let view = RadioButton()
            view.isUserInteractionEnabled = false
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        var item: CellViewModel! {
            didSet {
                config(with: item)
            }
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupView()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupView()
        }
    }
}

private extension HomeScene.Cell {
    func config(with item: HomeScene.CellViewModel) {
        let note = item.note
        titleLabel.text = note.title
        radioButton.isSelected = item.isSelected
    }

    func setupView() {
        backgroundColor = .white
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(radioButton)
        contentView.addSubview(stackView)
        Constraint.activate(
            radioButton.height.equalTo(24),
            radioButton.width.equalTo(24),
            radioButton.top.greaterThanOrEqualTo(contentView.top)
                .constant(16)
                .priority(.defaultLow),
            radioButton.bottom.greaterThanOrEqualTo(contentView.bottom)
                .constant(-16)
                .priority(.defaultLow),
            stackView.top.equalTo(contentView.top).constant(16),
            stackView.bottom.equalTo(contentView.bottom).constant(-16),
            stackView.leading.equalTo(contentView.leading).constant(16),
            stackView.trailing.equalTo(contentView.trailing).constant(-16))
    }
}
