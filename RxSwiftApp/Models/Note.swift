import FirebaseFirestore

struct Note: MutableType {
    let id: String?
    var title: String
    var details: String

    init() {
        id = nil
        title = ""
        details = ""
    }

    init(snapshot: DocumentSnapshot) {
        id = snapshot.documentID
        let data = snapshot.data()
        title = data?["title"] as? String ?? ""
        details = data?["details"] as? String ?? ""
    }

    var data: [String: Any] {
        return [
            "title": title,
            "details": details,
            "timestamp": Date().timeIntervalSince1970,
        ]
    }
}
