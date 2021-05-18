import FirebaseAuth
import RxSwift

protocol ServiceType {
    func getUser() -> Single<User>
}

extension ServiceType {
    func reloadUser() -> Single<Void> {
        return .create { single in
            guard let user = Auth.auth().currentUser else {
                single(.failure(ServiceError.userNotFound))
                return Disposables.create()
            }
            user.reload { error in
                if let _ = error {
                    single(.failure(ServiceError.userNotFound))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }

    func getUser() -> Single<User> {
        return .create { single in
            guard let user = Auth.auth().currentUser else {
                single(.failure(ServiceError.userNotFound))
                return Disposables.create()
            }
            single(.success(user))
            return Disposables.create()
        }
    }
}
