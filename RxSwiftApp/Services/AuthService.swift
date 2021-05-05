import FirebaseAuth

protocol AuthService {
    func signIn(
        withEmail email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void)
    func createUser(
        withEmail email: String,
        password: String,
        completion: @escaping (Result<User, Error>) -> Void)
    func updateUserName(
        _ name: String,
        for user: User,
        completion: @escaping (Result<Void, Error>) -> Void)
    func getUser() -> User?
    func signOut() -> Error?
}

final class DefaultAuthService: AuthService {
    func signIn(
        withEmail email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func createUser(
        withEmail email: String,
        password: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user {
                completion(.success(user))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(NSError(domain: "Something wrong!!!", code: 0, userInfo: nil)))
            }
        }
    }

    func updateUserName(
        _ name: String,
        for user: User,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        changeRequest.commitChanges { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func getUser() -> User? {
        return Auth.auth().currentUser
    }

    func signOut() -> Error? {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            return nil
        } catch {
            return error
        }
    }
}
