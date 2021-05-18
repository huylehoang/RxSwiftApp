import RxSwift

class BaseViewController: UIViewController {
    let contentView: UIView

    var hideNavigationBar: Bool {
        return true
    }

    var hidesBackButton: Bool {
        return true
    }

    var leftBarButtonItems: [UIBarButtonItem] {
        return []
    }

    var rightBarButtonItems: [UIBarButtonItem] {
        return []
    }

    private(set) lazy var disposeBag = DisposeBag()

    init() {
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.addSubview(contentView)
        Constraint.activate(
            contentView.leading.equalTo(view.leading),
            contentView.trailing.equalTo(view.trailing).priority(.level(999)),
            contentView.top.equalTo(view.top),
            contentView.bottom.equalTo(view.bottom))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

private extension BaseViewController {
    func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(hideNavigationBar, animated: false)
        navigationItem.setHidesBackButton(hidesBackButton, animated: false)
        navigationItem.rightBarButtonItems = rightBarButtonItems
        navigationItem.leftBarButtonItems = leftBarButtonItems

        rightBarButtonItems.forEach {
            $0.rx.tap.bind(to: rx.forceEndEditing).disposed(by: disposeBag)
        }

        leftBarButtonItems.forEach {
            $0.rx.tap.bind(to: rx.forceEndEditing).disposed(by: disposeBag)
        }
    }
}
