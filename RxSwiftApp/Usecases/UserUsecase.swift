import RxSwift
import FirebaseAuth

protocol UserUsecase: UsecaseType {
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
            .flatMap { [weak self] in
                return self?.service.reAuthenticate(withEmail: $0, password: $1) ?? .empty()
            }
    }

    func deleteUser() -> Observable<Void> {
        return service.deleteUser().flatMap { UserDefaults.removeAllValue() }
    }

    func signOut() -> Observable<Void> {
        return service.signOut().flatMap { UserDefaults.removeAllValue() }
    }
}
