import RxSwift
import FirebaseAuth

protocol UserUsecase {
    func getUser() -> Observable<User>
    func reAuthenticate() -> Observable<Void>
    func deleteUser() -> Observable<Void>
    func signOut() -> Observable<Void>
}

final class DefaultUserUsecase: UserUsecase {
    private let service: AuthService

    init(service: AuthService = DefaultAuthService()) {
        self.service = service
    }

    func getUser() -> Observable<User> {
        return service.getUser()
    }

    func reAuthenticate() -> Observable<Void> {
        return Observable.combineLatest(
            getUser().compactMap { $0.email },
            UserDefaults.getStringValue(forKey: .userPassword))
            .flatMap { [weak self] email, password -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.service.reAuthenticate(withEmail: email, password: password)
            }
    }

    func deleteUser() -> Observable<Void> {
        return service.deleteUser().flatMap { UserDefaults.removeAllValue() }
    }

    func signOut() -> Observable<Void> {
        return service.signOut().flatMap { UserDefaults.removeAllValue() }
    }
}
