import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel: ViewModelType {
    struct Input {
        let email: Driver<String>
        let emailIsEditing: Driver<Bool>
        let password: Driver<String>
        let passwordIsEditing: Driver<Bool>
        let loginTrigger: Driver<Void>
    }

    struct Output {
        let emailError: Driver<String>
        let passwordError: Driver<String>
        let enableLogin: Driver<Bool>
        let onLogin: Driver<Void>
    }

    private let usecase: LoginUsecase

    init(usecase: LoginUsecase) {
        self.usecase = usecase
    }

    func transform(input: Input) -> Output {
        let emailValidator = TextValidator(.email, input: input.email)
        let passwordValidator = TextValidator(.password, input: input.password)

        let enableLogin = Driver.combineLatest(input.email, input.password)
            .map { combined in return !combined.0.isEmpty && !combined.1.isEmpty }
            .startWith(false)

        let validate = Driver.combineLatest(
            input.loginTrigger,
            input.emailIsEditing,
            emailValidator.validate(),
            input.passwordIsEditing,
            passwordValidator.validate())

        let emailError = validate
            .filter { combined in return !combined.1 }
            .map { combined in return combined.2 }

        let passwordError = validate
            .filter { combined in return !combined.3 }
            .map { combined in return combined.4 }

        let loginAvailable = Driver.combineLatest(enableLogin, emailError, passwordError)
            .map { combined in return combined.0 && combined.1.isEmpty && combined.2.isEmpty }

        let onLogin = Driver.combineLatest(
            input.loginTrigger,
            loginAvailable,
            input.email,
            input.password)
            .filter { combined in return combined.1 }
            .do()
            .mapToVoid()

        return Output(
            emailError: emailError,
            passwordError: passwordError,
            enableLogin: enableLogin,
            onLogin: onLogin)
    }
}

private extension LoginViewModel {
    func login(withEmail email: String, password: String) -> Observable<Void> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
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
