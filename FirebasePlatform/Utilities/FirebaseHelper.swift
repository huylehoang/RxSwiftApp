import Domain
import FirebaseAuth
import FirebaseFirestore

enum FirebaseHelper {
    static func convertUserToProfile(user: User) -> Profile {
        return Profile(id: user.uid, name: user.displayName, mail: user.email)
    }

    static func convertSnapshotToProfile(snapshot: DocumentSnapshot) -> Profile {
        let data = snapshot.data()
        return Profile(
            id: data?["id"] as? String ?? "",
            name: data?["name"] as? String ?? "",
            mail: data?["mail"] as? String ?? "")
    }

    static func convertSnapshotToNote(snapshot: DocumentSnapshot) -> Note {
        let data = snapshot.data()
        return Note(
            id: snapshot.documentID,
            title: data?["title"] as? String ?? "",
            details: data?["details"] as? String ?? "")
    }
}
