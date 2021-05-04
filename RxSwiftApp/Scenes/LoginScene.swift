import UIKit
import RxSwift
import RxCocoa

final class LoginScene: UIViewController {
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
        view.setTitle("LOGIN", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.setTitleColor(.lightGray, for: .disabled)
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return view
    }()

    private var viewModel: LoginViewModel!

    private let disposeBag = DisposeBag()

    override func loadView() {
        super.loadView()
        viewModel = LoginViewModel(usecase: LoginUsecase())
        setupView()
        setupObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

private extension LoginScene {
    func setupView() {
        view.backgroundColor = .white
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        view.addSubview(stackView)
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(loginButton)
        let constraints = [
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupObserver() {
        loginButton.rx.tap
            .bind { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)

        let input = LoginViewModel.Input(
            email: emailField.rx.text.asDriver(),
            emailIsEditing: emailField.rx.isEditing,
            password: passwordField.rx.text.asDriver(),
            passwordIsEditing: passwordField.rx.isEditing,
            loginTrigger: loginButton.rx.tap.asDriver())

        let output = viewModel.transform(input: input)

        [
            output.emailError.drive(emailField.rx.error),
            output.passwordError.drive(passwordField.rx.error),
            output.enableLogin.drive(loginButton.rx.isEnabled),
            output.onLogin.drive(),
        ]
        .forEach { $0.disposed(by: disposeBag) }

    }
}
