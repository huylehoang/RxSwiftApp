import RxSwift
import FirebaseAuth

protocol LoginUsecase: UsecaseType {
    func signIn(withEmail email: String, password: String) -> Single<Void>
    func signUp(withName name: String, email: String, password: String) -> Single<Void>
}

struct DefaultLoginUsecase: LoginUsecase {
    private let service: AuthService

    init(service: AuthService = DefaultAuthService()) {
        self.service = service
    }

    func signIn(withEmail email: String, password: String) -> Single<Void> {
        return service.signIn(withEmail: email, password: password)
            .map { password }
            .do(onSuccess: savePassword)
            .mapToVoid()
    }

    func signUp(withName name: String, email: String, password: String) -> Single<Void> {
        return service.createUser(withEmail: email, password: password)
            .map { (name, $0) }
            .flatMap(updateUserName)
            .map { password }
            .do(onSuccess: savePassword)
            .mapToVoid()
    }
}

private extension DefaultLoginUsecase {
    func updateUserName(_ credential: (name: String, user: User)) -> Single<Void> {
        return service.updateUserName(credential.name, for: credential.user)
            .catchError(service.deleteUser)
    }

    func savePassword(_ password: String) {
        UserDefaults.setValue(password, forKey: .userPassword)
    }
}
