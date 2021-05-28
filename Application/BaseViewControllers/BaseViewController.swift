import RxSwift
import RxCocoa
import Domain

public class BaseViewController: UIViewController {
    let contentView: UIView

    let disposeBag = DisposeBag()

    var transition: MasterNavigationController.Transition? {
        return .normal
    }

    private let navigationBar = BehaviorRelay(value: NavigationBarBuilder())

    init() {
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = UIView()
        view.addSubview(contentView)
        Constraint.activate(
            contentView.leading.equalTo(view.leading),
            contentView.trailing.equalTo(view.trailing).priority(.level(999)),
            contentView.top.equalTo(view.top),
            contentView.bottom.equalTo(view.bottom))
        setupNavigationBar()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

extension BaseViewController {
    struct NavigationBarBuilder: MutableType {
        var hidesNavigationBar = false
        var hidesBackButton = true
        var leftBarButtonItems = [UIBarButtonItem]()
        var rightBarButtonItems = [UIBarButtonItem]()
    }

    func navigationBarUpdate(by change: (inout NavigationBarBuilder) -> Void) {
        navigationBar.accept(navigationBar.value.updated(by: change))
    }
}

private extension BaseViewController {
    func setupNavigationBar() {
        guard let navigationController = navigationController else { return }
        navigationController.interactivePopGestureRecognizer?.isEnabled = false

        let hideNavigationBar = navigationBar.map { $0.hidesNavigationBar }
        let hidesBackButton = navigationBar.map { $0.hidesBackButton }
        let rightBarButtonItems = navigationBar.map { $0.rightBarButtonItems }
        let leftBarButtonItems = navigationBar.map { $0.leftBarButtonItems }

        [
            hideNavigationBar.bind(to: navigationController.rx.isNavigationBarHidden),
            hidesBackButton.bind(to: navigationItem.rx.hidesBackButton),
            rightBarButtonItems.bind(to: navigationItem.rx.rightBarButtonItems),
            rightBarButtonItems.bind(to: barButtonsForceEndEditing),
            leftBarButtonItems.bind(to: navigationItem.rx.leftBarButtonItems),
            leftBarButtonItems.bind(to: barButtonsForceEndEditing),
        ]
        .forEach { $0.disposed(by: disposeBag) }
    }

    var barButtonsForceEndEditing: Binder<[UIBarButtonItem]> {
        return Binder(self) { base, barButtons in
            barButtons.forEach {
                $0.rx.tap.bind(to: base.rx.forceEndEditing).disposed(by: base.disposeBag)
            }
        }
    }
}
