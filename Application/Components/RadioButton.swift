import UIKit
import RxSwift

final class RadioButton: UIButton {
    private let activeColor: UIColor = .systemBlue
    private let deactiveColor: UIColor = .lightGray

    private lazy var activeImageSize: CGSize = {
        let activeImageOffset = bounds.height * 1/4
        let width = (bounds.width - activeImageOffset).rounded()
        let height = (bounds.width - activeImageOffset).rounded()
        let imageSize = CGSize(width: width, height: height)
        return imageSize
    }()

    private lazy var activeImage: UIImage = {
        return activeColor.toImage(activeImageSize).withRenderingMode(.alwaysOriginal)
    }()

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

extension Reactive where Base: RadioButton {
    var isSelectedObs: Observable<Bool> {
        return observe(Bool.self, #keyPath(UIButton.isSelected)).compactMap { $0 }
    }
}

private extension RadioButton {
    func commonInit() {
        setupView()
        setupBinding()
    }

    func setupView() {
        isSelected = false
        tintColor = .clear
        layer.borderWidth = 2
    }

    func setupBinding() {
        rx.boundsChanged
            .take(1)
            .withUnretained(self)
            .bind { view, bounds in
                view.layer.cornerRadius = bounds.height / 2
                view.imageView?.layer.cornerRadius = view.activeImageSize.height / 2
            }
            .disposed(by: disposeBag)
        
        rx.isSelectedObs
            .map(getBorderColor)
            .distinctUntilChanged()
            .bind(to: layer.rx.borderColor)
            .disposed(by: disposeBag)

        rx.isSelectedObs
            .map(getImage)
            .distinctUntilChanged()
            .bind(to: rx.image(for: .normal))
            .disposed(by: disposeBag)

        rx.tap
            .withUnretained(self)
            .bind { view, _ in view.isSelected.toggle() }
            .disposed(by: disposeBag)
    }

    func getBorderColor(by isSelected: Bool) -> CGColor {
        let color = isSelected ? activeColor : deactiveColor
        return color.cgColor
    }

    func getImage(by isSelected: Bool) -> UIImage? {
        return isSelected ? activeImage : nil
    }
}
