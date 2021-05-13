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
        let signedIn = service.signIn(withEmail: email, password: password)
        let savePassword = {
            UserDefaults.setValue(password, forKey: .userPassword)
        }
        return signedIn.do(onSuccess: savePassword)
    }

    func signUp(withName name: String, email: String, password: String) -> Single<Void> {
        let signedUp = service.createUser(withEmail: email, password: password)
            .map { (name, $0) }
            .flatMap(updateUserName)
        let savePassword = {
            UserDefaults.setValue(password, forKey: .userPassword)
        }
        return signedUp.do(onSuccess: savePassword)
    }
}

private extension DefaultLoginUsecase {
    func updateUserName(_ credential: (name: String, user: User)) -> Single<Void> {
        return service.updateUserName(credential.name, for: credential.user)
            .catchError(service.deleteUser)
    }
}
