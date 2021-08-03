import RxSwift
import RxCocoa
import Domain

public class BaseViewController: UIViewController, KeyboardHandling {
    let contentView: UIView

    let disposeBag = DisposeBag()

    var transition: MainNavigationController.Transition {
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
        setupBinding()
        setupNavigationBar()
    }
}

// MARK: - Navigation Bar
extension BaseViewController {
    var navigationBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
            + (navigationController?.navigationBar.frame.height ?? 0.0)
    }

    struct NavigationBarBuilder: MutableType, Equatable {
        var hidesNavigationBar = false
        var hidesBackButton = true
        var leftBarButtonItems = [UIBarButtonItem]()
        var rightBarButtonItems = [UIBarButtonItem]()
        var searchController: UISearchController?
        var hidesSearchBarWhenScrolling = false
    }

    func navigationBarUpdate(by change: (inout NavigationBarBuilder) -> Void) {
        navigationBar.accept(navigationBar.value.updated(by: change))
    }
}

private extension BaseViewController {
    func setupBinding() {
        rx.viewDidLoad.bind(to: rx.setupKeyboardHandling).disposed(by: disposeBag)
    }

    func setupNavigationBar() {
        guard let navigationController = navigationController else { return }

        let updateNavigationBar = Driver.merge(
            rx.viewWillAppear.withLatestFrom(navigationBar).asDriverOnErrorJustComplete(),
            navigationBar.asDriver())
        let hideNavigationBar = updateNavigationBar.map { $0.hidesNavigationBar }
        let hidesBackButton = updateNavigationBar.map { $0.hidesBackButton }
        let rightBarButtonItems = updateNavigationBar.map { $0.rightBarButtonItems }
        let leftBarButtonItems = updateNavigationBar.map { $0.leftBarButtonItems }
        let searchController = updateNavigationBar.map { $0.searchController }
        let hidesSearchBarWhenScrolling = updateNavigationBar.map { $0.hidesSearchBarWhenScrolling }

        [
            hideNavigationBar.drive(navigationController.rx.isNavigationBarHidden),
            hidesBackButton.drive(navigationItem.rx.hidesBackButton),
            rightBarButtonItems.drive(navigationItem.rx.rightBarButtonItems),
            leftBarButtonItems.drive(navigationItem.rx.leftBarButtonItems),
            searchController.drive(navigationItem.rx.searchController),
            hidesSearchBarWhenScrolling.drive(navigationItem.rx.hidesSearchBarWhenScrolling)
        ]
        .forEach { $0.disposed(by: disposeBag) }
    }
}
