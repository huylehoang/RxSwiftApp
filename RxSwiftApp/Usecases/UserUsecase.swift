import RxSwift
import FirebaseAuth

protocol UserUsecase {
    func getUser() -> Observable<User>
    func signOut() -> Observable<Void>
}

final class DefaultUserUsecase: UserUsecase {
    private let service: AuthService

    init(service: AuthService = DefaultAuthService()) {
        self.service = service
    }

    func getUser() -> Observable<User> {
        return Observable.just(service.getUser()).compactMap { $0 }
    }

    func signOut() -> Observable<Void> {
        return .create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            if let error = self.service.signOut() {
                observer.onError(error)
            } else {
                observer.onNext(())
            }
            return Disposables.create()
        }
    }
}
