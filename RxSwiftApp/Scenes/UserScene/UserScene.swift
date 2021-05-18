import RxSwift
import RxCocoa

final class UserScene: BaseViewController {
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
        stackView.addArrangedSubview(displayNameLabel)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(reAuthenticateButton)
        stackView.addArrangedSubview(deleteButton)
        contentView.addSubview(signOutButton)
        Constraint.activate(
            stackView.centerY.equalTo(view.centerY),
            stackView.leading.equalTo(contentView.leading).constant(24),
            stackView.trailing.equalTo(contentView.trailing).constant(-24),
            signOutButton.top.equalTo(contentView.safeAreaLayoutGuide.top).constant(24),
            signOutButton.trailing.equalTo(contentView.trailing).constant(-24))
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
            .withUnretained(self)
            .flatMap { $0.showAlert(with: $1) }
            .filter { $0 == 1 }
            .mapToVoid()

        let input = UserViewModel.Input(
            viewDidLoad: rx.viewDidLoad.asDriver(),
            reAuthenticateTrigger: reAuthenticateButton.rx.tap.asDriver(),
            deleteTrigger: deleteTrigger.asDriverOnErrorJustComplete(),
            signOutTrigger: signOutButton.rx.tap.asDriver())

        let output = viewModel.transform(input: input)

        [
            output.onAction.drive(),
            output.showToast.drive(rx.showToast),
            output.displayName.drive(displayNameLabel.rx.text),
            output.email.drive(emailLabel.rx.text),
            output.embeddedLoading.drive(rx.showEmbeddedIndicatorView),
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
