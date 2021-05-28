import Firebase

public enum FirebaseService {
    public static func setup() {
        FirebaseApp.configure()
    }

    public static func isSignedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}
