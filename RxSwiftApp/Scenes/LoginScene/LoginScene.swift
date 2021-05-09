import UIKit
import RxSwift
import RxCocoa

final class LoginScene: BaseViewController {
    private lazy var segmentControl: UISegmentedControl = {
        let items = LoginViewModel.Kind.allCases.map { $0.title }
        let view = UISegmentedControl(items: items)
        return view
    }()

    private lazy var nameField: ValidationTextfield = {
        let view = ValidationTextfield()
        view.placeholder = "Enter name..."
        return view
    }()

    private lazy var emailField: ValidationTextfield = {
        let view = ValidationTextfield()
        view.placeholder = "Enter email..."
        return view
    }()

    private lazy var passwordField: ValidationTextfield = {
        let view = ValidationTextfield()
        view.placeholder = "Enter password..."
        view.isSecrectTextEntry = true
        return view
    }()

    private lazy var loginButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        view.setTitleColor(.white, for: .normal)
        view.setTitleColor(.lightGray, for: .disabled)
        view.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return view
    }()

    private let viewModel: LoginViewModel

    private let disposeBag = DisposeBag()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    deinit {
        dump("Deinit LoginScene")
    }

    override func loadView() {
        super.loadView()
        setupView()
        setupBinding()
    }
}

private extension LoginScene {
    func setupView() {
        contentView.backgroundColor = .white
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.distribution = .fill
        stackView.alignment = .fill
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(segmentControl)
        stackView.addArrangedSubview(nameField)
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(loginButton)
        let constraints = [
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupBinding() {
        loginButton.rx.tap
            .bind { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)

        let input = LoginViewModel.Input(
            viewDidLoad: rx.viewDidLoad.asDriver(),
            name: nameField.rx.text.asDriver(),
            email: emailField.rx.text.asDriver(),
            password: passwordField.rx.text.asDriver(),
            segmentChanged: segmentControl.rx.selectedSegmentIndex.asDriver(),
            loginTrigger: loginButton.rx.tap.asDriver(),
            viewDidDisappear: rx.viewDidDisappear.asDriver())

        let output = viewModel.transform(input: input)

        [
            output.nameError.drive(nameField.rx.error),
            output.emailError.drive(emailField.rx.error),
            output.passwordError.drive(passwordField.rx.error),
            output.enableLogin.drive(loginButton.rx.isEnabled),
            output.onLogin.drive(),
            output.onSegmentChanged.drive(),
            output.resetSegment.drive(),
            output.selectedSegmentIndex.drive(segmentControl.rx.selectedSegmentIndex),
            output.hideNameField.drive(nameField.rx.isHidden),
            output.animateHideNameField.drive(nameField.rx.animatedHiddden),
            output.loginButtonTitle.drive(loginButton.rx.title()),
            output.emptyField.drive(nameField.rx.forceEmpty),
            output.emptyField.drive(emailField.rx.forceEmpty),
            output.emptyField.drive(passwordField.rx.forceEmpty),
            output.embeddedLoading.drive(rx.showEmbeddedIndicator),
            output.errorMessage.drive(rx.showErrorMessage),
        ]
        .forEach { $0.disposed(by: disposeBag) }
    }
}
