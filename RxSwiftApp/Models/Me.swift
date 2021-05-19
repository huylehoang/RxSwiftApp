import Foundation
import FirebaseAuth
import FirebaseFirestore

struct Me: Equatable {
    let id: String
    let name: String?
    let email: String?

    init(user: User) {
        id = user.uid
        name = user.displayName
        email = user.email
    }

    init(snapshot: DocumentSnapshot) {
        let data = snapshot.data()
        id = data?["id"] as? String ?? ""
        name = data?["name"] as? String ?? ""
        email = data?["email"] as? String ?? ""
    }

    var data: [String: Any] {
        var defaultData: [String: Any] = [
            "id": id,
            "timestamp": Date().timeIntervalSince1970,
        ]
        if let name = name {
            defaultData.updateValue(name, forKey: "name")
        }
        if let email = email {
            defaultData.updateValue(email, forKey: "email")
        }
        return defaultData
    }
}

extension DocumentSnapshot {
    func convertToMe() -> Me {
        return Me(snapshot: self)
    }
}
