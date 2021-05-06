import FirebaseAuth
import RxSwift

protocol AuthService {
    func signIn(withEmail email: String, password: String) -> Observable<Void>
    func createUser(withEmail email: String, password: String) -> Observable<User>
    func updateUserName(_ name: String, for user: User) -> Observable<Void>
    func getUser() -> Observable<User>
    func reAuthenticate(withEmail email: String, password: String) -> Observable<Void>
    func deleteUser() -> Observable<Void>
    func deleteUser(by error: Error) -> Observable<Void>
    func signOut() -> Observable<Void>
}

final class DefaultAuthService: AuthService {
    func signIn(withEmail email: String, password: String) -> Observable<Void> {
        return .create { observer -> Disposable in
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    func createUser(withEmail email: String, password: String) -> Observable<User> {
        return .create { observer -> Disposable in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let user = authResult?.user {
                    observer.onNext(user)
                    observer.onCompleted()
                } else if let error = error {
                    observer.onError(error)
                } else {
                    observer.onError(NSError(domain: "Something wrong!!!", code: 0, userInfo: nil))
                }
            }
            return Disposables.create()
        }
    }

    func updateUserName(_ name: String, for user: User) -> Observable<Void> {
        return .create { observer -> Disposable in
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    func getUser() -> Observable<User> {
        return Observable.just(Auth.auth().currentUser).compactMap { $0 }
    }

    func reAuthenticate(withEmail email: String, password: String) -> Observable<Void> {
        return .create { observer -> Disposable in
            guard let user = Auth.auth().currentUser else {
                observer.onCompleted()
                return Disposables.create()
            }
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            user.reauthenticate(with: credential) { _, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    func deleteUser() -> Observable<Void> {
        return .create { observer -> Disposable in
            guard let user = Auth.auth().currentUser else {
                observer.onCompleted()
                return Disposables.create()
            }
            user.delete { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    func deleteUser(by error: Error) -> Observable<Void> {
        return .create { observer -> Disposable in
            guard let user = Auth.auth().currentUser else {
                observer.onCompleted()
                return Disposables.create()
            }
            user.delete { deletingError in
                if let deletingError = deletingError {
                    observer.onError(deletingError)
                } else {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func signOut() -> Observable<Void> {
        return .create { observer -> Disposable in
            do {
                try Auth.auth().signOut()
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }

    }
}
