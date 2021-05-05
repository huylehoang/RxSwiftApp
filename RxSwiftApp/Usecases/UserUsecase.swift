import Foundation
import FirebaseAuth

final class UserUsecase {
    func getUser() -> User? {
        return Auth.auth().currentUser
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
