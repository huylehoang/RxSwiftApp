import Foundation
import FirebaseAuth

final class UserUsecase {
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
