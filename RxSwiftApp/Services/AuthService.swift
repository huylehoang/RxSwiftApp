import FirebaseAuth
import RxSwift

protocol AuthService: ServiceType {
    func signIn(withEmail email: String, password: String) -> Single<Void>
    func createUser(withEmail email: String, password: String) -> Single<User>
    func updateUserName(_ name: String, for user: User) -> Single<Void>
    func reAuthenticate(withEmail email: String, password: String) -> Single<User>
    func deleteUser() -> Single<Void>
    func deleteUser(by error: Error) -> Single<Void>
    func signOut() -> Single<Void>
}

struct DefaultAuthService: AuthService {
    func signIn(withEmail email: String, password: String) -> Single<Void> {
        return .create { single in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let _ = authResult?.user {
                    single(.success(()))
                } else if let error = error {
                    single(.failure(error))
                } else {
                    single(.failure(ServiceError.somethingWentWrong))
                }
            }
            return Disposables.create()
        }
    }

    func createUser(withEmail email: String, password: String) -> Single<User> {
        return .create { single in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let user = authResult?.user {
                    single(.success(user))
                } else if let error = error {
                    single(.failure(error))
                } else {
                    single(.failure(ServiceError.somethingWentWrong))
                }
            }
            return Disposables.create()
        }
    }

    func updateUserName(_ name: String, for user: User) -> Single<Void> {
        return .create { single in
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }

    func reAuthenticate(withEmail email: String, password: String) -> Single<User> {
        return getUser().map { ($0, email, password) }.flatMap(reAuthenticate)
    }

    func deleteUser() -> Single<Void> {
        return getUser().flatMap(deleteUser)
    }

    func deleteUser(by error: Swift.Error) -> Single<Void> {
        return getUser().map { ($0, error) }.flatMap(deleteUser)
    }

    func signOut() -> Single<Void> {
        return .create { single in
            do {
                try Auth.auth().signOut()
                single(.success(()))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}

private extension DefaultAuthService {
    func reAuthenticate(_ user: User, withEmail email: String, password: String) -> Single<User> {
        return .create { single in
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            user.reauthenticate(with: credential) { authResult, error in
                if let user = authResult?.user {
                    single(.success(user))
                } else if let error = error {
                    single(.failure(error))
                } else {
                    single(.failure(ServiceError.somethingWentWrong))
                }
            }
            return Disposables.create()
        }
    }

    func deleteUser(_ user: User) -> Single<Void> {
        return .create { single in
            user.delete { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }

    func deleteUser(_ user: User, by error: Swift.Error) -> Single<Void> {
        return .create { single in
            user.delete { deletingError in
                if let deletingError = deletingError {
                    single(.failure(deletingError))
                } else {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
