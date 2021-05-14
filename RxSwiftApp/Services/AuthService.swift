import FirebaseAuth
import RxSwift

protocol AuthService {
    func signIn(withEmail email: String, password: String) -> Single<Void>
    func createUser(withEmail email: String, password: String) -> Single<User>
    func updateUserName(_ name: String, for user: User) -> Single<Void>
    func getUser() -> Single<User>
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
                    single(.failure(Error.somethingWentWrong))
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
                    single(.failure(Error.somethingWentWrong))
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

    func getUser() -> Single<User> {
        return .create { single in
            guard let user = Auth.auth().currentUser else {
                single(.failure(Error.userNotFound))
                return Disposables.create()
            }
            single(.success(user))
            return Disposables.create()
        }
    }

    func reAuthenticate(withEmail email: String, password: String) -> Single<User> {
        return .create { single in
            guard let user = Auth.auth().currentUser else {
                single(.failure(Error.userNotFound))
                return Disposables.create()
            }
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            user.reauthenticate(with: credential) { authResult, error in
                if let user = authResult?.user {
                    single(.success(user))
                } else if let error = error {
                    single(.failure(error))
                } else {
                    single(.failure(Error.somethingWentWrong))
                }
            }
            return Disposables.create()
        }
    }

    func deleteUser() -> Single<Void> {
        return .create { single in
            guard let user = Auth.auth().currentUser else {
                single(.failure(Error.userNotFound))
                return Disposables.create()
            }
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

    func deleteUser(by error: Swift.Error) -> Single<Void> {
        return .create { single in
            guard let user = Auth.auth().currentUser else {
                single(.failure(Error.userNotFound))
                return Disposables.create()
            }
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

extension DefaultAuthService {
    enum Error: Swift.Error {
        case somethingWentWrong
        case userNotFound
    }
}

extension DefaultAuthService.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .somethingWentWrong: return "Something went wrong"
        case .userNotFound: return "User not found"
        }
    }
}
