import Foundation

struct Me {
    let id: String

    var data: [String: Any] {
        return [
            "id": id,
            "timestamp": Date().timeIntervalSince1970,
        ]
    }
}
