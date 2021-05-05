import RxSwift
import FirebaseAuth

final class UserUsecase {
    private let service: UserService

    init(service: UserService = DefaultUserService()) {
        self.service = service
    }

    func getUser() -> User? {
        return service.getUser()
    }

    func updateUserName(_ name: String, for user: User) -> Observable<Void> {
        return .create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            self.service.updateUserName(name, for: user) { result in
                switch result {
                case .success:
                    observer.onNext(())
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
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
