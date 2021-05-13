import RxSwift
import FirebaseAuth

protocol UserUsecase: UsecaseType {
    func getUser() -> Single<User>
    func reAuthenticate() -> Single<User>
    func deleteUser() -> Single<Void>
    func signOut() -> Single<Void>
}

struct DefaultUserUsecase: UserUsecase {
    private let service: AuthService

    init(service: AuthService = DefaultAuthService()) {
        self.service = service
    }

    func getUser() -> Single<User> {
        return service.getUser()
    }

    func reAuthenticate() -> Single<User> {
        return Observable.combineLatest(email, password).asSingle().flatMap(reAuthenticate)
    }

    func deleteUser() -> Single<Void> {
        return service.deleteUser().do(onSuccess: UserDefaults.removeAllValues)
    }

    func signOut() -> Single<Void> {
        return service.signOut().do(onSuccess: UserDefaults.removeAllValues)
    }
}

private extension DefaultUserUsecase {
    var email: Observable<String> {
        return getUser().asObservable().compactMap { $0.email }
    }

    var password: Observable<String> {
        return UserDefaults.getStringValue(forKey: .userPassword).asObservable()
    }

    func reAuthenticate(_ credential: (email: String, password: String)) -> Single<User> {
        return service.reAuthenticate(withEmail: credential.email, password: credential.password)
    }
}
