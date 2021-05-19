import Foundation
import FirebaseAuth

struct Me {
    let id: String
    let name: String?
    let email: String?

    init(from user: User) {
        id = user.uid
        name = user.displayName
        email = user.email
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
