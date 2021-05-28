import RxSwift

final class HomeScene: BaseViewController {
    private lazy var tableView: UITableView = {
        let view = RxTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.allowsMultipleSelection = false
        view.separatorStyle = .singleLine
        view.separatorColor = .lightGray
        view.separatorInset.left = 16
        view.estimatedRowHeight = 50
        view.rowHeight = 50
        view.refreshControl = refreshControl
        view.tableFooterView = UIView()
        return view
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        return view
    }()

    private lazy var addButton: UIBarButtonItem = {
        let view = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        return view
    }()

    private lazy var refreshButton: UIBarButtonItem = {
        let view = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
        return view
    }()

    private lazy var organizeButton: UIBarButtonItem = {
        let view = UIBarButtonItem(barButtonSystemItem: .organize, target: nil, action: nil)
        return view
    }()

    override var transition: MasterNavigationController.Transition? {
        return .crossDissolve
    }

    private let viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    deinit {
        dump("Deinit HomeScene")
    }

    override func loadView() {
        super.loadView()
        setupView()
        setupBinding()
    }
}

private extension HomeScene {
    func setupView() {
        navigationBarUpdate {
            $0.leftBarButtonItems = [organizeButton]
            $0.rightBarButtonItems = [addButton]
        }
        
        contentView.backgroundColor = .white
        contentView.addSubview(tableView)
        Constraint.activateGroup(tableView.equalToEdges(of: contentView))
    }

    func setupBinding() {
        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)

        let input = HomeViewModel.Input(
            viewDidLoad: rx.viewDidLoad.asDriver(),
            emptyRefreshTrigger: refreshButton.rx.tap.asDriver(),
            refreshTrigger: refreshControl.rx.controlEvent(.valueChanged).asDriver(),
            toAddNoteTrigger: addButton.rx.tap.asDriver(),
            toUserTrigger: organizeButton.rx.tap.asDriver(),
            itemSelected: tableView.rx.itemSelected.asDriver())

        let output = viewModel.transform(input: input)

        [
            output.title.drive(rx.title),
            output.noteTitles.drive(tableView.rx.items) { _, _, title in
                let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                cell.textLabel?.text = title
                cell.textLabel?.numberOfLines = 0
                return cell
            },
            output.isEmpty.drive(isEmpty),
            output.emptyMessage.drive(rx.showEmbeddedEmptyView()),
            output.embeddedLoading.drive(rx.showEmbeddedIndicator),
            output.refreshLoading.drive(refreshControl.rx.isRefreshing),
            output.errorMessage.drive(rx.showToast),
            output.onAction.drive(),
        ]
        .forEach { $0.disposed(by: disposeBag) }
    }
}

private extension HomeScene {
    var isEmpty: Binder<Bool> {
        return Binder(self) { base, isEmpty in
            let rightBarButtonItems: [UIBarButtonItem] = {
                if isEmpty {
                    return [base.addButton, base.refreshButton]
                } else {
                    return [base.addButton]
                }
            }()
            base.navigationBarUpdate { $0.rightBarButtonItems = rightBarButtonItems }
        }
    }
}
