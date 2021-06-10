import Domain
import RxSwift
import RxCocoa

extension HomeScene {
    final class Cell: RxTableViewCell {
        private lazy var titleLabel: UILabel = {
            let view = UILabel()
            view.font = .systemFont(ofSize: 18)
            view.textColor = .darkText
            view.textAlignment = .left
            view.numberOfLines = 0
            return view
        }()

        fileprivate lazy var radioButton: RadioButton = {
            let view = RadioButton()
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

extension Reactive where Base: HomeScene.Cell {
    var isSelecting: Binder<Bool> {
        return Binder(base) { base, isSelecting in
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

    var itemChecked: Observable<HomeScene.CellViewModel> {
        return base.radioButton.rx.isSelectedObs
            .filter { $0 }
            .withLatestFrom(Observable.just(base.item))
    }

    var itemUnchecked: Observable<HomeScene.CellViewModel> {
        return base.radioButton.rx.isSelectedObs
            .filter { !$0 }
            .withLatestFrom(Observable.just(base.item))
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
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(radioButton)
        contentView.addSubview(stackView)
        Constraint.activate(
            radioButton.height.equalTo(24),
            radioButton.width.equalTo(24),
            stackView.top.equalTo(contentView.top).constant(16),
            stackView.bottom.equalTo(contentView.bottom).constant(-16).priority(.level(999)),
            stackView.leading.equalTo(contentView.leading).constant(16),
            stackView.trailing.equalTo(contentView.trailing).constant(-16))
    }
}
