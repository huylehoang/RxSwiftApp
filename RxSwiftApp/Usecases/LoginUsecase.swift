import RxSwift
import FirebaseAuth

protocol LoginUsecase: UsecaseType {
    func signIn(withEmail email: String, password: String) -> Observable<Void>
    func signUp(withName name: String, email: String, password: String) -> Observable<Void>
}

struct DefaultLoginUsecase: LoginUsecase {
    private let service: AuthService

    init(service: AuthService = DefaultAuthService()) {
        self.service = service
    }

    func signIn(withEmail email: String, password: String) -> Observable<Void> {
        return service.signIn(withEmail: email, password: password)
            .map { password }
            .flatMap(savePassword)
    }

    func signUp(withName name: String, email: String, password: String) -> Observable<Void> {
        return service.createUser(withEmail: email, password: password)
            .map { (name, $0) }
            .flatMap(updateUserName)
            .map { password }
            .flatMap(savePassword)
    }
}

private extension DefaultLoginUsecase {
    func updateUserName(_ credential: (name: String, user: User)) -> Observable<Void> {
        return service.updateUserName(credential.name, for: credential.user)
            .catchError(service.deleteUser)
    }

    func savePassword(_ password: String) -> Observable<Void> {
        return UserDefaults.setValue(password, forKey: .userPassword)
    }
}
