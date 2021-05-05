import FirebaseAuth

protocol LoginService {
    func signIn(
        withEmail email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void)
    func createUser(
        withEmail email: String,
        password: String,
        completion: @escaping (Result<User, Error>) -> Void)
}

final class DefaultLoginService: LoginService {
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
}
