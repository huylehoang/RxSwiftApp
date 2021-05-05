import RxSwift
import FirebaseAuth

protocol LoginUsecase {
    func signIn(withEmail email: String, password: String) -> Observable<Void>
    func signUp(withName name: String, email: String, password: String) -> Observable<Void>
}

final class DefaultLoginUsecase: LoginUsecase {
    private let service: AuthService

    init(service: AuthService = DefaultAuthService()) {
        self.service = service
    }

    func signIn(withEmail email: String, password: String) -> Observable<Void> {
        return .create { [weak self] observer -> Disposable in
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

    func signUp(withName name: String, email: String, password: String) -> Observable<Void> {
        return createUser(withEmail: email, password: password)
            .concatMap { [weak self] user -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.updateUserName(name, for: user)
            }
    }
}

private extension DefaultLoginUsecase {
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
}
