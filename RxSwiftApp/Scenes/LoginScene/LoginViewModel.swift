import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel: ViewModelType {
    struct Input {
        let email: Driver<String>
        let password: Driver<String>
        let loginTrigger: Driver<Void>
    }

    struct Output {
        let emailError: Driver<String>
        let passwordError: Driver<String>
        let enableLogin: Driver<Bool>
        let onLogin: Driver<Void>
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
        let emailValidator = TextValidator(.email, input: input.email)
        let passwordValidator = TextValidator(.password, input: input.password)

        let emailError = input.loginTrigger.withLatestFrom(emailValidator.validate())

        let passwordError = input.loginTrigger.withLatestFrom(passwordValidator.validate())

        let enableLogin = Driver.combineLatest(input.email, input.password)
            .map { combined in return !combined.0.isEmpty && !combined.1.isEmpty }

        let loginAvailable = Driver.combineLatest(emailError, passwordError)
            .map { combined in return combined.0.isEmpty && combined.1.isEmpty }

        let loginCredential = Driver.combineLatest(input.email, input.password, loginAvailable)

        let onLogin = input.loginTrigger
            .withLatestFrom(loginCredential)
            .filter { combined in return combined.2 }
            .map { combined in return (combined.0, combined.1) }
            .flatMapLatest { [weak self] email, password -> Driver<Void> in
                guard let self = self else { return .empty() }
                return self.login(withEmail: email, password: password)
                    .trackActivity(indicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: navigator.toUser)
            .mapToVoid()

        let embeddedLoading = indicator.asDriver()

        let errorMessage = errorTracker.asDriver().map { $0.localizedDescription }

        return Output(
            emailError: emailError,
            passwordError: passwordError,
            enableLogin: enableLogin,
            onLogin: onLogin,
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
            self.usecase.login(withEmail: email, password: password) { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                }
            }
            return Disposables.create()
        }
    }
}
