import RxSwift
import RxCocoa

final class UserScene: BaseViewController {
    private lazy var uidLabel: UILabel = {
        return makeLabel()
    }()

    private lazy var displayNameLabel: UILabel = {
        return makeLabel()
    }()

    private lazy var emailLabel: UILabel = {
        return makeLabel()
    }()

    private lazy var reAuthenticateButton: UIButton = {
        let view = makeUserActionButton()
        view.setTitle("Re-Authenticate", for: .normal)
        return view
    }()

    private lazy var deleteButton: UIButton = {
        let view = makeUserActionButton()
        view.setTitle("Delete", for: .normal)
        return view
    }()

    private lazy var signOutButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("SIGN OUT", for: .normal)
        view.setTitleColor(.systemBlue, for: .normal)
        view.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.5), for: .highlighted)
        view.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        view.contentHorizontalAlignment = .leading
        return view
    }()

    private let viewModel: UserViewModel

    private let disposeBag = DisposeBag()

    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    deinit {
        dump("Deinit UserScene")
    }

    override func loadView() {
        super.loadView()
        setupView()
        setupBinding()
    }
}

private extension UserScene {
    func setupView() {
        contentView.backgroundColor = .white
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 16
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(uidLabel)
        stackView.addArrangedSubview(displayNameLabel)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(reAuthenticateButton)
        stackView.addArrangedSubview(deleteButton)
        contentView.addSubview(signOutButton)
        let constraints = [
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            signOutButton.topAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            signOutButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -24),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupBinding() {
        let deleteTrigger = deleteButton.rx.tap
            .map { AlertBuilder(
                title: "Delete User",
                message: "Are your sure you want to delete this user?",
                actions: [
                    .init(title: "Cancel", style: .destructive, tag: 0),
                    .init(title: "Confirm", style: .default, tag: 1),
                ])
            }
            .flatMap(weak: self) { $0.showAlert(with: $1) }
            .filter { $0 == 1 }
            .mapToVoid()

        let notiReAuthenticated = BehaviorRelay<Void>(value: ())
        notiReAuthenticated
            .skip(1)
            .map { "USER RE-AUTHENTICATED" }
            .flatMap(weak: self) { $0.showNotify(with: $1) }
            .subscribe()
            .disposed(by: disposeBag)

        let notiDeleted = BehaviorRelay<Void>(value: ())
        let confirmDeleted = notiDeleted
            .skip(1)
            .map { "USER DELETED" }
            .flatMap(weak: self) { $0.showNotify(with: $1) }

        let input = UserViewModel.Input(
            viewDidLoad: rx.viewDidLoad.asDriver(),
            reAuthenticateTrigger: reAuthenticateButton.rx.tap.asDriver(),
            deleteTrigger: deleteTrigger.asDriverOnErrorJustComplete(),
            signOutTrigger: signOutButton.rx.tap.asDriver(),
            confirmDelete: confirmDeleted.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input: input)

        [
            output.notiReAuthenticated.drive(notiReAuthenticated),
            output.notiDeleted.drive(notiDeleted),
            output.onAction.drive(),
            output.uid.drive(uidLabel.rx.text),
            output.displayName.drive(displayNameLabel.rx.text),
            output.email.drive(emailLabel.rx.text),
            output.embeddedLoading.drive(rx.showEmbeddedIndicator),
            output.errorMessage.drive(rx.showErrorMessage),
        ]
        .forEach { $0.disposed(by: disposeBag) }
    }
}

private extension UserScene {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18)
        view.textColor = .darkText
        view.numberOfLines = 0
        return view
    }

    func makeUserActionButton() -> UIButton {
        let view = UIButton()
        view.setTitleColor(.systemBlue, for: .normal)
        view.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.5), for: .highlighted)
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        return view
    }
}
