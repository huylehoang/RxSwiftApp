import Foundation
import FirebaseAuth
import RxSwift
import RxCocoa

struct LoginViewModel: ViewModelType {
    enum Kind: Int, CaseIterable {
        case signIn = 0
        case signUp = 1

        var title: String {
            switch self {
            case .signIn: return "SIGN IN"
            case .signUp: return "SIGN UP"
            }
        }
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
        let nameValidator = TextValidator(.name, input: input.name)
        let emailValidator = TextValidator(.email, input: input.email)
        let passwordValidator = TextValidator(.password, input: input.password)
        let kind = BehaviorRelay(value: Kind.signIn)

        let fields = Driver.combineLatest(input.name, input.email, input.password)

        let nameError = input.loginTrigger.withLatestFrom(nameValidator.validate())

        let emailError = input.loginTrigger.withLatestFrom(emailValidator.validate())

        let passwordError = input.loginTrigger.withLatestFrom(passwordValidator.validate())

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

        let onLogin = input.loginTrigger
            .withLatestFrom(noneError)
            .filter { $0 }
            .withLatestFrom(fields)
            .map { (kind.value, $0, $1, $2, indicator, errorTracker) }
            .map(LoginCredential.init)
            .flatMapLatest(login)
            .do(onNext: navigator.toUser)

        let onSegmentChanged = input.segmentChanged
            .compactMap(Kind.init)
            .do(onNext: kind.accept)
            .mapToVoid()

        let resetSegment = input.viewDidDisappear
            .compactMap { Kind.signIn }
            .do(onNext: kind.accept)
            .mapToVoid()

        let onAction = Driver.merge(onLogin, onSegmentChanged, resetSegment)

        let selectedSegmentIndex = kind.map { $0.rawValue }.asDriverOnErrorJustComplete()

        let isSignIn = kind.compactMap { $0 == .signIn }.asDriverOnErrorJustComplete()

        let hideNameField = input.viewDidLoad.withLatestFrom(isSignIn)

        let animateHideNameField = isSignIn.skip(1)

        let loginButtonTitle = kind.map { $0.title }.asDriverOnErrorJustComplete()

        let emptyField = kind.map { _ in return "" }.asDriverOnErrorJustComplete()

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
        let request: Observable<Void> = {
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
