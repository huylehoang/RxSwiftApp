import Domain
import RxSwift
import RxCocoa

final class HomeScene: BaseViewController {
    private lazy var tableView: UITableView = {
        let view = RxTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.allowsMultipleSelection = false
        view.separatorStyle = .singleLine
        view.separatorColor = .lightGray
        view.separatorInset.left = 16
        view.estimatedRowHeight = 54
        view.rowHeight = UITableView.automaticDimension
        view.register(Cell.self)
        view.refreshControl = refreshControl
        let tableFooterView = UIView()
        tableFooterView.frame.size.height = deleteButtonHeight
        view.tableFooterView = tableFooterView
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

    private lazy var cancelButton: UIBarButtonItem = {
        let view = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        return view
    }()

    private lazy var actionView: ActionView = {
        let view = ActionView(home: self)
        return view
    }()

    private lazy var deleteButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Delete", for: .normal)
        view.setTitleColor(.systemBlue, for: .normal)
        view.setTitleColor(.systemBlue.withAlphaComponent(0.7), for: .highlighted)
        view.setTitleColor(.lightGray, for: .disabled)
        view.backgroundColor = .white
        view.titleLabel?.font = .systemFont(ofSize: 18)
        view.applyMediumShadow()
        return view
    }()

    private lazy var searchController: UISearchController = {
        let controller = UISearchController()
        controller.hidesNavigationBarDuringPresentation = false
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search..."
        controller.searchBar.showsCancelButton = true
        controller.searchBar.autocapitalizationType = .none
        return controller
    }()

    override var transition: MainNavigationController.Transition {
        return .crossDissolve
    }

    private lazy var deleteButtonBottomConstraint: Constraint = {
        let contraint = deleteButton.bottom.equalTo(contentView.bottom).constant(deleteButtonHeight)
        return contraint
    }()

    private let deleteButtonHeight: CGFloat = 56

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
        contentView.addSubview(deleteButton)
        Constraint.activate(
            deleteButtonBottomConstraint,
            deleteButton.leading.equalTo(contentView.leading),
            deleteButton.trailing.equalTo(contentView.trailing),
            deleteButton.height.equalTo(deleteButtonHeight))
    }

    func setupBinding() {
        tableView.rx.itemSelected
            .withUnretained(self)
            .bind { $0.tableView.deselectRow(at: $1, animated: true) }
            .disposed(by: disposeBag)

        let searchTrigger = actionView.rx.didTapAction.filter { $0 == .search }.mapToVoid()

        let cancelSearchTrigger = searchController.searchBar.rx.cancelButtonClicked.asDriver()

        let searchText = searchController.searchBar.rx.text.orEmpty.asDriver()

        let toProfileTrigger = actionView.rx.didTapAction.filter { $0 == .toProfile }.mapToVoid()

        let selectAllTrigger = actionView.rx.didTapAction.filter { $0 == .selectAll }.mapToVoid()

        let deleteTrigger = deleteButton.rx.tap
            .map {
                AlertBuilder(
                    title: "Delete Notes",
                    message: "Are your sure you want to delete all selected note?",
                    style: .alert,
                    actions: [
                        .init(title: "Cancel", style: .destructive, tag: 0),
                        .init(title: "Confirm", style: .default, tag: 1),
                    ])
            }
            .withUnretained(self)
            .flatMap { $0.showAlert(with: $1) }
            .filter { $0 == 1 }
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let input = HomeViewModel.Input(
            viewDidLoad: rx.viewDidLoad.asDriver(),
            viewWillDisappear: rx.viewWillDisappear.asDriver(),
            emptyRefreshTrigger: refreshButton.rx.tap.asDriver(),
            refreshTrigger: refreshControl.rx.controlEvent(.valueChanged).asDriver(),
            toAddNoteTrigger: addButton.rx.tap.asDriver(),
            toProfileTrigger: toProfileTrigger,
            searchTrigger: searchTrigger,
            cancelSearchTrigger: cancelSearchTrigger,
            searchText: searchText,
            selectAllTrigger: selectAllTrigger,
            organizeTrigger: organizeButton.rx.tap.asDriver(),
            tableViewDidScroll: tableView.rx.didScroll.asDriver(),
            actionViewDismissed: actionView.rx.dismissed,
            cancelTrigger: cancelButton.rx.tap.asDriver(),
            itemSelected: tableView.rx.modelSelected(CellViewModel.self).asDriver(),
            deleteTrigger: deleteTrigger)

        let output = viewModel.transform(input: input)

        [
            output.embeddedLoading.drive(rx.showEmbeddedIndicator),
            output.embeddedLoadingView.drive(rx.showEmbeddedIndicatorView),
            output.refreshLoading.drive(refreshControl.rx.isRefreshing),
            output.enableDelete.drive(deleteButton.rx.isEnabled),
            output.isSelectingAll.drive(isSelectingAll),
            output.enableSearch.drive(enableSearch),
            output.items.drive(tableView.rx.items) { tableView, row, item in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = tableView.dequeueReusableCell(Cell.self, for: indexPath)
                cell.item = item

                output.isSelectingAll
                    .drive(cell.rx.isSelecting)
                    .disposed(by: cell.disposeBag)

                return cell
            },
            output.disableActions.drive(actionView.rx.disableActions(.search, .selectAll)),
            output.title.drive(rx.title),
            output.hideTableView.drive(animateHideTableView),
            output.isEmpty.drive(isEmpty),
            output.emptyMessage.drive(rx.showEmbeddedEmptyView()),
            output.errorMessage.drive(rx.showToast),
            output.enableOrganize.drive(organizeButton.rx.isEnabled),
            output.showActionView.drive(actionView.rx.show),
            output.onAction.drive(),
        ]
        .forEach { $0.disposed(by: disposeBag) }
    }
}

private extension HomeScene {
    var animateHideTableView: Binder<Bool> {
        return Binder(self) { base, isHidden in
            if !isHidden {
                base.tableView.isHidden = false
            }
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseInOut,
                animations: {
                    base.tableView.alpha = isHidden ? 0 : 1
                },
                completion: { _ in
                    guard isHidden else { return }
                    base.tableView.isHidden = true
                })
        }
    }

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

    var isSelectingAll: Binder<Bool> {
        return Binder(self) { base, isSelectingAll in
            let constant: CGFloat = isSelectingAll ? 0 : base.deleteButtonHeight
            base.deleteButtonBottomConstraint.constant = constant
            let leftBarButtonItems = isSelectingAll ? [base.cancelButton] : [base.organizeButton]
            base.navigationBarUpdate { $0.leftBarButtonItems = leftBarButtonItems }
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseInOut,
                animations: {
                    base.contentView.layoutIfNeeded()
                })
        }
    }

    var enableSearch: Binder<Bool> {
        return Binder(self) { base, enableSearch in
            if !enableSearch {
                base.tableView.refreshControl = base.refreshControl
                base.searchController.searchBar.text = ""
                base.searchController.searchBar.resignFirstResponder()
                UIView.animate(
                    withDuration: 0.25,
                    animations: {
                        base.searchController.searchBar.alpha = 0
                    },
                    completion: { _ in
                        base.navigationBarUpdate { $0.searchController = nil }
                    })
            } else {
                base.tableView.refreshControl = nil
                base.navigationBarUpdate { $0.searchController = base.searchController }
                base.searchController.searchBar.alpha = 0
                UIView.animate(
                    withDuration: 0.25,
                    animations: {
                        base.searchController.searchBar.alpha = 1
                    })
            }
        }
    }
}
