import Foundation
import FirebaseAuth
import RxSwift
import RxCocoa

final class LoginViewModel: ViewModelType {
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
        let onLogin: Driver<Void>
        let onSegmentChanged: Driver<Void>
        let resetSegment: Driver<Void>
        let selectedSegmentIndex: Driver<Int>
        let hideNameField: Driver<Bool>
        let loginButtonTitle: Driver<String>
        let emptyField: Driver<String>
        let embeddedLoading: Driver<Bool>
        let errorMessage: Driver<String>
    }

    private let loginUsecase: LoginUsecase
    private let userUsecase: UserUsecase
    private let navigator: LoginNavigator

    init(loginUsecase: LoginUsecase, userUsecase: UserUsecase, navigator: LoginNavigator) {
        self.loginUsecase = loginUsecase
        self.userUsecase = userUsecase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let indicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let nameValidator = TextValidator(.name, input: input.name)
        let emailValidator = TextValidator(.email, input: input.email)
        let passwordValidator = TextValidator(.password, input: input.password)
        let kind = BehaviorRelay(value: Kind.signIn)

        let nameError = input.loginTrigger.withLatestFrom(nameValidator.validate())

        let emailError = input.loginTrigger.withLatestFrom(emailValidator.validate())

        let passwordError = input.loginTrigger.withLatestFrom(passwordValidator.validate())

        let enableLogin = Driver.combineLatest(input.name, input.email, input.password)
            .map { combined -> Bool in
                switch kind.value {
                case .signIn:
                    return !combined.1.isEmpty && !combined.2.isEmpty
                case .signUp:
                    return !combined.0.isEmpty && !combined.1.isEmpty && !combined.2.isEmpty
                }
            }

        let loginAvailable = Driver.combineLatest(nameError, emailError, passwordError)
            .map { combined -> Bool in
                switch kind.value {
                case .signIn:
                    return combined.1.isEmpty && combined.2.isEmpty
                case .signUp:
                    return combined.0.isEmpty && combined.1.isEmpty && combined.2.isEmpty
                }
            }

        let loginCredential = Driver.combineLatest(
            input.name,
            input.email,
            input.password,
            loginAvailable)

        let onLogin = input.loginTrigger
            .withLatestFrom(loginCredential)
            .filter { combined in return combined.3 }
            .debug()
            .map { combined in return (combined.0, combined.1, combined.2) }
            .flatMapLatest { [weak self] name, email, password -> Driver<Void> in
                guard let self = self else { return .empty() }
                let request: Observable<Void> = {
                    switch kind.value {
                    case .signIn:
                        return self.login(withEmail: email, password: password)
                    case .signUp:
                        return self.register(withName: name, email: email, password: password)
                    }
                }()
                return request
                    .trackActivity(indicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: navigator.toUser)
            .mapToVoid()

        let onSegmentChanged = input.segmentChanged
            .compactMap(Kind.init)
            .do(onNext: kind.accept)
            .mapToVoid()

        let resetSegment = input.viewDidDisappear
            .compactMap { Kind.signIn }
            .do(onNext: kind.accept)
            .mapToVoid()

        let selectedSegmentIndex = kind.map { $0.rawValue }.asDriverOnErrorJustComplete()

        let hideNameField = kind.compactMap { $0 == .signIn }.asDriverOnErrorJustComplete()

        let loginButtonTitle = kind.map { $0.title }.asDriverOnErrorJustComplete()

        let emptyField = kind.map { _ in return "" }.asDriverOnErrorJustComplete()

        let embeddedLoading = indicator.asDriver()

        let errorMessage = errorTracker.asDriver().map { $0.localizedDescription }

        return Output(
            nameError: nameError,
            emailError: emailError,
            passwordError: passwordError,
            enableLogin: enableLogin,
            onLogin: onLogin,
            onSegmentChanged: onSegmentChanged,
            resetSegment: resetSegment,
            selectedSegmentIndex: selectedSegmentIndex,
            hideNameField: hideNameField,
            loginButtonTitle: loginButtonTitle,
            emptyField: emptyField,
            embeddedLoading: embeddedLoading,
            errorMessage: errorMessage)
    }
}

private extension LoginViewModel {
    func login(withEmail email: String, password: String) -> Observable<Void> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            self.loginUsecase.login(withEmail: email, password: password) { result in
                switch result {
                case .success:
                    observer.onNext(())
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func register(withName name: String, email: String, password: String) -> Observable<Void> {
        return register(withEmail: email, password: password)
            .concatMap { [weak self] user -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.updateUserName(name, for: user)
            }
    }

    func register(withEmail email: String, password: String) -> Observable<User> {
        return .create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            self.loginUsecase.register(withEmail: email, password: password) { result in
                switch result {
                case .success(let user):
                    observer.onNext(user)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func updateUserName(_ name: String, for user: User) -> Observable<Void> {
        return .create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            self.userUsecase.updateUserName(name, for: user) { result in
                switch result {
                case .success:
                    observer.onNext(())
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
