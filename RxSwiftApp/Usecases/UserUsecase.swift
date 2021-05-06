import RxSwift
import FirebaseAuth

protocol UserUsecase {
    func getUser() -> Observable<User>
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

    func deleteUser() -> Observable<Void> {
        return service.deleteUser()
    }

    func signOut() -> Observable<Void> {
        return service.signOut()
    }
}
