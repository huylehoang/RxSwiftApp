import RxSwift
import FirebaseAuth

final class LoginUsecase {
    private let service: LoginService

    init(service: LoginService = DefaultLoginService()) {
        self.service = service
    }

    func signIn(withEmail email: String, password: String) -> Observable<Void> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            self.service.signIn(withEmail: email, password: password) { result in
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

    func createUser(withEmail email: String, password: String) -> Observable<User> {
        return .create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            self.service.createUser(withEmail: email, password: password) { result in
                switch result {
                case .success(let user):
                    observer.onNext(user)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
