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
            .flatMap { UserDefaults.setValue(password, forKey: .userPassword) }
    }

    func signUp(withName name: String, email: String, password: String) -> Observable<Void> {
        return service.createUser(withEmail: email, password: password)
            .flatMap { [weak self] user in
                return self?.service.updateUserName(name, for: user) ?? .empty()
            }
            .catchError { [weak self] error in
                return self?.service.deleteUser(by: error) ?? .empty()
            }
            .flatMap { UserDefaults.setValue(password, forKey: .userPassword) }
    }
}
