import RxSwift
import FirebaseAuth

protocol LoginUsecase: UsecaseType {
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
            .flatMap { [weak self] in return self?.updateUserName(name, for: $0) ?? .empty() }
            .flatMap { UserDefaults.setValue(password, forKey: .userPassword) }
    }
}

private extension DefaultLoginUsecase {
    func updateUserName(_ name: String, for user: User) -> Observable<Void> {
        return service.updateUserName(name, for: user)
            .catchError { [weak self] in return self?.service.deleteUser(by: $0) ?? .empty() }
    }
}
