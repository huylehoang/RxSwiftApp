import RxSwift
import FirebaseAuth

protocol LoginUsecase {
    func signIn(withEmail email: String, password: String) -> Observable<Void>
    func signUp(withName name: String, email: String, password: String) -> Observable<Void>
}

final class DefaultLoginUsecase: LoginUsecase {
    private let service: AuthService

    init(service: AuthService = DefaultAuthService()) {
        self.service = service
    }

    func signIn(withEmail email: String, password: String) -> Observable<Void> {
        return service.signIn(withEmail: email, password: password)
    }

    func signUp(withName name: String, email: String, password: String) -> Observable<Void> {
        return service.createUser(withEmail: email, password: password)
            .concatMap { [weak self] user -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.service.updateUserName(name, for: user)
            }
    }
}
