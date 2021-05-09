import RxSwift
import FirebaseAuth

protocol UserUsecase: UsecaseType {
    func getUser() -> Observable<User>
    func reAuthenticate() -> Observable<Void>
    func deleteUser() -> Observable<Void>
    func signOut() -> Observable<Void>
}

struct DefaultUserUsecase: UserUsecase {
    private let service: AuthService

    init(service: AuthService = DefaultAuthService()) {
        self.service = service
    }

    func getUser() -> Observable<User> {
        return service.getUser()
    }

    func reAuthenticate() -> Observable<Void> {
        return Observable.combineLatest(email, password).flatMap(reAuthenticate)
    }

    func deleteUser() -> Observable<Void> {
        return service.deleteUser().flatMap(UserDefaults.removeAllValues)
    }

    func signOut() -> Observable<Void> {
        return service.signOut().flatMap(UserDefaults.removeAllValues)
    }
}

private extension DefaultUserUsecase {
    var email: Observable<String> {
        return getUser().compactMap { $0.email }
    }

    var password: Observable<String> {
        return UserDefaults.getStringValue(forKey: .userPassword)
    }

    func reAuthenticate(_ credential: (email: String, password: String)) -> Observable<Void> {
        return service.reAuthenticate(withEmail: credential.email, password: credential.password)
    }
}
