import RxSwift
import RxCocoa

extension Reactive where Base: HomeScene.ActionView {
    var didTapAction: Driver<HomeScene.Action> {
        return base.didTapAction.asDriverOnErrorJustComplete()
    }

    var dismissed: Driver<Void> {
        return base.dismissed.asDriverOnErrorJustComplete()
    }

    func disableActions(_ actions: HomeScene.Action...) -> Binder<Bool> {
        return Binder(base) { base, disable in
            base
                .stackView
                .arrangedSubviews
                .compactMap { $0 as? UIButton }
                .filter { actions.map { $0.rawValue }.contains($0.currentTitle)  }
                .forEach { $0.isEnabled = !disable }
        }
    }

    var show: Binder<Bool> {
        return Binder(base) { base, show in
            show ? base.show() : base.dismiss()
        }
    }
}

extension HomeScene {
    enum Action: String, CaseIterable {
        case search = "Search"
        case selectAll = "Select All"
        case toProfile = "Profile"
    }

    private struct ActionViewConstraintsModel {
        var top: Constraint? = nil
        var leading: Constraint? = nil
        var width: Constraint? = nil
        
        var constraints: [Constraint] {
            return [top, leading, width].compactMap { $0 }
        }
    }

    final class ActionView: UIView, TapOutsideDimissal {
        fileprivate lazy var stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.clipsToBounds = true
            stackView.axis = .vertical
            stackView.spacing = 0
            stackView.alignment = .fill
            stackView.distribution = .fill
            return stackView
        }()

        fileprivate var selectAllButton: UIButton? {
            return stackView
                .arrangedSubviews
                .compactMap { $0 as? UIButton }
                .first(where: { $0.currentTitle == HomeScene.Action.selectAll.rawValue })
        }

        private let actions = HomeScene.Action.allCases
        private let animationDuration: TimeInterval = 0.25
        private var showAnimator: UIViewPropertyAnimator?
        private var dismissAnimator: UIViewPropertyAnimator?

        private var constraintsModel = ActionViewConstraintsModel()

        fileprivate let didTapAction = PublishRelay<Action>()
        fileprivate let dismissed = PublishRelay<Void>()

        private let disposeBag = DisposeBag()

        private weak var home: HomeScene?

        init(home: HomeScene) {
            self.home = home
            super.init(frame: .zero)
            commonInit()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        fileprivate func show() {
            setupConstraints()
            setupTapOutsideGesture()
            alpha = 0
            transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            showAnimator?.stopAnimation(true)
            dismissAnimator?.stopAnimation(true)
            showAnimator = UIViewPropertyAnimator(
                duration: animationDuration,
                dampingRatio: 1.0,
                animations: { [weak self] in
                    guard let self = self else { return }
                    self.alpha = 1
                    self.transform = .identity
                })
            showAnimator?.startAnimation()
        }

        fileprivate func dismiss() {
            dismissed.accept(())
            removeTapOutsideGesture()
            showAnimator?.stopAnimation(true)
            guard !(dismissAnimator?.isRunning ?? false) else { return }
            dismissAnimator = UIViewPropertyAnimator(
                duration: animationDuration,
                dampingRatio: 1.0,
                animations: { [weak self] in
                    guard let self = self else { return }
                    self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    self.alpha = 0
                })
            dismissAnimator?.addCompletion({ [weak self] _ in
                guard let self = self else { return }
                self.removeFromSuperview()
            })
            dismissAnimator?.startAnimation()
        }
    }
}

private extension HomeScene.ActionView {
    var topOffSetForAnchorPoint: CGFloat {
        return bounds.size.width * 0.3
    }

    var leadingOffSetForAnchorPoint: CGFloat {
        return bounds.size.width * 0.5
    }

    func setupConstraints() {
        guard let home = home, !isDescendant(of: home.contentView) else { return }
        home.contentView.addSubview(self)
        constraintsModel.top = top.equalTo(home.contentView.top)
            .constant((home.navigationBarHeight + 4) - topOffSetForAnchorPoint)
        constraintsModel.leading = leading.equalTo(home.contentView.leading)
            .constant(16 - leadingOffSetForAnchorPoint)
        constraintsModel.width = width.equalTo(home.contentView.width, multiplier: 3/5)
        Constraint.activate(constraintsModel.constraints)
    }

    func commonInit() {
        setupView()
        setUpBinding()
    }

    func setupView() {
        layer.anchorPoint = .zero
        layer.cornerRadius = 16
        clipsToBounds = true
        backgroundColor = .lightGray
        actions.enumerated().forEach(setupButtonsInStackView)
        addSubview(stackView)
        Constraint.activate(stackView.equalToEdges(of: self))
    }

    func setUpBinding() {
        Observable.merge(didTapAction.mapToVoid(), rx.tappedOutside)
            .withUnretained(self)
            .bind { view, _ in view.dismiss() }
            .disposed(by: disposeBag)

        rx.boundsChanged
            .take(1)
            .withUnretained(self)
            .bind { view, _ in
                view.constraintsModel.top?.constant -= view.topOffSetForAnchorPoint
                view.constraintsModel.leading?.constant -= view.leadingOffSetForAnchorPoint
            }
            .disposed(by: disposeBag)
    }

    func setupButtonsInStackView(at index: Int, with action: HomeScene.Action) {
        let button = makeButton(with: action)

        // Action
        button.rx.tap
            .withLatestFrom(Observable.just(action))
            .bind(to: didTapAction)
            .disposed(by: disposeBag)

        Constraint.activate(button.height.equalTo(50))
        stackView.addArrangedSubview(button)

        // Add separator
        guard index != actions.count - 1 else { return }
        let separator = makeSeparator()
        stackView.addArrangedSubview(separator)
        Constraint.activate(separator.height.equalTo(1))
    }

    func makeButton(with action: HomeScene.Action) -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentEdgeInsets.left = 8
        view.contentHorizontalAlignment = .leading
        view.setTitle(action.rawValue, for: .normal)
        view.setTitleColor(.darkText, for: .normal)
        view.setTitleColor(.darkText.withAlphaComponent(0.5), for: .disabled)
        view.setBackgroundImage(
            UIColor.white.withAlphaComponent(0.5).toImage(),
            for: .highlighted)
        return view
    }

    func makeSeparator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.5)
        return view
    }
}
