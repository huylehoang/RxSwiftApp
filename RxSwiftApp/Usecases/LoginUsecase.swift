import Foundation
import FirebaseAuth

final class LoginUsecase {
    func login(withEmail email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }

    func signOut() -> String? {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            return nil
        } catch {
            return String(format: "Error signing out: %@", error.localizedDescription)
        }
    }
}
