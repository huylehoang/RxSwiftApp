import RxSwift
import RxCocoa
import Domain

struct LoginViewModel: ViewModelType {
    enum Kind: Int, CaseIterable {
        case signIn = 0
        case signUp = 1
    }

    struct Input {
        let viewDidLoad: Driver<Void>
        let name: Driver<String>
        let email: Driver<String>
        let password: Driver<String>
        let segmentChanged: Driver<Int>
        let loginTrigger: Driver<Void>
        let viewDidDisappear: Driver<Void>
    }

    struct Output {
        let nameError: Driver<String>
        let emailError: Driver<String>
        let passwordError: Driver<String>
        let enableLogin: Driver<Bool>
        let onAction: Driver<Void>
        let selectedSegmentIndex: Driver<Int>
        let hideNameField: Driver<Bool>
        let animateHideNameField: Driver<Bool>
        let loginButtonTitle: Driver<String>
        let emptyField: Driver<String>
        let embeddedLoading: Driver<Bool>
        let errorMessage: Driver<String>
    }

    private let usecase: LoginUsecase
    private let navigator: LoginNavigator

    init(usecase: LoginUsecase, navigator: LoginNavigator) {
        self.usecase = usecase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let indicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let kind = BehaviorRelay(value: Kind.signIn)
        let nameField = BehaviorRelay(value: "")
        let emailField = BehaviorRelay(value: "")
        let passwordField = BehaviorRelay(value: "")

        let onSegmentChanged = Driver.merge(
            input.segmentChanged.compactMap(Kind.init),
            input.viewDidDisappear.map { Kind.signIn })
            .do(onNext: kind.accept)
            .mapToVoid()

        let onNameField = input.name.do(onNext: nameField.accept).mapToVoid()

        let onEmailField = input.email.do(onNext: emailField.accept).mapToVoid()

        let onPasswordField = input.password.do(onNext: passwordField.accept).mapToVoid()

        let validateTrigger = Driver.merge(input.loginTrigger, onSegmentChanged)

        let nameError = validateTrigger
            .withLatestFrom(TextValidator.name.validate(nameField.asDriver()))
            .distinctUntilChanged()

        let emailError = validateTrigger
            .withLatestFrom(TextValidator.email.validate(emailField.asDriver()))
            .distinctUntilChanged()

        let passwordError = validateTrigger
            .withLatestFrom(TextValidator.password.validate(passwordField.asDriver()))
            .distinctUntilChanged()

        let noneError = Driver.combineLatest(nameError, emailError, passwordError)
            .map { combined -> Bool in
                switch kind.value {
                case .signIn:
                    return combined.1.isEmpty && combined.2.isEmpty
                case .signUp:
                    return combined.0.isEmpty && combined.1.isEmpty && combined.2.isEmpty
                }
            }
            .distinctUntilChanged()

        let fields = Driver.combineLatest(
            nameField.asDriver(),
            emailField.asDriver(),
            passwordField.asDriver())

        let enableLogin = fields
            .map { combined -> Bool in
                switch kind.value {
                case .signIn:
                    return !combined.1.isEmpty && !combined.2.isEmpty
                case .signUp:
                    return !combined.0.isEmpty && !combined.1.isEmpty && !combined.2.isEmpty
                }
            }
            .distinctUntilChanged()

        let onLogin = input.loginTrigger
            .withLatestFrom(noneError)
            .filter { $0 }
            .withLatestFrom(fields)
            .map { (kind.value, $0, $1, $2, indicator, errorTracker) }
            .map(LoginCredential.init)
            .flatMapLatest(login)
            .do(onNext: navigator.toHome)

        let onAction = Driver.merge(
            onLogin,
            onSegmentChanged,
            onNameField,
            onEmailField,
            onPasswordField)

        let selectedSegmentIndex = kind.map { $0.rawValue }.asDriverOnErrorJustComplete()

        let isSignIn = kind.compactMap { $0 == .signIn }.asDriverOnErrorJustComplete()

        let hideNameField = input.viewDidLoad.withLatestFrom(isSignIn)

        let animateHideNameField = isSignIn.skip(1)

        let loginButtonTitle = kind.map { $0.title }.asDriverOnErrorJustComplete()

        let emptyField = kind.map { _ in "" }
            .do(onNext: {
                nameField.accept($0)
                emailField.accept($0)
                passwordField.accept($0)
            })
            .asDriverOnErrorJustComplete()

        let embeddedLoading = indicator.asDriver()

        let errorMessage = errorTracker.asDriver().map { $0.localizedDescription }

        return Output(
            nameError: nameError,
            emailError: emailError,
            passwordError: passwordError,
            enableLogin: enableLogin,
            onAction: onAction,
            selectedSegmentIndex: selectedSegmentIndex,
            hideNameField: hideNameField,
            animateHideNameField: animateHideNameField,
            loginButtonTitle: loginButtonTitle,
            emptyField: emptyField,
            embeddedLoading: embeddedLoading,
            errorMessage: errorMessage)
    }
}

extension LoginViewModel.Kind {
    var title: String {
        switch self {
        case .signIn: return "SIGN IN"
        case .signUp: return "SIGN UP"
        }
    }
}

private extension LoginViewModel {
    struct LoginCredential {
        let kind: Kind
        let name: String
        let email: String
        let password: String
        let indicator: ActivityIndicator
        let errorTracker: ErrorTracker
    }

    func login(_ credential: LoginCredential) -> Driver<Void> {
        let request: Single<Void> = {
            switch credential.kind {
            case .signIn:
                return usecase.signIn(withEmail: credential.email, password: credential.password)
            case .signUp:
                return usecase.signUp(
                    withName: credential.name,
                    email: credential.email,
                    password: credential.password)
            }
        }()
        return request
            .trackActivity(credential.indicator)
            .trackError(credential.errorTracker)
            .asDriverOnErrorJustComplete()
    }
}
